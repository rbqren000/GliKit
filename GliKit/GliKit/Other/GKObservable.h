//
//  GKObservable.h
//  GliKit
//
//  Created by 罗海雄 on 2020/9/8.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKObject.h"

NS_ASSUME_NONNULL_BEGIN

/// 回调
/// @param keyPath  属性，和addObserver 中的一致
/// @param newValue 新值 值类型要拆箱
/// @param oldValue 旧值 值类型要拆箱
typedef void(^GKObserverCallback)(NSString *keyPath, id _Nullable newValue, id _Nullable oldValue);

///可观察的对象
@interface GKObservable : GKObject

///是否监听只读属性 default is `NO`
@property(nonatomic, assign) BOOL shouldObserveReadonly;

/// 添加一个观察者，必须通过 .语法 设置新值才会触发回调
/// @param observer 观察者，将使用hash作为 key来保持
/// @param callback 回调
/// @param keyPath 要监听的属性
- (void)addObserver:(NSObject*) observer callback:(GKObserverCallback) callback forKeyPath:(NSString*) keyPath;
- (void)addObserver:(NSObject*) observer callback:(GKObserverCallback) callback forKeyPaths:(NSArray<NSString*>*) keyPaths;
- (void)addObserver:(NSObject*) observer callback:(GKObserverCallback) callback;


/// 移除观察者
/// @param observer 观察者，将使用hash作为 key来保持
/// @param keyPath 监听的属性，如果为空，则移除observer对应的所有 keyPath
- (void)removeObserver:(NSObject*) observer forKeyPath:(NSString*) keyPath;
- (void)removeObserver:(NSObject*) observer forKeyPaths:(NSArray<NSString*>*) keyPaths;
- (void)removeObserver:(NSObject*) observer;

@end

NS_ASSUME_NONNULL_END