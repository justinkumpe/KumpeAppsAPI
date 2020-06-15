#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KBug.h"
#import "KBugBugDetailsViewController.h"
#import "KBugCore.h"
#import "KBugImageEditorViewController.h"
#import "KBugTouchDrawImageView.h"
#import "UIWindow+KBugShakeRecognizer.h"

FOUNDATION_EXPORT double KBugVersionNumber;
FOUNDATION_EXPORT const unsigned char KBugVersionString[];

