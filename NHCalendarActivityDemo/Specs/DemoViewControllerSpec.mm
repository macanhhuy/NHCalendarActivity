#import <objc/runtime.h>
#import "DemoViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#define kCalendarComponents (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)

@interface DemoViewController (Spec)

- (IBAction)openBtnTouched:(id)sender;
-(NHCalendarEvent *)createCalendarEvent;

@end

SPEC_BEGIN(DemoViewControllerSpec)

describe(@"DemoViewController", ^{
    __block DemoViewController *controller;
    
    beforeEach(^{
        controller = [[DemoViewController alloc] init];
    });
    
    context(@"#openBtnTouched:", ^{
        context(@"UIActivityViewController", ^{
            __block IMP origImpl;
            __block Method origMethod;
            __block BOOL methodHasBeenCalled;
            
            __block BOOL animated;
            __block id viewController;
            
            beforeEach(^{
                methodHasBeenCalled = NO;
                animated = NO;
                
                origMethod = class_getInstanceMethod([UIViewController class], @selector(presentViewController:animated:completion:));
                
                IMP mockBlock = imp_implementationWithBlock(^(id _self, id view, BOOL anim, id completion) {
                    methodHasBeenCalled = YES;
                    
                    viewController = view;
                    animated = anim;
                });
                
                origImpl = method_setImplementation(origMethod, mockBlock);
                
                [controller openBtnTouched:nil];
            });
            
            afterEach(^{
                method_setImplementation(origMethod, origImpl);
            });
            
            it(@"should have been called", ^{
                methodHasBeenCalled should be_truthy;
            });
            
            it(@"should have animation", ^{
                animated should be_truthy;
            });
            
            it(@"should display a proper viewController", ^{
                viewController should be_instance_of([UIActivityViewController class]);
            });
            
            context(@"activities", ^{
                __block UIActivityViewController *activity;
                
                beforeEach(^{
                    activity = viewController;
                });
                
                it(@"should exclude four activities", ^{
                    activity.excludedActivityTypes.count should equal(4);
                    
                    activity.excludedActivityTypes should contain(UIActivityTypePostToWeibo);
                    activity.excludedActivityTypes should contain(UIActivityTypePrint);
                    activity.excludedActivityTypes should contain(UIActivityTypeSaveToCameraRoll);
                    activity.excludedActivityTypes should contain(UIActivityTypeAssignToContact);
                });
            });
        });
    });
    
    context(@"#createCalendarEvent", ^{
        context(@"event", ^{
            __block NHCalendarEvent *event;
            
            beforeEach(^{
                event = [controller createCalendarEvent];
            });
            
            it(@"should exist", ^{
                event should_not be_nil;
            });
            
            it(@"should have proper title", ^{
                event.title should equal(@"Long-expected Party");
            });
            
            it(@"should have proper location", ^{
                event.location should equal(@"The Shire");
            });
            
            it(@"should have proper notes", ^{
                event.notes should equal(@"Bilbo's eleventy-first birthday.");
            });
            
            context(@"should have start and end dates", ^{
                context(@"startDate", ^{
                    it(@"should exit", ^{
                        event.startDate should_not be_nil;
                    });
                    
                    it(@"should have a proper startDate", ^{
                        NSCalendar *startCalendar = [NSCalendar currentCalendar];
                        [startCalendar components:kCalendarComponents
                                         fromDate:event.startDate];
                        NSDate *localDate = [NSDate dateWithTimeIntervalSinceNow:3600];
                        NSCalendar *localCalendar = [NSCalendar currentCalendar];
                        [localCalendar components:kCalendarComponents
                                         fromDate:localDate];
                        
                        startCalendar should equal(localCalendar);
                    });
                });
                
                context(@"endDate", ^{
                    it(@"should exit", ^{
                        event.endDate should_not be_nil;
                    });
                    
                    it(@"should have a proper endDate", ^{
                        NSCalendar *startCalendar = [NSCalendar currentCalendar];
                        [startCalendar components:kCalendarComponents
                                         fromDate:event.startDate];
                        NSDate *localDate = [NSDate dateWithTimeInterval:3600
                                                               sinceDate:event.startDate];
                        NSCalendar *localCalendar = [NSCalendar currentCalendar];
                        [localCalendar components:kCalendarComponents
                                         fromDate:localDate];
                        
                        startCalendar should equal(localCalendar);
                    });
                });
            });
            
            it(@"should not be an all day event", ^{
                event.allDay should_not be_truthy;
            });
            
            it(@"should have a proper URL", ^{
                event.URL should equal([NSURL URLWithString:@"http://github.com/otaviocc/NHCalendarActivity"]);
            });
            
            context(@"has alarms", ^{
                context(@"alarms", ^{
                    it(@"should have two alarms", ^{
                        event.alarms.count should equal(2);
                    });
                    
                    it(@"should have the proper type", ^{                        
                        event.alarms[0] should be_instance_of([EKAlarm class]);
                        event.alarms[1] should be_instance_of([EKAlarm class]);
                    });
                });
            });
        });
    });
});

SPEC_END
