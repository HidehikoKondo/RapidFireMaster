//
//  ViewController.m
//  rapidfire

//
//  Created by UDONKONET on 2013/10/20.
//  Copyright (c) 2013年 UDONKONET. All rights reserved.
//
#import "ViewController.h"
#import <MrdIconSDK/MrdIconSDK.h>
#import "Bead.h"
#import <GameFeatKit/GFView.h>
#import <GameFeatKit/GFController.h>
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//アスタのキー
#define kMEDIA_CODE @"ast004002umvuatpy3tx"
#define IF_NO_ARC(x) {x}

//ゲームフィート
#define GAMEFEATKEY @"3844"

//bead
#define BEADKEY @"240de5cb325a1c9da19404f2feba6af09a4ece964ce6fc94"

#define TWEETTITLE   @"Twitterにサインインしてね"
#define TWEETMESSAGE @"iPhoneの「設定」→「Twitter」→ユーザー名とパスワードを入力して「サインイン」をタップ"
#define TWEETCANCEL  @"キャンセル"
#define TWEETDEFAULT @"テスト #udonkonet"
#define SOCIALTEXT   @"\nめっちゃハマる！みんなも遊んでみてね。#udonkonet\n\n"
#define APPURL       @"https://itunes.apple.com/us/app/rapid-fire/id713576899?l=ja&ls=1&mt=8"
#define TIMEREMAINING 10
#define COUNTLABELSTRING @"%dHIT / %dsec"
#define APPLITURL @"http://www.udonko.net/wp/applist"

#define SNSTEXT @"【連射の名人】\nハイスコア：%d連射%@"

int hitCount = 0;            //ヒット数
int timeRemaining = TIMEREMAINING;     //残り時間
NSTimer *timer;             //タイマー
int tapTag = 0 ; //タップした場所のタグ
int tapTagPrev = 0 ; //前回タップした場所のタグ
BOOL gameOverFlg = true;    //ゲームオーバーかどうかのフラグ

NSString *nowTagStr;
NSString *txtBuffer;

NSString *strNo;
NSString *strDate;
NSString *strMessage;
NSString *strTitle;
NSString *strUrl;
bool error = NO;

//スクリーンサイズ取得
CGRect screenSize;

//ハイスコア更新用userdefaults
NSUserDefaults *ud;
NSUserDefaults *newapp; //新アプリダイアログの表示判断用。xmlのnoを保存。

@interface ViewController ()
@property (nonatomic, retain) MrdIconLoader* iconLoader;
@property (nonatomic, retain) IBOutlet UIView *gameoverView;
@property (nonatomic, retain) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *BButton;
@property (weak, nonatomic) IBOutlet UIButton *AButton;
@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel10sec;
@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel1sec;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel10sec;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel1sec;

//@property (nonatomic, retain)    AVSpeechSynthesizer* speechSynthesizer;

@end

@interface ViewController(MrdIconLoaderDelegate)<MrdIconLoaderDelegate,GFViewDelegate>

@end

@implementation ViewController
@synthesize iconLoader = _iconLoader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Siriさん初期化
    //_speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    //ビューの状態
    [self viewAnimation:YES scaleX:1 scaleY:1];        //ゲームオーバー画面を非表示
    
    //ハイスコア用userdefaults
    ud = [NSUserDefaults standardUserDefaults];  // 取得
    
    //ダウンロードダイアログ用
    newapp = [NSUserDefaults standardUserDefaults];

    
    //ゲームセンター
    NSLog(@"ゲームセンター対応チェック%d",isGameCenterAPIAvailable());
    //ゲームセンター対応の有効なバージョンならログイン画面を出す
    if(isGameCenterAPIAvailable() == 1){
        [self authenticateLocalPlayer];
    }
    
    //アスタ表示
    [self displayIconAdd];
    
    [_AButton setEnabled:NO];
    [_BButton setEnabled:NO];
   
   
   //ダウンロードしてねダイアログのxml読み込み
   [self loadDownloadXML];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark -ゲームロジック

