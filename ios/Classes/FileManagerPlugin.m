#import "FileManagerPlugin.h"
#if __has_include(<file_manager/file_manager-Swift.h>)
#import <file_manager/file_manager-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "file_manager-Swift.h"
#endif

@implementation FileManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFileManagerPlugin registerWithRegistrar:registrar];
}
@end
