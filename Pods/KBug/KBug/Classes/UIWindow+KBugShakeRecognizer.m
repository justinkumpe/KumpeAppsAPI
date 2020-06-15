//
//  UIWindow+KBugShakeRecognizer.m
//  AyAyObjectiveCPort
//
//  Modified by Justin on 06-14-2020.
//  Copyright © 2020 KBug. All rights reserved.
//

#import "UIWindow+KBugShakeRecognizer.h"
#import "KBugCore.h"

@implementation UIWindow (KBugShakeRecognizer)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [KBug shakeInvocation];
    }
}

@end
