//
//  GKCollectionViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCollectionViewController.h"
#import "UICollectionView+GKUtils.h"
#import "UIView+GKEmptyView.h"
#import "GKCollectionViewConfig.h"
#import "GKBaseDefines.h"

@interface GKCollectionViewController ()

@end

@implementation GKCollectionViewController

@synthesize collectionView = _collectionView;
@synthesize flowLayout = _flowLayout;

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout*) layout
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.curPage = 1;
        self.layout = layout;
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithFlowLayout:nil];
}


// MARK: - Init

- (UICollectionViewFlowLayout*)flowLayout
{
    if(!_flowLayout){
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
    }
    
    return _flowLayout;
}

- (UICollectionViewLayout*)layout
{
    if(!_layout){
        return self.flowLayout;
    }
    
    return _layout;
}

- (UICollectionView*)collectionView
{
    [self initCollectionView];
    return _collectionView;
}

- (void)initScrollViewIfNeeded
{
    [self initCollectionView];
}

- (void)initCollectionView
{
    if(_collectionView == nil){
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.backgroundView = nil;
        _collectionView.gkEmptyViewDelegate = self;
        self.scrollView = _collectionView;
    }
}

- (void)initViews
{
    [super initViews];
    [self initCollectionView];
    if(self.config){
        NSAssert([self.config isKindOfClass:GKCollectionViewConfig.class], @"%@.config 必须是GKCollectionViewConfig的子类", NSStringFromClass(self.class));
        [self.config config];
        _collectionView.dataSource = self.config;
        _collectionView.delegate = self.config;
    }else{
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    self.contentView = _collectionView;
}

- (void)reloadListData
{
    if(self.isInit){
        [self.collectionView reloadData];
    }
}

// MARK: - Register Cell

- (void)registerNib:(Class)clazz
{
    [self.collectionView registerNib:clazz];
}

- (void)registerClass:(Class) clazz
{
    [self.collectionView registerClass:clazz];
}

- (void)registerHeaderClass:(Class) clazz
{
    [self.collectionView registerHeaderClass:clazz];
}

- (void)registerHeaderNib:(Class) clazz
{
    [self.collectionView registerHeaderNib:clazz];
}

- (void)registerFooterClass:(Class) clazz
{
    [self.collectionView registerFooterClass:clazz];
}

- (void)registerFooterNib:(Class) clazz
{
    [self.collectionView registerFooterNib:clazz];
}

// MARK: - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GKThrowNotImplException
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKThrowNotImplException
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    //防止挡住滚动条
    view.layer.zPosition = 0;
}

@end
