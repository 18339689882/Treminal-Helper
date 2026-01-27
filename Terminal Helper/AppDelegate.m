//
//  AppDelegate.m
//  Terminal Helper
//
//  Created by sunDS on 2026/1/13.
//

#import "AppDelegate.h"
#import "THConstants.h"
#import "THCommand.h"
#import "THCommandManager.h"
#import "THCommandExecutor.h"
#import "THLocalization.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *commandWatchTimer;

- (void)setupStatusBarMenu;
- (void)commandMenuItemClicked:(NSMenuItem *)sender;
- (void)quitMenuItemClicked:(id)sender;
- (void)executeCommand:(THCommand *)command inDirectory:(NSString *)directoryPath;
- (NSString *)getCurrentFinderPath;
- (void)startWatchingForCommands;
- (void)checkForPendingCommand;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create status bar item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    // Set status bar icon - 使用简洁的终端符号
    NSImage *statusImage = [NSImage imageWithSystemSymbolName:@"terminal.fill" accessibilityDescription:@"Terminal Helper"];
    if (!statusImage) {
        // 备用：使用命令行符号
        statusImage = [NSImage imageWithSystemSymbolName:@"chevron.right.2" accessibilityDescription:@"Terminal Helper"];
    }
    if (!statusImage) {
        // 最后备用
        statusImage = [NSImage imageNamed:@"StatusBarIcon"];
    }
    if (statusImage) {
        statusImage.template = YES;
        // 设置合适的尺寸
        [statusImage setSize:NSMakeSize(18, 18)];
    }
    self.statusItem.button.image = statusImage;
    self.statusItem.button.toolTip = [THLocalization appName];
    
    // Setup menu
    [self setupStatusBarMenu];
    
    // Listen for command list updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupStatusBarMenu)
                                                 name:THCommandListDidUpdateNotification
                                               object:nil];
    
    // Start watching for commands from Finder Extension
    [self startWatchingForCommands];
    
    NSLog(@"Terminal Helper: Started watching for commands from Finder Extension");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Stop watching for commands
    [self.commandWatchTimer invalidate];
    self.commandWatchTimer = nil;
    
    // Remove notification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

#pragma mark - Status Bar Menu

- (void)setupStatusBarMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    // Get all commands from command manager
    THCommandManager *commandManager = [THCommandManager sharedManager];
    NSArray<THCommand *> *allCommands = commandManager.allCommands;
    
    // 如果没有命令，显示提示
    if (allCommands.count == 0) {
        NSMenuItem *noCommandsItem = [[NSMenuItem alloc] initWithTitle:[THLocalization noCommands]
                                                                action:nil
                                                         keyEquivalent:@""];
        noCommandsItem.enabled = NO;
        [menu addItem:noCommandsItem];
        [menu addItem:[NSMenuItem separatorItem]];
    } else {
        // Add command menu items with icons
        for (THCommand *command in allCommands) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:command.name
                                                           action:@selector(commandMenuItemClicked:)
                                                    keyEquivalent:@""];
            item.target = self;
            item.representedObject = command;
            
            // 添加命令图标
            NSImage *cmdIcon = [NSImage imageWithSystemSymbolName:@"terminal.fill" accessibilityDescription:nil];
            if (cmdIcon) {
                cmdIcon.size = NSMakeSize(16, 16);
                item.image = cmdIcon;
            }
            
            [menu addItem:item];
        }
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    // Add "Quit" option with icon
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:[THLocalization quit]
                                                      action:@selector(quitMenuItemClicked:)
                                               keyEquivalent:@"q"];
    quitItem.target = self;
    NSImage *quitIcon = [NSImage imageWithSystemSymbolName:@"power" accessibilityDescription:nil];
    if (quitIcon) {
        quitIcon.size = NSMakeSize(16, 16);
        quitItem.image = quitIcon;
    }
    [menu addItem:quitItem];
    
    // Set menu to status item
    self.statusItem.menu = menu;
}

- (void)commandMenuItemClicked:(NSMenuItem *)sender {
    THCommand *command = sender.representedObject;
    if (!command) {
        return;
    }
    
    // 获取当前 Finder 窗口的路径
    NSString *currentPath = [self getCurrentFinderPath];
    
    if (currentPath) {
        // 如果成功获取到 Finder 路径，在终端中执行
        [self executeCommand:command inDirectory:currentPath];
    } else {
        // 如果无法获取 Finder 路径，显示提示
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [THLocalization cannotGetFinderPath];
        alert.informativeText = [THLocalization pleaseOpenFinderWindow];
        alert.alertStyle = NSAlertStyleWarning;
        [alert addButtonWithTitle:[THLocalization ok]];
        [alert runModal];
    }
}

- (void)quitMenuItemClicked:(id)sender {
    [NSApp terminate:nil];
}

