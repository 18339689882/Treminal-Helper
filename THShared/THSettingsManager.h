//
//  THSettingsManager.h
//  THShared
//
//  Settings management singleton for Terminal Helper.
//  Handles user preferences and persistence.
//

#import <Foundation/Foundation.h>
#import "THConstants.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * THSettingsManager is a singleton that manages user settings and preferences.
 * It handles persistence using App Group UserDefaults.
 */
@interface THSettingsManager : NSObject

#pragma mark - Properties

/// Default execution mode for commands
@property (nonatomic, assign) THExecutionMode defaultExecutionMode;

/// Whether to show notifications when command execution completes
@property (nonatomic, assign) BOOL showNotificationOnComplete;

#pragma mark - Singleton

/**
 * Returns the shared settings manager instance.
 * @return The singleton THSettingsManager instance.
 */
+ (instancetype)sharedManager;

/// Unavailable. Use sharedManager instead.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Persistence

/**
 * Manually saves all settings to persistent storage.
 * This is called automatically when settings are changed.
 */
- (void)save;

/**
 * Manually loads settings from persistent storage.
 * This is called automatically during initialization.
 */
- (void)load;

@end

NS_ASSUME_NONNULL_END