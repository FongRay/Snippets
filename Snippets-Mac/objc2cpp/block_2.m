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
    void (^block)(...) = ^(...) {
        NSLog(@"Block!");
    };

    block(1, @{}, @[@"666"], 999.9999);
}
