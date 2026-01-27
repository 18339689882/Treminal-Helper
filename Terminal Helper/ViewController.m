//
//  ViewController.m
//  Terminal Helper
//
//  Created by sunDS on 2026/1/13.
//

#import "ViewController.h"
#import "THCommand.h"
#import "THCommandManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray<THCommand *> *commands;
@property (nonatomic, strong) THCommand *selectedCommand;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create UI programmatically
    [self setupUI];
    
    // Load commands from manager
    [self reloadCommands];
    
    // Update button states
    [self updateButtonStates];
}

- (void)setupUI {
    // Create main container view
    NSView *containerView = self.view;
    
    // Create table view with scroll view
    [self setupTableView];
    
    // Create edit controls
    [self setupEditControls];
    
    // Layout constraints
    [self setupConstraints];
}

- (void)setupTableView {
    // Create scroll view
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = NO;
    scrollView.borderType = NSBezelBorder;
    
    // Create table view
    NSTableView *tableView = [[NSTableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 24;
    tableView.intercellSpacing = NSMakeSize(3, 2);
    tableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    tableView.usesAlternatingRowBackgroundColors = YES;
    tableView.allowsEmptySelection = YES;
    tableView.allowsMultipleSelection = NO;
    
    // Create "Type" column (Preset/Custom indicator)
    NSTableColumn *typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"type"];
    typeColumn.title = @"类型";
    typeColumn.width = 80;
    typeColumn.minWidth = 60;
    typeColumn.maxWidth = 100;
    [tableView addTableColumn:typeColumn];
    
    // Create "Name" column
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    nameColumn.title = @"命令名称";
    nameColumn.width = 150;
    nameColumn.minWidth = 100;
    [tableView addTableColumn:nameColumn];
    
    // Create "Command" column
    NSTableColumn *commandColumn = [[NSTableColumn alloc] initWithIdentifier:@"command"];
    commandColumn.title = @"命令字符串";
    commandColumn.width = 250;
    commandColumn.minWidth = 150;
    [tableView addTableColumn:commandColumn];
    
    scrollView.documentView = tableView;
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
    self.commandTableView = tableView;
}

- (void)setupEditControls {
    // Name label
    NSTextField *nameLabel = [[NSTextField alloc] init];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.stringValue = @"命令名称:";
    nameLabel.editable = NO;
    nameLabel.bordered = NO;
    nameLabel.backgroundColor = [NSColor clearColor];
    nameLabel.alignment = NSTextAlignmentRight;
    [self.view addSubview:nameLabel];
    
    // Name text field
    NSTextField *nameTextField = [[NSTextField alloc] init];
    nameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    nameTextField.placeholderString = @"输入命令名称";
    [self.view addSubview:nameTextField];
    self.nameTextField = nameTextField;
    
    // Command label
    NSTextField *commandLabel = [[NSTextField alloc] init];
    commandLabel.translatesAutoresizingMaskIntoConstraints = NO;
    commandLabel.stringValue = @"命令字符串:";
    commandLabel.editable = NO;
    commandLabel.bordered = NO;
    commandLabel.backgroundColor = [NSColor clearColor];
    commandLabel.alignment = NSTextAlignmentRight;
    [self.view addSubview:commandLabel];
    
    // Command text field
    NSTextField *commandTextField = [[NSTextField alloc] init];
    commandTextField.translatesAutoresizingMaskIntoConstraints = NO;
    commandTextField.placeholderString = @"输入命令字符串 (例如: pod install)";
    commandTextField.font = [NSFont fontWithName:@"Menlo" size:12] ?: [NSFont systemFontOfSize:12];
    [self.view addSubview:commandTextField];
    self.commandTextField = commandTextField;
    
    // Add button
    NSButton *addButton = [[NSButton alloc] init];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    addButton.title = @"添加";
    addButton.bezelStyle = NSBezelStyleRounded;
    addButton.target = self;
    addButton.action = @selector(addCommand:);
    [self.view addSubview:addButton];
    self.addButton = addButton;
    
    // Edit button
    NSButton *editButton = [[NSButton alloc] init];
    editButton.translatesAutoresizingMaskIntoConstraints = NO;
    editButton.title = @"编辑";
    editButton.bezelStyle = NSBezelStyleRounded;
    editButton.target = self;
    editButton.action = @selector(editCommand:);
    [self.view addSubview:editButton];
    self.editButton = editButton;
    
    // Delete button
    NSButton *deleteButton = [[NSButton alloc] init];
    deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    deleteButton.title = @"删除";
    deleteButton.bezelStyle = NSBezelStyleRounded;
    deleteButton.target = self;
    deleteButton.action = @selector(deleteCommand:);
    [self.view addSubview:deleteButton];
    self.deleteButton = deleteButton;
    
    // Store references for constraints
    nameLabel.identifier = @"nameLabel";
    commandLabel.identifier = @"commandLabel";
}

- (void)setupConstraints {
    NSView *containerView = self.view;
    NSScrollView *scrollView = self.scrollView;
    NSTextField *nameTextField = self.nameTextField;
    NSTextField *commandTextField = self.commandTextField;
    NSButton *addButton = self.addButton;
    NSButton *editButton = self.editButton;
    NSButton *deleteButton = self.deleteButton;
    
    // Find labels
    NSTextField *nameLabel = nil;
    NSTextField *commandLabel = nil;
    for (NSView *subview in containerView.subviews) {
        if ([subview.identifier isEqualToString:@"nameLabel"]) {
            nameLabel = (NSTextField *)subview;
        } else if ([subview.identifier isEqualToString:@"commandLabel"]) {
            commandLabel = (NSTextField *)subview;
        }
    }
    
    // Layout: Table view on top, edit controls at bottom
    [NSLayoutConstraint activateConstraints:@[
        // Scroll view (table) - top section
        [scrollView.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:20],
        [scrollView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [scrollView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-20],
        [scrollView.bottomAnchor constraintEqualToAnchor:nameLabel.topAnchor constant:-20],
        
        // Name label and text field
        [nameLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [nameLabel.widthAnchor constraintEqualToConstant:90],
        [nameLabel.centerYAnchor constraintEqualToAnchor:nameTextField.centerYAnchor],
        
        [nameTextField.leadingAnchor constraintEqualToAnchor:nameLabel.trailingAnchor constant:8],
        [nameTextField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-20],
        [nameTextField.bottomAnchor constraintEqualToAnchor:commandLabel.topAnchor constant:-12],
        
        // Command label and text field
        [commandLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [commandLabel.widthAnchor constraintEqualToConstant:90],
        [commandLabel.centerYAnchor constraintEqualToAnchor:commandTextField.centerYAnchor],
        
        [commandTextField.leadingAnchor constraintEqualToAnchor:commandLabel.trailingAnchor constant:8],
        [commandTextField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-20],
        [commandTextField.bottomAnchor constraintEqualToAnchor:addButton.topAnchor constant:-12],
        
        // Buttons
        [addButton.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20],
        [addButton.widthAnchor constraintEqualToConstant:80],
        [addButton.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-20],
        
        [editButton.leadingAnchor constraintEqualToAnchor:addButton.trailingAnchor constant:12],
        [editButton.widthAnchor constraintEqualToConstant:80],
        [editButton.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-20],
        
        [deleteButton.leadingAnchor constraintEqualToAnchor:editButton.trailingAnchor constant:12],
        [deleteButton.widthAnchor constraintEqualToConstant:80],
        [deleteButton.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-20],
    ]];
}

- (void)reloadCommands {
    self.commands = [[THCommandManager sharedManager] allCommands];
    [self.commandTableView reloadData];
}

- (void)updateButtonStates {
    NSInteger selectedRow = self.commandTableView.selectedRow;
    BOOL hasSelection = selectedRow >= 0 && selectedRow < self.commands.count;
    
    if (hasSelection) {
        self.selectedCommand = self.commands[selectedRow];
        
        // Enable edit button for all commands
        self.editButton.enabled = YES;
        
        // Enable delete button only for custom commands
        self.deleteButton.enabled = !self.selectedCommand.isPreset;
        
        // Populate text fields with selected command
        self.nameTextField.stringValue = self.selectedCommand.name ?: @"";
        self.commandTextField.stringValue = self.selectedCommand.commandString ?: @"";
    } else {
        self.selectedCommand = nil;
        self.editButton.enabled = NO;
        self.deleteButton.enabled = NO;
        
        // Clear text fields
        self.nameTextField.stringValue = @"";
        self.commandTextField.stringValue = @"";
    }
    
    // Add button is always enabled
    self.addButton.enabled = YES;
}

#pragma mark - Actions

- (IBAction)addCommand:(id)sender {
    NSString *name = [self.nameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *commandString = [self.commandTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Validate input
    if (name.length == 0 || commandString.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"输入验证失败";
        alert.informativeText = @"命令名称和命令字符串不能为空";
        alert.alertStyle = NSAlertStyleWarning;
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        return;
    }
    
    // Create and add command
    THCommand *newCommand = [[THCommand alloc] initWithName:name commandString:commandString];
    if (newCommand) {
        [[THCommandManager sharedManager] addCommand:newCommand];
        
        // Reload and clear
        [self reloadCommands];
        self.nameTextField.stringValue = @"";
        self.commandTextField.stringValue = @"";
        [self updateButtonStates];
    }
}

- (IBAction)editCommand:(id)sender {
    if (!self.selectedCommand) {
        return;
    }
    
    NSString *name = [self.nameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *commandString = [self.commandTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Validate input
    if (name.length == 0 || commandString.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"输入验证失败";
        alert.informativeText = @"命令名称和命令字符串不能为空";
        alert.alertStyle = NSAlertStyleWarning;
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        return;
    }
    
    // Update command properties
    self.selectedCommand.name = name;
    self.selectedCommand.commandString = commandString;
    
    // Update in manager
    [[THCommandManager sharedManager] updateCommand:self.selectedCommand];
    
    // Reload
    [self reloadCommands];
    [self updateButtonStates];
}

- (IBAction)deleteCommand:(id)sender {
    if (!self.selectedCommand || self.selectedCommand.isPreset) {
        return;
    }
    
    // Confirm deletion
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"确认删除";
    alert.informativeText = [NSString stringWithFormat:@"确定要删除命令 \"%@\" 吗？", self.selectedCommand.name];
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"删除"];
    [alert addButtonWithTitle:@"取消"];
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [[THCommandManager sharedManager] deleteCommand:self.selectedCommand];
        
        // Reload and clear
        [self reloadCommands];
        self.nameTextField.stringValue = @"";
        self.commandTextField.stringValue = @"";
        [self updateButtonStates];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.commands.count;
}

#pragma mark - NSTableViewDelegate

- (nullable NSView *)tableView:(NSTableView *)tableView 
             viewForTableColumn:(nullable NSTableColumn *)tableColumn 
                            row:(NSInteger)row {
    
    if (row < 0 || row >= self.commands.count) {
        return nil;
    }
    
    THCommand *command = self.commands[row];
    NSString *identifier = tableColumn.identifier;
    
    // Create or reuse cell view
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = identifier;
        
        // Create text field
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 20)];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        textField.selectable = YES;
        textField.lineBreakMode = NSLineBreakByTruncatingTail;
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        // Auto layout
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
            [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
        ]];
    }
    
    // Set cell content based on column
    if ([identifier isEqualToString:@"type"]) {
        cellView.textField.stringValue = command.isPreset ? @"预设" : @"自定义";
        cellView.textField.textColor = command.isPreset ? [NSColor systemBlueColor] : [NSColor labelColor];
    } else if ([identifier isEqualToString:@"name"]) {
        cellView.textField.stringValue = command.name ?: @"";
    } else if ([identifier isEqualToString:@"command"]) {
        cellView.textField.stringValue = command.commandString ?: @"";
        cellView.textField.font = [NSFont fontWithName:@"Menlo" size:11] ?: [NSFont systemFontOfSize:11];
    }
    
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateButtonStates];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
