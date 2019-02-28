//
//  YWWebViewController.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/16.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "YWWebViewController.h"
#import <WebKit/WebKit.h>
#import "GoodsDetailViewController.h"
#import "YWAlertView.h"

@interface YWWebViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkwebView;

@end

@implementation YWWebViewController

- (WKWebView *)wkwebView {
    if (!_wkwebView) {
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        [configuration.userContentController addScriptMessageHandler:self name:@"getGoodsDetailId"];
        [configuration.userContentController addScriptMessageHandler:self name:@"getDownloadUrl"];
        [configuration.userContentController addScriptMessageHandler:self name:@"showPhoneCall"];
        
        _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - 64) configuration:configuration];
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        [self.view addSubview:_wkwebView];
        
        // loading界面
        [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    }
    return _wkwebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _titleStr;
    [self loadData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 加载UIWebView
-(void)loadData
{
    NSString *urlStr = nil;
    if (_webURL) {
        urlStr =  [_webURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.wkwebView loadRequest:request];
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.view stopLoading];
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    YWWeakSelf;
    [self.view showErrorWithRefreshBlock:^{
        [weakSelf loadData];
    }];
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"getGoodsDetailId"]) {
        NSLog(@"111");
        
        GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
        detailVC.goodsID = message.body;
        [self.navigationController pushViewController:detailVC animated:YES];
        
    } else if ([message.name isEqualToString:@"getDownloadUrl"]) {
        NSLog(@"111");
        
        NSString *downUrl = message.body;
        if (![downUrl hasPrefix:@"http"]) {
            downUrl = kAppendUrl(message.body);
        }
        
        [YWAlertView showNotice:@"确认下载嘛？" WithType:YWAlertTypeNormal clickSureBtn:^(UIButton *btn) {
            [SVProgressHUD showWithStatus:@"正在下载……"];
            
            [self performSelector:@selector(completeDownLoad) withObject:nil afterDelay:2.0];
//            [HttpTools DownLoad:downUrl progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
//
//            } success:^(id responseObject) {
//
//                [SVProgressHUD showSuccessWithStatus:@"下载完成"];
//
//            } failure:^(NSError *error) {
//
//                [SVProgressHUD showSuccessWithStatus:@"下载失败"];
//
//            }];
        }];
        
    }
}

- (void)completeDownLoad {
    [SVProgressHUD showSuccessWithStatus:@"下载完成"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                
    }];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"tel"]) {
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        });
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
