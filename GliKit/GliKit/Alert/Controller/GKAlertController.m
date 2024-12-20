//
//  GKAlertViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAlertController.h"
#import "GKContainer.h"
#import "UIImage+GKUtils.h"
#import "GKButton.h"
#import "NSAttributedString+GKUtils.h"
#import "GKAlertCell.h"
#import "GKAlertHeader.h"
#import "UIViewController+GKDialog.h"
#import "UIView+GKUtils.h"
#import "NSString+GKUtils.h"
#import "UIApplication+GKTheme.h"
#import "UIView+GKStateUtils.h"

@interface GKAlertController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

///按钮列表
@property(nonatomic, strong) UICollectionView *collectionView;

///头部
@property(nonatomic, strong) GKAlertHeader *header;

///取消按钮 用于 `actionSheet`
@property(nonatomic, strong) UIButton *cancelButton;

///取消按钮标题
@property(nonatomic, copy) NSString *cancelTitle;

///标题 NSString 或者 NSAttributedString
@property(nonatomic, copy) id alertTitle;

///信息 NSString 或者 NSAttributedString
@property(nonatomic, copy) id message;

///图标
@property(nonatomic, strong) UIImage *icon;

///按钮
@property(nonatomic, strong) NSMutableArray<GKAlertAction*> *actions;

@end

@implementation GKAlertController

