//
//  NCWWebViewDelegate.h
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NCWCalloutAction;

@interface NSObject (NCWWebViewDelegate)

- (BOOL)ncw_webView:(UIWebView *)webView shouldOpenDefaultCalloutWithAction:(NCWCalloutAction *)action;

@end
