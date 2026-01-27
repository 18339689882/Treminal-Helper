//
//  THCommandExecutor.m
//  THShared
//
//  Implementation of the command execution engine.
//

#import "THCommandExecutor.h"
#import "THCommand.h"
#import "THSettingsManager.h"
#import <AppKit/AppKit.h>

// Error codes
typedef NS_ENUM(NSInteger, THCommandExecutorErrorCode) {
    THCommandExecutorErrorInvalidCommand = 1000,
    THCommandExecutorErrorInvalidDirectory = 1001,
    THCommandExecutorErrorExecutionFailed = 1002,
    THCommandExecutorErrorTerminalNotFound = 1003,
    THCommandExecutorErrorAlreadyExecuting = 1004
};

@interface THCommandExecutor ()

/// Current NSTask for background execution
@property (nonatomic, strong, nullable) NSTask *currentTask;

/// Current execution state
@property (nonatomic, assign, readwrite) BOOL isExecuting;
@property (nonatomic, strong, readwrite, nullable) THCommand *currentCommand;
@property (nonatomic, strong, readwrite, nullable) NSString *currentDirectory;

/// Completion handler for current execution
@property (nonatomic, copy, nullable) THExecutionCompletionHandler currentCompletion;

@end

@implementation THCommandExecutor

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _isExecuting = NO;
        _currentCommand = nil;
        _currentDirectory = nil;
        _currentTask = nil;
        _currentCompletion = nil;
    }
    return self;
}

#pragma mark - Execution Methods

- (void)executeCommand:(THCommand *)command
           inDirectory:(nullable NSString *)directory
                  mode:(THExecutionMode)mode
              progress:(nullable THExecutionProgressHandler)progress
            completion:(nullable THExecutionCompletionHandler)completion {
    
    // Validate command and directory
    NSError *validationError = nil;
    if (![self validateCommand:command inDirectory:directory error:&validationError]) {
        if (completion) {
            completion(NO, -1, nil, validationError.localizedDescription);
        }
        return;
    }
    
    // Check if already executing
    if (self.isExecuting) {
        NSError *error = [NSError errorWithDomain:THCommandExecutorErrorDomain
                                             code:THCommandExecutorErrorAlreadyExecuting
                                         userInfo:@{NSLocalizedDescriptionKey: @"Another command is already executing"}];
        if (completion) {
            completion(NO, -1, nil, error.localizedDescription);
        }
        return;
    }
    
    // Execute based on mode
    switch (mode) {
        case THExecutionModeBackground:
            [self executeCommandInBackground:command inDirectory:directory progress:progress completion:completion];
            break;
            
        case THExecutionModeTerminal:
            [self executeCommandInTerminal:command inDirectory:directory completion:completion];
            break;
            
        default:
            if (completion) {
                completion(NO, -1, nil, @"Invalid execution mode");
            }
            break;
    }
}

- (void)executeCommand:(THCommand *)command
           inDirectory:(nullable NSString *)directory
              progress:(nullable THExecutionProgressHandler)progress
            completion:(nullable THExecutionCompletionHandler)completion {
    
    THExecutionMode defaultMode = [THSettingsManager sharedManager].defaultExecutionMode;
    [self executeCommand:command inDirectory:directory mode:defaultMode progress:progress completion:completion];
}

#pragma mark - Background Execution

