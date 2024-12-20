//
//  UIViewController+GKKeyboard.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKKeyboard.h"
#import <objc/runtime.h>

static char GKKeyboardHiddenKey;
static char GKKeyboardFrameKey;
static char GKKeyboardAnimationDurationKey;

@implementation UIViewController (GKKeyboard)

// MARK: - property

- (void)setKeyboardHidden:(BOOL) hidden
{
    objc_setAssociatedObject(self, &GKKeyboardHiddenKey, @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)keyboardHidden
{
    NSNumber *number = objc_getAssociatedObject(self, &GKKeyboardHiddenKey);
    if(number != nil){
        return [number boolValue];
    }else{
        return YES;
    }
}

- (void)setKeyboardFrame:(CGRect) frame
{
    objc_setAssociatedObject(self, &GKKeyboardFrameKey, @(frame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)keyboardFrame
{
    return [objc_getAssociatedObject(self, &GKKeyboardFrameKey) CGRectValue];
}

- (void)setKeyboardAnimationDuration:(NSTimeInterval) duration
{
    objc_setAssociatedObject(self, &GKKeyboardAnimationDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)keyboardAnimationDuration
{
    return [objc_getAssociatedObject(self, &GKKeyboardAnimationDurationKey) doubleValue];
}

- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification*) notification
{
    if(!self.keyboardHidden){
        self.keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.keyboardAnimationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    }else{
        self.keyboardFrame = CGRectZero;
        self.keyboardAnimationDuration = 0.25;
    }
}

- (void)keyboardDidChangeFrame:(NSNotification*) notification
{
    
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification*) notification
{
    self.keyboardHidden = YES;
    [self keyboardWillChangeFrame:notification];
}

//键盘显示
- (void)keyboardWillShow:(NSNotification*) notification
{
    self.keyboardHidden = NO;
    [self keyboardWillChangeFrame:notification];
}

@end
