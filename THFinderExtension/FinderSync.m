//
//  FinderSync.m
//  THFinderExtension
//
//  Terminal Helper Finder Sync Extension
//

#import "FinderSync.h"
#import <THShared/THConstants.h>
#import <THShared/THCommand.h>
#import <THShared/THCommandManager.h>
#import <THShared/THCommandExecutor.h>
#import <THShared/THLocalization.h>

@interface FinderSync ()
@property (nonatomic, strong) THCommandManager *commandManager;
@property (nonatomic, strong) THCommandExecutor *commandExecutor;
@property (nonatomic, strong) NSArray<THCommand *> *cachedCommands;
@end

@implementation FinderSync

- (instancetype)init {
    self = [super init];
    if (self) {
        _commandManager = [THCommandManager sharedManager];
        _commandExecutor = [[THCommandExecutor alloc] init];
        
        // Monitor the root directory for Finder Sync
        // This enables the extension for all directories
        [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:[NSURL fileURLWithPath:@"/"]];
        
        // Register for command list update notifications
        [self registerForNotifications];
        
        NSLog(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);
    }
    return self;
}

- (void)dealloc {
    // Unregister from notifications
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Primary Finder Sync protocol methods

- (NSString *)toolbarItemName {
    return [THLocalization appName];
}

- (NSString *)toolbarItemToolTip {
    return [THLocalization executeInTerminal];
}

- (NSImage *)toolbarItemImage {
    NSImage *image = [NSImage imageWithSystemSymbolName:@"terminal" accessibilityDescription:nil];
    if (!image) {
        image = [NSImage imageNamed:NSImageNameActionTemplate];
    }
    return image;
}

#pragma mark - Notifications

- (void)registerForNotifications {
    // Listen for command list updates from the main app
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(handleCommandListUpdate:)
                                                            name:THCommandListDidUpdateNotification
                                                          object:nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    NSLog(@"FinderSync: Registered for command list update notifications");
}

- (void)handleCommandListUpdate:(NSNotification *)notification {
    NSLog(@"FinderSync: Received command list update notification");
    
    // Reload commands from shared storage
    [self.commandManager loadCommands];
    
    // Note: The menu will be regenerated automatically the next time the user right-clicks
    // Finder Sync doesn't provide a way to force menu refresh, but the menu is built
    // dynamically each time it's displayed, so the updated commands will appear
    
    NSLog(@"FinderSync: Command list refreshed, %lu commands available", (unsigned long)self.commandManager.allCommands.count);
}

#pragma mark - Menu Generation

- (NSMenu *)menuForMenuKind:(FIMenuKind)menuKind {
    NSLog(@"FinderSync: menuForMenuKind called with kind: %ld", (long)menuKind);
    
    // This method is called when the user right-clicks in Finder
    if (menuKind == FIMenuKindContextualMenuForItems || menuKind == FIMenuKindContextualMenuForContainer) {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
        
        // Get all commands from the command manager and cache them
        self.cachedCommands = [self.commandManager.allCommands copy];
        
        NSLog(@"FinderSync: Building menu with %lu commands", (unsigned long)self.cachedCommands.count);
        
        if (self.cachedCommands.count == 0) {
            NSLog(@"FinderSync: WARNING - No commands available!");
            NSMenuItem *noCommandsItem = [[NSMenuItem alloc] initWithTitle:[THLocalization noCommands] action:nil keyEquivalent:@""];
            [noCommandsItem setEnabled:NO];
            [menu addItem:noCommandsItem];
        } else {
            // Add menu items for each command using tag to identify
            for (NSUInteger i = 0; i < self.cachedCommands.count; i++) {
                THCommand *command = self.cachedCommands[i];
                NSLog(@"FinderSync: Adding menu item for command: %@ (tag: %lu)", command.name, (unsigned long)i);
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:command.name
                                                              action:@selector(executeCommand:)
                                                       keyEquivalent:@""];
                [item setTarget:self];
                [item setTag:i];  // Use tag instead of representedObject
                [menu addItem:item];
            }
        }
        
        NSLog(@"FinderSync: Menu created with %ld items", (long)menu.numberOfItems);
        return menu;
    }
    
    NSLog(@"FinderSync: menuKind not supported, returning nil");
    return nil;
}

#pragma mark - Command Execution

- (void)executeCommand:(NSMenuItem *)sender {
    NSLog(@"FinderSync: executeCommand called");
    
    // Get command from cached array using tag
    NSInteger tag = sender.tag;
    if (tag < 0 || tag >= (NSInteger)self.cachedCommands.count) {
        NSLog(@"FinderSync: ERROR - Invalid tag: %ld", (long)tag);
        return;
    }
    
    THCommand *command = self.cachedCommands[tag];
    if (!command) {
        NSLog(@"FinderSync: ERROR - No command at index %ld", (long)tag);
        return;
    }
    
    NSLog(@"FinderSync: Command name: %@, commandString: %@", command.name, command.commandString);
    
    // Get the selected folder path
    NSString *folderPath = [self getSelectedFolderPath];
    if (!folderPath) {
        NSLog(@"FinderSync: ERROR - Could not determine folder path");
        return;
    }
    
    NSLog(@"FinderSync: Folder path: %@", folderPath);
    
    // 写入命令到 App Group 共享目录，让主应用监控并执行
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.terminal-helper.shared"];
    
    if (!containerURL) {
        NSLog(@"FinderSync: ERROR - Could not get container URL");
        return;
    }
    
    NSURL *commandFileURL = [containerURL URLByAppendingPathComponent:@"pending_command.plist"];
    
    NSDictionary *commandData = @{
        @"commandString": command.commandString,
        @"folderPath": folderPath,
        @"timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:commandData
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                  options:0
                                                                    error:&error];
    if (error) {
        NSLog(@"FinderSync: ERROR - Failed to serialize command: %@", error);
        return;
    }
    
    BOOL success = [plistData writeToURL:commandFileURL options:NSDataWritingAtomic error:&error];
    if (!success) {
        NSLog(@"FinderSync: ERROR - Failed to write command file: %@", error);
        return;
    }
    
    NSLog(@"FinderSync: Command written to shared file: %@", commandFileURL.path);
}

#pragma mark - Helper Methods

- (NSString *)getSelectedFolderPath {
    // Get the target URL from Finder Sync Controller
    FIFinderSyncController *syncController = [FIFinderSyncController defaultController];
    NSURL *targetURL = syncController.targetedURL;
    
    if (targetURL) {
        return [targetURL path];
    }
    
    // Fallback: try to get selected items
    NSArray<NSURL *> *selectedItems = syncController.selectedItemURLs;
    if (selectedItems.count > 0) {
        NSURL *firstItem = selectedItems.firstObject;
        
        // Check if it's a directory
        NSNumber *isDirectory;
        [firstItem getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if ([isDirectory boolValue]) {
            return [firstItem path];
        } else {
            // If it's a file, use its parent directory
            return [[firstItem URLByDeletingLastPathComponent] path];
        }
    }
    
    return nil;
}

@end
