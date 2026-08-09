//
//  THCommand.h
//  THShared
//
//  Command model representing a terminal command that can be executed.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * THCommand represents a terminal command that can be executed in a directory.
 * Commands can be either preset (built-in) or custom (user-defined).
 * Supports NSSecureCoding for persistence via UserDefaults.
 */
@interface THCommand : NSObject <NSSecureCoding>

#pragma mark - Properties

/// Unique identifier for the command (UUID string)
@property (nonatomic, copy, readonly) NSString *identifier;

/// Display name for the command (e.g., "Pod Install")
@property (nonatomic, copy) NSString *name;

/// Full command string to execute (e.g., "pod install --repo-update")
@property (nonatomic, copy) NSString *commandString;

/// Whether this is a preset (built-in) command
@property (nonatomic, assign, readonly) BOOL isPreset;

/// Sort order for display in lists
@property (nonatomic, assign) NSInteger sortOrder;

#pragma mark - Initialization

/**
 * Creates a new custom command with the given name and command string.
 * @param name The display name for the command.
 * @param commandString The full command string to execute.
 * @return A new THCommand instance, or nil if name or commandString is empty.
 */
- (nullable instancetype)initWithName:(NSString *)name commandString:(NSString *)commandString;

/**
 * Creates a new preset command with the given name and command string.
 * This initializer is intended for internal use when creating preset commands.
 * @param name The display name for the command.
 * @param commandString The full command string to execute.
 * @param isPreset Whether this is a preset command.
 * @return A new THCommand instance, or nil if name or commandString is empty.
 */
- (nullable instancetype)initWithName:(NSString *)name 
                        commandString:(NSString *)commandString 
                             isPreset:(BOOL)isPreset NS_DESIGNATED_INITIALIZER;

/// Unavailable. Use initWithName:commandString: instead.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Comparison

/**
 * Checks if two commands are equal based on their identifier.
 * @param object The object to compare with.
 * @return YES if the commands have the same identifier.
 */
- (BOOL)isEqual:(nullable id)object;

/// Hash based on identifier for use in collections.
- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
