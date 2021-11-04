//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GliKitDemo-Swift.h>
#import <GKAppUtils.h>
#import <NSJSONSerialization+GKUtils.h>
#import <SDWebImageDownloader.h>

@interface GKParent : NSObject<NSCopying>

@property(nonatomic, copy) NSString *name;

@end

@implementation GKParent

GKConvenientCopying

@end

@interface GKChild : GKParent

@property(nonatomic, copy) NSString *childName;

@end

@implementation GKChild

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@interface CATextContainer : NSTextContainer

@end

@implementation CATextContainer
//
//- (CGSize)size
//{
//    CGSize size = [super size];
//    NSLog(@"%@", NSStringFromCGSize(size));
//    return size;
//}

@end

@interface CALayoutManager : NSLayoutManager

@end

@implementation CALayoutManager

- (CGRect)usedRectForTextContainer:(NSTextContainer *)container
{
    CGRect rect = [super usedRectForTextContainer:container];
    NSLog(@"%@", NSStringFromCGRect(rect));
//    rect.size.height += 10;
    return rect;
}

@end

@interface DemoView : UIView

@end

@implementation DemoView

- (void)drawRect:(CGRect)rect
{
    
}

@end

@interface GKDRootViewController ()

@property(nonatomic, strong) UILabel *countLabel;

@property(nonatomic, assign) NSInteger count;



@end

@interface GKDRootViewController ()

///
@property(nonatomic, copy) NSString *dir;
@property(nonatomic, copy) NSString *doc;
@property(nonatomic, copy) NSString *imageDir;
@property(nonatomic, strong) NSArray *files;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = GKAppUtils.appName;
    
//    UITextView *textView = [UITextView new];
//    textView.text = @"လက်ခံသူအကောင့် nomnal 粗体";
//    UIFont *font = [UIFont fontWithName:@"NotoSansMyanmar-Bold" size:15];
//    textView.font = font;
//    [self.view addSubview:textView];
//
//    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(20);
//        make.top.equalTo(150);
//        make.trailing.equalTo(-20);
//        make.height.equalTo(100);
//    }];
//
//    textView = [UITextView new];
//    textView.text = @"လက်ခံသူအကောင့် nomnal 粗体";
//    font = [UIFont fontWithName:@"Oxygen-Bold" size:15];
//    textView.font = font;
//    [self.view addSubview:textView];
//
//    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(20);
//        make.top.equalTo(280);
//        make.trailing.equalTo(-20);
//        make.height.equalTo(100);
//    }];
//
//    DemoView *view = [DemoView new];
//    [self.view addSubview:view];
//
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(0);
//    }];
//
//    dispatch_main_after(1, ^{
//        NSLog(@"%@", view.layer.contents);
//    })
    
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"user/photo"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"skeleton"],
                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:@"GKDTransitionViewController"],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"GKDNestedParentViewController"],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   ];


    [self initViews];

//    self.countLabel = [UILabel new];
//    self.countLabel.text = @"0";
//    self.countLabel.font = [UIFont boldSystemFontOfSize:40];
//    [self.view addSubview:self.countLabel];
//
//    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(0);
//    }];
    
    [self gkSetLeftItemWithTitle:@"左边" action:@selector(start)];
    
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dir = [doc stringByAppendingPathComponent:@"车"];
    NSString *imageDir = [doc stringByAppendingPathComponent:@"图片"];
    
    NSFileManager *manager = NSFileManager.defaultManager;
    self.files = [manager contentsOfDirectoryAtPath:dir error:nil];
    self.dir = dir;
    self.imageDir = imageDir;
    self.doc = doc;
}

- (void)start
{
    [self downloadNext];
}

- (void)downloadNext
{
    if (self.count < self.files.count) {
        [self downloadForFilename:self.files[self.count]];
        self.countLabel.text = [NSString stringWithFormat:@"%ld", self.count + 1];
    }
}

- (void)downloadForFilename:(NSString*) filename
{
    NSString *file = [self.dir stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSDictionary *dic = [NSJSONSerialization gkDictionaryFromData:data];
    NSArray *list = [[[dic gkDictionaryForKey:@"result"] gkDictionaryForKey:@"getSingleFilterInfo"] gkArrayForKey:@"pList"];
    
    NSString *imageDir = [self.imageDir stringByAppendingPathComponent:[filename stringByReplacingOccurrencesOfString:@".json" withString:@""]];
    if (![NSFileManager.defaultManager fileExistsAtPath:imageDir isDirectory:nil]) {
        if (![NSFileManager.defaultManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"下载失败 %@", filename);
            self.count ++;
            [self downloadNext];
            return;
        }
    }
    
    NSInteger count = list.count;
    if (count > 0) {
        __block NSInteger totalCount = 0;
        for (NSDictionary *dict in list) {
            NSString *icon = [dict gkStringForKey:@"icon"];
            if (![NSString isEmpty:icon]) {
                NSString *title = [dict gkStringForKey:@"text"];
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:icon] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    
                    totalCount ++;
                    if (data) {
                        NSString *suffix = [[icon componentsSeparatedByString:@"."] lastObject];
                        if ([NSString isEmpty:suffix]) {
                            suffix = @"png";
                        }
                        NSString *imageFile = [imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", title, suffix]];
                        if (![data writeToFile:imageFile atomically:YES]) {
                            NSLog(@"写入文件失败 %@ - %@", filename, title);
                        }
                    } else {
                        NSLog(@"下载失败 %@ - %@", filename, title);
                    }
                    if (totalCount >= count) {
                        self.count ++;
                        [self downloadNext];
                    }
                }];
            } else {
                totalCount ++;
            }
        }
    } else {
        NSLog(@"下载失败 %@", filename);
        self.count ++;
        [self downloadNext];
    }
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:RootListCell.class];
    [super initViews];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"velocity %f %f, %f, %f", [scrollView.panGestureRecognizer velocityInView:scrollView].y, velocity.y, scrollView.contentOffset.y, targetContentOffset->y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f", scrollView.contentOffset.y);
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootListCell *cell = [tableView dequeueReusableCellWithIdentifier:RootListCell.gkNameOfClass forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    NSString *title = self.datas[indexPath.row % self.datas.count].title;
    if (indexPath.row % 2 == 0) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:title];
        [attr addAttribute:NSStrokeWidthAttributeName value:@(-2) range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSStrokeColorAttributeName value:UIColor.blackColor range:NSMakeRange(0, attr.length)];
        cell.textLabel.attributedText = attr;
    } else {
    cell.textLabel.text = title;
    }
    
    UIFont *font = [UIFont fontWithName:@"NotoSansMyanmar-Medium" size:17];
//    NSLog(@"%@", font);
    cell.textLabel.font = font;
    cell.textLabel.textColor = UIColor.blackColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = UIColor.redColor;
    cell.swipeDirection = GKSwipeDirectionLeft | GKSwipeDirectionRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
    [GKRouter.sharedRouter open:^(GKRouteConfig * _Nonnull config) {
        config.path = model.className;
    }];
}

- (NSArray<UIView *> *)swipeCell:(UIView<GKSwipeCell> *)cell swipeButtonsForDirection:(GKSwipeDirection)direction
{
    UIButton *deleteBtn = [UIButton new];
    deleteBtn.backgroundColor = UIColor.redColor;
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    deleteBtn.bounds = CGRectMake(0, 0, 100, 44);
    
    UIButton *btn = [UIButton new];
    btn.backgroundColor = UIColor.blueColor;
    [btn setTitle:@"收藏" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    btn.bounds = CGRectMake(0, 0, 100, 44);
    
    
    return @[deleteBtn, btn];
}

@end
