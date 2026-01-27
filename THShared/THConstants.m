//
//  THConstants.m
//  THShared
//
//  Implementation of shared constants.
//

#import "THConstants.h"

#pragma mark - App Group

NSString * const THAppGroupIdentifier = @"group.com.terminal-helper.shared";

#pragma mark - UserDefaults Keys

NSString * const THUserDefaultsCommandsKey = @"com.terminal-helper.commands";
NSString * const THUserDefaultsSettingsKey = @"com.terminal-helper.settings";
NSString * const THUserDefaultsLastDirectoryKey = @"com.terminal-helper.lastDirectory";

#pragma mark - Settings Keys

NSString * const THSettingsExecutionModeKey = @"executionMode";
NSString * const THSettingsShowNotificationKey = @"showNotificationOnComplete";

#pragma mark - Notifications

NSString * const THCommandListDidUpdateNotification = @"com.terminal-helper.commandListDidUpdate";
NSString * const THSettingsDidUpdateNotification = @"com.terminal-helper.settingsDidUpdate";

#pragma mark - Error Domains

NSString * const THCommandExecutorErrorDomain = @"THCommandExecutorErrorDomain";

#pragma mark - Helper Functions

NSUserDefaults * _Nullable THSharedUserDefaults(void) {
    static NSUserDefaults *sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:THAppGroupIdentifier];
    });
    return sharedDefaults;
}
