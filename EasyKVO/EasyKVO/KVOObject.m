//
//  KVOObject.m
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/11.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import "KVOObject.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation KVOObject

- (NSString *)description {
    NSLog(@"object address : %p \n", self);
    
    IMP nameIMP = class_getMethodImplementation(object_getClass(self), @selector(setName:));
    IMP ageIMP = class_getMethodImplementation(object_getClass(self), @selector(setAge:));
    NSLog(@"object setName: IMP %p object setAge: IMP %p \n", nameIMP, ageIMP);
    
    Class objectMethodClass = [self class];
    Class objectRuntimeClass = object_getClass(self);
    Class superClass = class_getSuperclass(objectRuntimeClass);
    NSLog(@"objectMethodClass : %@, ObjectRuntimeClass : %@, superClass : %@ \n", objectMethodClass, objectRuntimeClass, superClass);
    
    NSLog(@"object method list \n");
    unsigned int count;
    Method *methodList = class_copyMethodList(objectRuntimeClass, &count);
    for (NSInteger i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        NSLog(@"method Name = %@\n", methodName);
    }
    free(methodList);
    
    return @"";
}

@end
