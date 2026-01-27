//
//  THHotkeyManager.h
//  Terminal Helper
//
//  Global hotkey manager for executing commands with keyboard shortcuts.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class THCommand;

/**
 * Callback block when a hotkey is pressed
 */
typedef void (^THHotkeyHandler)(THCommand * _Nullable command);

/**
 * THHotkeyManager manages global keyboard shortcuts for commands.
 * It allows registering hotkeys that work system-wide, even when the app is in the background.
 */
@interface THHotkeyManager : NSObject

/**
 * Returns the shared hotkey manager instance.
 */
+ (instancetype)sharedManager;

/**
 * Register a global hotkey for a command.
 * @param command The command to associate with the hotkey
 * @param keyCode The virtual key code (e.g., kVK_ANSI_1 for '1')
 * @param modifierFlags The modifier flags (e.g., NSEventModifierFlagCommand | NSEventModifierFlagShift)
 * @param handler The block to call when the hotkey is pressed
 * @return YES if registration succeeded, NO otherwise
 */
- (BOOL)registerHotkeyForCommand:(THCommand *)command
                         keyCode:(unsigned short)keyCode
                   modifierFlags:(NSUInteger)modifierFlags
                         handler:(THHotkeyHandler)handler;

/**
 * Unregister a hotkey for a command.
 * @param command The command whose hotkey should be unregistered
 */
- (void)unregisterHotkeyForCommand:(THCommand *)command;

/**
 * Unregister all hotkeys.
 */
- (void)unregisterAllHotkeys;

@end

NS_ASSUME_NONNULL_END
