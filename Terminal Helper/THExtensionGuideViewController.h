//
//  THExtensionGuideViewController.h
//  Terminal Helper
//
//  Created by Kiro on 2026/1/14.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface THExtensionGuideViewController : NSViewController

@property (nonatomic, assign) BOOL isExtensionEnabled;

- (void)checkExtensionStatus;
- (IBAction)openSystemPreferences:(id)sender;
- (IBAction)recheckStatus:(id)sender;

@end

NS_ASSUME_NONNULL_END