+ (instancetype)alertWithTitle:(id)title
                       message:(id)message
             cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
{
    return [[GKAlertController alloc] initWithTitle:title message:message icon:nil style:GKAlertStyleAlert cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

+ (instancetype)actionSheetWithTitle:(id)title
                             message:(id)message
                   otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
{
    return [[GKAlertController alloc] initWithTitle:title message:message icon:nil style:GKAlertStyleActionSheet cancelButtonTitle:nil otherButtonTitles:otherButtonTitles];
}

- (instancetype)initWithTitle:(id) title
                      message:(id) message
                         icon:(UIImage*) icon
                        style:(GKAlertStyle) style
            cancelButtonTitle:(NSString *) cancelButtonTitle
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
{
    NSMutableArray *actions = [NSMutableArray array];
    for(NSString *title in otherButtonTitles){
        [actions addObject:[GKAlertAction alertActionWithTitle:title]];
    }
    return [self initWithTitle:title message:message icon:icon style:style cancelButtonTitle:cancelButtonTitle otherButtonActions:actions];
}

- (instancetype)initWithTitle:(id)title
                      message:(id)message
                         icon:(UIImage *)icon
                        style:(GKAlertStyle)style
            cancelButtonTitle:(NSString *)cancelButtonTitle
           otherButtonActions:(NSArray<GKAlertAction *> *)actions
{
    NSAssert(!title || [title isKindOfClass:NSString.class] || [title isKindOfClass:NSAttributedString.class], @"GKAlertController title 必须为 nil 或者 NSString 或者 NSAttributedString");
    NSAssert(!message || [message isKindOfClass:NSString.class] || [message isKindOfClass:NSAttributedString.class], @"GKAlertController message 必须为 nil 或者 NSString 或者 NSAttributedString");
    
    self = [super initWithNibName:nil bundle:nil];
    
    if(self){
        
        self.alertTitle = title;
        self.message = message;
        self.icon = icon;
        
        self.cancelTitle = cancelButtonTitle;
        _style = style;
        
        self.actions = [NSMutableArray arrayWithArray:actions];
        
        switch (_style){
            case GKAlertStyleAlert : {
                if(self.actions.count == 0 && !self.cancelTitle){
                    self.cancelTitle = @"取消";
                }
                
                if(self.cancelTitle){
                    if(self.actions.count < 2){
                        [self.actions insertObject:[GKAlertAction alertActionWithTitle:self.cancelTitle] atIndex:0];
                    }else{
                        [self.actions addObject:[GKAlertAction alertActionWithTitle:self.cancelTitle]];
                    }
                }
            }
                break;
            case GKAlertStyleActionSheet :
                break;
        }
        
        [self initProps];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dialogShowAnimate = GKDialogAnimateCustom;
    self.dialogDismissAnimate = GKDialogAnimateCustom;
    self.shouldDismissDialogOnTapTranslucent = self.style == GKAlertStyleActionSheet && ![NSString isEmpty:self.cancelTitle];
    self.tapDialogBackgroundGestureRecognizer.delegate = self;
}

///属性初始化
- (void)initProps
{
    self.dialogShouldUseNewWindow = YES;
    _destructiveButtonIndex = NSNotFound;
    _dismissAfterClickButton = YES;
}

// MARK: - layout

- (void)viewDidLayoutSubviews
{
    if(!self.isViewDidLayoutSubviews){
        
        GKAlertProps *props = self.props;
        CGFloat width = [self alertViewWidth];
        CGFloat margin = (self.view.gkWidth - width) / 2.0;
        
        self.container.backgroundColor = props.mainColor;
        self.container.layer.cornerRadius = props.cornerRadius;
        self.container.layer.masksToBounds = YES;
        
        
        if(self.alertTitle || self.message || self.icon){
            self.header = [[GKAlertHeader alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
            CGFloat constraintWidth = self.header.gkWidth - props.textInsets.left - props.textInsets.right;
            
            CGFloat y = props.textInsets.top;
            if(self.icon){
                self.header.imageView.image = self.icon;
                if(self.icon.size.width > constraintWidth){
                    CGSize size = [self.icon gkFitWithSize:CGSizeMake(constraintWidth, 0)];
                    self.header.imageView.frame = CGRectMake((self.header.gkWidth - size.width) / 2, y, size.width, size.height);
                }else{
                    self.header.imageView.frame = CGRectMake((self.header.gkWidth - self.icon.size.width) / 2, y, self.icon.size.width, self.icon.size.height);
                }
                y += self.header.imageView.gkHeight;
            }
            
            if(self.alertTitle){
                if(self.icon){
                    y += props.verticalSpacing;
                }
                self.header.titleLabel.font = props.titleFont;
                self.header.titleLabel.textColor = props.titleTextColor;
                self.header.titleLabel.textAlignment = props.titleTextAlignment;
                
                CGSize size = CGSizeZero;
                if([self.alertTitle isKindOfClass:[NSString class]]){
                    self.header.titleLabel.text = self.alertTitle;
                    size = [self.alertTitle gkStringSizeWithFont:props.titleFont contraintWith:constraintWidth];
                }else if([self.alertTitle isKindOfClass:[NSAttributedString class]]){
                    self.header.titleLabel.attributedText = self.alertTitle;
                    size = [self.alertTitle gkBoundsWithConstraintWidth:constraintWidth];
                }
                
                self.header.titleLabel.frame = CGRectMake(props.textInsets.left, y, constraintWidth, size.height);
                y += self.header.titleLabel.gkHeight;
            }
            
            if(self.message){
                if(self.icon || self.alertTitle){
                    y += props.verticalSpacing;
                }
                self.header.messageLabel.font = props.messageFont;
                self.header.messageLabel.textColor = props.messageTextColor;
                self.header.messageLabel.textAlignment = props.messageTextAlignment;
                
                CGSize size = CGSizeZero;
                if([self.message isKindOfClass:[NSString class]]){
                    self.header.messageLabel.text = self.message;
                    size = [self.message gkStringSizeWithFont:props.messageFont contraintWith:constraintWidth];
                }else if ([self.message isKindOfClass:[NSAttributedString class]]){
                    self.header.messageLabel.attributedText = self.message;
                    size = [self.message gkBoundsWithConstraintWidth:constraintWidth];
                }
                self.header.messageLabel.frame = CGRectMake(props.textInsets.left, y, constraintWidth, size.height);
                y += self.header.messageLabel.gkHeight;
            }
            
            self.header.gkHeight = y + props.textInsets.bottom;
            
            //小于最低高度
            if(self.header.gkHeight < props.contentMinHeight){
                CGFloat rest = (props.contentMinHeight - self.header.gkHeight) / 2.0;
                CGFloat y = props.textInsets.top + rest;
                if(self.icon){
                    self.header.imageView.gkTop = y;
                    y += self.header.imageView.gkHeight;
                }
                
                if(self.alertTitle){
                    if(self.icon){
                        y += props.verticalSpacing;
                    }
                    self.header.titleLabel.gkTop = y;
                    y += self.header.titleLabel.gkHeight;
                }
                
                if(self.message){
                    if(self.icon || self.alertTitle){
                        y += props.verticalSpacing;
                    }
                    self.header.messageLabel.gkTop = y;
                    y += self.header.messageLabel.gkHeight;
                }
                self.header.gkHeight = y + props.textInsets.bottom + rest;
            }
            self.header.contentSize = CGSizeMake(self.header.gkWidth, self.header.gkHeight);
            
            self.header.backgroundColor = props.mainColor;
            [self.container addSubview:self.header];
        }
        
        switch (_style){
            case GKAlertStyleAlert : {
                self.container.frame = CGRectMake(margin, margin, width, 0);
            }
                break;
            case GKAlertStyleActionSheet : {
                
                self.container.frame = CGRectMake(props.contentInsets.left, margin, width, 0);
                
                if(![NSString isEmpty:self.cancelTitle]){
                    CGFloat height = props.buttonHeight;
                    CGFloat bottom = UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom;
                    if (props.contentInsets.bottom == 0 && bottom > 0) {
                        height += bottom;
                    } else {
                        bottom = 0;
                    }
                    
                    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, width, height)];
                    self.cancelButton.layer.cornerRadius = props.cornerRadius;
                    self.cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, bottom, 0);
                    [self.cancelButton gkSetBackgroundColor:props.mainColor forState:UIControlStateNormal];
                    [self.cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
                    [self.cancelButton setTitleColor:props.cancelButtonTextColor forState:UIControlStateNormal];
                    self.cancelButton.titleLabel.font = props.cancelButtonFont;
                    [self.cancelButton gkSetBackgroundColor:props.highlightedBackgroundColor forState:UIControlStateHighlighted];
                    [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
                    
                    //取消按钮和 内容视图的间隔
                    if(props.spacingBackgroundColor && props.cancelButtonVerticalSpacing > 0){
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -props.cancelButtonVerticalSpacing, self.cancelButton.gkWidth, props.cancelButtonVerticalSpacing)];
                        view.backgroundColor = props.spacingBackgroundColor;
                        [self.cancelButton addSubview:view];
                        self.cancelButton.clipsToBounds = NO;
                    }
                    
                    [self.view addSubview:self.cancelButton];
                }
                
                if (props.cancelButtonVerticalSpacing == 0) {
                    self.container.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                    if (props.contentInsets.bottom == 0) {
                        self.cancelButton.layer.cornerRadius = 0;
                    } else {
                        self.cancelButton.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                    }
                }
            }
                break;
        }
        
        if(self.actions.count > 0){
            self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.header.gkBottom, width, 0)collectionViewLayout:[self layout]];
            self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            [self.collectionView registerClass:[GKAlertCell class] forCellWithReuseIdentifier:@"GKAlertCell"];
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
            self.collectionView.bounces = NO;
            self.collectionView.showsHorizontalScrollIndicator = NO;
            [self.container addSubview:self.collectionView];
        }
        
        [self layoutSubViews];
    }
    [super viewDidLayoutSubviews];
}

