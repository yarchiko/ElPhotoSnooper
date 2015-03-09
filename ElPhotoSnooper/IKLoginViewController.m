//
//    Copyright (c) 2013 Shyam Bhat
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "IKLoginViewController.h"
#import "EPSConstants.h"

@interface IKLoginViewController () <UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *mWebView;
}
@end

@implementation IKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareAuthWebView];
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token",
                                       configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey]]];

    [mWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)prepareAuthWebView {
    mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mWebView.scrollView.bounces = NO;
    mWebView.contentMode = UIViewContentModeScaleAspectFit;
    mWebView.delegate = self;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *URLString = [request.URL absoluteString];
    
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            /**
             *  Знаю, что это не безопасно. Решение выбрано ради скорости реализации.
             */
            [[NSUserDefaults standardUserDefaults] setObject:accessToken
                                                      forKey:INSTAGRAM_USER_ACCESS_TOKEN];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];

            [self dismissViewControllerAnimated:YES completion:^{
                /**
                 *  Обновления ленты пользователя из другого контроллера.
                 */
                [_feedTableViewController reloadFeedFromOutside];
            }];
        }
        return NO;
    }
    return YES;
}

@end
