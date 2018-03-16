//
//  NSObject+KVOBlock.h
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/12.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^lxz_KVOObserverBlock) (id observedObject, NSString *observedKey, id oldValue, id newValue);

@interface NSObject (KVOBlock)

- (void)lxz_addObserver:(NSObject *)observer
       originalSelector:(SEL)originalSelector
               callback:(lxz_KVOObserverBlock)callback;

- (void)lxz_removeObserver:(NSObject *)observer
          originalSelector:(SEL)originalSelector;

@end
