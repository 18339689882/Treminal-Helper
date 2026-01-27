//
//  THCommandExecutor.h
//  THShared
//
//  Command execution engine for Terminal Helper.
//  Handles both background and Terminal.app execution modes.
//

#import <Foundation/Foundation.h>
#import "THConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class THCommand;

/**
 * Progress callback for command execution.
 * @param output Current output from the command (incremental)
 * @param isError Whether the output is from stderr
 */
typedef void (^THExecutionProgressHandler)(NSString *output, BOOL isError);

/**
 * Completion callback for command execution.
 * @param success Whether the command executed successfully (exit code 0)
 * @param exitCode The exit code from the command
 * @param output Complete stdout output from the command
 * @param error Complete stderr output from the command, or execution error message
 */
typedef void (^THExecutionCompletionHandler)(BOOL success, int exitCode, NSString * _Nullable output, NSString * _Nullable error);

/**
 * THCommandExecutor handles command execution in different modes.
 * It supports both background execution and Terminal.app execution.
 */
@interface THCommandExecutor : NSObject

#pragma mark - Properties

/// Whether a command is currently executing
@property (nonatomic, assign, readonly) BOOL isExecuting;

/// The currently executing command (nil if not executing)
@property (nonatomic, strong, readonly, nullable) THCommand *currentCommand;

/// The current execution directory (nil if not executing)
@property (nonatomic, strong, readonly, nullable) NSString *currentDirectory;

#pragma mark - Execution Methods

/**
 * Executes a command in the specified directory with the given execution mode.
 * @param command The command to execute
 * @param directory The working directory for execution (nil for current directory)
 * @param mode The execution mode (background or Terminal.app)
 * @param progress Progress callback for incremental output (background mode only)
 * @param completion Completion callback when execution finishes
 */
- (void)executeCommand:(THCommand *)command
           inDirectory:(nullable NSString *)directory
                  mode:(THExecutionMode)mode
              progress:(nullable THExecutionProgressHandler)progress
            completion:(nullable THExecutionCompletionHandler)completion;

/**
 * Executes a command using the default execution mode from settings.
 * @param command The command to execute
 * @param directory The working directory for execution (nil for current directory)
 * @param progress Progress callback for incremental output (background mode only)
 * @param completion Completion callback when execution finishes
 */
- (void)executeCommand:(THCommand *)command
           inDirectory:(nullable NSString *)directory
              progress:(nullable THExecutionProgressHandler)progress
            completion:(nullable THExecutionCompletionHandler)completion;

#pragma mark - Background Execution

/**
 * Executes a command in background mode (silent execution with output capture).
 * @param command The command to execute
 * @param directory The working directory for execution (nil for current directory)
 * @param progress Progress callback for incremental output
 * @param completion Completion callback when execution finishes
 */
- (void)executeCommandInBackground:(THCommand *)command
                       inDirectory:(nullable NSString *)directory
                          progress:(nullable THExecutionProgressHandler)progress
                        completion:(nullable THExecutionCompletionHandler)completion;

#pragma mark - Terminal.app Execution

/**
 * Executes a command by opening Terminal.app.
 * @param command The command to execute
 * @param directory The working directory for execution (nil for current directory)
 * @param completion Completion callback when Terminal.app is opened (not when command finishes)
 */
- (void)executeCommandInTerminal:(THCommand *)command
                     inDirectory:(nullable NSString *)directory
                      completion:(nullable THExecutionCompletionHandler)completion;

#pragma mark - Execution Control

/**
 * Cancels the currently executing command (background mode only).
 * @return YES if a command was cancelled, NO if no command was executing
 */
- (BOOL)cancelCurrentExecution;

#pragma mark - Utility Methods

/**
 * Validates that a command can be executed.
 * @param command The command to validate
 * @param directory The target directory (nil for current directory)
 * @param error Error pointer for validation errors
 * @return YES if command is valid, NO otherwise
 */
- (BOOL)validateCommand:(THCommand *)command
            inDirectory:(nullable NSString *)directory
                  error:(NSError **)error;

/**
 * Prepares a command string for execution by expanding variables and paths.
 * @param commandString The raw command string
 * @param workingDirectory The working directory for execution
 * @return The prepared command string
 */
- (NSString *)prepareCommandString:(NSString *)commandString
                  workingDirectory:(nullable NSString *)workingDirectory;

@end

NS_ASSUME_NONNULL_END