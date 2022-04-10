////////////////Check for OS and Device
#define VTTOSLessThan7 (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
#define VTTOSLessThan8 (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)

#define IS_IPHONE_5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define VTTValidNSString(string) (string && ![[NSNull null] isEqual: string] && ![string isEqualToString: @""])

#define ApplicationDelegate                 ((OSAppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define SharedApplication                   [UIApplication sharedApplication]
#define LastWindow                          [[[UIApplication sharedApplication] windows] lastObject]
#define Bundle                              [NSBundle mainBundle]
#define MainScreen                          [UIScreen mainScreen]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        self.navigationController.navigationBar.bounds.size.height
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))

#define RectChangeWidth(f, w)               f = CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectChangeHeight(f, h)              f = CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectChangeX(f, x)                   f = CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectChangeY(f, y)                   f = CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectChangeSize(f, w, h)             f = CGRectMake(RectX(f), RectY(f), w, h)
#define RectChangeOrigin(f, x, y)           f = CGRectMake(x, y, RectWidth(f), RectHeight(f))

#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define FlushPool(p)                        [p drain]; p = [[NSAutoreleasePool alloc] init]
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define PrintPointWithName(p, n)            NSLog(@"%@: %f %f", n, p.x, p.y)
#define PrintRectWithName(r, n)             NSLog(@"%@: %f %f %f %f", n, r.origin.x, r.origin.y, r.size.width, r.size.height)
#define PrintSizeWithName(s, n)             NSLog(@"%@: %f %f", n, s.width, s.height)

#define DegreesToRadians(x) x * M_PI/180.0f