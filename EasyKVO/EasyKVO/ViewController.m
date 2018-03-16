//
//  ViewController.m
//  EasyKVO
//
//  Created by 刘小壮 on 2018/3/16.
//  Copyright © 2018年 刘小壮. All rights reserved.
//

#import "ViewController.h"
#import "KVOObject.h"
#import "NSObject+KVOBlock.h"

@interface ViewController ()
@property (nonatomic, strong) KVOObject *object1;
@property (nonatomic, strong) KVOObject *object2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.object1 = [[KVOObject alloc] init];
    self.object2 = [[KVOObject alloc] init];
    [self.object1 description];
    [self.object2 description];
    
    [self.object1 lxz_addObserver:self originalSelector:@selector(name) callback:^(id observedObject, NSString *observedKey, id oldValue, id newValue) {
        
    }];
    
    [self.object1 description];
    [self.object2 description];
    
    self.object1.name = @"lxz";
    self.object1.age = 20;
    
    [self.object1 lxz_removeObserver:self originalSelector:@selector(name)];
}

@end
