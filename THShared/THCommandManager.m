//
//  THCommandManager.m
//  THShared
//
//  Implementation of the command management singleton.
//

#import "THCommandManager.h"
#import "THConstants.h"

@interface THCommandManager ()

/// Internal mutable array of all commands
@property (nonatomic, strong) NSMutableArray<THCommand *> *mutableCommands;

@end

@implementation THCommandManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static THCommandManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[THCommandManager alloc] initInternal];
    });
    return sharedInstance;
}

- (instancetype)initInternal {
    self = [super init];
    if (self) {
        _mutableCommands = [[NSMutableArray alloc] init];
        [self loadCommands];
    }
    return self;
}

#pragma mark - Properties

- (NSArray<THCommand *> *)allCommands {
    // Return sorted copy of commands
    return [self.mutableCommands sortedArrayUsingComparator:^NSComparisonResult(THCommand *obj1, THCommand *obj2) {
        if (obj1.sortOrder < obj2.sortOrder) {
            return NSOrderedAscending;
        } else if (obj1.sortOrder > obj2.sortOrder) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (NSArray<THCommand *> *)presetCommands {
    NSPredicate *presetPredicate = [NSPredicate predicateWithFormat:@"isPreset == YES"];
    NSArray<THCommand *> *presets = [self.allCommands filteredArrayUsingPredicate:presetPredicate];
    return presets;
}

- (NSArray<THCommand *> *)customCommands {
    NSPredicate *customPredicate = [NSPredicate predicateWithFormat:@"isPreset == NO"];
    NSArray<THCommand *> *customs = [self.allCommands filteredArrayUsingPredicate:customPredicate];
    return customs;
}

#pragma mark - Command Operations

- (void)addCommand:(THCommand *)command {
    NSParameterAssert(command != nil);
    
    // Check if command already exists
    THCommand *existingCommand = [self commandWithIdentifier:command.identifier];
    if (existingCommand) {
        NSLog(@"Warning: Command with identifier %@ already exists. Use updateCommand: instead.", command.identifier);
        return;
    }
    
    // Set sort order to be last
    command.sortOrder = (NSInteger)self.mutableCommands.count;
    
    // Add to internal array
    [self.mutableCommands addObject:command];
    
    // Persist changes
    [self saveCommands];
    
    // Post notification
    [self postCommandListUpdateNotification];
}

- (void)updateCommand:(THCommand *)command {
    NSParameterAssert(command != nil);
    
    // Find existing command by identifier
    NSUInteger index = [self.mutableCommands indexOfObjectPassingTest:^BOOL(THCommand *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:command.identifier];
    }];
    
    if (index == NSNotFound) {
        NSLog(@"Warning: Command with identifier %@ not found. Use addCommand: instead.", command.identifier);
        return;
    }
    
    // Replace the command
    [self.mutableCommands replaceObjectAtIndex:index withObject:command];
    
    // Persist changes
    [self saveCommands];
    
    // Post notification
    [self postCommandListUpdateNotification];
}

- (void)deleteCommand:(THCommand *)command {
    NSParameterAssert(command != nil);
    
    // Cannot delete preset commands
    if (command.isPreset) {
        NSLog(@"Warning: Cannot delete preset command: %@", command.name);
        return;
    }
    
    // Find and remove command
    NSUInteger index = [self.mutableCommands indexOfObjectPassingTest:^BOOL(THCommand *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:command.identifier];
    }];
    
    if (index == NSNotFound) {
        NSLog(@"Warning: Command with identifier %@ not found.", command.identifier);
        return;
    }
    
    [self.mutableCommands removeObjectAtIndex:index];
    
    // Persist changes
    [self saveCommands];
    
    // Post notification
    [self postCommandListUpdateNotification];
}

- (void)reorderCommands:(NSArray<THCommand *> *)commands {
    NSParameterAssert(commands != nil);
    
    // Validate that all commands exist in our collection
    for (THCommand *command in commands) {
        if (![self.mutableCommands containsObject:command]) {
            NSLog(@"Warning: Command %@ not found in manager. Skipping reorder.", command.identifier);
            return;
        }
    }
    
    // Update sort order for each command
    [commands enumerateObjectsUsingBlock:^(THCommand *command, NSUInteger idx, BOOL *stop) {
        command.sortOrder = (NSInteger)idx;
    }];
    
    // Persist changes
    [self saveCommands];
    
    // Post notification
    [self postCommandListUpdateNotification];
}

- (nullable THCommand *)commandWithIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier != nil);
    
    NSUInteger index = [self.mutableCommands indexOfObjectPassingTest:^BOOL(THCommand *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:identifier];
    }];
    
    return (index != NSNotFound) ? self.mutableCommands[index] : nil;
}

