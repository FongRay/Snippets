//
//  main-runtime.m
//  Snippets-Mac
//
//  Created by Ray Fong on 2019/9/8.
//  Copyright © 2019 YiMu. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef _MAIN_RUNTIME_
@interface Father : NSObject
@end
@implementation Father

+ (Class)class {
    return [NSDictionary class];
}

@end

@interface Son : Father
@end
@implementation Son

- (id)init {
    if (self = [super init]) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Son *s = [Son new];
        NSLog(@"%@, %@", [Son class], [Son superclass]);

        sleep(1000);
    }
}
#endif
