//
//  THCommandManager.h
//  THShared
//
//  Command management singleton for Terminal Helper.
//  Handles CRUD operations and persistence of commands.
//

#import <Foundation/Foundation.h>
#import "THCommand.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * THCommandManager is a singleton that manages all terminal commands.
 * It handles both preset and custom commands, provides CRUD operations,
 * and persists data using App Group UserDefaults.
 */
@interface THCommandManager : NSObject

#pragma mark - Properties

/// All commands (preset + custom), sorted by sortOrder
@property (nonatomic, readonly) NSArray<THCommand *> *allCommands;

/// Only preset commands
@property (nonatomic, readonly) NSArray<THCommand *> *presetCommands;

/// Only custom (user-defined) commands
@property (nonatomic, readonly) NSArray<THCommand *> *customCommands;

#pragma mark - Singleton

/**
 * Returns the shared command manager instance.
 * @return The singleton THCommandManager instance.
 */
+ (instancetype)sharedManager;

/// Unavailable. Use sharedManager instead.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Command Operations

/**
 * Adds a new command to the manager.
 * The command will be persisted to UserDefaults.
 * @param command The command to add. Must not be nil.
 */
- (void)addCommand:(THCommand *)command;

/**
 * Updates an existing command in the manager.
 * The command is identified by its identifier property.
 * @param command The updated command. Must not be nil and must exist in the manager.
 */
- (void)updateCommand:(THCommand *)command;

/**
 * Deletes a command from the manager.
 * Preset commands cannot be deleted.
 * @param command The command to delete. Must not be nil.
 */
- (void)deleteCommand:(THCommand *)command;

/**
 * Reorders all commands according to the provided array.
 * Updates the sortOrder property of each command.
 * @param commands Array of commands in the desired order.
 */
- (void)reorderCommands:(NSArray<THCommand *> *)commands;

/**
 * Finds a command by its identifier.
 * @param identifier The unique identifier to search for.
 * @return The command with the matching identifier, or nil if not found.
 */
- (nullable THCommand *)commandWithIdentifier:(NSString *)identifier;

#pragma mark - Persistence

/**
 * Manually saves all commands to persistent storage.
 * This is called automatically after add/update/delete operations.
 */
- (void)saveCommands;

/**
 * Manually loads commands from persistent storage.
 * This is called automatically during initialization.
 */
- (void)loadCommands;

@end

NS_ASSUME_NONNULL_END