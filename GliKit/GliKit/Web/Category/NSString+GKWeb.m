//
//  NSString+GKWeb.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSString+GKWeb.h"

@implementation NSString (GKWeb)

+ (NSString*)gkAdjustScreenHtmlString
{
    return @"<style>img {width:100%;}</style><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>";
}

@end
