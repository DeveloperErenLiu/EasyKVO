//
//  KVOMapTable.m
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/15.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import "KVOObserverItem.h"

@implementation KVOObserverItem

- (instancetype)initWithObserver:(NSObject *)observer
                             key:(NSString *)key
                           block:(lxz_KVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.observer = observer;
        self.key = key;
        self.block = block;
    }
    return self;
}

@end
