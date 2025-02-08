// https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (void)showError:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"MPV Protocol Error"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    [NSApp terminate:nil];
}

- (void)showInfo:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"MPV Protocol Info"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (NSString *)getMPVPath {
    // 设置完整的 PATH 环境变量
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/which"];
    [task setArguments:@[@"mpv"]];
    
    // 设置环境变量
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
    [env setObject:@"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin" forKey:@"PATH"];
    [task setEnvironment:env];

    // 创建一个管道来捕获命令的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]]; // 忽略错误输出

    // 启动任务并等待完成
    [task launch];
    [task waitUntilExit];

    // 读取命令的输出
    NSData *outputData = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

    // 去除输出中的换行符
    NSString *mpvPath = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 如果路径不为空，返回路径；否则返回 nil
    return [mpvPath length] > 0 ? mpvPath : nil;
}

- (BOOL)isMPVInstalled {
    // 调用 getMPVPath 方法获取 mpv 路径
    NSString *mpvPath = [self getMPVPath];

    // 如果路径存在，则说明 mpv 已安装
    return mpvPath != nil;
}

- (NSString *)decodeURL:(NSString *)url {
    return [[url 
        stringByReplacingOccurrencesOfString:@"+" withString:@" "]
        stringByRemovingPercentEncoding];
}

- (void)logMessage:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stderr, "[mpvplay-protocol] %s\n", [message UTF8String]);
}

- (NSString *)repairBrokenUrl:(NSString *)url {
    [self logMessage:@"Original URL: %@", url];
    
    // First decode the URL to handle any encoding
    // 不需要解码，因为以前的URL并没有编码
    // url = [self decodeURL:url];
    // [self logMessage:@"Decoded URL: %@", url];
    
    // Fix Chrome 130+ format
    if ([url hasPrefix:@"http//"]) {
        url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"http://"];
        [self logMessage:@"Fixed HTTP URL: %@", url];
    } else if ([url hasPrefix:@"https//"]) {
        url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@"https://"];
        [self logMessage:@"Fixed HTTPS URL: %@", url];
    }
    
    return url;
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent: (NSAppleEventDescriptor *)replyEvent {
    [self logMessage:@"Received URL request"];
    
    // Check if MPV is installed
    if (![self isMPVInstalled]) {
        [self showError:@"MPV is not installed! Please install MPV player and ensure it's in your PATH."];
        return;
    }
    
    // Get input data
    NSString *input = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *url;
    
    if ([input hasPrefix:@"mpvplay://weblink?"]) {
        // Handle weblink format: mpvplay://weblink?url=http://...
        NSString *query = [input substringFromIndex:14];  
        [self logMessage:@"Query part: %@", query];
        
        // 直接检查url=参数
        if ([query hasPrefix:@"url="]) {
            url = [query substringFromIndex:4];
            // URL解码
            url = [self decodeURL:url];
            [self logMessage:@"Found URL: %@", url];
        } else {
            [self showError:[NSString stringWithFormat:@"Invalid weblink format. URL parameter is missing. Query: %@", query]];
            return;
        }
    } else if ([input hasPrefix:@"mpvplay://"]) {
        url = [input substringFromIndex:10];
    } else if ([input hasPrefix:@"mpvplay:"]) {
        url = [input substringFromIndex:8];
    } else {
        [self showError:@"Invalid URL format. Must start with 'mpvplay://' or 'mpvplay://weblink?url='."];
        return;
    }
    
    // First repair URL if needed
    url = [self repairBrokenUrl:url];
    
    // Then check protocol
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        [self showError:@"Only HTTP and HTTPS protocols are supported."];
        return;
    }

    // Launch MPV
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    // NSURL *app = [NSURL fileURLWithPath:@"/Applications/MPV.app"];
    // NSArray *arguments = [NSArray arrayWithObjects: @"--open", url, nil];
    NSString *mpvPath = [self getMPVPath];
    NSURL *app = [NSURL fileURLWithPath:mpvPath];
    NSArray *arguments = [NSArray arrayWithObjects: url, nil];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
    [config setObject:arguments forKey:NSWorkspaceLaunchConfigurationArguments];
    
    NSError *error = nil;
    if (![ws launchApplicationAtURL:app options:NSWorkspaceLaunchNewInstance configuration:config error:&error]) {
        [self showError:[NSString stringWithFormat:@"Failed to launch MPV: %@", [error localizedDescription]]];
        return;
    }
    
    [NSApp terminate:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Close this program if it wasn't launched using a link (i.e. launched normally)
    [NSApp terminate:nil];
}

@end

int main() {
    // Make sure the shared application is created
    [NSApplication sharedApplication];

    AppDelegate *appDelegate = [AppDelegate new];
    NSAppleEventManager *sharedAppleEventManager = [NSAppleEventManager new];
    [sharedAppleEventManager setEventHandler:appDelegate
                               andSelector:@selector(handleAppleEvent:withReplyEvent:)
                             forEventClass:kInternetEventClass
                                andEventID:kAEGetURL];

    [NSApp setDelegate:appDelegate];
    [NSApp run];
    return 0;
}
