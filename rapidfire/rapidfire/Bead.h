//
//  Bead.h
//  Bead
//
//  Ver 1.0.0
//
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Bead : NSObject

/**
 * 初期化
 *
 */
+ (void)initializeAd;

/**
 * Beadインスタンス取得
 *
 */
+ (Bead *)sharedInstance;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 */
- (void)addSID:(NSString *)sid;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 * @param interval 広告表示インターバル
 */
- (void)addSID:(NSString *)sid interval:(int)interval;
/**
 * 広告の追加
 *
 * @param sid 広告ID
 * @param interval 広告表示インターバル
 */
- (void)addBannerSID:(NSString *)sid refresh:(int)interval;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 */
- (void)addIconSID:(NSString *)sid;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 * @param interval 広告表示インターバル
 */
- (void)addIconSID:(NSString *)sid interval:(int)interval;


- (void) closeAd;
/**
 * 広告ダイアログの表示
 *
 * @param sid 広告ID
 */
- (BOOL)showWithSID:(NSString *)sid;

/**
 * 広告ダイアログの表示
 * インターバル回数に達した際にアラートを表示する
 *
 * @param sid 広告ID
 * @return YES: 表示 NO: 非表示
 */
- (BOOL)showBannerWithSID:(NSString *)sid;
/**
 * 広告ダイアログの表示
 * インターバル回数に達した際にアラートを表示する
 *
 * @param sid 広告ID
 * @return YES: 表示 NO: 非表示
 */
- (BOOL)showIconWithSID:(NSString *)sid;

/**
 * 広告ダイアログの表示
 * インターバル回数に達した際にアラートを表示する
 *
 * @param sid 広告ID                    LandScapeRT
 *                              ⌈‾‾‾‾‾ LandScapeLT
 *                              |⌈‾‾‾‾ Portrait UpsideDown
 *                              ||⌈‾‾‾ Portrait
 *                              |||⌈‾‾
 * @param orientation : binary  0000
 * @return YES: 表示 NO: 非表示
 */
- (BOOL)showWithSIDandOrientation:(NSString *)sid orientation:(int)orientation;
/**
 * 広告ダイアログの表示
 * インターバル回数に達した際にアラートを表示する
 *
 * @param sid 広告ID                    LandScapeRT
 *                              ⌈‾‾‾‾‾ LandScapeLT
 *                              |⌈‾‾‾‾ Portrait UpsideDown
 *                              ||⌈‾‾‾ Portrait
 *                              |||⌈‾‾
 * @param orientation : binary  0000
 * @return YES: 表示 NO: 非表示
 */
- (BOOL)showIconWithSIDandOrientation:(NSString *)sid orientation:(int)orientation;

@end