//
//  ExampleViewController.m
//  Example
//
//  Created by mtmta on 13/05/26.
//  Copyright (c) 2013年 501dev.org. All rights reserved.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    // Web view selector
    NSArray *selectorItems = @[
                               @"NEETCalloutWebView",
                               NSStringFromClass([UIWebView class])
                               ];
    self.webViewSelector = [[UISegmentedControl alloc] initWithItems:selectorItems];
    
    [self.webViewSelector addTarget:self
                             action:@selector(selectWebView:)
                   forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = self.webViewSelector;
    
    self.webViewSelector.selectedSegmentIndex = 0;
    [self selectWebView:self.webViewSelector];
    
    // Refresh bar button item
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                target:self
                                action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refresh;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        _selectedWebView.scrollView.contentInset = (UIEdgeInsets){
            self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0,
        };
    }
}

- (void)selectWebView:(UISegmentedControl *)segmentedControl {
    
    [_selectedWebView removeFromSuperview];
    
    _selectedWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _selectedWebView.scalesPageToFit = YES;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        _selectedWebView.delegate = self;
    }
    
    [self.view addSubview:_selectedWebView];
    
    [self refresh];
}

- (void)refresh {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.selectedWebView loadRequest:request];
}


#pragma mark - NCWWebViewDelegate

- (BOOL)ncw_webView:(UIWebView *)webView shouldOpenDefaultCalloutWithAction:(NCWCalloutAction *)action {
    
    NSString *msg = [NSString stringWithFormat:
                     @"link = %@\n"
                     @"image = %@",
                     action.linkURL, action.imageURL];
    
    UIAlertView *alertView = [UIAlertView.alloc initWithTitle:@"NEETCalloutWebView"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [alertView show];
    
    return NO;
}

@end
