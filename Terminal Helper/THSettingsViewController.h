//
//  THSettingsViewController.h
//  Terminal Helper
//
//  Created by Kiro on 2026/1/13.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface THSettingsViewController : NSViewController

@property (nonatomic, strong) IBOutlet NSPopUpButton *executionModePopUp;
@property (nonatomic, strong) IBOutlet NSButton *notificationCheckbox;
@property (nonatomic, strong) IBOutlet NSButton *saveButton;

- (IBAction)saveSettings:(id)sender;

@end

NS_ASSUME_NONNULL_END
