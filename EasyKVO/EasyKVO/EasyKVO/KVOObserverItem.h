//
//  KVOMapTable.h
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/15.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+KVOBlock.h"

@interface KVOObserverItem : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) lxz_KVOObserverBlock block;

- (instancetype)initWithObserver:(NSObject *)observer
                             key:(NSString *)key
                           block:(lxz_KVOObserverBlock)block;

@end