- (void)executeCommandInBackground:(THCommand *)command
                       inDirectory:(nullable NSString *)directory
                          progress:(nullable THExecutionProgressHandler)progress
                        completion:(nullable THExecutionCompletionHandler)completion {
    
    // Set execution state
    self.isExecuting = YES;
    self.currentCommand = command;
    self.currentDirectory = directory;
    self.currentCompletion = completion;
    
    // Prepare command string
    NSString *preparedCommand = [self prepareCommandString:command.commandString workingDirectory:directory];
    
    NSLog(@"Executing command in background: %@ (directory: %@)", preparedCommand, directory ?: @"current");
    
    // Create task
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", preparedCommand];
    
    // Set working directory if specified
    if (directory && directory.length > 0) {
        // Expand tilde and resolve path
        NSString *expandedDirectory = [directory stringByExpandingTildeInPath];
        task.currentDirectoryPath = expandedDirectory;
    }
    
    // Set up pipes for output capture
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    
    // Store task reference
    self.currentTask = task;
    
    // Set up output monitoring for progress callbacks
    NSMutableString *outputBuffer = [NSMutableString string];
    NSMutableString *errorBuffer = [NSMutableString string];
    
    // Monitor stdout
    NSFileHandle *outputHandle = [outputPipe fileHandleForReading];
    outputHandle.readabilityHandler = ^(NSFileHandle *handle) {
        NSData *data = [handle availableData];
        if (data.length > 0) {
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (output) {
                [outputBuffer appendString:output];
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progress(output, NO);
                    });
                }
            }
        }
    };
    
    // Monitor stderr
    NSFileHandle *errorHandle = [errorPipe fileHandleForReading];
    errorHandle.readabilityHandler = ^(NSFileHandle *handle) {
        NSData *data = [handle availableData];
        if (data.length > 0) {
            NSString *error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (error) {
                [errorBuffer appendString:error];
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progress(error, YES);
                    });
                }
            }
        }
    };
    
    // Set up termination handler
    task.terminationHandler = ^(NSTask *terminatedTask) {
        // Stop monitoring output
        outputHandle.readabilityHandler = nil;
        errorHandle.readabilityHandler = nil;
        
        // Read any remaining output
        NSData *remainingOutput = [outputHandle readDataToEndOfFile];
        if (remainingOutput.length > 0) {
            NSString *output = [[NSString alloc] initWithData:remainingOutput encoding:NSUTF8StringEncoding];
            if (output) {
                [outputBuffer appendString:output];
            }
        }
        
        NSData *remainingError = [errorHandle readDataToEndOfFile];
        if (remainingError.length > 0) {
            NSString *error = [[NSString alloc] initWithData:remainingError encoding:NSUTF8StringEncoding];
            if (error) {
                [errorBuffer appendString:error];
            }
        }
        
        // Get execution results
        int exitCode = terminatedTask.terminationStatus;
        BOOL success = (exitCode == 0);
        
        NSLog(@"Command execution completed: success=%@, exitCode=%d", success ? @"YES" : @"NO", exitCode);
        
        // Reset execution state
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isExecuting = NO;
            self.currentCommand = nil;
            self.currentDirectory = nil;
            self.currentTask = nil;
            
            // Call completion handler
            if (self.currentCompletion) {
                self.currentCompletion(success, exitCode, outputBuffer.copy, errorBuffer.length > 0 ? errorBuffer.copy : nil);
                self.currentCompletion = nil;
            }
        });
    };
    
    // Launch task
    @try {
        [task launch];
        NSLog(@"Task launched successfully");
    } @catch (NSException *exception) {
        NSLog(@"Failed to launch task: %@", exception.reason);
        
        // Reset state
        self.isExecuting = NO;
        self.currentCommand = nil;
        self.currentDirectory = nil;
        self.currentTask = nil;
        
        if (completion) {
            completion(NO, -1, nil, exception.reason ?: @"Failed to launch task");
        }
        self.currentCompletion = nil;
    }
}

#pragma mark - Terminal.app Execution

