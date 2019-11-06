//
//  main.m
//  Snippets-Mac
//
//  Created by Yimu on 2019/9/1.
//  Copyright © 2019 Yimu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <iostream>
//#include <stdarg.h>
#import "fishhook.h"
#import "CTBlockDescription.h"

// --- 关于 block 的几个面试题 (by sunyuansunnyxx@didichuxing.com) --- //

/*** Problem #1 ***/
// 实现以下函数，将 block 的实现修改成 NSLog(@"Hello world"),
// 也就是说，在调用完这个函数后调用 block() 时，将不调用原始实现，而是打印出 "Hello world"
/*
 void HookBlockToPrintHelloWorld(id block) {
 }
 */

/*** Problem #2 ***/
// 实现以下函数，将 block 的实现修改成打印所有入参，并调用原始实现，
// 比如
// void (^block)(int a, NSString *b) = ^(int a, NSString *b) {
//     NSLog(@"block invoke");
// }
// HookBlockToPrintArguments(block);
// block(123, @"aaa");
// --- 这里应该输出 "123, aaa" 和 "block invoke"
//

/*
 void HookBlockToPrintArguments(id block) {
 }
 */


/*** Problem #3 ***/
// 实现以下函数，使得调用这个函数这个，后面创建的任意 block 都能自动实现第2题的功能
/*
 void HookEveryBlockToPrintArguments(void) {
 }
 */

// --- END --- //

// 注释下面这行，可以 hook 所有类型的 block
//#define SIMPLE_IMPL_HOOK

#ifdef _MAIN_BLOCK_
struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FunPtr;
};

struct __my_block_desc_x {
    size_t reserved;
    size_t Block_size;
    void (*copy)(struct __my_block_impl_x*, struct __main_block_impl_0*);
    void (*dispose)(struct __main_block_impl_0*);
};

struct __my_block_impl_x {
    struct __block_impl impl;
    struct __my_block_desc_x *Desc;
    __my_block_impl_x(void *fp, __my_block_desc_x *desc, int flags = 0) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FunPtr = fp;
        Desc = desc;
    }
};

#pragma mark - Problem #1

static void __my_block_func_0() {
    NSLog(@"<Hooked>\nHello world");
}

void HookBlockToPrintHelloWorld(id block) {
    struct __my_block_impl_x *t = (__bridge struct __my_block_impl_x *)block;
    t->impl.FunPtr = (void *)__my_block_func_0;
}

#pragma mark - Problem #2
#ifdef SIMPLE_IMPL_HOOK
typedef void(*SIMPLE_BLOCK)(void *f, int a, NSString *b);
SIMPLE_BLOCK origin_block;
#else
static __my_block_impl_x *origin_block;
#endif

//struct expand_type {
//    template<typename... T>
//    expand_type(T&&...) {}
//};
//template<typename... ArgTypes>
//void print(ArgTypes... args) {
//    expand_type{ 0, (std::cout << args << ",", 0)... };
//}