#pragma mark - Persistence

- (void)saveCommands {
    NSUserDefaults *sharedDefaults = THSharedUserDefaults();
    if (!sharedDefaults) {
        NSLog(@"Error: Could not access shared UserDefaults for App Group");
        return;
    }
    
    // Encode commands array using NSKeyedArchiver
    NSError *error = nil;
    NSData *commandsData = [NSKeyedArchiver archivedDataWithRootObject:self.mutableCommands
                                                 requiringSecureCoding:YES
                                                                 error:&error];
    
    if (error) {
        NSLog(@"Error archiving commands: %@", error.localizedDescription);
        return;
    }
    
    [sharedDefaults setObject:commandsData forKey:THUserDefaultsCommandsKey];
    [sharedDefaults synchronize];
}

- (void)loadCommands {
    NSUserDefaults *sharedDefaults = THSharedUserDefaults();
    if (!sharedDefaults) {
        NSLog(@"Error: Could not access shared UserDefaults for App Group");
        [self loadDefaultCommands];
        return;
    }
    
    NSData *commandsData = [sharedDefaults objectForKey:THUserDefaultsCommandsKey];
    
    if (!commandsData) {
        // First launch - load default preset commands
        [self loadDefaultCommands];
        return;
    }
    
    // Decode commands array
    NSError *error = nil;
    NSSet *allowedClasses = [NSSet setWithObjects:[NSMutableArray class], [THCommand class], nil];
    NSMutableArray<THCommand *> *loadedCommands = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
                                                                                       fromData:commandsData
                                                                                          error:&error];
    
    if (error || !loadedCommands) {
        NSLog(@"Error unarchiving commands: %@", error.localizedDescription);
        [self loadDefaultCommands];
        return;
    }
    
    self.mutableCommands = loadedCommands;
    
    // Ensure preset commands are present (in case they were missing)
    [self ensurePresetCommandsExist];
}

- (void)loadDefaultCommands {
    [self.mutableCommands removeAllObjects];
    
    // Add preset commands
    THCommand *podInstall = [THCommand presetPodInstall];
    if (podInstall) {
        [self.mutableCommands addObject:podInstall];
    }
    
    // Save the default commands
    [self saveCommands];
}

- (void)ensurePresetCommandsExist {
    // Check if pod install preset exists
    BOOL hasPodInstall = NO;
    for (THCommand *command in self.mutableCommands) {
        if (command.isPreset && [command.identifier isEqualToString:@"preset.pod-install"]) {
            hasPodInstall = YES;
            break;
        }
    }
    
    // Add missing preset commands
    if (!hasPodInstall) {
        THCommand *podInstall = [THCommand presetPodInstall];
        if (podInstall) {
            [self.mutableCommands insertObject:podInstall atIndex:0];
        }
    }
}

#pragma mark - Notifications

- (void)postCommandListUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:THCommandListDidUpdateNotification
                                                        object:self];
    
    // Also post distributed notification for cross-process communication
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:THCommandListDidUpdateNotification
                                                                    object:nil
                                                                  userInfo:nil
                                                        deliverImmediately:YES];
}

@end