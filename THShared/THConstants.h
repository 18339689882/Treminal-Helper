//
//  THConstants.h
//  THShared
//
//  Constants shared across all Terminal Helper components.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - App Group

/// App Group identifier for sharing data between main app, Finder Extension, and Menu Bar component
extern NSString * const THAppGroupIdentifier;

#pragma mark - UserDefaults Keys

/// Key for storing commands array in UserDefaults
extern NSString * const THUserDefaultsCommandsKey;

/// Key for storing settings dictionary in UserDefaults
extern NSString * const THUserDefaultsSettingsKey;

/// Key for storing last selected directory path
extern NSString * const THUserDefaultsLastDirectoryKey;

#pragma mark - Settings Keys

/// Key for execution mode setting (NSInteger: 0=Background, 1=Terminal)
extern NSString * const THSettingsExecutionModeKey;

/// Key for show notification on complete setting (BOOL)
extern NSString * const THSettingsShowNotificationKey;

#pragma mark - Notifications

/// Notification posted when command list is updated
extern NSString * const THCommandListDidUpdateNotification;

/// Notification posted when settings are updated
extern NSString * const THSettingsDidUpdateNotification;

#pragma mark - Error Domains

/// Error domain for THCommandExecutor
extern NSString * const THCommandExecutorErrorDomain;

#pragma mark - Execution Mode

/// Execution mode enumeration
typedef NS_ENUM(NSInteger, THExecutionMode) {
    /// Execute command silently in background, capture output
    THExecutionModeBackground = 0,
    /// Open Terminal.app and execute command there
    THExecutionModeTerminal = 1
};

#pragma mark - Helper Functions

/// Returns the shared UserDefaults instance for the App Group
NSUserDefaults * _Nullable THSharedUserDefaults(void);

NS_ASSUME_NONNULL_END
