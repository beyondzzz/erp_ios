//
//  AppDelegate.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/18.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

