//
//  AppDelegate.m
//  Example
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    ExampleViewController *viewController = [[ExampleViewController alloc] init];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
