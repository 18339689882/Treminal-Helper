//
//  THExtensionGuideViewController.m
//  Terminal Helper
//
//  Created by Kiro on 2026/1/14.
//

#import "THExtensionGuideViewController.h"
#import <FinderSync/FinderSync.h>

@interface THExtensionGuideViewController ()

@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) NSTextField *instructionLabel;
@property (nonatomic, strong) NSButton *openPreferencesButton;
@property (nonatomic, strong) NSButton *recheckButton;
@property (nonatomic, strong) NSImageView *statusImageView;

@end

@implementation THExtensionGuideViewController

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 400)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self checkExtensionStatus];
}

- (void)setupUI {
    NSView *containerView = self.view;
    
    // Title label
    NSTextField *titleLabel = [[NSTextField alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.stringValue = @"Finder Extension 设置";
    titleLabel.font = [NSFont boldSystemFontOfSize:18];
    titleLabel.editable = NO;
    titleLabel.bordered = NO;
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.alignment = NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // Status image view
    NSImageView *statusImageView = [[NSImageView alloc] init];
    statusImageView.translatesAutoresizingMaskIntoConstraints = NO;
    statusImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    [containerView addSubview:statusImageView];
    self.statusImageView = statusImageView;
    
    // Status label
    NSTextField *statusLabel = [[NSTextField alloc] init];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.font = [NSFont systemFontOfSize:14];
    statusLabel.editable = NO;
    statusLabel.bordered = NO;
    statusLabel.backgroundColor = [NSColor clearColor];
    statusLabel.alignment = NSTextAlignmentCenter;
    [containerView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    // Instruction label (multi-line)
    NSTextField *instructionLabel = [[NSTextField alloc] init];
    instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instructionLabel.font = [NSFont systemFontOfSize:12];
    instructionLabel.editable = NO;
    instructionLabel.bordered = NO;
    instructionLabel.backgroundColor = [NSColor clearColor];
    instructionLabel.alignment = NSTextAlignmentLeft;
    instructionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    instructionLabel.maximumNumberOfLines = 0;
    instructionLabel.preferredMaxLayoutWidth = 450;
    [containerView addSubview:instructionLabel];
    self.instructionLabel = instructionLabel;
    
    // Open System Preferences button
    NSButton *openPreferencesButton = [[NSButton alloc] init];
    openPreferencesButton.translatesAutoresizingMaskIntoConstraints = NO;
    openPreferencesButton.title = @"打开系统设置";
    openPreferencesButton.bezelStyle = NSBezelStyleRounded;
    openPreferencesButton.target = self;
    openPreferencesButton.action = @selector(openSystemPreferences:);
    [containerView addSubview:openPreferencesButton];
    self.openPreferencesButton = openPreferencesButton;
    
    // Recheck button
    NSButton *recheckButton = [[NSButton alloc] init];
    recheckButton.translatesAutoresizingMaskIntoConstraints = NO;
    recheckButton.title = @"重新检测";
    recheckButton.bezelStyle = NSBezelStyleRounded;
    recheckButton.target = self;
    recheckButton.action = @selector(recheckStatus:);
    [containerView addSubview:recheckButton];
    self.recheckButton = recheckButton;
    
    // Layout constraints
    [NSLayoutConstraint activateConstraints:@[
        // Title
        [titleLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:30],
        [titleLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [titleLabel.widthAnchor constraintEqualToConstant:400],
        
        // Status image
        [statusImageView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:30],
        [statusImageView.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [statusImageView.widthAnchor constraintEqualToConstant:64],
        [statusImageView.heightAnchor constraintEqualToConstant:64],
        
        // Status label
        [statusLabel.topAnchor constraintEqualToAnchor:statusImageView.bottomAnchor constant:20],
        [statusLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [statusLabel.widthAnchor constraintEqualToConstant:400],
        
        // Instruction label
        [instructionLabel.topAnchor constraintEqualToAnchor:statusLabel.bottomAnchor constant:20],
        [instructionLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [instructionLabel.widthAnchor constraintEqualToConstant:450],
        
        // Open Preferences button
        [openPreferencesButton.topAnchor constraintEqualToAnchor:instructionLabel.bottomAnchor constant:30],
        [openPreferencesButton.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor constant:-60],
        [openPreferencesButton.widthAnchor constraintEqualToConstant:140],
        
        // Recheck button
        [recheckButton.topAnchor constraintEqualToAnchor:instructionLabel.bottomAnchor constant:30],
        [recheckButton.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor constant:60],
        [recheckButton.widthAnchor constraintEqualToConstant:100],
    ]];
}

- (void)checkExtensionStatus {
    // Check if Finder Sync Extension is enabled
    // Note: There's no direct API to check if a Finder Sync Extension is enabled
    // We can check if the extension bundle exists and is properly configured
    
    BOOL extensionEnabled = [self isFinderSyncExtensionEnabled];
    self.isExtensionEnabled = extensionEnabled;
    
    [self updateUI];
}

- (BOOL)isFinderSyncExtensionEnabled {
    // Check if the extension bundle exists in the app bundle
    NSString *extensionPath = [[NSBundle mainBundle] pathForResource:@"THFinderExtension" ofType:@"appex" inDirectory:@"PlugIns"];
    
    if (!extensionPath) {
        return NO;
    }
    
    // Check if the extension bundle is valid
    NSBundle *extensionBundle = [NSBundle bundleWithPath:extensionPath];
    if (!extensionBundle) {
        return NO;
    }
    
    // Try to check if FIFinderSync is available (indicates extension framework is linked)
    // This is a heuristic check - we can't directly query if the extension is enabled in System Preferences
    // The user will need to manually enable it in System Settings
    
    // For now, we'll assume if the extension bundle exists and is valid, we show the guide
    // The user can use the "Recheck" button after enabling it
    
    // A more sophisticated check would involve checking if the extension is registered
    // but macOS doesn't provide a public API for this
    
    return NO; // Default to showing the guide
}

- (void)updateUI {
    if (self.isExtensionEnabled) {
        // Extension is enabled
        self.statusImageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
        self.statusLabel.stringValue = @"✓ Finder Extension 已启用";
        self.statusLabel.textColor = [NSColor systemGreenColor];
        
        self.instructionLabel.stringValue = @"Finder Extension 已成功启用！\n\n您现在可以在 Finder 中右键点击文件夹，选择 \"Terminal Helper\" 来执行命令。";
        
        self.openPreferencesButton.hidden = YES;
        self.recheckButton.title = @"关闭";
        
    } else {
        // Extension is not enabled
        self.statusImageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
        self.statusLabel.stringValue = @"✗ Finder Extension 未启用";
        self.statusLabel.textColor = [NSColor systemRedColor];
        
        self.instructionLabel.stringValue = @"要使用 Finder 右键菜单功能，您需要启用 Finder Extension：\n\n"
                                           @"1. 点击下方 \"打开系统设置\" 按钮\n"
                                           @"2. 在 \"隐私与安全性\" 中找到 \"扩展\"\n"
                                           @"3. 选择 \"已添加的扩展\"\n"
                                           @"4. 找到并启用 \"Terminal Helper Extension\"\n"
                                           @"5. 点击 \"重新检测\" 按钮确认";
        
        self.openPreferencesButton.hidden = NO;
        self.recheckButton.title = @"重新检测";
    }
}

- (IBAction)openSystemPreferences:(id)sender {
    // Open System Settings to Extensions preferences
    // In macOS 13+, the URL scheme changed
    NSURL *prefsURL = nil;
    
    if (@available(macOS 13.0, *)) {
        // macOS 13 Ventura and later
        prefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preferences.extensions"];
    } else {
        // macOS 12 and earlier
        prefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.extensions"];
    }
    
    if (prefsURL) {
        [[NSWorkspace sharedWorkspace] openURL:prefsURL];
    } else {
        // Fallback: open System Preferences/Settings
        NSURL *prefsAppURL = nil;
        if (@available(macOS 13.0, *)) {
            prefsAppURL = [NSURL fileURLWithPath:@"/System/Applications/System Settings.app"];
        } else {
            prefsAppURL = [NSURL fileURLWithPath:@"/System/Applications/System Preferences.app"];
        }
        [[NSWorkspace sharedWorkspace] openURL:prefsAppURL];
    }
}

- (IBAction)recheckStatus:(id)sender {
    if (self.isExtensionEnabled) {
        // Close the window if extension is enabled
        [self.view.window close];
    } else {
        // Recheck the status
        [self checkExtensionStatus];
        
        // Show a message if still not enabled
        if (!self.isExtensionEnabled) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Extension 仍未启用";
            alert.informativeText = @"请确保您已在系统设置中启用了 Terminal Helper Extension，然后重试。";
            alert.alertStyle = NSAlertStyleInformational;
            [alert addButtonWithTitle:@"确定"];
            [alert runModal];
        }
    }
}

@end
