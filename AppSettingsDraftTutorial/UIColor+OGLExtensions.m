//
//  UIColor+Extensions.m
//
//  Created by Lawrence F MacFadyen on 2014-10-02.
//  Copyright (c) 2014 larrymac. All rights reserved.
//

#import "UIColor+OGLExtensions.h"

@implementation UIColor (OGLExtensions)

+ (UIColor *)defaultTintColor
{
    return [UIColor colorWithRed:0 / 255.0 green:122 / 255.0 blue:255 / 255.0 alpha:1];
}

+ (UIColor *)defaultNavBarColor
{
    return [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
}

+ (UIColor *)mercuryColor
{
    return [UIColor colorWithRed:0.901961 green:0.901961 blue:0.901961 alpha:1];
}

+ (UIColor *)snowColor
{
    return [UIColor colorWithRed:255 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1];
}

+ (UIColor *)almostBlackColor
{
    return [UIColor colorWithWhite:66.0 / 255.0 alpha:1.0];
}

+ (UIColor *)defaultLightGray
{
    return [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:244 / 255.0 alpha:1];
}

+ (UIColor *)greenCompleteColor
{
    return [UIColor colorWithRed:0 / 255.0 green:204 / 255.0 blue:0 / 255.0 alpha:1];
}

+ (UIColor *)placeholderTextColor
{
    return [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
}

@end
