//
//  THLogViewController.h
//  Terminal Helper
//
//  Created by Kiro on 2026/1/13.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface THLogViewController : NSViewController

@property (nonatomic, copy) NSString *logContent;
@property (nonatomic, assign) BOOL isExecuting;

- (void)appendLog:(NSString *)text;
- (void)clearLog;
- (IBAction)copyLogToClipboard:(id)sender;

@end

NS_ASSUME_NONNULL_END
