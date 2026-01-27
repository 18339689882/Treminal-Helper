//
//  THLocalization.h
//  THShared
//
//  Localization helper for Terminal Helper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Localization helper class
@interface THLocalization : NSObject

/// Check if current system language is Chinese
+ (BOOL)isChineseLanguage;

/// Get localized string for key
+ (NSString *)localizedStringForKey:(NSString *)key;

// Common strings
+ (NSString *)appName;
+ (NSString *)quit;
+ (NSString *)noCommands;
+ (NSString *)cannotGetFinderPath;
+ (NSString *)pleaseOpenFinderWindow;
+ (NSString *)ok;
+ (NSString *)executionFailed;
+ (NSString *)cannotOpenTerminal;
+ (NSString *)executeInTerminal;

@end

/// Convenience macro for localization
#define THLocalizedString(key) [THLocalization localizedStringForKey:key]

NS_ASSUME_NONNULL_END
