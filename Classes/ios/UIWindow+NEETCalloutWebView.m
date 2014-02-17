//
//  UIWindow+NEETCalloutWebView.m
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import "UIWindow+NEETCalloutWebView.h"
#import <objc/runtime.h>

#import "UIWebView+NEETCalloutWebView.h"


static __weak NSTimer *_longPressTimer;

static __weak UIView *_pressingView;

static CGPoint _pressingLocationInWindow;


static void NCWSwizzleMethod(Class cls, SEL orgSelector, SEL newSelector) {
    
    Method orgMethod = class_getInstanceMethod(cls, orgSelector);
    Method newMethod = class_getInstanceMethod(cls, newSelector);
    
    if (class_addMethod(cls, orgSelector, method_getImplementation(newMethod),
                        method_getTypeEncoding(newMethod))) {
        
        class_replaceMethod(cls, newSelector, method_getImplementation(orgMethod),
                            method_getTypeEncoding(orgMethod));
        
    } else {
        
        method_exchangeImplementations(orgMethod, newMethod);
        
    }
}

static void NCWCancel() {
    [_longPressTimer invalidate], _longPressTimer = nil;
    _pressingView = nil;
}


@implementation UIWindow (NEETCalloutWebView)

+ (void)load {
    NCWSwizzleMethod(self, @selector(sendEvent:), @selector(ncw_sendEvent:));
}

- (void)ncw_sendEvent:(UIEvent *)event {
    [self ncw_sendEvent:event];
    
    if (event.type == UIEventTypeTouches) {
        
        NSSet *touches = [event touchesForWindow:self];
        
        if (touches.count == 1) {
            UITouch *touch = [touches anyObject];
            
            switch (touch.phase) {
                case UITouchPhaseBegan:
                    NCWCancel();
                    
                    _pressingLocationInWindow = [touch locationInView:nil];
                    _pressingView = touch.view;
                    
                    // UIWebView のメニューは約0.75秒で表示されるので、その前にカスタムメニューを表示する
                    _longPressTimer = [NSTimer
                                       scheduledTimerWithTimeInterval:0.65
                                       target:self
                                       selector:@selector(NEETCalloutWebView_longPressAction:)
                                       userInfo:nil
                                       repeats:NO];
                    break;
                    
                case UITouchPhaseStationary:
                    break;
                    
                case UITouchPhaseEnded:
                case UITouchPhaseMoved:
                case UITouchPhaseCancelled:
                    NCWCancel();
                    break;
            }
            
        } else {
            NCWCancel();
        }
    }
}

- (void)NEETCalloutWebView_longPressAction:(NSTimer *)timer {
    
    UIView *view = _pressingView;
    
    NCWCancel();
    
    do {
        if ([view isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)view;
            [webView ncw_handleLongPressWithLocationInWindow:_pressingLocationInWindow];
        }
    } while ((view = view.superview));
}

@end
