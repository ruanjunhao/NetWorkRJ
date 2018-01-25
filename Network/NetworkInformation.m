//
//  NetworkInformation.m
//  Network
//
//  Created by 沈凯 on 2018/1/23.
//  Copyright © 2018年 Ssky. All rights reserved.
//

#import "NetworkInformation.h"
#import "AppDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation NetworkInformation

#pragma mark 获取当前网络类型
+ (NSString *)getNetworkType
{
    UIApplication *app = [UIApplication sharedApplication];
    id statusBar = [app valueForKeyPath:@"statusBar"];
    NSString *network = @"";
    
    if (KIsiPhoneX) {
//        iPhone X
        id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
        UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
        
        NSArray *subviews = [[foregroundView subviews][2] subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                network = @"WIFI";
            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                network = [subview valueForKeyPath:@"originalText"];
            }
        }
    }else {
//        非 iPhone X
        UIView *foregroundView = [statusBar valueForKeyPath:@"foregroundView"];
        NSArray *subviews = [foregroundView subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
                switch (networkType) {
                    case 0:
                        network = @"NONE";
                        break;
                    case 1:
                        network = @"2G";
                        break;
                    case 2:
                        network = @"3G";
                        break;
                    case 3:
                        network = @"4G";
                        break;
                    case 5:
                        network = @"WIFI";
                        break;
                    default:
                        break;
                }
            }
        }
    }

    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}
+ (NSString *)getNetworkTypeByReachability
{
    NSString *network = @"";
    switch ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]) {
        case NotReachable:
            network = @"NONE";
            break;
        case ReachableViaWiFi:
            network = @"WIFI";
            break;
        case ReachableViaWWAN:
            network = @"WWAN";
            break;
        default:
            break;
    }
    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}
#pragma mark 获取Wifi信息
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
#pragma mark 获取WIFI名字
+ (NSString *)getWifiSSID
{
    return (NSString *)[self fetchSSIDInfo][@"SSID"];
}
#pragma mark 获取WIFI的MAC地址
+ (NSString *)getWifiBSSID
{
    return (NSString *)[self fetchSSIDInfo][@"BSSID"];
}
#pragma mark 获取Wifi信号强度
+ (int)getWifiSignalStrength{
    
    int signalStrength = 0;
//    判断类型是否为WIFI
    if ([[self getNetworkType]isEqualToString:@"WIFI"]) {
        UIApplication *app = [UIApplication sharedApplication];
        id statusBar = [app valueForKey:@"statusBar"];
        if (KIsiPhoneX) {
//            iPhone X
            id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
            UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
            NSArray *subviews = [[foregroundView subviews][2] subviews];
            
            for (id subview in subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                    signalStrength = [[subview valueForKey:@"_numberOfActiveBars"] intValue];
                }
            }
        }else {
//            非 iPhone X
            UIView *foregroundView = [statusBar valueForKey:@"foregroundView"];
            
            NSArray *subviews = [foregroundView subviews];
            NSString *dataNetworkItemView = nil;
            
            for (id subview in subviews) {
                if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                    dataNetworkItemView = subview;
                    break;
                }
            }
            
            signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
            
            return signalStrength;
        }
    }
    return signalStrength;
}
@end
