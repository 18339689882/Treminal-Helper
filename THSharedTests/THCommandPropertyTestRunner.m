//
//  THCommandPropertyTestRunner.m
//  THSharedTests
//
//  Command-line test runner for THCommand property tests.
//  Compile and run: clang -framework Foundation -fobjc-arc THShared/*.m THSharedTests/THCommandPropertyTestRunner.m -o test_runner && ./test_runner
//
//  **Feature: terminal-helper, Property 2: Command Data Integrity**
//  **Validates: Requirements 3.2, 4.3**
//

#import <Foundation/Foundation.h>
#import "../THShared/THCommand.h"

/// Number of iterations for property-based tests
static const NSInteger kPropertyTestIterations = 100;

#pragma mark - Test Result Tracking

static NSInteger totalTests = 0;
static NSInteger passedTests = 0;
static NSInteger failedTests = 0;

void logTestStart(NSString *testName) {
    printf("Running: %s\n", [testName UTF8String]);
    totalTests++;
}

void logTestPass(NSString *testName) {
    printf("✓ PASS: %s\n", [testName UTF8String]);
    passedTests++;
}

void logTestFail(NSString *testName, NSString *reason) {
    printf("✗ FAIL: %s\n  Reason: %s\n", [testName UTF8String], [reason UTF8String]);
    failedTests++;
}

#pragma mark - Helper Methods for Random Data Generation

NSString *randomCommandStringWithLength(NSUInteger length) {
    NSString *chars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_=+[]{}|;':\",./<>?!@#$%^&*()~`\\";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        NSUInteger index = arc4random_uniform((uint32_t)chars.length);
        [result appendFormat:@"%C", [chars characterAtIndex:index]];
    }
    
    return [result copy];
}

NSString *randomNameWithLength(NSUInteger length) {
    NSString *chars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        NSUInteger index = arc4random_uniform((uint32_t)chars.length);
        [result appendFormat:@"%C", [chars characterAtIndex:index]];
    }
    
    return [result copy];
}

NSString *randomRealisticCommandString(void) {
    NSArray *commands = @[
        @"pod install",
        @"pod install --repo-update",
        @"pod update",
        @"npm install",
        @"npm run build",
        @"yarn install",
        @"git pull origin main",
        @"swift build",
        @"xcodebuild -scheme MyApp",
        @"carthage update --platform iOS",
        @"bundle exec fastlane beta",
        @"echo \"Hello World\"",
        @"ls -la | grep '.swift'",
        @"find . -name '*.m' -exec wc -l {} \\;",
        @"cd ~/Projects && pod install",
        @"export PATH=$PATH:/usr/local/bin && pod install"
    ];
    
    return commands[arc4random_uniform((uint32_t)commands.count)];
}

#pragma mark - Property 2: Command Data Integrity Tests

/**
 * Property 2: Command Data Integrity - Direct Access
 */
BOOL testProperty2_DirectAccess(void) {
    NSString *testName = @"Property2_CommandDataIntegrity_DirectAccess";
    logTestStart(testName);
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            NSUInteger length = arc4random_uniform(200) + 1;
            NSString *originalCommandString = randomCommandStringWithLength(length);
            NSString *name = randomNameWithLength(arc4random_uniform(50) + 1);
            
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            
            if (!command) {
                continue;
            }
            
            if (![command.commandString isEqualToString:originalCommandString]) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Iteration %ld: Command string not preserved. Original: '%@', Got: '%@'",
                    (long)i, originalCommandString, command.commandString]);
                return NO;
            }
        }
    }
    
    logTestPass(testName);
    return YES;
}


/**
 * Property 2: Command Data Integrity - NSSecureCoding Round Trip
 */
BOOL testProperty2_SecureCodingRoundTrip(void) {
    NSString *testName = @"Property2_CommandDataIntegrity_SecureCodingRoundTrip";
    logTestStart(testName);
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            NSUInteger length = arc4random_uniform(200) + 1;
            NSString *originalCommandString = randomCommandStringWithLength(length);
            NSString *originalName = randomNameWithLength(arc4random_uniform(50) + 1);
            
            THCommand *originalCommand = [[THCommand alloc] initWithName:originalName 
                                                           commandString:originalCommandString];
            
            if (!originalCommand) {
                continue;
            }
            
            // Encode
            NSError *encodeError = nil;
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:originalCommand
                                                        requiringSecureCoding:YES
                                                                        error:&encodeError];
            
            if (encodeError || !encodedData) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Iteration %ld: Encoding failed: %@", (long)i, encodeError]);
                return NO;
            }
            
            // Decode
            NSError *decodeError = nil;
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&decodeError];
            
            if (decodeError || !decodedCommand) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Iteration %ld: Decoding failed: %@", (long)i, decodeError]);
                return NO;
            }
            
            if (![decodedCommand.commandString isEqualToString:originalCommandString]) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Iteration %ld: Command string not preserved through encode/decode. Original: '%@', Got: '%@'",
                    (long)i, originalCommandString, decodedCommand.commandString]);
                return NO;
            }
            
            if (![decodedCommand.name isEqualToString:originalName]) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Iteration %ld: Name not preserved through encode/decode. Original: '%@', Got: '%@'",
                    (long)i, originalName, decodedCommand.name]);
                return NO;
            }
        }
    }
    
    logTestPass(testName);
    return YES;
}