-(void)countTimer:(NSTimer*)timer{
    //経過時間をインクリメント
    timeRemaining--;
    NSLog(@"timeRemining:%d",timeRemaining);
    if(timeRemaining >=1){
        [self playSound:@"countdown"];          //カウントダウン
        //        NSString *countdown = [NSString stringWithFormat:@"%d",timeRemaining];
        //        [self speech:countdown];
    }else{
        [self playSound:@"retry"];              //終わり
        //        NSString *countdown = [NSString stringWithFormat:@"%@",@"終了"];
        //        [self speech:countdown];
    }
    [self updateScoreLabel];
    if(timeRemaining <= 0){             //残り時間が0秒以下になったらゲームオーバー
        if([timer isValid]){           //タイマーが無効でない場合は停止する
            [timer invalidate];
        }
        [self gameover];            //ゲームオーバー
    }
}
- (IBAction)pushAButton:(id)sender {
    [self playSound:@"click"];
    //ヒット数をインクリメント
    hitCount ++;
    [self updateScoreLabel];
}

-(IBAction)dragABButton:(id)sender{
    UIButton *btn = sender;
    NSLog(@"Drag Outside :%d",btn.tag);
    [self pushAButton:NULL];
    [btn setEnabled:false];
    [btn setEnabled:true];
}

- (IBAction)retryButton:(id)sender {
    [self playSound:@"select"];
    [self viewAnimation:YES scaleX:0 scaleY:0];        //ゲームオーバー画面を非表示
   [_scoreLabel setText:@"Push Start!!"];
}
- (IBAction)selectButton:(id)sender {
    [self playSound:@"select"];
    timeRemaining = TIMEREMAINING;      //残り時間をリセット
    [self viewAnimation:NO scaleX:1 scaleY:1];      //ゲームオーバー画面を表示
    //ラベル更新のためゲームオーバーを呼び出す
    [self gameover];
}//gameoverViewの表示　hidden:表示非表示　x:横のスケール値 y:縦のスケール値

-(void)viewAnimation:(BOOL)hidden scaleX:(float)x scaleY:(float)y {
    float duration = 0.2;
    if(hidden == YES){
        //消す場合はsetHiddenを0.2秒遅れで実行
        [NSTimer scheduledTimerWithTimeInterval:duration target:[NSBlockOperation blockOperationWithBlock:^{
            [_gameoverView setHidden:hidden];
        }] selector:@selector(main) userInfo:nil repeats:NO];
    }else{
        //表示の場合は即実行
        [_gameoverView setHidden:hidden];
    }
    [UIView beginAnimations:nil context:nil];  // 条件指定開始
    [UIView setAnimationDuration:duration];  // 2秒かけてアニメーションを終了させる
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];  // アニメーションは一定速度
    _gameoverView.transform = CGAffineTransformMakeScale(x,y);
    [UIView commitAnimations];  // アニメーション開始！
}

-(void)gameover{
    gameOverFlg = true;
    int nowScore10 = hitCount;                  //10秒間ヒット数
    float nowScore1 = (float)hitCount/10;       //1秒間ヒット数
    //ハイスコアの更新
    int highScore =  [ud integerForKey:@"HIGHSCORE"];
    //今回のスコアがハイスコアを超えていたらハイスコアを更新
    if(highScore < nowScore10){
        [ud setInteger:nowScore10 forKey:@"HIGHSCORE"];
        [ud synchronize];  // NSUserDefaultsに即時反映させる
       
       if(nowScore10 >= 160 && nowScore10 < 240){
          [self reportAchievementIdentifier:@"16rensha" percentComplete:100];
       }else if(nowScore10 >= 240 && nowScore10 < 320){
          [self reportAchievementIdentifier:@"24rensha" percentComplete:100];
       }else if(nowScore10 >=320){
          [self reportAchievementIdentifier:@"32rensha" percentComplete:100];
       }else{
         // なにもしない;
       }
       
       
    }else{
        //何もしない
    }
    //    // NSUserDefaultsに保存・更新する
    //    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    //    [ud setInteger:100 forKey:@"KEY_I"];  // int型の100をKEY_Iというキーで保存
    //    [ud setFloat:1.23 forKey:@"KEY_F"];  // float型の1.23をKEY_Fというキーで保存
    //    [ud setDouble:1.23 forKey:@"KEY_D"];  // double型の1.23をKEY_Dというキーで保存
    //    [ud setBool:YES forKey:@"KEY_B"];  // BOOL型のYESをKEY_Bというキーで保存
    //    [ud setObject:@"あいう" forKey:@"KEY_S"];  // "あいう"をKEY_Sというキーで保存
    //ラベルの更新
    [_nowScoreLabel1sec setText:[NSString stringWithFormat:@"%.1f連射 / 1秒",nowScore1]];
    [_nowScoreLabel10sec setText:[NSString stringWithFormat:@"%dHit",nowScore10]];
    [_highScoreLabel1sec setText:[NSString stringWithFormat:@"%.1f連射　/ 1秒",(float)highScore/10]];
    [_highScoreLabel10sec setText:[NSString stringWithFormat:@"%dHit",highScore]];
    [_gameoverView setHidden:NO];
    _gameoverView.hidden = NO;
    [_startButton setEnabled:YES];
    [_selectButton setEnabled:YES];
    [_AButton setEnabled:NO];
    [_BButton setEnabled:NO];
    [self viewAnimation:NO scaleX:1 scaleY:1];        //ゲームオーバー画面を非表示
    timer = NULL;
    //ゲームセンターに結果を送信
    [self sendLeaderboard];
    
    [[Bead sharedInstance] showWithSID:BEADKEY];    //bead表示
    


}

