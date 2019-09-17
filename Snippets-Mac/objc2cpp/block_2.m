//
//  block_2.cpp
//  omeD
//
//  Created by Ray Fong on 2019/9/1.
//  Copyright © 2019 Ray Fong. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>

int main () {
    void (^block)(int a, NSString *b) = ^(int a, NSString *b){
        printf("Block !!");
        NSLog(@"%d, %@", a, b);
    };

    block(1, @"fuck");
}
