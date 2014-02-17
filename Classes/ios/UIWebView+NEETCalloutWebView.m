//
//  UIWebView+NEETCalloutWebView.m
//  NEETCalloutWebView
//
//  Created by mtmta on 2014/02/17.
//  Copyright (c) 2014年 NeetHouse. All rights reserved.
//

#import "UIWebView+NEETCalloutWebView.h"
#import <objc/runtime.h>

#import "NCWWebViewDelegate.h"
#import "NCWCalloutAction.h"


/// ヒアドキュメントマクロ
#define _JS(...) @#__VA_ARGS__


@implementation UIWebView (NEETCalloutWebView)

- (void)ncw_handleLongPressWithLocationInWindow:(CGPoint)locationInWindow {

    if ([self.delegate respondsToSelector:@selector(ncw_webView:shouldOpenDefaultCalloutWithAction:)] == NO) {
        // NCWWebViewDelegate を実装していない場合は何もしない
        return;
    }
    
    CGPoint location = [self.window convertPoint:locationInWindow toView:self];
    
    CGPoint offset = [self ncw_scrollOffset];
    CGPoint domOffset  = [self ncw_domScrollOffset];
    
    CGSize viewSize = self.frame.size;
    CGSize windowSize = [self ncw_domWindowSize];
    
    CGFloat scale = windowSize.width / viewSize.width;
    
    CGPoint domLocation = (CGPoint){
        (location.x - offset.x) * scale + domOffset.x,
        (location.y - offset.y) * scale + domOffset.y };
    
    [self ncw_handleLongPressWithDOMLocation:domLocation scale:scale];
}

- (void)ncw_handleLongPressWithDOMLocation:(CGPoint)domLocation scale:(CGFloat)scale {
    
    NSString *script = _JS(function(global, contextName, x, y, scale) {
        
        function main() {
            var result = {
            };
            
            try {
                /* 周囲 12 px まで調べる */
                for (var i = 0; i < 3; i++) {
                    var margin = (i + 1) * 5 * scale;
                    var isFound = getLinkOrImageInfo(x, y, margin, result);
                    if (isFound) {
                        break;
                    }
                }
                
            } catch(e) {
                result.error = e;
            }
            
            result.isFound = isFound;
            
            global[contextName] = result;
            return JSON.stringify(createJSONSafeObject(result));
        }
        
        var deltas = [[  0,  0 ], /* 中心 */
                      [  0, -1 ], /* 中上 */
                      [  1, -1 ], /* 右上 */
                      [  1,  0 ], /* 以下時計回り */
                      [  1,  1 ],
                      [  0,  1 ],
                      [ -1,  1 ],
                      [ -1,  0 ],
                      [ -1, -1 ],
                      ];
        
        /**
         
         指定した座標にあるリンクまたは画像の URL を取得する.
         @return 指定された座標にリンクまたは画像が存在する場合に YES を返す.
         
         */
        function getLinkOrImageInfo(x, y, margin, result) {
            var isFound = deltas.some(function(dxy, i) {
                var stop = false;
                
                var cx = x + dxy[0] * margin;
                var cy = y + dxy[1] * margin;
                
                var elem = document.elementFromPoint(cx, cy);
                
                if (elem) {
                    var linkElem = findAncestorElement(elem, "A");

                    if (elem.tagName == "IMG") {
                        /* IMG 要素 */
                        result.image = elem;
                        result.imageURL = elem.src;
                        stop = true;
                        
                    } else {
                        /* background-image が設定されてるか確認 */
                        var style = document.defaultView.getComputedStyle(elem, null);
                        
                        if (style.backgroundImage && style.backgroundImage != "none") {
                            var url = style.backgroundImage.replace(/^url\\(['"]?/, "").replace(/["']?\\)$/, "");
                            if (url) {
                                result.image = elem;
                                result.imageURL = url;
                                stop = true;
                            }
                        }
                    }
                    
                    if (linkElem && linkElem.href && 0 < linkElem.href.length) {
                        /* リンクあり */
                        result.link = linkElem;
                        result.linkURL = linkElem.href;
                        stop = true;
                    }
                }
                
                return stop;
            });
            
            return isFound;
        }
        
        /* elem の祖先 (または elem 自身) からタグ名が ancestorTag の要素を探す.
         * ancestorTag は大文字で指定する.
         */
        function findAncestorElement(elem, ancestorTag) {
            if (!elem) {
                return null;
                
            } else if (elem.tagName == ancestorTag) {
                return elem;
            }
            
            return findAncestorElement(elem.parentNode, ancestorTag);
        }
        
        function createJSONSafeObject(obj) {
            var jsonObj = {};
            
            for (var name in obj) {
                if (obj.hasOwnProperty(name)) {
                    if (typeof obj[name] != "object") {
                        jsonObj[name] = obj[name];
                    } else {
                        jsonObj[name] = "" + obj[name];
                    }
                }
            }
            
            return jsonObj;
        }
        
        return main();
    });
    
    script = [NSString stringWithFormat:@"(%@)(this, '%@', %.0f, %.0f, %.3f)",
              script, self.ncw_contextName, domLocation.x, domLocation.y, scale];
    
    NSString *resultJSON = [self stringByEvaluatingJavaScriptFromString:script];
    
    NSDictionary *result = [NSJSONSerialization
                            JSONObjectWithData:[resultJSON dataUsingEncoding:NSUTF8StringEncoding]
                            options:0
                            error:NULL];
    
    if ([result[@"isFound"] boolValue]) {
        // リンク or 画像が見つかった
        
        NCWCalloutAction *action = [NCWCalloutAction.alloc initWithJSONDictionary:result];

        if ([(NSObject *)self.delegate ncw_webView:self shouldOpenDefaultCalloutWithAction:action] == NO) {
            // タッチ、範囲選択をキャンセル
            [self ncw_cancelTouch];
            [self endEditing:YES];
        }
    }
    
    // JavaScript context を削除
    NSString *finalizeScript = [NSString stringWithFormat:@"delete this['%@']", self.ncw_contextName];
    [self stringByEvaluatingJavaScriptFromString:finalizeScript];
}

- (void)ncw_cancelTouch {
    UIView *superview = self.superview;
    NSUInteger viewIndex = [superview.subviews indexOfObject:self];
    
    [self removeFromSuperview];
    
    [superview insertSubview:self atIndex:viewIndex];
}

- (NSString *)ncw_contextName {
    
    static int sContextNameKey;
    
    NSString *contextName = objc_getAssociatedObject(self, &sContextNameKey);
    
    if (contextName == nil) {
        contextName = [NSString stringWithFormat:@".%@.%@", NSStringFromClass([self class]), [[NSUUID UUID] UUIDString]];
        objc_setAssociatedObject(self, &sContextNameKey, contextName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return contextName;
}


#pragma mark - DOM measuring

- (CGSize)ncw_domWindowSize {
    return (CGSize){
        [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue],
        [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue]
    };
}

- (CGPoint)ncw_domScrollOffset {
    
    return CGPointZero;
    
    // iOS5 以降はスクロール位置の補正は必要なし
    // http://j-apps.sakura.ne.jp/prototype/2011/10/13/ios5%E3%81%AEuiwebview%E3%81%A7document-elementfrompointxy%E3%81%AE%E4%BB%95%E6%A7%98%E3%81%8C%E5%A4%89%E3%82%8F%E3%81%A3%E3%81%9F/
    // CGPoint pt;
    // pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    // pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    // return pt;
}

- (CGPoint)ncw_scrollOffset {
    UIEdgeInsets inset = self.scrollView.contentInset;
    return (CGPoint){ inset.left, inset.top };
}

@end
