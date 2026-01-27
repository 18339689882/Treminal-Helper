//
//  THLogViewController.m
//  Terminal Helper
//
//  Created by Kiro on 2026/1/13.
//

#import "THLogViewController.h"

@interface THLogViewController ()

@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSButton *btnCopyLog;
@property (nonatomic, strong) NSButton *btnClearLog;

@end

@implementation THLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize log content
    _logContent = @"";
    _isExecuting = NO;
    
    // Setup UI
    [self setupUI];
}

- (void)setupUI {
    NSView *containerView = self.view;
    
    // Create scroll view for text view
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    scrollView.borderType = NSBezelBorder;
    scrollView.autohidesScrollers = NO;
    [containerView addSubview:scrollView];
    self.scrollView = scrollView;
    
    // Create text view
    NSTextView *textView = [[NSTextView alloc] init];
    textView.editable = NO;
    textView.selectable = YES;
    textView.font = [NSFont fontWithName:@"Menlo" size:11] ?: [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
    textView.textColor = [NSColor labelColor];
    textView.backgroundColor = [NSColor textBackgroundColor];
    textView.autoresizingMask = NSViewWidthSizable;
    textView.maxSize = NSMakeSize(FLT_MAX, FLT_MAX);
    textView.textContainer.widthTracksTextView = NO;
    textView.textContainer.containerSize = NSMakeSize(FLT_MAX, FLT_MAX);
    scrollView.documentView = textView;
    self.textView = textView;
    
    // Create progress indicator
    NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] init];
    progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    progressIndicator.style = NSProgressIndicatorStyleSpinning;
    progressIndicator.controlSize = NSControlSizeRegular;
    progressIndicator.hidden = YES;
    [containerView addSubview:progressIndicator];
    self.progressIndicator = progressIndicator;
    
    // Create copy button
    NSButton *btnCopyLog = [[NSButton alloc] init];
    btnCopyLog.translatesAutoresizingMaskIntoConstraints = NO;
    btnCopyLog.title = @"复制日志";
    btnCopyLog.bezelStyle = NSBezelStyleRounded;
    btnCopyLog.target = self;
    btnCopyLog.action = @selector(copyLogToClipboard:);
    [containerView addSubview:btnCopyLog];
    self.btnCopyLog = btnCopyLog;
    
    // Create clear button
    NSButton *btnClearLog = [[NSButton alloc] init];
    btnClearLog.translatesAutoresizingMaskIntoConstraints = NO;
    btnClearLog.title = @"清除日志";
    btnClearLog.bezelStyle = NSBezelStyleRounded;
    btnClearLog.target = self;
    btnClearLog.action = @selector(clearButtonClicked:);
    [containerView addSubview:btnClearLog];
    self.btnClearLog = btnClearLog;
    
    // Setup constraints
    [self setupConstraints];
}

- (void)setupConstraints {
    NSView *containerView = self.view;
    NSScrollView *scrollView = self.scrollView;
    NSProgressIndicator *progressIndicator = self.progressIndicator;
    NSButton *btnCopyLog = self.btnCopyLog;
    NSButton *btnClearLog = self.btnClearLog;
    
    [NSLayoutConstraint activateConstraints:@[
        // Scroll view (text view container) - takes most of the space
        [scrollView.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:20],
        [scrollView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [scrollView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-20],
        [scrollView.bottomAnchor constraintEqualToAnchor:btnCopyLog.topAnchor constant:-12],
        
        // Progress indicator - centered in the view
        [progressIndicator.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor],
        [progressIndicator.centerYAnchor constraintEqualToAnchor:scrollView.centerYAnchor],
        
        // Copy button - bottom left
        [btnCopyLog.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [btnCopyLog.widthAnchor constraintEqualToConstant:100],
        [btnCopyLog.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-20],
        
        // Clear button - next to copy button
        [btnClearLog.leadingAnchor constraintEqualToAnchor:btnCopyLog.trailingAnchor constant:12],
        [btnClearLog.widthAnchor constraintEqualToConstant:100],
        [btnClearLog.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-20],
    ]];
}

#pragma mark - Public Methods

- (void)appendLog:(NSString *)text {
    if (!text || text.length == 0) {
        return;
    }
    
    // Append to log content
    if (self.logContent.length > 0) {
        self.logContent = [self.logContent stringByAppendingString:@"\n"];
    }
    self.logContent = [self.logContent stringByAppendingString:text];
    
    // Update text view on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.string = self.logContent;
        
        // Scroll to bottom
        [self scrollToBottom];
    });
}

- (void)clearLog {
    self.logContent = @"";
    
    // Update text view on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.string = @"";
    });
}

- (void)scrollToBottom {
    NSRange range = NSMakeRange(self.textView.string.length, 0);
    [self.textView scrollRangeToVisible:range];
}

#pragma mark - Properties

- (void)setIsExecuting:(BOOL)isExecuting {
    _isExecuting = isExecuting;
    
    // Update progress indicator on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isExecuting) {
            self.progressIndicator.hidden = NO;
            [self.progressIndicator startAnimation:nil];
        } else {
            [self.progressIndicator stopAnimation:nil];
            self.progressIndicator.hidden = YES;
        }
    });
}

#pragma mark - Actions

- (IBAction)copyLogToClipboard:(id)sender {
    if (self.logContent.length == 0) {
        // Show alert if log is empty
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"日志为空";
        alert.informativeText = @"没有可复制的日志内容";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        return;
    }
    
    // Copy to clipboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:self.logContent forType:NSPasteboardTypeString];
    
    // Show success feedback
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"复制成功";
    alert.informativeText = @"日志内容已复制到剪贴板";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

- (IBAction)clearButtonClicked:(id)sender {
    if (self.logContent.length == 0) {
        return;
    }
    
    // Confirm clear
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"确认清除";
    alert.informativeText = @"确定要清除所有日志内容吗？";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"清除"];
    [alert addButtonWithTitle:@"取消"];
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self clearLog];
    }
}

@end