///弹窗宽度
- (CGFloat)alertViewWidth
{
    switch (_style){
        case GKAlertStyleAlert :
            return 260 + UIApplication.gkSeparatorHeight;
        case GKAlertStyleActionSheet : {
            GKAlertProps *props = self.props;
            return self.view.gkWidth - props.contentInsets.left - props.contentInsets.right;
        }
    }
}

///collectionView布局方式
- (UICollectionViewFlowLayout*)layout
{
    GKAlertProps *props = self.props;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = UIApplication.gkSeparatorHeight;
    layout.minimumLineSpacing = UIApplication.gkSeparatorHeight;
    
    switch (_style){
        case GKAlertStyleActionSheet : {
            layout.itemSize = CGSizeMake([self alertViewWidth], props.buttonHeight);
        }
            break;
        case GKAlertStyleAlert : {
            layout.itemSize = CGSizeMake(self.actions.count == 2 ? ([self alertViewWidth] - UIApplication.gkSeparatorHeight) / 2.0 : [self alertViewWidth], props.buttonHeight);
            layout.scrollDirection = self.actions.count > 2 ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
        }
            break;
    }
    
    return layout;
}

///布局子视图
- (void)layoutSubViews
{
    GKAlertProps *props = self.props;
    
    //头部高度
    CGFloat headerHeight = 0;
    if(self.header){
        headerHeight = self.header.gkHeight;
    }
    
    //按钮高度
    CGFloat buttonHeight = 0;
    
    if(self.actions.count > 0){
        switch (_style){
            case GKAlertStyleAlert : {
                buttonHeight = self.actions.count < 3 ? props.buttonHeight : self.actions.count * (UIApplication.gkSeparatorHeight + props.buttonHeight);
                if(headerHeight > 0){
                    buttonHeight += 0.1;
                }
            }
                break;
            case GKAlertStyleActionSheet : {
                buttonHeight = self.actions.count * props.buttonHeight + (self.actions.count - 1) * UIApplication.gkSeparatorHeight;
                
                if(headerHeight > 0){
                    buttonHeight += UIApplication.gkSeparatorHeight;
                }
            }
                break;
        }
    }
    
    
    //取消按钮高度
    CGFloat cancelHeight = self.cancelButton ? (self.cancelButton.gkHeight + props.contentInsets.bottom) : 0;
    CGFloat maxContentHeight = self.view.gkHeight - props.contentInsets.top - props.contentInsets.bottom - cancelHeight;
    
    CGRect frame = self.collectionView.frame;
    if(headerHeight + buttonHeight > maxContentHeight){
        CGFloat contentHeight = maxContentHeight;
        if(headerHeight >= contentHeight / 2.0 && buttonHeight >= contentHeight / 2.0){
            self.header.gkHeight = contentHeight / 2.0;
            frame.size.height = buttonHeight;
        }else if (headerHeight >= contentHeight / 2.0 && buttonHeight < contentHeight / 2.0){
            self.header.gkHeight = contentHeight - buttonHeight;
            frame.size.height = buttonHeight;
        }else{
            self.header.gkHeight = headerHeight;
            frame.size.height = contentHeight - headerHeight;
        }
        
        frame.origin.y = self.header.gkBottom;
        self.collectionView.frame = frame;
        self.container.gkHeight = maxContentHeight;
    }else{
        
        frame.origin.y = self.header.gkBottom;
        frame.size.height = buttonHeight;
        self.collectionView.frame = frame;
        self.container.gkHeight = headerHeight + buttonHeight;
    }
    
    if(self.header.gkHeight > 0){
        self.collectionView.gkHeight += UIApplication.gkSeparatorHeight;
        self.container.gkHeight += UIApplication.gkSeparatorHeight;
    }
    
    switch (_style){
        case GKAlertStyleActionSheet : {
            self.container.gkTop = self.view.gkHeight;
        }
            break;
        case GKAlertStyleAlert : {
            self.container.gkTop = (self.view.gkHeight - self.container.gkHeight) / 2.0;
        }
            break;
    }
    
    self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
}