/**
 * Property 2: Command Data Integrity - Special Characters
 */
BOOL testProperty2_SpecialCharacters(void) {
    NSString *testName = @"Property2_CommandDataIntegrity_SpecialCharacters";
    logTestStart(testName);
    
    NSArray *specialCommandStrings = @[
        @"echo \"Hello World\"",
        @"echo 'Single quotes'",
        @"ls -la | grep '.swift'",
        @"cat file.txt > output.txt",
        @"cat file.txt >> output.txt",
        @"command1 && command2",
        @"command1 || command2",
        @"$(pwd)/script.sh",
        @"${HOME}/bin/tool",
        @"find . -name \"*.m\" -exec wc -l {} \\;",
        @"awk '{print $1}'",
        @"sed 's/old/new/g'",
        @"curl -H \"Authorization: Bearer $TOKEN\" https://api.example.com",
        @"echo $PATH",
        @"export VAR=\"value with spaces\"",
        @"command `subcommand`",
        @"array=(one two three)",
        @"test -f file && echo exists",
        @"[[ -d dir ]] && cd dir",
        @"command &",
        @"nohup command &",
        @"command 2>&1",
        @"command < input.txt",
        @"path/to/script\\ with\\ spaces.sh",
        @"echo -e \"line1\\nline2\"",
        @"printf '%s\\n' \"$var\"",
        @"command; another_command",
        @"(subshell command)",
        @"{ grouped; commands; }",
        @"command #comment",
        @"~/.config/tool",
        @"command --option=\"value\"",
        @"command --option='value'",
        @"command -o=value",
        @"unicode: 你好世界 🚀 émojis",
        @"tab\there\tand\tthere",
        @"newline\nembedded"
    ];
    
    for (NSString *originalCommandString in specialCommandStrings) {
        @autoreleasepool {
            NSString *name = @"Test Command";
            
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            if (!command) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Command creation failed for: %@", originalCommandString]);
                return NO;
            }
            
            if (![command.commandString isEqualToString:originalCommandString]) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Command string not preserved. Original: '%@', Got: '%@'",
                    originalCommandString, command.commandString]);
                return NO;
            }
            
            // Round trip check
            NSError *error = nil;
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:command
                                                        requiringSecureCoding:YES
                                                                        error:&error];
            if (!encodedData) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Encoding failed for: %@", originalCommandString]);
                return NO;
            }
            
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&error];
            if (!decodedCommand) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Decoding failed for: %@", originalCommandString]);
                return NO;
            }
            
            if (![decodedCommand.commandString isEqualToString:originalCommandString]) {
                logTestFail(testName, [NSString stringWithFormat:
                    @"Command string not preserved through encode/decode. Original: '%@', Got: '%@'",
                    originalCommandString, decodedCommand.commandString]);
                return NO;
            }
        }
    }
    
    logTestPass(testName);
    return YES;
}

#pragma mark - Main Function

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("=== THCommand Property-Based Tests ===\n");
        printf("Running Property 2: Command Data Integrity tests...\n\n");
        
        // Run all Property 2 tests
        BOOL allPassed = YES;
        
        allPassed &= testProperty2_DirectAccess();
        allPassed &= testProperty2_SecureCodingRoundTrip();
        allPassed &= testProperty2_SpecialCharacters();
        
        // Print summary
        printf("\n=== Test Summary ===\n");
        printf("Total tests: %ld\n", (long)totalTests);
        printf("Passed: %ld\n", (long)passedTests);
        printf("Failed: %ld\n", (long)failedTests);
        
        if (allPassed) {
            printf("✓ All Property 2 tests PASSED!\n");
            return 0;
        } else {
            printf("✗ Some tests FAILED!\n");
            return 1;
        }
    }
}
