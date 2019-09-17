//
//  main-category.m
//  Snippets-Mac
//
//  Created by Ray Fong on 2019/9/8.
//  Copyright © 2019 YiMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+c1.h"
#import "NSArray+c2.h"

#ifdef _MAIN_CATEGORY_

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *array = [NSArray array];
        // 结果与工程设置中 Build Phases/Compile Sources 中的 category 顺序有关，执行的是被后编译的文件
        // 但如果多个 framework 都实现了同一方法，结果是未知的
        // 总的来说，结果是 undefined，所以不要重写系统同名方法
        NSLog(@"%@", [array descriptionWithLocale:nil]);

        NSString *str1 = @"hello1";
        NSMutableString *str2 = @"hello2";
        NSArray *test1 = @[str1, str2];
        NSInteger idx = [test1 indexOfObject:str1];
        NSLog(@"%p %p", str1, str2);
    }
}

#endif
