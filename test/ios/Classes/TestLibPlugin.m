//
//  TestLibPlugin.m
//  Adjust SDK
//
//  Created by Srdjan Tubin (@2beens) on 1st October 2018.
//  Copyright (c) 2018-Present Adjust GmbH. All rights reserved.
//

#import "TestLibPlugin.h"
#import "AdjustCommandExecutor.h"

@interface TestLibPlugin ()

@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, strong) ATLTestLibrary *testLibrary;
@property(nonatomic, strong) AdjustCommandExecutor *adjustCommandExecutor;

@end

@implementation TestLibPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.adjust.test.lib/api"
                                                                binaryMessenger:[registrar messenger]];
    TestLibPlugin *instance = [[TestLibPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

// TODO: check if needed
- (void)dealloc {
    [self.channel setMethodCallHandler:nil];
    self.channel = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      [self init:call withResult:result];
  } else if ([@"startTestSession" isEqualToString:call.method]) {
      [self startTestSession:call withResult:result];
  } else if ([@"addInfoToSend" isEqualToString:call.method]) {
      [self addInfoToSend:call withResult:result];
  } else if ([@"sendInfoToServer" isEqualToString:call.method]) {
      [self sendInfoToServer:call withResult:result];
  } else if ([@"addTest" isEqualToString:call.method]) {
      [self addTest:call withResult:result];
  } else if ([@"addTestDirectory" isEqualToString:call.method]) {
      [self addTestDirectory:call withResult:result];
  } else if ([@"doNotExitAfterEnd" isEqualToString:call.method]) {
      [self doNotExitAfterEnd:call withResult:result];
  } else if ([@"setTestConnectionOptions" isEqualToString:call.method]) {
    // do nothing, Android specific method
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)init:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"Initializing test lib bridge ...");
    NSString *baseUrl = call.arguments[@"baseUrl"];
    NSString *controlUrl = call.arguments[@"controlUrl"];
    if (![self isFieldValid:baseUrl] || ![self isFieldValid:controlUrl]) {
        result([FlutterError errorWithCode:@"WRONG-ARGS"
                                   message:@"Arguments null or wrong (missing argument >baseUrl< or >controlUrl<)"
                                   details:nil]);
        return;
    }

    self.adjustCommandExecutor = [[AdjustCommandExecutor alloc]initWithMethodChannel:self.channel];
    self.testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl andControlUrl:controlUrl andCommandDelegate:self.adjustCommandExecutor];
    NSLog(@"TestLib bridge initialized.");
}

- (void)startTestSession:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        NSLog(@"Error. Cannot start test session. Test lib bridge not initialized.");
        return;
    }

    NSString *clientSdk = call.arguments[@"clientSdk"];
    if (![self isFieldValid:clientSdk]) {
        result([FlutterError errorWithCode:@"WRONG-CLIENT-SDK"
                                   message:@"Arguments null or wrong (missing argument >clientSdk<"
                                   details:nil]);
        return;
    }

    NSLog(@"Starting test session. Client SDK %@", clientSdk);
    [self.testLibrary startTestSession:clientSdk];
}

- (void)addInfoToSend:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        return;
    }
    NSString *key = call.arguments[@"key"];
    NSString *value = call.arguments[@"value"];
    [self.testLibrary addInfoToSend:key value:value];
}

- (void)sendInfoToServer:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        return;
    }
    NSString *basePath = call.arguments[@"basePath"];
    [self.testLibrary sendInfoToServer:basePath];
}

- (void)addTest:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        return;
    }
    NSString *testName = call.arguments[@"testName"];
    [self.testLibrary addTest:testName];
}

- (void)addTestDirectory:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        return;
    }
    NSString *testDirectory = call.arguments[@"testDirectory"];
    [self.testLibrary addTestDirectory:testDirectory];
}

- (void)doNotExitAfterEnd:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    if ([self testLibOk:result] == NO) {
        return;
    }
    [self.testLibrary doNotExitAfterEnd];
}

// Helper methods

- (BOOL)testLibOk:(FlutterResult)result {
    if (self.testLibrary == nil) {
        result([FlutterError errorWithCode:@"TEST-LIB-NIL"
                                   message:@"Test Library not initialized. Call >init< first."
                                   details:nil]);
        return NO;
    }
    return YES;
}

- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }
    
    // Check if its an instance of the singleton NSNull
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    // If field can be converted to a string, check if it has any content.
    NSString *str = [NSString stringWithFormat:@"%@", field];
    if (str != nil) {
        if ([str length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

@end
