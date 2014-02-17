//
//  NCWCalloutAction.h
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCWCalloutAction : NSObject

@property (nonatomic, readonly) NSString *linkURL;

@property (nonatomic, readonly) NSString *imageURL;

- (id)initWithJSONDictionary:(NSDictionary *)dict;

@end