-(void)updateScoreLabel{
    NSString *labelString = [NSString stringWithFormat:COUNTLABELSTRING,hitCount,timeRemaining];
    [_scoreLabel setText:labelString];
}

- (IBAction)startButton:(id)sender {
    gameOverFlg = false;
    [self playSound:@"start"];
    hitCount = 0;
    timeRemaining = TIMEREMAINING;      //残り時間をリセット
    [self updateScoreLabel];
    [_startButton setEnabled:NO];        //スタートボタンを無効にする
    [_selectButton setEnabled:NO];        //セレクトボタンを無効にする
    [_AButton setEnabled:YES];          //Aボタンを有効
    [_BButton setEnabled:YES];          //Bボタンを有効
    // タイマーの生成
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                           selector:@selector(countTimer:)
                                           userInfo:nil
                                            repeats:YES];
}

//ゲームフィート表示
- (IBAction)displayGameFeat:(id)sender {
    [self playSound:@"click"];
    [GFController showGF:self site_id:GAMEFEATKEY];
}

//アスタ広告
-(void)displayIconAdd{
    //アイコンの表示数
    NSInteger iconsNumber = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        iconsNumber = 8;
    }
    else {
        // iphone
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if(screenSize.width == 320.0 && screenSize.height == 568.0)
        {
            //4インチ
            iconsNumber = 6;
        }
        else{
            //3.5インチ
            iconsNumber = 3;
        }
    }
    // The array of points used as origin of icon frame
    CGPoint origins_35inch[] = {
        {405, 50},
        {405, 140},
        {405, 230}
    };
    CGPoint origins_4inch[] = {
        {0, 50},
        {0, 140},
        {0, 230},
        {490, 50},
        {490, 140},
        {490, 230}
    };
    CGPoint origins_ipad[] = {
        {0, 150},
        {0, 300},
        {0, 450},
        {0, 600},
        {874, 150},
        {874, 300},
        {874, 450},
        {874, 600}
        
    };
    MrdIconLoader* iconLoader = [[MrdIconLoader alloc]init]; // (1)
    self.iconLoader = iconLoader;
    iconLoader.delegate = self;
    //	IF_NO_ARC([iconLoader release];)
    for (int i=0; i < iconsNumber; i++)
    {
        CGRect frame;                                                       //frame
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            frame.origin = origins_ipad[i];                                   //位置
            frame.size = CGSizeMake(150, 150);                          //サイズ75x75
        }else {
            // iphone
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            if(screenSize.width == 320.0 && screenSize.height == 568.0)
            {
                //4インチ
                frame.origin = origins_4inch[i];                                   //位置
            }
            else{
                //3.5インチ
                frame.origin = origins_35inch[i];                                   //位置
            }
            frame.size = kMrdIconCell_DefaultViewSize;                          //サイズ75x75
        }
        //        frame.origin = origins_35inch[i];                                   //位置
        
        MrdIconCell* iconCell = [[MrdIconCell alloc]initWithFrame:frame];   //セル生成
        [iconLoader addIconCell:iconCell];                                  //セル追加
        [self.view addSubview:iconCell];                                    //セル配置
        [iconLoader startLoadWithMediaCode: kMEDIA_CODE];                //ID設定
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
            }
            else
            {
                // 認証に失敗
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
    [self playSound:@"select"];
    GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.gameCenterDelegate = self;
        [self presentViewController: leaderboardController animated: YES completion:nil];
    }
}


