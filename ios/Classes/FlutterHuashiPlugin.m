#import "FlutterHuashiPlugin.h"
#if __has_include(<flutter_huashi/flutter_huashi-Swift.h>)
#import <flutter_huashi/flutter_huashi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_huashi-Swift.h"
#endif

@implementation FlutterHuashiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterHuashiPlugin registerWithRegistrar:registrar];
}
@end
