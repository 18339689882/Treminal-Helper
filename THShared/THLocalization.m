//
//  THLocalization.m
//  THShared
//
//  Localization helper for Terminal Helper
//

#import "THLocalization.h"

@implementation THLocalization

+ (BOOL)isChineseLanguage {
    NSArray *languages = [NSLocale preferredLanguages];
    if (languages.count > 0) {
        NSString *preferredLanguage = languages.firstObject;
        return [preferredLanguage hasPrefix:@"zh"];
    }
    return NO;
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSDictionary *zhStrings = nil;
    static NSDictionary *enStrings = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        zhStrings = @{
            @"app_name": @"终端助手",
            @"quit": @"退出",
            @"no_commands": @"暂无命令",
            @"cannot_get_finder_path": @"无法获取 Finder 路径",
            @"please_open_finder_window": @"请先打开一个 Finder 窗口",
            @"ok": @"确定",
            @"execution_failed": @"执行失败",
            @"cannot_open_terminal": @"无法打开终端",
            @"execute_in_terminal": @"在终端中执行命令",
            @"add_command": @"添加命令",
            @"settings": @"设置",
            @"about": @"关于",
            @"command_name": @"命令名称",
            @"command_string": @"命令内容",
            @"cancel": @"取消",
            @"save": @"保存",
            @"delete": @"删除",
            @"edit": @"编辑",
            @"terminal_helper": @"终端助手",
            @"version": @"版本",
            @"no_commands_hint": @"点击菜单栏图标添加命令"
        };
        
        enStrings = @{
            @"app_name": @"Terminal Helper",
            @"quit": @"Quit",
            @"no_commands": @"No Commands",
            @"cannot_get_finder_path": @"Cannot Get Finder Path",
            @"please_open_finder_window": @"Please open a Finder window first",
            @"ok": @"OK",
            @"execution_failed": @"Execution Failed",
            @"cannot_open_terminal": @"Cannot open Terminal",
            @"execute_in_terminal": @"Execute commands in Terminal",
            @"add_command": @"Add Command",
            @"settings": @"Settings",
            @"about": @"About",
            @"command_name": @"Command Name",
            @"command_string": @"Command String",
            @"cancel": @"Cancel",
            @"save": @"Save",
            @"delete": @"Delete",
            @"edit": @"Edit",
            @"terminal_helper": @"Terminal Helper",
            @"version": @"Version",
            @"no_commands_hint": @"Click menu bar icon to add commands"
        };
    });
    
    NSDictionary *strings = [self isChineseLanguage] ? zhStrings : enStrings;
    return strings[key] ?: key;
}

+ (NSString *)appName {
    return [self localizedStringForKey:@"app_name"];
}

+ (NSString *)quit {
    return [self localizedStringForKey:@"quit"];
}

+ (NSString *)noCommands {
    return [self localizedStringForKey:@"no_commands"];
}

+ (NSString *)cannotGetFinderPath {
    return [self localizedStringForKey:@"cannot_get_finder_path"];
}

+ (NSString *)pleaseOpenFinderWindow {
    return [self localizedStringForKey:@"please_open_finder_window"];
}

+ (NSString *)ok {
    return [self localizedStringForKey:@"ok"];
}

+ (NSString *)executionFailed {
    return [self localizedStringForKey:@"execution_failed"];
}

+ (NSString *)cannotOpenTerminal {
    return [self localizedStringForKey:@"cannot_open_terminal"];
}

+ (NSString *)executeInTerminal {
    return [self localizedStringForKey:@"execute_in_terminal"];
}

@end
