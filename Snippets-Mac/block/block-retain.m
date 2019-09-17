//
//  block-retain.m
//  Snippets-Mac
//
//  Created by Ray Fong on 2019/9/18.
//  Copyright © 2019 YiMu. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef _MAIN_BLOCK_2_
@interface MyClass : NSObject
@property (nonatomic, copy) dispatch_block_t myBlock;
@end

@implementation MyClass
@end

void test() {
    MyClass *cls = [[MyClass alloc] init];
    cls.myBlock = ^{
        NSLog(@"%@", cls.description);
    };
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test();
    }
}
#endif