- (void)executeCommandInTerminal:(THCommand *)command
                     inDirectory:(nullable NSString *)directory
                      completion:(nullable THExecutionCompletionHandler)completion {
    
    // Prepare command string
    NSString *preparedCommand = [self prepareCommandString:command.commandString workingDirectory:directory];
    
    NSLog(@"Executing command in Terminal.app: %@ (directory: %@)", preparedCommand, directory ?: @"current");
    
    // Build AppleScript to open Terminal and execute command
    NSMutableString *appleScript = [NSMutableString string];
    [appleScript appendString:@"tell application \"Terminal\"\n"];
    [appleScript appendString:@"  activate\n"];
    
    // If working directory is specified, cd to it first
    if (directory && directory.length > 0) {
        NSString *expandedDirectory = [directory stringByExpandingTildeInPath];
        NSString *cdCommand = [NSString stringWithFormat:@"cd '%@' && %@", expandedDirectory, preparedCommand];
        [appleScript appendFormat:@"  do script \"%@\"\n", [self escapeAppleScriptString:cdCommand]];
    } else {
        [appleScript appendFormat:@"  do script \"%@\"\n", [self escapeAppleScriptString:preparedCommand]];
    }
    
    [appleScript appendString:@"end tell"];
    
    NSLog(@"AppleScript: %@", appleScript);
    
    // Execute AppleScript
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:appleScript];
    NSDictionary *errorInfo = nil;
    [script executeAndReturnError:&errorInfo];
    
    if (errorInfo) {
        NSLog(@"AppleScript execution failed: %@", errorInfo);
        if (completion) {
            NSString *errorMessage = errorInfo[NSAppleScriptErrorMessage] ?: @"Failed to open Terminal.app";
            completion(NO, -1, nil, errorMessage);
        }
        return;
    }
    
    NSLog(@"Command sent to Terminal.app successfully");
    
    // For Terminal.app execution, we consider it successful if we managed to open Terminal
    // We can't easily get the actual command exit code
    if (completion) {
        completion(YES, 0, @"Command sent to Terminal.app", nil);
    }
}

#pragma mark - Execution Control

- (BOOL)cancelCurrentExecution {
    if (!self.isExecuting || !self.currentTask) {
        return NO;
    }
    
    NSLog(@"Cancelling current command execution");
    
    // Terminate the task
    [self.currentTask terminate];
    
    // Reset state (termination handler will also reset, but we do it here for immediate effect)
    self.isExecuting = NO;
    self.currentCommand = nil;
    self.currentDirectory = nil;
    self.currentTask = nil;
    
    // Call completion with cancellation
    if (self.currentCompletion) {
        self.currentCompletion(NO, -1, nil, @"Command execution was cancelled");
        self.currentCompletion = nil;
    }
    
    return YES;
}

#pragma mark - Utility Methods

- (BOOL)validateCommand:(THCommand *)command
            inDirectory:(nullable NSString *)directory
                  error:(NSError **)error {
    
    if (!command) {
        if (error) {
            *error = [NSError errorWithDomain:THCommandExecutorErrorDomain
                                         code:THCommandExecutorErrorInvalidCommand
                                     userInfo:@{NSLocalizedDescriptionKey: @"Command cannot be nil"}];
        }
        return NO;
    }
    
    if (!command.commandString || command.commandString.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:THCommandExecutorErrorDomain
                                         code:THCommandExecutorErrorInvalidCommand
                                     userInfo:@{NSLocalizedDescriptionKey: @"Command string cannot be empty"}];
        }
        return NO;
    }
    
    // Validate directory if specified
    if (directory && directory.length > 0) {
        NSString *expandedDirectory = [directory stringByExpandingTildeInPath];
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:expandedDirectory isDirectory:&isDirectory];
        
        if (!exists || !isDirectory) {
            if (error) {
                *error = [NSError errorWithDomain:THCommandExecutorErrorDomain
                                             code:THCommandExecutorErrorInvalidDirectory
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Directory does not exist: %@", expandedDirectory]}];
            }
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)prepareCommandString:(NSString *)commandString
                  workingDirectory:(nullable NSString *)workingDirectory {
    
    NSString *prepared = commandString;
    
    // Expand ~ to home directory
    prepared = [prepared stringByExpandingTildeInPath];
    
    // TODO: Add more variable expansion as needed
    // For example: $HOME, $USER, etc.
    
    return prepared;
}

- (NSString *)escapeAppleScriptString:(NSString *)string {
    // Escape quotes and backslashes for AppleScript
    NSString *escaped = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    return escaped;
}

@end