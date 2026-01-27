//
//  THCommandPropertyTests.m
//  THSharedTests
//
//  Property-based tests for THCommand data integrity.
//  **Feature: terminal-helper, Property 2: Command Data Integrity**
//  **Validates: Requirements 3.2, 4.3**
//

#import <XCTest/XCTest.h>
#import "THCommand.h"

/// Number of iterations for property-based tests
static const NSInteger kPropertyTestIterations = 100;

@interface THCommandPropertyTests : XCTestCase
@end

@implementation THCommandPropertyTests

#pragma mark - Helper Methods for Random Data Generation

/// Generates a random string with various characters including special chars, spaces, and unicode
- (NSString *)randomCommandStringWithLength:(NSUInteger)length {
    // Include various character types that might appear in command strings
    NSString *chars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_=+[]{}|;':\",./<>?!@#$%^&*()~`\\";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        NSUInteger index = arc4random_uniform((uint32_t)chars.length);
        [result appendFormat:@"%C", [chars characterAtIndex:index]];
    }
    
    return [result copy];
}

/// Generates a random non-empty name string
- (NSString *)randomNameWithLength:(NSUInteger)length {
    NSString *chars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        NSUInteger index = arc4random_uniform((uint32_t)chars.length);
        [result appendFormat:@"%C", [chars characterAtIndex:index]];
    }
    
    return [result copy];
}

/// Generates a realistic command string with parameters
- (NSString *)randomRealisticCommandString {
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
 * Property 2: Command Data Integrity
 * 
 * *For any* command string (including those with parameters, special characters, or spaces),
 * when stored and retrieved from THCommand, the commandString property SHALL be exactly 
 * equal to the original input string.
 *
 * This test verifies that command strings are preserved exactly through:
 * 1. Direct property access after initialization
 * 2. NSSecureCoding encode/decode cycle
 */
- (void)testProperty2_CommandDataIntegrity_DirectAccess {
    // **Feature: terminal-helper, Property 2: Command Data Integrity**
    // **Validates: Requirements 3.2, 4.3**
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            // Generate random command string with varying lengths (1-200 chars)
            NSUInteger length = arc4random_uniform(200) + 1;
            NSString *originalCommandString = [self randomCommandStringWithLength:length];
            NSString *name = [self randomNameWithLength:arc4random_uniform(50) + 1];
            
            // Create command
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            
            // Skip if command creation failed (empty strings are rejected)
            if (!command) {
                continue;
            }
            
            // Property: commandString must be exactly equal to original
            XCTAssertEqualObjects(command.commandString, originalCommandString,
                @"Iteration %ld: Command string should be preserved exactly. Original: '%@', Got: '%@'",
                (long)i, originalCommandString, command.commandString);
        }
    }
}

/**
 * Property 2: Command Data Integrity - NSSecureCoding Round Trip
 * 
 * *For any* command string, encoding with NSKeyedArchiver and decoding with NSKeyedUnarchiver
 * SHALL produce a command with exactly the same commandString.
 */
- (void)testProperty2_CommandDataIntegrity_SecureCodingRoundTrip {
    // **Feature: terminal-helper, Property 2: Command Data Integrity**
    // **Validates: Requirements 3.2, 4.3**
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            // Generate random command string
            NSUInteger length = arc4random_uniform(200) + 1;
            NSString *originalCommandString = [self randomCommandStringWithLength:length];
            NSString *originalName = [self randomNameWithLength:arc4random_uniform(50) + 1];
            
            // Create original command
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
            
            XCTAssertNil(encodeError, @"Iteration %ld: Encoding should not fail: %@", 
                (long)i, encodeError);
            XCTAssertNotNil(encodedData, @"Iteration %ld: Encoded data should not be nil", (long)i);
            
            // Decode
            NSError *decodeError = nil;
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&decodeError];
            
            XCTAssertNil(decodeError, @"Iteration %ld: Decoding should not fail: %@", 
                (long)i, decodeError);
            XCTAssertNotNil(decodedCommand, @"Iteration %ld: Decoded command should not be nil", (long)i);
            
            // Property: commandString must be exactly equal after round trip
            XCTAssertEqualObjects(decodedCommand.commandString, originalCommandString,
                @"Iteration %ld: Command string should be preserved through encode/decode. Original: '%@', Got: '%@'",
                (long)i, originalCommandString, decodedCommand.commandString);
            
            // Also verify name is preserved
            XCTAssertEqualObjects(decodedCommand.name, originalName,
                @"Iteration %ld: Name should be preserved through encode/decode. Original: '%@', Got: '%@'",
                (long)i, originalName, decodedCommand.name);
        }
    }
}

/**
 * Property 2: Command Data Integrity - Special Characters
 * 
 * *For any* command string containing special characters (quotes, pipes, redirects, etc.),
 * the commandString SHALL be preserved exactly.
 */