// MARK: - private method

///取消
- (void)cancel:(id) sender
{
    NSUInteger index = 0;
    if(_style == GKAlertStyleActionSheet){
        index = self.actions.count;
    }
    
    void(^handler)(NSUInteger index) = self.selectHandler;
    self.dialogDismissCompletionHandler = ^{
        !handler ?: handler(index);
    };
    [self dismiss];
}

- (void)didExecuteDialogShowCustomAnimate:(void (^)(BOOL))completion
{
    switch (_style){
        case GKAlertStyleAlert : {
            self.container.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.dialogBackgroundView.alpha = 1.0;
                self.container.alpha = 1.0;
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.fromValue = @(1.3);
                animation.toValue = @(1.0);
                animation.duration = 0.25;
                [self.container.layer addAnimation:animation forKey:@"scale"];
            } completion:completion];
        }
            break;
        case GKAlertStyleActionSheet : {
            GKAlertProps *props = self.props;
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void){
                
                CGFloat spacing = self.cancelButton ? props.cancelButtonVerticalSpacing : 0;
                self.dialogBackgroundView.alpha = 1.0;
                self.container.gkTop = self.view.gkHeight - self.container.gkHeight - props.contentInsets.bottom - self.cancelButton.gkHeight - spacing;
                self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
            }completion:completion];
        }
            break;
    }
}

