//
//  ViewController.m
//  rapidfire
//
//  Created by UDONKONET on 2013/10/20.
//  Copyright (c) 2013年 UDONKONET. All rights reserved.
//

#import "ViewController.h"
#import <MrdIconSDK/MrdIconSDK.h>


//アスタのキー
#define kMEDIA_CODE 	@"__TEST__"
#define IF_NO_ARC(x) {x}



@interface ViewController ()
@property (nonatomic, retain) MrdIconLoader* iconLoader;

@end

@interface ViewController(MrdIconLoaderDelegate)<MrdIconLoaderDelegate>
@end


@implementation ViewController
@synthesize iconLoader = _iconLoader;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //ゲームセンター
    NSLog(@"ゲームセンター対応チェック%d",isGameCenterAPIAvailable());
    //ゲームセンター対応の有効なバージョンならログイン画面を出す
    if(isGameCenterAPIAvailable() == 1){
        [self authenticateLocalPlayer];
    }
 
    
    //アスタ表示
    [self displayIconAdd];
    
    

}

//アスタ広告
-(void)displayIconAdd{
    //表示するY座標をUDONKOAPPSボタンと同じにする
    NSInteger icons_35inch = 3;
    NSInteger icons_4inch = 6;
    NSInteger icons_ipad = 3;

    
    // The array of points used as origin of icon frame
	CGPoint origins_35inch[] = {
		{0, 50},
        {0, 130},
        {0, 210}
    };
    
    CGPoint origins_4inch[] = {
		{0, 50},
        {0, 130},
        {0, 210},
        {490, 50},
        {490, 130},
        {490, 210}
    };

    CGPoint origins_ipad[] = {
		{0, 50},
        {0, 130},
        {0, 210}
    };
    
    
    MrdIconLoader* iconLoader = [[MrdIconLoader alloc]init]; // (1)
    self.iconLoader = iconLoader;
	iconLoader.delegate = self;
    //	IF_NO_ARC([iconLoader release];)
    
    
    
    for (int i=0; i < 6; i++)
	{
        CGRect frame;                                                       //frame
        frame.origin = origins_4inch[i];                                          //位置
        frame.size = kMrdIconCell_DefaultViewSize;                          //サイズ75x75
        MrdIconCell* iconCell = [[MrdIconCell alloc]initWithFrame:frame];   //セル生成
        [iconLoader addIconCell:iconCell];                                  //セル追加
        [self.view addSubview:iconCell];                                    //セル配置
        [iconLoader startLoadWithMediaCode: @"id570377317"];                //ID設定
        _iconLoader = iconLoader;
    }
    
}



#pragma mark - ゲームセンター
//ゲームセンター関係の処理

//ゲームセンターに接続できるかどうかの確認処理
BOOL isGameCenterAPIAvailable()
{
    // GKLocalPlayerクラスが存在するかどうかをチェックする
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) !=
    nil;
    // デバイスはiOS 4.1以降で動作していなければならない
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (localPlayerClassAvailable && osVersionSupported);
}

//Gamecenterに接続する処理
- (void) authenticateLocalPlayer
{
    //バージョン確認
    NSString *version = [[UIDevice currentDevice]systemVersion];
    NSLog(@"Version %@", version);
    
    // iOS 6
    if([ version floatValue] >= 6.0) {
        GKLocalPlayer* player = [GKLocalPlayer localPlayer];
        player.authenticateHandler = ^(UIViewController* ui, NSError* error )
        {
            if( nil != ui )
            {
                [self presentViewController:ui animated:YES completion:nil];
            }
            else if( player.isAuthenticated )
            {
                // 認証に成功
                NSLog(@"ios6:認証OK");
            }
            else
            {
                // 認証に失敗
                NSLog(@"ios6:認証NG");
            }
        };
    }else{
        //ios5.1以前
        GKLocalPlayer* player = [GKLocalPlayer localPlayer];
        [player authenticateWithCompletionHandler:^(NSError* error)
         {
             if( player.isAuthenticated )
             {
                 // 認証に成功
                 NSLog(@"ios5:認証OK");
                 
             }
             else
             {
                 // 認証に失敗
                 NSLog(@"ios5:認証NG");
                 
             }
         }];
        
        
    }
}


//リーダーボードを立ち上げる
//UIButtonなどにアクションを関連づけて使用します。
//ランキングを表示する画面が表示されます。

-(IBAction)showBord
{
    //音再生
    //   [self playSound:@"ok"];
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentViewController: leaderboardController animated: YES completion:nil];
    }
}

//リーダーボードで完了を押した時に呼ばれる（リーダーボードを閉じる処理）
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)sendLeaderboard{
    //リーダーボードに値を送信
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"ItazuraRanking"];
    NSInteger scoreR;
    //   //scoreRにゲームのスコアtapCountを格納
    //   scoreR = [score integerForKey:@"SCORE"];
    //   scoreReporter.value = scoreR;
    
    //scoreRepoterにハイスコアを格納
    //ハイスコアを送信
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // 報告エラーの処理
            NSLog(@"error %@",error);
        }else{
            // リーダーボードに値を送信
            NSLog(@"リーダーボードに値を送信");
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
