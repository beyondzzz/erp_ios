//
//  GoodsDetailWebController.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "GoodsDetailWebController.h"
#import <WebKit/WebKit.h>

@interface GoodsDetailWebController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkwebView;

@end

@implementation GoodsDetailWebController

- (WKWebView *)wkwebView {
    if (!_wkwebView) {
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        [configuration.userContentController addScriptMessageHandler:self name:@"sendGoodsDetailId"];
        
        _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, kIphoneHeight - 64) configuration:configuration];
        _wkwebView.UIDelegate = self;
        _wkwebView.navigationDelegate = self;
        [self.view addSubview:_wkwebView];
        [_wkwebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        // loading界面
        [self.view startLoadingWithY:0 Height:kIphoneHeight - SafeAreaTopHeight];
    }
    return _wkwebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"图文详情";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

#pragma mark - 加载UIWebView
-(void)loadData
{
    NSString *urlStr = nil;
    if (_goodsId) {
        urlStr = [NSString stringWithFormat:@"%@?goodsId=%@", kAppendUrl(YWGoodsDetailHtmlString), _goodsId];
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
    
//    NSString *jsStr = [NSString stringWithFormat:@"sendGoodsDetailId('%@')",_goodsId];
//    [self.wkwebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//    }];
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    YWWeakSelf;
    [self.view showErrorWithRefreshBlock:^{
        [weakSelf loadData];
    }];
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
    if ([message.name isEqualToString:@"sendGoodsDetailId"]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
