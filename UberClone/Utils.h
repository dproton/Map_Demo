//
//  Utils.h
//  UberClone
//
//  Created by Dung Le on 6/18/16.
//  Copyright © 2016 Dung Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

#if DEBUG
#define DEBUG_LOG(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define DEBUG_LOG(...) ((void)0)
#endif

@interface Utils : NSObject


@end