- (void)didExecuteDialogDismissCustomAnimate:(void (^)(BOOL))completion
{
    switch (_style){
        case GKAlertStyleAlert : {
            [UIView animateWithDuration:0.25 animations:^(void){
                
                self.dialogBackgroundView.alpha = 0;
                self.container.alpha = 0;
                
            }completion:completion];
        }
            break;
        case GKAlertStyleActionSheet : {
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void){
                
                self.dialogBackgroundView.alpha = 0;
                self.container.gkTop = self.view.gkHeight;
                GKAlertProps *props = self.props;
                self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
                
            }completion:completion];
        }
            break;
    }
}

// MARK: - public method

- (void)reloadButtonForIndex:(NSUInteger) index
{
    if(index < self.actions.count){
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }
}

- (NSString*)buttonTitleForIndex:(NSUInteger) index
{
    if(index < self.actions.count){
        GKAlertAction *action = self.actions[index];
        return action.title;
    }
    
    if(self.style == GKAlertStyleActionSheet && index == self.actions.count){
        return self.cancelTitle;
    }
    
    return nil;
}

- (void)show
{
    [self showAsDialog];
}

- (void)dismiss
{
    [self dismissDialog];
}

// MARK: - UITapGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.dialogBackgroundView];
    point.y += self.dialogBackgroundView.gkTop;
    if(CGRectContainsPoint(self.container.frame, point)){
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.dialogBackgroundView;
}

// MARK: - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(self.header.gkHeight > 0){
        return UIEdgeInsetsMake(UIApplication.gkSeparatorHeight, 0, 0, 0);
    }else{
        return UIEdgeInsetsZero;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKAlertCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKAlertCell" forIndexPath:indexPath];
    
    GKAlertAction *action = self.actions[indexPath.item];
    GKAlertProps *props = self.props;
    UIFont *font;
    UIColor *textColor;
    
    if(action.enabled){
        BOOL isCancel = NO;
        if(self.style == GKAlertStyleAlert && self.cancelTitle){
            isCancel = (indexPath.item == 0 && self.actions.count < 3) || (indexPath.item == self.actions.count - 1 && self.actions.count >= 3);
        }
        
        if(isCancel){
            textColor = action.textColor ? action.textColor : props.cancelButtonTextColor;
            font = action.font ? action.font : props.cancelButtonFont;
        }else if(indexPath.item == _destructiveButtonIndex){
            textColor = action.textColor ? action.textColor : props.destructiveButtonTextColor;
            font = action.font ? action.font : props.destructiveButtonFont;
        }else{
            textColor = action.textColor ? action.textColor : props.buttonTextColor;
            font = action.font ? action.font : props.butttonFont;
        }
    }else{
        textColor = props.disableButtonTextColor;
        font = props.disableButtonFont;
    }
    
    [cell.button setTitleColor:textColor forState:UIControlStateNormal];
    cell.button.titleLabel.font = font;
    
    [cell.button setTitle:action.title forState:UIControlStateNormal];
    [cell.button setImage:action.icon forState:UIControlStateNormal];
    cell.button.imagePadding = action.spacing;
    cell.button.imagePosition = action.imagePosition;
    cell.selectedBackgroundView.backgroundColor = props.highlightedBackgroundColor;
    
    if(indexPath.item == _destructiveButtonIndex && props.destructiveButtonBackgroundColor){
        cell.backgroundColor = props.destructiveButtonBackgroundColor;
    }else{
        cell.backgroundColor = props.mainColor;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    GKAlertAction *action = self.actions[indexPath.item];
    if(action.enabled){
        if(self.dismissAfterClickButton){
            
            void(^handler)(NSUInteger index) = self.selectHandler;
            [self dismissDialogAnimated:YES completion:^{
                !handler ?: handler(indexPath.item);
            }];
        }else{
            !self.selectHandler ?: self.selectHandler(indexPath.item);
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.actions[indexPath.item].enabled;
}

// MARK: - property

- (GKAlertProps*)props
{
    if(!_props){
        _props = _style == GKAlertStyleActionSheet ? [GKAlertProps defaultActionSheetProps] : [GKAlertProps defaultAlertProps];
    }
    return _props;
}

- (NSArray<GKAlertAction*>*)alertActions
{
    return [self.actions copy];
}

@end
