//
//  AppDelegate.h
//  Terminal Helper
//
//  Created by sunDS on 2026/1/13.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindowController *settingsWindowController;
@property (nonatomic, strong) NSWindowController *extensionGuideWindowController;
@property (nonatomic, strong) NSStatusItem *statusItem;

- (IBAction)showSettings:(id)sender;
- (IBAction)showExtensionGuide:(id)sender;

@end