//アチーブメントを表示
-(IBAction)showAchievement
{
   //音再生
   [self playSound:@"select"];
   GKAchievementViewController *leaderboardController = [[GKAchievementViewController alloc] init];
   if (leaderboardController != nil)
   {
      leaderboardController.gameCenterDelegate = self;
      [self presentViewController: leaderboardController animated: YES completion:nil];
   }
}

//リーダーボードで完了を押した時に呼ばれる（リーダーボードを閉じる処理）
- (void)leaderboardViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self playSound:@"select"];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self playSound:@"select"];

}

-(void)sendLeaderboard{
    //リーダーボードに値を送信
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"16rensha"];
    NSInteger scoreR;
    //   //scoreRにゲームのスコアtapCountを格納
    scoreR = hitCount;
    scoreReporter.value = scoreR;
    NSArray *scores = @[scoreReporter];
    //scoreRepoterにハイスコアを格納
    //ハイスコアを送信
    //    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // 報告エラーの処理
            NSLog(@"error %@",error);
        }else{
            // リーダーボードに値を送信
            NSLog(@"リーダーボードに値を送信");
        }
    }];
    //   GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: identifier];
    //   scoreReporter.value = score;
    //   scoreReporter.context = 0;
}

#pragma -mark アチーブメント
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete:
(float) percent
{
   GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:
                                 identifier];
   if (achievement)
   {
      achievement.percentComplete = percent;
      [achievement reportAchievementWithCompletionHandler:^(NSError *error)
      {
         if (error != nil)
         {
            NSLog(@"Error in reporting achievements: %@", error);
         }
      }];
   }
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//=======================================================
// GFViewDelegate
//=======================================================

- (void)didShowGameFeat{
    // GameFeatが表示されたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didShowGameFeat");
}

- (void)didCloseGameFeat{
    // GameFeatが閉じられたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didCloseGameFeat");
}

- (IBAction)lineButton:(id)sender {
    //音再生
    [self playSound:@"click"];
    // LINE に直接遷移。contentType で画像を指定する事もできる。アプリが入っていない場合は何も起きない。
    NSString *contentType = @"text";
    NSString *plainString = [NSString stringWithFormat:SNSTEXT,[ud integerForKey:@"HIGHSCORE"],SOCIALTEXT];
    
    plainString = [plainString stringByAppendingString:APPURL];
    // escape
    NSString *contentKey = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                        NULL,
                                                                                        (CFStringRef)plainString,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                        kCFStringEncodingUTF8 );
    NSString *urlString2 = [NSString
                            stringWithFormat:@"line://msg/%@/%@",
                            contentType, contentKey];
    NSURL *url = [NSURL URLWithString:urlString2];
    // LINEがインストールされているかどうか確認
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""
                                                      message:[NSString stringWithFormat:@"LINEをインストールしてね～♪"]
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil] ;
        [alert show];
    }
}

- (IBAction)likeButton:(id)sender {
    //音再生
    [self playSound:@"click"];
    //バージョン確認
    NSString *version = [[UIDevice currentDevice]systemVersion];
    NSLog(@"Version %@", version);
    // iOS 6
    if([ version floatValue] >= 6.0) {
        SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPostVC setInitialText:[NSString stringWithFormat:SNSTEXT,[ud integerForKey:@"HIGHSCORE"],SOCIALTEXT]];
        [facebookPostVC addImage:[UIImage imageNamed:@"icon/iTunesArtwork.png"]];
        [facebookPostVC addURL:[NSURL URLWithString:APPURL]];
        [self presentViewController:facebookPostVC animated:YES completion:nil];
    }else{
        NSLog(@"FB未対応");
        UIAlertView *alert =
        [[UIAlertView alloc]initWithTitle:@"未対応じゃ！"
                                  message:@"facebookに投稿するには\n最新のiOSにアップデートしてね"
                                 delegate:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:@"OK", nil
         ];
        [alert show];
    }
}

