//
//  THSettingsViewController.m
//  Terminal Helper
//
//  Created by Kiro on 2026/1/13.
//

#import "THSettingsViewController.h"
#import "THSettingsManager.h"
#import "THCommandExecutor.h"

@interface THSettingsViewController ()

@end

@implementation THSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create UI programmatically
    [self setupUI];
    
    // Load current settings
    [self loadSettings];
}

- (void)setupUI {
    NSView *containerView = self.view;
    
    // Create execution mode label
    NSTextField *executionModeLabel = [[NSTextField alloc] init];
    executionModeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    executionModeLabel.stringValue = @"执行模式:";
    executionModeLabel.editable = NO;
    executionModeLabel.bordered = NO;
    executionModeLabel.backgroundColor = [NSColor clearColor];
    executionModeLabel.alignment = NSTextAlignmentRight;
    [containerView addSubview:executionModeLabel];
    
    // Create execution mode popup button
    NSPopUpButton *executionModePopUp = [[NSPopUpButton alloc] init];
    executionModePopUp.translatesAutoresizingMaskIntoConstraints = NO;
    [executionModePopUp addItemWithTitle:@"后台执行"];
    [executionModePopUp addItemWithTitle:@"Terminal.app"];
    [containerView addSubview:executionModePopUp];
    self.executionModePopUp = executionModePopUp;
    
    // Create notification checkbox
    NSButton *notificationCheckbox = [[NSButton alloc] init];
    notificationCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    notificationCheckbox.title = @"执行完成后显示通知";
    [notificationCheckbox setButtonType:NSButtonTypeSwitch];
    [containerView addSubview:notificationCheckbox];
    self.notificationCheckbox = notificationCheckbox;
    
    // Create save button
    NSButton *saveButton = [[NSButton alloc] init];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.title = @"保存设置";
    saveButton.bezelStyle = NSBezelStyleRounded;
    saveButton.target = self;
    saveButton.action = @selector(saveSettings:);
    [containerView addSubview:saveButton];
    self.saveButton = saveButton;
    
    // Create description label
    NSTextField *descriptionLabel = [[NSTextField alloc] init];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.stringValue = @"后台执行: 命令在后台静默执行，输出显示在日志视图中\nTerminal.app: 在 Terminal 应用中打开并执行命令";
    descriptionLabel.editable = NO;
    descriptionLabel.bordered = NO;
    descriptionLabel.backgroundColor = [NSColor clearColor];
    descriptionLabel.textColor = [NSColor secondaryLabelColor];
    descriptionLabel.font = [NSFont systemFontOfSize:11];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.maximumNumberOfLines = 0;
    [containerView addSubview:descriptionLabel];
    
    // Setup constraints
    [NSLayoutConstraint activateConstraints:@[
        // Execution mode label
        [executionModeLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:30],
        [executionModeLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [executionModeLabel.widthAnchor constraintEqualToConstant:90],
        
        // Execution mode popup
        [executionModePopUp.centerYAnchor constraintEqualToAnchor:executionModeLabel.centerYAnchor],
        [executionModePopUp.leadingAnchor constraintEqualToAnchor:executionModeLabel.trailingAnchor constant:8],
        [executionModePopUp.widthAnchor constraintEqualToConstant:200],
        
        // Description label
        [descriptionLabel.topAnchor constraintEqualToAnchor:executionModePopUp.bottomAnchor constant:8],
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:executionModePopUp.leadingAnchor],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-20],
        
        // Notification checkbox
        [notificationCheckbox.topAnchor constraintEqualToAnchor:descriptionLabel.bottomAnchor constant:30],
        [notificationCheckbox.leadingAnchor constraintEqualToAnchor:executionModePopUp.leadingAnchor],
        
        // Save button
        [saveButton.topAnchor constraintEqualToAnchor:notificationCheckbox.bottomAnchor constant:30],
        [saveButton.leadingAnchor constraintEqualToAnchor:executionModePopUp.leadingAnchor],
        [saveButton.widthAnchor constraintEqualToConstant:100],
    ]];
}

- (void)loadSettings {
    THSettingsManager *settingsManager = [THSettingsManager sharedManager];
    
    // Load execution mode
    THExecutionMode mode = settingsManager.defaultExecutionMode;
    [self.executionModePopUp selectItemAtIndex:mode];
    
    // Load notification setting
    self.notificationCheckbox.state = settingsManager.showNotificationOnComplete ? NSControlStateValueOn : NSControlStateValueOff;
}

- (IBAction)saveSettings:(id)sender {
    THSettingsManager *settingsManager = [THSettingsManager sharedManager];
    
    // Save execution mode
    NSInteger selectedIndex = self.executionModePopUp.indexOfSelectedItem;
    settingsManager.defaultExecutionMode = (THExecutionMode)selectedIndex;
    
    // Save notification setting
    settingsManager.showNotificationOnComplete = (self.notificationCheckbox.state == NSControlStateValueOn);
    
    // Persist settings
    [settingsManager save];
    
    // Show confirmation
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"设置已保存";
    alert.informativeText = @"您的设置已成功保存";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

@end
