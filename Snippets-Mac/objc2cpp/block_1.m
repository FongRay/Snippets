#include <stdio.h>

// clang -rewrite-objc xx.m -o xx.cpp
int main () {
    __block int a = 1;
    void (^block)(void) = ^{
        a = 2;
        printf("Block2 !! %d", a);
    };
    block();
}
