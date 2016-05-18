//
//  ZWSToAppStore.m
//  Pods
//
//  Created by LOFT.LIFE.ZHENG on 16/5/18.
//
//

#import "ZWSToAppStore.h"

static NSString *const kStoredAppVersion = @"storedAppVersion";
static NSString *const kSelectedIndex    = @"selectedIndex";
static NSString *const kDaysSince1970    = @"daysSince1970";

@interface ZWSToAppStore ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
@property (nonatomic, strong) UIAlertView *alertView;
#else
@property (nonatomic, strong) UIAlertController *alertController;
#endif

@property (nonatomic, copy) NSString *appId;

@end

@implementation ZWSToAppStore


- (instancetype)initWithAppId:(NSString *)appId {

    self = [super init];
    if (self) {
        _alertContent = [[ZWSAlertContent alloc] init];
        self.appId = appId;
    }
    return self;
}


- (void)showToAppStoreInController:(UIViewController *)viewController {

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int storedDaysSince1970 = [[userDefaults objectForKey:kDaysSince1970] intValue];
    float storedAppVersion = [[userDefaults objectForKey:kStoredAppVersion] intValue];
    int selectedIndex = [[userDefaults objectForKey:kSelectedIndex] intValue];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    int daysSince1970 = (int)interval / (24 * 60 * 60);
    

    int difDays = daysSince1970 -storedDaysSince1970;
    
    if (storedAppVersion && appVersion >storedAppVersion) {
        [userDefaults removeObjectForKey:kDaysSince1970];
        [userDefaults removeObjectForKey:kStoredAppVersion];
        [userDefaults removeObjectForKey:kSelectedIndex];
        [self showCommentAlertInController:viewController];
    }
    
    // 1.从来没弹出过的
    // 2.用户选择😄好评赞赏或者😓我要吐槽，7天之后再弹出
    // 3.用户选择😭残忍拒绝的30天后，才会弹出
    else if (!selectedIndex ||
             (selectedIndex > 1 && difDays >7) ||
             (selectedIndex == 1 && difDays >30))
    {
        [self showCommentAlertInController:viewController];
    }
}

- (void)showCommentAlertInController:(UIViewController *)viewController {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        // 当前的信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        int daysSince1970 = (int)interval / (24 * 60 * 60);
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
        
        // 存储的信息
        float storedAppVersion = [[userDefaults objectForKey:kStoredAppVersion] floatValue];
//        int selectedIndex = [[userDefaults objectForKey:kSelectedIndex] intValue];
//        int storedDaysSince1970 = [[userDefaults objectForKey:kDaysSince1970] intValue];
        
//        int difDays = daysSince1970 - storedDaysSince1970;
        
        if (appVersion >storedAppVersion) {
            [userDefaults setObject:[NSString stringWithFormat:@"%f", appVersion] forKey:kStoredAppVersion];
        }
        
        _alertController = [UIAlertController alertControllerWithTitle:self.alertContent.title
                                                               message:self.alertContent.message
                                                        preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:self.alertContent.rejectText
                                                               style:(UIAlertActionStyleDefault)
                                                             handler:^(UIAlertAction *action)
        {
            
            [userDefaults setObject:@"1" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
        }];
        
        UIAlertAction *praiseAction = [UIAlertAction actionWithTitle:self.alertContent.praiseText
                                                               style:(UIAlertActionStyleDefault)
                                                             handler:^(UIAlertAction *action)
        {
            [userDefaults setObject:@"2" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
            
            NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", self.appId ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }];
        
        UIAlertAction *shitsAction = [UIAlertAction actionWithTitle:self.alertContent.shitsText
                                                              style:(UIAlertActionStyleDefault)
                                                            handler:^(UIAlertAction *action)
        {
            [userDefaults setObject:@"3" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
            
            NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", self.appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }];
        
        
        [_alertController addAction:rejectAction];
        [_alertController addAction:praiseAction];
        [_alertController addAction:shitsAction];
        
//        NSLog(@"%@",[userDefaults objectForKey:kStoredAppVersion]);
//        NSLog(@"%@",[userDefaults objectForKey:kSelectedIndex]);
//        NSLog(@"%@",[userDefaults objectForKey:kDaysSince1970]);
        
        [viewController presentViewController:_alertController animated:YES completion:nil];
        
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        _alertView = [[UIAlertView alloc] initWithTitle:self.alertContent.title
                                                   message:self.alertContent.message
                                                  delegate:self
                                         cancelButtonTitle:self.alertContent.rejectText
                                         otherButtonTitles:self.alertContent.praiseText , self.alertContent.shitsText, nil];
        
        [_alertView show];
#endif
    }
    
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSInteger daysSince1970 = interval / (24 * 60 * 60);

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];

    float storedAppVersion = [[userDefaults objectForKey:kStoredAppVersion] intValue];
    int selectedIndex = [[userDefaults objectForKey:kSelectedIndex] intValue];
    int storedDaysSince1970 = [[userDefaults objectForKey:kDaysSince1970] intValue];
    
    if (appVersion >storedAppVersion) {
        [userDefaults setObject:[NSString stringWithFormat:@"%f", appVersion] forKey:kStoredAppVersion];
    }
    
    switch (buttonIndex) {
        case 0: // 残忍拒绝
            [userDefaults setObject:@"1" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
            break;
        case 1:{ // 好评
            [userDefaults setObject:@"2" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
            
            NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", self.appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        case 2:{ // 不好用，我要提意见
            [userDefaults setObject:@"3" forKey:kSelectedIndex];
            [userDefaults setObject:[NSNumber numberWithInt:daysSince1970] forKey:kDaysSince1970];
            
            NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8", self.appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
            
        default:
            break;
    }
    //    NSLog(@"%@",[userDefaults objectForKey:kStoredAppVersion]);
    //    NSLog(@"%@",[userDefaults objectForKey:kSelectedIndex]);
    //    NSLog(@"%@",[userDefaults objectForKey:kDaysSince1970]);
}

#endif

@end


@implementation ZWSAlertContent

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.title = @"致用户的一封信";
        self.message = @"有了您的支持才能更好的为您服务，提供更加优质的，更加适合您的App，当然您也可以直接反馈问题给到我们";
        self.rejectText = @"😭残忍拒绝";
        self.praiseText = @"😄好评赞赏";
        self.shitsText = @"😓我要吐槽";
    }
    return self;
}

@end