#pragma mark - Command Execution

- (void)executeCommand:(THCommand *)command inDirectory:(NSString *)directoryPath {
    // 直接使用 osascript 打开终端执行命令，避免 NSAppleScript 权限问题
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/osascript";
    task.arguments = @[
        @"-e", @"tell application \"Terminal\" to activate",
        @"-e", [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"cd '%@' && %@\"", 
                directoryPath, command.commandString]
    ];
    
    @try {
        [task launch];
        NSLog(@"命令已发送到终端: %@ (目录: %@)", command.commandString, directoryPath);
    } @catch (NSException *exception) {
        NSLog(@"执行命令失败: %@", exception.reason);
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [THLocalization executionFailed];
        alert.informativeText = exception.reason ?: [THLocalization cannotOpenTerminal];
        alert.alertStyle = NSAlertStyleCritical;
        [alert addButtonWithTitle:[THLocalization ok]];
        [alert runModal];
    }
}

#pragma mark - Finder Extension Integration

/**
 * 开始监控来自 Finder Extension 的命令
 */
- (void)startWatchingForCommands {
    // 每 0.5 秒检查一次是否有待执行的命令
    self.commandWatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                              target:self
                                                            selector:@selector(checkForPendingCommand)
                                                            userInfo:nil
                                                             repeats:YES];
}

/**
 * 检查是否有待执行的命令
 */
- (void)checkForPendingCommand {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.terminal-helper.shared"];
    
    if (!containerURL) {
        return;
    }
    
    NSURL *commandFileURL = [containerURL URLByAppendingPathComponent:@"pending_command.plist"];
    
    if (![fileManager fileExistsAtPath:commandFileURL.path]) {
        return;
    }
    
    // 读取命令文件
    NSError *error = nil;
    NSData *plistData = [NSData dataWithContentsOfURL:commandFileURL options:0 error:&error];
    if (!plistData) {
        return;
    }
    
    NSDictionary *commandData = [NSPropertyListSerialization propertyListWithData:plistData
                                                                          options:NSPropertyListImmutable
                                                                           format:nil
                                                                            error:&error];
    if (!commandData) {
        // 删除无效文件
        [fileManager removeItemAtURL:commandFileURL error:nil];
        return;
    }
    
    NSString *commandString = commandData[@"commandString"];
    NSString *folderPath = commandData[@"folderPath"];
    
    // 删除命令文件（防止重复执行）
    [fileManager removeItemAtURL:commandFileURL error:nil];
    
    if (!commandString || !folderPath) {
        return;
    }
    
    NSLog(@"Terminal Helper: Found pending command: %@ in folder: %@", commandString, folderPath);
    
    // 执行命令
    [self executeCommandString:commandString inDirectory:folderPath];
}

/**
 * 执行命令字符串
 */
- (void)executeCommandString:(NSString *)commandString inDirectory:(NSString *)directoryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/osascript";
    task.arguments = @[
        @"-e", @"tell application \"Terminal\" to activate",
        @"-e", [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"cd '%@' && %@\"", 
                directoryPath, commandString]
    ];
    
    @try {
        [task launch];
        NSLog(@"Terminal Helper: Command sent to Terminal: %@ (directory: %@)", commandString, directoryPath);
    } @catch (NSException *exception) {
        NSLog(@"Terminal Helper: Failed to execute command: %@", exception.reason);
    }
}

#pragma mark - Finder Integration

/**
 * 获取当前 Finder 窗口的路径
 * 使用 osascript 命令行工具执行 AppleScript
 */
- (NSString *)getCurrentFinderPath {
    // 使用 osascript 命令行工具，避免 NSAppleScript 的权限问题
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/osascript";
    task.arguments = @[@"-e",
        @"tell application \"Finder\"\n"
        @"    if (count of Finder windows) > 0 then\n"
        @"        set currentFolder to (target of front Finder window) as alias\n"
        @"        return POSIX path of currentFolder\n"
        @"    else\n"
        @"        return \"\"\n"
        @"    end if\n"
        @"end tell"];
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    
    @try {
        [task launch];
        [task waitUntilExit];
    } @catch (NSException *exception) {
        NSLog(@"获取 Finder 路径失败: %@", exception.reason);
        return nil;
    }
    
    if (task.terminationStatus != 0) {
        NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
        NSString *errorStr = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"osascript 执行失败，退出码: %d, 错误: %@", task.terminationStatus, errorStr);
        return nil;
    }
    
    NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
    NSString *path = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    // 去除换行符和空白
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (path && path.length > 0) {
        // 移除末尾的斜杠（如果有）
        if ([path hasSuffix:@"/"]) {
            path = [path substringToIndex:path.length - 1];
        }
        return path;
    }
    
    return nil;
}

@end

