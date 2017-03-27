//
//  AppDelegate.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/13.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSMutableString *syr = [NSMutableString stringWithFormat:@"987654321"];
//    NSMutableString *result = [[NSMutableString alloc]init];
//    const char *ch = [syr UTF8String];
//    for (int i = (int)syr.length-1; i>=0; i--) {
//        NSString *str = [NSString stringWithCString:ch+i encoding:NSUTF8StringEncoding];
//        [result appendString:[str substringToIndex:1]];
//    }
//    NSLog(@"%@",result);
    
//    const char *temp = [syr UTF8String];
//    char *result = strdup(temp);
//    
//    char *start = result;
//    char *end = start+syr.length-1;
//    while (start<end) {
//        char cc = *start;
//        *start++ = *end;
//        *end-- = cc;
//    }
//    printf("%s",result);
//    free(result);
    
    NSString *copyStr = [syr copy];
    NSString *muCopyStr = [syr mutableCopy];
    NSLog(@"%@:%p,%@:%p,%@:%p",[syr class],syr,NSStringFromClass([syr class]),copyStr,NSStringFromClass([syr class]),muCopyStr);
    
    return YES;
}
/*
如果用实例对象调用实例方法，会到实例的isa指针指向的对象（也就是类对象）操作。
如果调用的是类方法，就会到类对象的isa指针指向的对象（也就是元类对象）中操作。

首先，在相应操作的对象中的缓存方法列表中找调用的方法，如果找到，转向相应实现并执行。
如果没找到，在相应操作的对象中的方法列表中找调用的方法，如果找到，转向相应实现执行
如果没找到，去父类指针所指向的对象中执行1，2.
以此类推，如果一直到根类还没找到，转向拦截调用。
如果没有重写拦截调用的方法，程序报错。
 */
+(BOOL)resolveClassMethod:(SEL)sel
{
    return NO;
}

+(BOOL)resolveInstanceMethod:(SEL)sel
{
    return NO;
}

-(id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
    id obj = [[NSObject alloc]init];
    [anInvocation invokeWithTarget:obj];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
