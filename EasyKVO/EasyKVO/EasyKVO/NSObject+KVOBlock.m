//
//  NSObject+KVOBlock.m
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/12.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import "NSObject+KVOBlock.h"
#import "KVOObserverItem.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void *const lxz_KVOObserverAssociatedKey = (void *)&lxz_KVOObserverAssociatedKey;
static NSString *lxz_KVOClassPrefix = @"lxz_KVONotifying_";

@implementation NSObject (KVOBlock)

/**
 1. 通过Method判断是否有这个key对应的selector，如果没有则Crash。
 2. 判断当前类是否是KVO子类，如果不是则创建，并设置其isa指针。
 3. 如果没有实现，则添加Key对应的setter方法。
 4. 将调用对象添加到数组中。
 */
- (void)lxz_addObserver:(NSObject *)observer
       originalSelector:(SEL)originalSelector
               callback:(lxz_KVOObserverBlock)callback {
    
    // 1.
    SEL originalSetter = NSSelectorFromString(lxz_setterForGetter(originalSelector));
    Method originalMethod = class_getInstanceMethod(object_getClass(self), originalSetter);
    if (!originalMethod) {
        NSString *exceptionReason = [NSString stringWithFormat:@"%@ Class %@ setter SEL not found.", NSStringFromClass([self class]), NSStringFromSelector(originalSelector)];
        NSException *exception = [NSException exceptionWithName:@"NotExistKeyExceptionName" reason:exceptionReason userInfo:nil];
        [exception raise];
    }
    
    // 2.
    Class kvoClass = object_getClass(self);
    NSString *kvoClassString = NSStringFromClass(kvoClass);
    if (![kvoClassString hasPrefix:lxz_KVOClassPrefix]) {
        kvoClass = [self lxz_makeKVOClassWithName:kvoClassString];
        object_setClass(self, kvoClass);
    }
    
    // 3.
    if (![self lxz_hasMethodWithKey:originalSetter]) {
        class_addMethod(kvoClass, originalSetter, (IMP)lxz_kvoSetter, method_getTypeEncoding(originalMethod));
    }
    
    // 4.
    KVOObserverItem *observerItem = [[KVOObserverItem alloc] initWithObserver:observer key:NSStringFromSelector(originalSelector) block:callback];
    NSMutableArray<KVOObserverItem *> *observers = objc_getAssociatedObject(self, lxz_KVOObserverAssociatedKey);
    if (observers == nil) {
        observers = [NSMutableArray array];
    }
    [observers addObject:observerItem];
    objc_setAssociatedObject(self, lxz_KVOObserverAssociatedKey, observers, OBJC_ASSOCIATION_RETAIN);
}

- (void)lxz_removeObserver:(NSObject *)observer
          originalSelector:(SEL)originalSelector {
    NSMutableArray <KVOObserverItem *>* observers = objc_getAssociatedObject(self, lxz_KVOObserverAssociatedKey);
    [observers enumerateObjectsUsingBlock:^(KVOObserverItem * _Nonnull mapTable, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(mapTable.key);
        if (mapTable.observer == observer && selector == originalSelector) {
            [observers removeObject:mapTable];
        }
    }];
}

#pragma mark - ----- Private Method Or Funcation ------

/**
 1. 获取旧值。
 2. 创建super的结构体，并向super发送属性的消息。
 3. 遍历调用block。
 */
static void lxz_kvoSetter(id self, SEL selector, id value) {
    // 1.
    id (*getterMsgSend) (id, SEL) = (void *)objc_msgSend;
    NSString *getterString = lxz_getterForSetter(selector);
    SEL getterSelector = NSSelectorFromString(getterString);
    id oldValue = getterMsgSend(self, getterSelector);
    
    // 2.
    id (*msgSendSuper) (void *, SEL, id) = (void *)objc_msgSendSuper;
    struct objc_super objcSuper = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    msgSendSuper(&objcSuper, selector, value);
    
    // 3.
    NSMutableArray <KVOObserverItem *>* observers = objc_getAssociatedObject(self, lxz_KVOObserverAssociatedKey);
    [observers enumerateObjectsUsingBlock:^(KVOObserverItem * _Nonnull mapTable, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([mapTable.key isEqualToString:getterString] && mapTable.block) {
            mapTable.block(self, NSStringFromSelector(selector), oldValue, value);
        }
    }];
}

- (BOOL)lxz_hasMethodWithKey:(SEL)key {
    NSString *setterName = NSStringFromSelector(key);
    unsigned int count;
    Method *methodList = class_copyMethodList(object_getClass(self), &count);
    for (NSInteger i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if ([methodName isEqualToString:setterName]) {
            return YES;
        }
    }
    return NO;
}

static NSString * lxz_getterForSetter(SEL setter) {
    NSString *setterString = NSStringFromSelector(setter);
    if (![setterString hasPrefix:@"set"]) {
        return nil;
    }
    
    NSString *getterString = [setterString substringWithRange:NSMakeRange(4, setterString.length - 5)];
    NSString *firstString = [setterString substringWithRange:NSMakeRange(3, 1)];
    firstString = [firstString lowercaseString];
    getterString = [NSString stringWithFormat:@"%@%@", firstString, getterString];
    return getterString;
}

static NSString * lxz_setterForGetter(SEL getter) {
    NSString *getterString = NSStringFromSelector(getter);
    NSString *firstString = [getterString substringToIndex:1];
    firstString = [firstString uppercaseString];
    
    NSString *setterString = [getterString substringFromIndex:1];
    setterString = [NSString stringWithFormat:@"set%@%@:", firstString, setterString];
    return setterString;
}

/**
 1. 判断是否存在KVO类，如果存在则返回。
 2. 如果不存在，则创建KVO类。
 3. 重写KVO类的class方法，指向自定义的IMP。
 */
- (Class)lxz_makeKVOClassWithName:(NSString *)name {
    // 1.
    NSString *className = [NSString stringWithFormat:@"%@%@", lxz_KVOClassPrefix, name];
    Class kvoClass = objc_getClass(className.UTF8String);
    if (kvoClass) {
        return kvoClass;
    }
    
    // 2.
    kvoClass = objc_allocateClassPair(object_getClass(self), className.UTF8String, 0);
    objc_registerClassPair(kvoClass);
    
    // 3.
    Method method = class_getInstanceMethod(object_getClass(self), @selector(class));
    const char *types = method_getTypeEncoding(method);
    class_addMethod(kvoClass, @selector(class), (IMP)lxz_kvoClass, types);
    
    return kvoClass;
}

static Class lxz_kvoClass(id self, SEL selector) {
    return class_getSuperclass(object_getClass(self));
}

@end
