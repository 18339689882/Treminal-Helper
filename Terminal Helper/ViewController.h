//
//  ViewController.h
//  Terminal Helper
//
//  Created by sunDS on 2026/1/13.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSTableView *commandTableView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;

// Edit controls
@property (nonatomic, strong) IBOutlet NSTextField *nameTextField;
@property (nonatomic, strong) IBOutlet NSTextField *commandTextField;
@property (nonatomic, strong) IBOutlet NSButton *addButton;
@property (nonatomic, strong) IBOutlet NSButton *editButton;
@property (nonatomic, strong) IBOutlet NSButton *deleteButton;

- (IBAction)addCommand:(id)sender;
- (IBAction)editCommand:(id)sender;
- (IBAction)deleteCommand:(id)sender;

@end