- (IBAction)tweetButton:(id)sender {
    //再生
    [self playSound:@"click"];
    if(NSClassFromString(@"SLComposeViewController")) {
        // Social Frameworkが使える
        SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostVC setInitialText:[NSString stringWithFormat:SNSTEXT,[ud integerForKey:@"HIGHSCORE"],SOCIALTEXT]];
        [twitterPostVC addImage:[UIImage imageNamed:@"icon/iTunesArtwork.png"]];
        [twitterPostVC addURL:[NSURL URLWithString:APPURL]];
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }
    else {
        //        // いままで通りの方法 (iOS5)
        //        // ビューコントローラの初期化
        //        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        //
        //        // 送信文字列を設定
        //        [tweetViewController setInitialText:[NSString stringWithFormat:@"%@　【ハゲ親父断髪式：最高記録 %d本抜き】#udonkonet",SOCIALTEXT, [score integerForKey:@"SCORE"]]];
        //
        //        // 送信画像を設定
        //        [tweetViewController addImage:[UIImage imageNamed:@"icon512.png"]];
        //
        //        // イベントハンドラ定義
        //        tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        //            if (res == TWTweetComposeViewControllerResultCancelled) {
        //                NSLog(@"キャンセル");
        //            }
        //            else if (res == TWTweetComposeViewControllerResultDone) {
        //                NSLog(@"成功");
        //            }
        //            [self dismissModalViewControllerAnimated:YES];
        //        };
        //
        //        // 送信View表示
        //        [self presentModalViewController:tweetViewController animated:YES];
        //
    }
}

- (IBAction)udonkoButton:(id)sender {
    [self playSound:@"click"];
    NSURL *url = [NSURL URLWithString:APPLITURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - 音声処理関係
-(void) playSound:(NSString *)filename{
    //OK音再生
    SystemSoundID soundID;
    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:filename
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound (soundID);
}

#pragma mark - タッチイベント
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!gameOverFlg){
        //タッチイベントの設定
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        if (CGRectContainsPoint(_AButton.frame,location)) {
            tapTag =_AButton.tag;
            if(tapTag != tapTagPrev){
                tapTagPrev = _AButton.tag;
                NSLog(@"あたりA");
                [_AButton setEnabled:false];
                [self pushAButton:NULL];
            }
        }else if(CGRectContainsPoint(_BButton.frame,location)){
            tapTag =_BButton.tag;
            if(tapTag != tapTagPrev){
                tapTagPrev = _BButton.tag;
                NSLog(@"あたりB");
                [_BButton setEnabled:false];
                [self pushAButton:NULL];
            }
        }else{
            //AB以外は親のviewのタグ0
            tapTagPrev =touch.view.tag;
            [_AButton setEnabled:true];
            [_BButton setEnabled:true];
        }
        //前回のタグをセット
        //tapTagPrev =touch.view.tag;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!gameOverFlg){
        [_AButton setEnabled:true];
        [_BButton setEnabled:true];
    }
}

-(void)speech:(NSString *)string{
    // AVSpeechSynthesizerを初期化する。
    //    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
    //    [_speechSynthesizer speakUtterance:utterance];
}


#pragma mark - 新アプリダイアログ




-(void)loadDownloadXML{
    //ダウンロードしてねダイアログのメッセージを取得
    NSURL *URL = [NSURL URLWithString:@"http://coco8.sakura.ne.jp/udonko/apps/dlpopup/popup.xml"];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    xmlParser.delegate = self;
    [xmlParser parse];
    
    //非同期通信
    /*
     NSString *urlstring = @"http://saryou.jp";
     NSURL *url = [NSURL URLWithString:urlstring];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
     [connection start];
     */
    
    //日付とナンバーを取れるようにしておいたので、これで何かしらの判定をしてから
    //showDownloadDialogを呼び出すようにしましょう。
    //このままだと、毎回呼び出されちゃうのでうっとーしー。
    //ここは要検討
    NSLog(@"NO:%d userdefaultsのDLNO:%d",strNo.intValue,[newapp integerForKey:@"DLNO"]);
    NSLog(@"date:%@",strDate);
    
    //xmlパースでエラーがなければダイアログ表示
    if(!error){
        
        //noを比較して、保存してあるnoと異なればxmlが更新されたものと見なしてダイアログを表示する。
        //１度表示したら更新されるまで表示しないようにする。
        if(strNo.intValue == [newapp integerForKey:@"DLNO"]){
            //なにもしない
        }else{
                //ダイアログを表示
                [newapp setInteger:strNo.intValue forKey:@"DLNO"];
                NSLog(@"DLNO保存:%d",strNo.intValue);
                [newapp synchronize];
                [self showDownloadDialog];
        }
    }
}

