//
//  THCommand.m
//  THShared
//
//  Implementation of the THCommand model.
//

#import "THCommand.h"

#pragma mark - NSSecureCoding Keys

static NSString * const kTHCommandIdentifierKey = @"identifier";
static NSString * const kTHCommandNameKey = @"name";
static NSString * const kTHCommandCommandStringKey = @"commandString";
static NSString * const kTHCommandIsPresetKey = @"isPreset";
static NSString * const kTHCommandSortOrderKey = @"sortOrder";

#pragma mark - Preset Command Identifiers

static NSString * const kTHPresetPodInstallIdentifier = @"preset.pod-install";

@interface THCommand ()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, assign, readwrite) BOOL isPreset;

@end

@implementation THCommand

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:kTHCommandIdentifierKey];
    [coder encodeObject:self.name forKey:kTHCommandNameKey];
    [coder encodeObject:self.commandString forKey:kTHCommandCommandStringKey];
    [coder encodeBool:self.isPreset forKey:kTHCommandIsPresetKey];
    [coder encodeInteger:self.sortOrder forKey:kTHCommandSortOrderKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    NSString *name = [coder decodeObjectOfClass:[NSString class] forKey:kTHCommandNameKey];
    NSString *commandString = [coder decodeObjectOfClass:[NSString class] forKey:kTHCommandCommandStringKey];
    BOOL isPreset = [coder decodeBoolForKey:kTHCommandIsPresetKey];
    
    self = [self initWithName:name commandString:commandString isPreset:isPreset];
    if (self) {
        NSString *identifier = [coder decodeObjectOfClass:[NSString class] forKey:kTHCommandIdentifierKey];
        if (identifier) {
            _identifier = [identifier copy];
        }
        _sortOrder = [coder decodeIntegerForKey:kTHCommandSortOrderKey];
    }
    return self;
}

#pragma mark - Preset Commands

+ (instancetype)presetPodInstall {
    THCommand *command = [[THCommand alloc] initWithName:@"Pod Install" 
                                           commandString:@"pod install" 
                                                isPreset:YES];
    if (command) {
        command->_identifier = kTHPresetPodInstallIdentifier;
        command->_sortOrder = 0;
    }
    return command;
}

#pragma mark - Initialization

- (nullable instancetype)initWithName:(NSString *)name commandString:(NSString *)commandString {
    return [self initWithName:name commandString:commandString isPreset:NO];
}

- (nullable instancetype)initWithName:(NSString *)name 
                        commandString:(NSString *)commandString 
                             isPreset:(BOOL)isPreset {
    // Validate inputs - name and commandString must not be empty
    if (!name || name.length == 0) {
        return nil;
    }
    if (!commandString || commandString.length == 0) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _name = [name copy];
        _commandString = [commandString copy];
        _isPreset = isPreset;
        _sortOrder = 0;
    }
    return self;
}

#pragma mark - Comparison

- (BOOL)isEqual:(nullable id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[THCommand class]]) {
        return NO;
    }
    THCommand *other = (THCommand *)object;
    return [self.identifier isEqualToString:other.identifier];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier=%@, name=%@, command=%@, isPreset=%@>",
            NSStringFromClass([self class]),
            self,
            self.identifier,
            self.name,
            self.commandString,
            self.isPreset ? @"YES" : @"NO"];
}

@end