#ifdef SIMPLE_IMPL_HOOK
static void __my_block_func_1(void *f, int a, NSString *b) {
    NSLog(@"<Hooked> %d %@", a, b);
    origin_block(f, a, b);
}
#else
static void __my_block_func_1(struct __my_block_impl_x *__cself, ...) {
//    std::cout << __PRETTY_FUNCTION__ << std::endl;
    va_list args;
    va_start(args, __cself);
    NSObject *myBlock = CFBridgingRelease(origin_block);
    
    // https://opensource.apple.com/source/libclosure/libclosure-67/Block_private.h.auto.html
    // 私有 API 已不可用
//    const char *_Block_signature(void *);
//    const char *hookBlockSignature = _Block_signature((__bridge void *)myBlock);
//    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:hookBlockSignature];
    
    CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:myBlock];
    NSMethodSignature *methodSignature = ct.blockSignature;
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [blockInvocation setArgument:&myBlock atIndex:0];
    
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < methodSignature.numberOfArguments; ++i) {
        const char *s = [methodSignature getArgumentTypeAtIndex:i];
        NSString *str = [NSString stringWithUTF8String:s];
        [paramArray addObject:str];
    }
    NSInteger paramCount = 1;
    NSMutableString *paramLog = [NSMutableString stringWithString:@"<Hooked>\n"];
    // Objective-C type encodings https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    // String Format Specifiers https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
    static NSDictionary *type_code = @{@"c": @"char",
                                       @"i": @"int",
                                       @"s": @"short",
                                       @"l": @"long",
                                       @"q": @"long long",
                                       @"C": @"unsigned char",
                                       @"I": @"unsigned int",
                                       @"S": @"unsigned short",
                                       @"L": @"unsigned long",
                                       @"Q": @"unsigned long long",
                                       @"f": @"float",
                                       @"d": @"double",
                                       @"B": @"BOOL",
//                                       @"v": @"void",
                                       @"*": @"char *",
                                       @"@": @"id",
                                       @"#": @"Class",
                                       @":": @"SEL",
                                       @"?": @"unknown"
                                       };
    static NSDictionary *type_format = @{@"c": @"%c",
                                         @"i": @"%d",
                                         @"s": @"%hd",
                                         @"l": @"%ld",
                                         @"q": @"%lld",
                                         @"C": @"%c",
                                         @"I": @"%u",
                                         @"S": @"%hu",
                                         @"L": @"%lu",
                                         @"Q": @"%llu",
                                         @"f": @"%f",
                                         @"d": @"%lf",
                                         @"B": @"%@",
//                                         @"v": @"%@",
                                         @"*": @"%s",
                                         @"@": @"%@",
                                         @"#": @"%@",
                                         @":": @"%@",
                                         @"?": @"%p"
                                         };
    for (NSString *varType in paramArray) {
        NSString *code = [type_code objectForKey:varType] ?: @"unknown";
        NSString *format = [type_format objectForKey:varType] ?: @"%@";
        NSString *fmt = [NSString stringWithFormat:@"<%ld> [%@] %@\n", paramCount, code, format];
        // char
        if ([varType isEqualToString:@"c"]) {
            char arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // int
        else if ([varType isEqualToString:@"i"]) {
            int arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // short
        else if ([varType isEqualToString:@"s"]) {
            short arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // long
        else if ([varType isEqualToString:@"l"]) {
            long arg = va_arg(args, long);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // long long
        else if ([varType isEqualToString:@"q"]) {
            long long arg = va_arg(args, long long);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unsigned char
        else if ([varType isEqualToString:@"C"]) {
            unsigned char arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unsigned int
        else if ([varType isEqualToString:@"I"]) {
            unsigned int arg = va_arg(args, unsigned int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unsigned short
        else if ([varType isEqualToString:@"S"]) {
            unsigned short arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unsigned long
        else if ([varType isEqualToString:@"L"]) {
            unsigned long arg = va_arg(args, unsigned long);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unsigned long long
        else if ([varType isEqualToString:@"Q"]) {
            unsigned long long arg = va_arg(args, unsigned long long);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // float
        else if ([varType isEqualToString:@"f"]) {
            float arg = va_arg(args, float);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // double
        else if ([varType isEqualToString:@"d"]) {
            double arg = va_arg(args, double);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // bool (_Bool) <! NOT BOOL -> BOOL is char
        else if ([varType isEqualToString:@"B"]) {
            BOOL arg = va_arg(args, int);
            [paramLog appendFormat:fmt, arg ? @"YES": @"NO"];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // void
//        else if ([varType isEqualToString:@"v"]) {
//        }
        // char *
        else if ([varType isEqualToString:@"*"]) {
            char *arg = va_arg(args, char *);
            [paramLog appendFormat:fmt, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // id (@)
        // array ([array type])
        // structure ({name=type...})
        // union ((name=type...))
        // bit field (bnum)
        // pointer (^type)
        else if ([varType isEqualToString:@"@"] ||
                 varType.length > 2) {
            id arg = va_arg(args, id);
            if ([varType isEqualToString:@"@\"NSArray\""]) {
                [paramLog appendFormat:@"<%ld> [%@] (\n\t%@\n)\n",
                 paramCount, [arg class],
                 [[arg valueForKey:@"description"] componentsJoinedByString:@",\n\t"]];
            } else {
                [paramLog appendFormat:@"<%ld> [%@] %@\n", paramCount, [arg class], arg];
            }
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // Class
        else if ([varType isEqualToString:@"#"]) {
            id arg = va_arg(args, id);
            [paramLog appendFormat:@"<%ld> [%@] %@\n", paramCount, [arg class], arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // SEL
        else if ([varType isEqualToString:@":"]) {
//            typedef struct objc_selector *SEL;
            SEL arg = va_arg(args, SEL);
            [paramLog appendFormat:@"<%ld> [SEL] %s\n", paramCount, sel_getName(arg)];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        // unknown
        else {
            void *arg = va_arg(args, void *);
            [paramLog appendFormat:@"<%ld> [unknown] %p\n", paramCount, arg];
            [blockInvocation setArgument:&arg atIndex:(paramCount)];
        }
        
        paramCount += 1;
    }
    
    NSLog(@"%@", paramLog);
    va_end(args);
    [blockInvocation invokeWithTarget:myBlock];
}
#endif

void HookBlockToPrintArguments(id block) {
    struct __my_block_impl_x *t = (__bridge struct __my_block_impl_x *)block;
    if (t->impl.FunPtr != &__my_block_func_1) {
#ifdef SIMPLE_IMPL_HOOK
        origin_block = (SIMPLE_BLOCK)t->impl.FunPtr;
#else
        origin_block = (__my_block_impl_x *)malloc(t->Desc->Block_size);
        memcpy(origin_block, t, t->Desc->Block_size);
#endif
        t->impl.FunPtr = (void *)__my_block_func_1;
    }
}

#pragma mark - Problem #3

static id (*original__Block_copy)(id);

id hook__Block_copy(id blk) {
    id temp = original__Block_copy(blk);
    
    struct __my_block_impl_x *t = (__bridge struct __my_block_impl_x *)blk;
    // 避免重复 hook
    if (!t->impl.Reserved) {
        HookBlockToPrintArguments(blk);
        t->impl.Reserved = YES;
    }

    return temp;
}

void HookEveryBlockToPrintArguments(void) {
    struct rebinding r[] = {
        {
            "_Block_copy",
            (void *)hook__Block_copy,
            (void **)&original__Block_copy
        }
    };
    rebind_symbols(r, 1);
}

@interface MyObj : NSObject
@property (nonatomic, strong) NSArray *temp;
@property (nonatomic, assign) CGRect rt;
@end
@implementation MyObj
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        if (sizeof(void*) == 4) {
//            NSLog(@"32-bit App");
//        } else if (sizeof(void*) == 8) {
//            NSLog(@"64-bit App");
//        }
//        NSNumber *foo = [NSNumber numberWithBool: YES];
//        NSLog(@"encode BOOL: %s", @encode(BOOL));
//        NSLog(@"encode boolean: %s", @encode(Boolean));
//        NSLog(@"encode bool: %s", @encode(bool));
//        NSLog(@"encode char: %s", @encode(char));
//        NSLog(@"object: %s", [foo objCType]);
        
        void (^blk1)(void) = ^{
            NSLog(@"[Block1] invoke!");
        };
        HookBlockToPrintHelloWorld(blk1);
        blk1();

        void (^blk2)(int a, NSString *b) = ^(int a, NSString *b) {
            NSLog(@"[Block2] invoke! %d %@", a, b);
        };
        HookBlockToPrintArguments(blk2);
        blk2(123, @"aaa");
        
        HookEveryBlockToPrintArguments();
#ifndef SIMPLE_IMPL_HOOK
        void (^blk3)(char a, int b, short c, long d, long long e, unsigned char f, unsigned int g,
                    unsigned short h, unsigned long i, unsigned long long j,
                    float k, double l, bool m, char *n, NSArray *o, NSMutableDictionary *p, Class q, SEL r, id s) =
            ^(char a, int b, short c, long d, long long e, unsigned char f, unsigned int g,
              unsigned short h, unsigned long i, unsigned long long j,
              float k, double l, bool m, char *n, NSArray *o, NSMutableDictionary *p, Class q, SEL r, id s) {
//                NSLog(@"[Block3] invoke!\n%@ %f", [o objectAtIndex:2], [(MyObj *)s rt].size.height);
                NSLog(@"[Block3] invoke!\n"
                      "%c %d %hd %ld %lld %c %u %hu %lu %llu"
                      "%f %lf %d %s\n%@\n%@\n%@ %s %@",
                      a, b, c, d, e, f, g, h, i, j,
                      k, l, m, n, o, p, q, sel_getName(r), s);
        };
        char ch[] = "hello";
        SEL r = @selector(setHTTPCookieStorage:);
//        NSArray *o = @[@1, @2, @"hello", @(3.14)];
        NSMutableArray *o = [NSMutableArray arrayWithArray:@[@1, @2, @"hello", @(3.14)]];
        NSDictionary *p = @{@"1": @(2), @"2": @[], @"3": @(2.33)};
        MyObj *s = [MyObj new];
        s.temp = [o copy];
        s.rt = CGRectMake(0, 0, 100, 100);
        blk3('a', 'b', 'c', 400, 500, 'f', 700, 800, 900, 1000,
             11.11, 12.222222, true, ch, o,
             [NSMutableDictionary dictionaryWithDictionary:p], [NSDictionary class], r, s);
#endif
        
        void (^blk4)(int a, NSString *b) = ^(int a, NSString *b) {
            NSLog(@"[Block4] invoke! %d %@", a, b);
        };
        blk4(44, @"555");
        void (^blk5)(int a, NSString *b) = ^(int a, NSString *b) {
            NSLog(@"[Block5] invoke! %d %@", a, b);
        };
        blk5(555, @"6667");
    }
    return 0;
}

#endif