//パーススタート
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"no"]){
        nowTagStr = [NSString stringWithString:elementName];
        txtBuffer = [NSString stringWithFormat:@"%@",@""];
    }else if([elementName isEqualToString:@"title"]){
        nowTagStr = [NSString stringWithString:elementName];
        txtBuffer = [NSString stringWithFormat:@"%@",@""];
    }else if([elementName isEqualToString:@"message"]){
        nowTagStr = [NSString stringWithString:elementName];
        txtBuffer = [NSString stringWithFormat:@"%@",@""];
    }else if([elementName isEqualToString:@"url"]){
        nowTagStr = [NSString stringWithString:elementName];
        txtBuffer = [NSString stringWithFormat:@"%@",@""];
    }else if([elementName isEqualToString:@"date"]){
        nowTagStr = [NSString stringWithString:elementName];
        txtBuffer = [NSString stringWithFormat:@"%@",@""];
    }
}

//エレメント内に文字列を発見！
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([nowTagStr isEqualToString:@"no"]){
        txtBuffer = [txtBuffer stringByAppendingFormat:@"%@",string];
    }else if([nowTagStr isEqualToString:@"title"]){
        txtBuffer = [txtBuffer stringByAppendingFormat:@"%@",string];
    }else if([nowTagStr isEqualToString:@"message"]){
        txtBuffer = [txtBuffer stringByAppendingFormat:@"%@",string];
    }else if([nowTagStr isEqualToString:@"url"]){
        txtBuffer = [txtBuffer stringByAppendingFormat:@"%@",string];
    }else if([nowTagStr isEqualToString:@"date"]){
        txtBuffer = [txtBuffer stringByAppendingFormat:@"%@",string];
    }
}

//エレメントの読み込み終了時のイベント
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"no"]){
        strNo = [NSString stringWithFormat:@"%@",txtBuffer];
    }else if([elementName isEqualToString:@"title"]){
        strTitle = [NSString stringWithFormat:@"%@",txtBuffer];
    }else if([elementName isEqualToString:@"message"]){
        strMessage = [NSString stringWithFormat:@"%@",txtBuffer];
    }else if([elementName isEqualToString:@"url"]){
        strUrl = [NSString stringWithFormat:@"%@",txtBuffer];
    }else if([elementName isEqualToString:@"date"]){
        strDate = [NSString stringWithFormat:@"%@",txtBuffer];
    }
}

//パース完了
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    nowTagStr = [NSString stringWithFormat:@"%@",@""];
}

//パースエラー
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"エラーが発生しました");
    //error発生した場合はerrorをYESにしてダウンロードダイアログを表示しないようにする
    //主に通信切断時に呼び出されると思う。
    error = YES;
}




- (void)showDownloadDialog
{
    // 生成例
    UIAlertView *alert = [[UIAlertView alloc] init];
    
    // 生成と同時に各種設定も完了させる例
    alert =[[UIAlertView alloc]
            initWithTitle:strTitle
            message:strMessage
            delegate:self
            cancelButtonTitle:@"あとで"
            otherButtonTitles:@"ダウンロード", nil];
    [alert show];
}

// アラートのボタンが押された時に呼ばれるデリゲート
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //１番目のボタンが押されたときの処理を記述する
            NSLog(@"いいえ");
            break;
        case 1:
            //２番目のボタンが押されたときの処理を記述する
            NSLog(@"ダウンロード");
            NSURL *url= [NSURL URLWithString:strUrl];
            [[UIApplication sharedApplication] openURL:url];
            break;
    }
}

@end
////////////////////////////////////////////////////////////////////////////////////

#pragma mark -

@implementation ViewController(MrdIconLoaderDelegate)
- (void)loader:(MrdIconLoader*)loader didReceiveContentForCells:(NSArray *)cells

{
    for (id cell in cells) {
        NSLog(@"---- The content loaded for iconCell:%p, loader:%p", cell,  loader);
    }
}
- (void)loader:(MrdIconLoader*)loader didFailToLoadContentForCells:(NSArray*)cells

{
    for (id cell in cells) {
        NSLog(@"---- The content is missing for iconCell:%p, loader:%p", cell,  loader);
    }
}
- (BOOL)loader:(MrdIconLoader*)loader willHandleTapOnCell:(MrdIconCell*)aCell

{
    NSLog(@"---- loader:%p willHandleTapOnCell:%@", loader, aCell);
    return YES;
}
- (void)loader:(MrdIconLoader*)loader willOpenURL:(NSURL*)url cell:(MrdIconCell*)aCell

{
    NSLog(@"---- loader:%p willOpenURL:%@ cell:%@", loader, [url absoluteString], aCell);
}

@end

