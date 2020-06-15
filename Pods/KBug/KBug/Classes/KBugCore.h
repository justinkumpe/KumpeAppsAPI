//
//  KBug.h
//  AyAyObjectiveCPort
//
//  Modified by Justin on 06-14-2020.
//  Copyright © 2020 KBug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum activationMethodTypes { NONE, SHAKE } KBugActivationMethod;

@interface KBug : NSObject

/**
 * Returns a new shared instance of KBug.
 * @author KBug
 *
 * @return A new shared instance of KBug.
 */
+ (instancetype)sharedInstance;

/**
 * Initializes the KBug SDK.
 * @author KBug
 *
 * @param token The SDK key, which can be found on dashboard.KBug.io
 * @param activationMethod Activation method, which triggers a new bug report.
 */
+ (void)initWithToken: (NSString *)token andActivationMethod: (KBugActivationMethod)activationMethod;

/**
 * Manually start the bug reporting workflow. This is used, when you use the activation method "NONE".
 * @author KBug
 *
 */
+ (void)startBugReporting;

/**
 * Attach custom data, which can be view in the KBug dashboard.
 * @author KBug
 *
 * @param customData The data to attach to a bug report.
 */
+ (void)attachCustomData: (NSDictionary *)customData;

/**
 * Set a custom navigationbar tint color.
 * @author KBug
 *
 * @param color The background color of the navigationbar.
 */
+ (void)setNavigationBarTint: (UIColor *)color;

/**
 * Sets the customer's email address.
 * @author KBug
 *
 * @param email The customer's email address.
 */
+ (void)setCustomerEmail: (NSString *)email;

/**
 * Add a 'step to reproduce' step.
 * @author KBug
 *
 * @param type Type of the step. (Use any custom string or one of the predefined constants - KBugStepTypeView, Button, Input)
 * @param data Custom data associated with the step.
 */
+ (void)trackStepWithType: (NSString *)type andData: (NSString *)data;

+ (void)attachData: (NSDictionary *)data;
+ (NSBundle *)frameworkBundle;
+ (void)shakeInvocation;
+ (void)attachScreenshot: (UIImage *)screenshot;
+ (UIImage *)getAttachedScreenshot;

- (void)sendReport: (void (^)(bool success))completion;

@property (nonatomic, retain) NSString* token;
@property (nonatomic, assign) KBugActivationMethod activationMethod;
@property (nonatomic, retain) NSMutableDictionary* data;

extern NSString *const KBugStepTypeView;
extern NSString *const KBugStepTypeButton;
extern NSString *const KBugStepTypeInput;

@end

NS_ASSUME_NONNULL_END
