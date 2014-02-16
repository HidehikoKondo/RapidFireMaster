//
//  GFCommon.h
//  GameFeatKit
//
//  Created by zaru on 2013/07/09.
//  Copyright (c) 2013年 Basicinc.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDK_VERSION     @"2.0.0"

#define REQUEST_NONE            0
#define REQUEST_UUID            1
#define REQUEST_SCHEME          2
#define REQUEST_ADLIST          3
#define REQUEST_CLICK           4
#define REQUEST_CONV            5
#define REQUEST_ADJSON          6
#define REQUEST_ADENTRY         7
#define REQUEST_IMP             8
#define REQUEST_ICON_ADLIST     9
#define REQUEST_POPUP_ADLIST    9

#define ALERT_MODE_WAIT         0

#define TAG_DISPLAY_VIEW        999
#define TAG_WEBVIEW_ERROR       101
#define TAG_WEBVIEW_ENTRY       102

#define ICON_REFRESH_TIMING     20

@interface GFCommon : NSObject

@end
