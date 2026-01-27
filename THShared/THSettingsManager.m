//
//  THSettingsManager.m
//  THShared
//
//  Implementation of the settings management singleton.
//

#import "THSettingsManager.h"

@interface THSettingsManager ()

/// Internal flag to prevent recursive save calls during loading
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation THSettingsManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static THSettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[THSettingsManager alloc] initInternal];
    });
    return sharedInstance;
}

- (instancetype)initInternal {
    self = [super init];
    if (self) {
        // Set default values
        _defaultExecutionMode = THExecutionModeBackground;
        _showNotificationOnComplete = YES;
        
        // Load persisted settings
        [self load];
    }
    return self;
}

#pragma mark - Property Overrides

- (void)setDefaultExecutionMode:(THExecutionMode)defaultExecutionMode {
    if (_defaultExecutionMode != defaultExecutionMode) {
        _defaultExecutionMode = defaultExecutionMode;
        if (!self.isLoading) {
            [self save];
        }
    }
}

- (void)setShowNotificationOnComplete:(BOOL)showNotificationOnComplete {
    if (_showNotificationOnComplete != showNotificationOnComplete) {
        _showNotificationOnComplete = showNotificationOnComplete;
        if (!self.isLoading) {
            [self save];
        }
    }
}

#pragma mark - Persistence

- (void)save {
    NSUserDefaults *sharedDefaults = THSharedUserDefaults();
    if (!sharedDefaults) {
        NSLog(@"Error: Could not access shared UserDefaults for App Group");
        return;
    }
    
    // Save execution mode as integer
    [sharedDefaults setInteger:self.defaultExecutionMode forKey:THSettingsExecutionModeKey];
    
    // Save notification setting
    [sharedDefaults setBool:self.showNotificationOnComplete forKey:THSettingsShowNotificationKey];
    
    // Synchronize to ensure immediate persistence
    [sharedDefaults synchronize];
    
    NSLog(@"Settings saved: executionMode=%ld, showNotification=%@", 
          (long)self.defaultExecutionMode, 
          self.showNotificationOnComplete ? @"YES" : @"NO");
    
    // Post notification that settings were updated
    [[NSNotificationCenter defaultCenter] postNotificationName:THSettingsDidUpdateNotification
                                                        object:self];
    
    // Also post distributed notification for cross-process communication
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:THSettingsDidUpdateNotification
                                                                    object:nil
                                                                  userInfo:nil
                                                        deliverImmediately:YES];
}

- (void)load {
    NSUserDefaults *sharedDefaults = THSharedUserDefaults();
    if (!sharedDefaults) {
        NSLog(@"Error: Could not access shared UserDefaults for App Group");
        return;
    }
    
    // Set loading flag to prevent automatic saves during loading
    self.isLoading = YES;
    
    // Load execution mode (default to background if not set)
    if ([sharedDefaults objectForKey:THSettingsExecutionModeKey] != nil) {
        NSInteger executionModeValue = [sharedDefaults integerForKey:THSettingsExecutionModeKey];
        if (executionModeValue >= THExecutionModeBackground && executionModeValue <= THExecutionModeTerminal) {
            _defaultExecutionMode = (THExecutionMode)executionModeValue;
        } else {
            NSLog(@"Warning: Invalid execution mode value %ld, using default", (long)executionModeValue);
            _defaultExecutionMode = THExecutionModeBackground;
        }
    } else {
        // First launch - use default value
        _defaultExecutionMode = THExecutionModeBackground;
    }
    
    // Load notification setting (default to YES if not set)
    if ([sharedDefaults objectForKey:THSettingsShowNotificationKey] != nil) {
        _showNotificationOnComplete = [sharedDefaults boolForKey:THSettingsShowNotificationKey];
    } else {
        // First launch - use default value
        _showNotificationOnComplete = YES;
    }
    
    // Clear loading flag
    self.isLoading = NO;
    
    NSLog(@"Settings loaded: executionMode=%ld, showNotification=%@", 
          (long)self.defaultExecutionMode, 
          self.showNotificationOnComplete ? @"YES" : @"NO");
}

#pragma mark - Utility Methods

+ (NSString *)stringForExecutionMode:(THExecutionMode)mode {
    switch (mode) {
        case THExecutionModeBackground:
            return @"Background";
        case THExecutionModeTerminal:
            return @"Terminal";
        default:
            return @"Unknown";
    }
}

+ (THExecutionMode)executionModeForString:(NSString *)string {
    if ([string isEqualToString:@"Background"]) {
        return THExecutionModeBackground;
    } else if ([string isEqualToString:@"Terminal"]) {
        return THExecutionModeTerminal;
    } else {
        return THExecutionModeBackground; // Default fallback
    }
}

@end