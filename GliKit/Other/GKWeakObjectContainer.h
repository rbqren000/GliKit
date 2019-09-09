//
//  GKWeakObjectContainer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

///主要用于类目中设置 weak的属性， 因为 objc_setAssociatedObject 是没有weak的
@interface GKWeakObjectContainer<__covariant ObjectType> : NSObject

///需要weak引用的对象
@property(nonatomic, weak) ObjectType weakObject;

+ (instancetype)containerWithObject:(ObjectType) object;

@end