- (void)testProperty2_CommandDataIntegrity_SpecialCharacters {
    // **Feature: terminal-helper, Property 2: Command Data Integrity**
    // **Validates: Requirements 3.2, 4.3**
    
    // Test specific special character patterns that are common in shell commands
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
        @"command <<EOF\nline1\nline2\nEOF",
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
            
            // Create command
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            XCTAssertNotNil(command, @"Command creation should succeed for: %@", originalCommandString);
            
            // Direct access check
            XCTAssertEqualObjects(command.commandString, originalCommandString,
                @"Command string should be preserved exactly. Original: '%@', Got: '%@'",
                originalCommandString, command.commandString);
            
            // Round trip check
            NSError *error = nil;
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:command
                                                        requiringSecureCoding:YES
                                                                        error:&error];
            XCTAssertNotNil(encodedData, @"Encoding should succeed for: %@", originalCommandString);
            
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&error];
            XCTAssertNotNil(decodedCommand, @"Decoding should succeed for: %@", originalCommandString);
            
            XCTAssertEqualObjects(decodedCommand.commandString, originalCommandString,
                @"Command string should be preserved through encode/decode. Original: '%@', Got: '%@'",
                originalCommandString, decodedCommand.commandString);
        }
    }
}

/**
 * Property 2: Command Data Integrity - Realistic Commands
 * 
 * *For any* realistic command string (pod install, npm, git, etc.),
 * the commandString SHALL be preserved exactly through storage and retrieval.
 */
- (void)testProperty2_CommandDataIntegrity_RealisticCommands {
    // **Feature: terminal-helper, Property 2: Command Data Integrity**
    // **Validates: Requirements 3.2, 4.3**
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            NSString *originalCommandString = [self randomRealisticCommandString];
            NSString *name = [self randomNameWithLength:arc4random_uniform(30) + 1];
            
            // Create command
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            XCTAssertNotNil(command, @"Iteration %ld: Command creation should succeed", (long)i);
            
            // Direct access check
            XCTAssertEqualObjects(command.commandString, originalCommandString,
                @"Iteration %ld: Command string should be preserved exactly", (long)i);
            
            // Round trip check
            NSError *error = nil;
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:command
                                                        requiringSecureCoding:YES
                                                                        error:&error];
            
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&error];
            
            XCTAssertEqualObjects(decodedCommand.commandString, originalCommandString,
                @"Iteration %ld: Command string should be preserved through encode/decode", (long)i);
        }
    }
}

/**
 * Property 2: Command Data Integrity - Parameters Preservation
 * 
 * *For any* command with parameters (flags, options, arguments),
 * the full command string including all parameters SHALL be preserved exactly.
 */
- (void)testProperty2_CommandDataIntegrity_ParametersPreservation {
    // **Feature: terminal-helper, Property 2: Command Data Integrity**
    // **Validates: Requirements 3.2, 4.3**
    
    // Generate commands with various parameter patterns
    NSArray *baseCommands = @[@"pod", @"npm", @"git", @"xcodebuild", @"swift", @"cargo"];
    NSArray *flags = @[@"-v", @"--verbose", @"-f", @"--force", @"-q", @"--quiet"];
    NSArray *options = @[@"--output=file.txt", @"--config=/path/to/config", @"--name=\"My App\""];
    NSArray *arguments = @[@"install", @"build", @"test", @"run", @"update"];
    
    for (NSInteger i = 0; i < kPropertyTestIterations; i++) {
        @autoreleasepool {
            // Build a random command with parameters
            NSMutableString *commandBuilder = [NSMutableString string];
            
            // Add base command
            [commandBuilder appendString:baseCommands[arc4random_uniform((uint32_t)baseCommands.count)]];
            
            // Add random argument
            [commandBuilder appendFormat:@" %@", arguments[arc4random_uniform((uint32_t)arguments.count)]];
            
            // Add 0-3 random flags
            NSUInteger flagCount = arc4random_uniform(4);
            for (NSUInteger j = 0; j < flagCount; j++) {
                [commandBuilder appendFormat:@" %@", flags[arc4random_uniform((uint32_t)flags.count)]];
            }
            
            // Add 0-2 random options
            NSUInteger optionCount = arc4random_uniform(3);
            for (NSUInteger j = 0; j < optionCount; j++) {
                [commandBuilder appendFormat:@" %@", options[arc4random_uniform((uint32_t)options.count)]];
            }
            
            NSString *originalCommandString = [commandBuilder copy];
            NSString *name = @"Test Command";
            
            // Create command
            THCommand *command = [[THCommand alloc] initWithName:name commandString:originalCommandString];
            XCTAssertNotNil(command, @"Iteration %ld: Command creation should succeed", (long)i);
            
            // Property: full command with parameters must be preserved
            XCTAssertEqualObjects(command.commandString, originalCommandString,
                @"Iteration %ld: Full command with parameters should be preserved. Original: '%@', Got: '%@'",
                (long)i, originalCommandString, command.commandString);
            
            // Round trip check
            NSError *error = nil;
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:command
                                                        requiringSecureCoding:YES
                                                                        error:&error];
            
            THCommand *decodedCommand = [NSKeyedUnarchiver unarchivedObjectOfClass:[THCommand class]
                                                                          fromData:encodedData
                                                                             error:&error];
            
            XCTAssertEqualObjects(decodedCommand.commandString, originalCommandString,
                @"Iteration %ld: Full command with parameters should be preserved through encode/decode",
                (long)i);
        }
    }
}

@end
