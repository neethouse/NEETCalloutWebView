//
//  NCWCalloutAction.m
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import "NCWCalloutAction.h"

@implementation NCWCalloutAction

- (id)initWithJSONDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        if (0 < [dict[@"linkURL"] length]) {
            _linkURL = dict[@"linkURL"];
        }
        
        if (0 < [dict[@"imageURL"] length]) {
            _imageURL = dict[@"imageURL"];
        }
    }
    return self;
}

@end
