//
//  THHotkeyManager.m
//  Terminal Helper
//
//  Global hotkey manager implementation using Carbon Event Manager.
//

#import "THHotkeyManager.h"
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

@interface THHotkeyManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, THHotkeyHandler> *hotkeyHandlers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *commandToHotkeyID;
@property (nonatomic, assign) UInt32 nextHotkeyID;

@end

@implementation THHotkeyManager

+ (instancetype)sharedManager {
    static THHotkeyManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hotkeyHandlers = [NSMutableDictionary dictionary];
        _commandToHotkeyID = [NSMutableDictionary dictionary];
        _nextHotkeyID = 1;
        
        // Install event handler for hotkeys
        EventTypeSpec eventType;
        eventType.eventClass = kEventClassKeyboard;
        eventType.eventKind = kEventHotKeyPressed;
        InstallApplicationEventHandler(&HotkeyHandler, 1, &eventType, (__bridge void *)self, NULL);
    }
    return self;
}

- (BOOL)registerHotkeyForCommand:(id)command
                         keyCode:(unsigned short)keyCode
                   modifierFlags:(NSUInteger)modifierFlags
                         handler:(THHotkeyHandler)handler {
    if (!command || !handler) {
        return NO;
    }
    
    // Convert NSEvent modifier flags to Carbon modifiers
    UInt32 carbonModifiers = 0;
    if (modifierFlags & NSEventModifierFlagCommand) {
        carbonModifiers |= cmdKey;
    }
    if (modifierFlags & NSEventModifierFlagShift) {
        carbonModifiers |= shiftKey;
    }
    if (modifierFlags & NSEventModifierFlagOption) {
        carbonModifiers |= optionKey;
    }
    if (modifierFlags & NSEventModifierFlagControl) {
        carbonModifiers |= controlKey;
    }
    
    // Generate unique hotkey ID
    UInt32 hotkeyID = self.nextHotkeyID++;
    
    // Register the hotkey with Carbon
    EventHotKeyID hotkeyIDStruct;
    hotkeyIDStruct.signature = 'THCM'; // Terminal Helper Command
    hotkeyIDStruct.id = hotkeyID;
    
    EventHotKeyRef hotkeyRef;
    OSStatus status = RegisterEventHotKey(keyCode, carbonModifiers, hotkeyIDStruct,
                                         GetApplicationEventTarget(), 0, &hotkeyRef);
    
    if (status != noErr) {
        NSLog(@"Failed to register hotkey: %d", (int)status);
        return NO;
    }
    
    // Store the handler
    self.hotkeyHandlers[@(hotkeyID)] = handler;
    
    // Store the mapping from command to hotkey ID
    NSString *commandKey = [NSString stringWithFormat:@"%p", command];
    self.commandToHotkeyID[commandKey] = @(hotkeyID);
    
    return YES;
}

- (void)unregisterHotkeyForCommand:(id)command {
    if (!command) {
        return;
    }
    
    NSString *commandKey = [NSString stringWithFormat:@"%p", command];
    NSNumber *hotkeyID = self.commandToHotkeyID[commandKey];
    
    if (hotkeyID) {
        // Remove the handler
        [self.hotkeyHandlers removeObjectForKey:hotkeyID];
        [self.commandToHotkeyID removeObjectForKey:commandKey];
        
        // Note: Carbon doesn't provide an easy way to unregister individual hotkeys
        // We would need to keep track of EventHotKeyRef to unregister
        // For now, we just remove from our tracking dictionaries
    }
}

- (void)unregisterAllHotkeys {
    [self.hotkeyHandlers removeAllObjects];
    [self.commandToHotkeyID removeAllObjects];
}

#pragma mark - Carbon Event Handler

OSStatus HotkeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData) {
    @autoreleasepool {
        THHotkeyManager *manager = (__bridge THHotkeyManager *)userData;
        
        EventHotKeyID hotkeyID;
        GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL,
                         sizeof(hotkeyID), NULL, &hotkeyID);
        
        // Find and call the handler
        THHotkeyHandler handler = manager.hotkeyHandlers[@(hotkeyID.id)];
        if (handler) {
            // We don't have the command object here, so we pass nil
            // The handler should be designed to work without it
            handler(nil);
        }
        
        return noErr;
    }
}

@end
