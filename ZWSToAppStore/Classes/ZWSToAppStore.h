//
//  ZWSToAppStore.h
//  Pods
//
//  Created by LOFT.LIFE.ZHENG on 16/5/18.
//
//

#import <Foundation/Foundation.h>

@interface ZWSAlertContent : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *rejectText;
@property (nonatomic, copy) NSString *shitsText;
@property (nonatomic, copy) NSString *praiseText;

@end


@interface ZWSToAppStore : NSObject

- (instancetype)initWithAppId:(NSString *)appId;
- (void)showToAppStoreInController:(UIViewController *)viewController;

// alertContent有默认值
@property (nonatomic, strong) ZWSAlertContent *alertContent;

@end
