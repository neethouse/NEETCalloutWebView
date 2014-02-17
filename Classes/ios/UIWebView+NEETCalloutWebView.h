//
//  UIWebView+NEETCalloutWebView.h
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (NEETCalloutWebView)

- (void)ncw_handleLongPressWithLocationInWindow:(CGPoint)locationInWindow;

@property (nonatomic, readonly) NSString *ncw_contextName;

@end
