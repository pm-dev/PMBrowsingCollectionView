//
//  PMUtils.h
//  PMUtils-iOSExample
//
//  Created by Peter Meyers on 3/2/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#ifndef PMUtils_iOSExample_PMUtils_h
#define PMUtils_iOSExample_PMUtils_h

#import "UIView+PMUtils.h"
#import "NSFileManager+PMUtils.h"
#import "NSString+PMUtils.h"
#import "UIDevice+PMUtils.h"
#import "UIScreen+PMUtils.h"
#import "NSData+PMUtils.h"
#import "UIImage+PMUtils.h"
#import "UIColor+PMUtils.h"
#import "NSThread+PMUtils.h"
#import "NSIndexPath+PMUtils.h"
#import "UITableView+PMUtils.h"
#import "PMOrderedDictionary.h"
#import "UICollectionView+PMUtils.h"
#import "PMProtocolInterceptor.h"
#import "UIScrollView+PMUtils.h"
#import "UICollectionViewFlowLayout+PMUtils.h"
#import "UICollectionReusableView+PMUtils.h"
#import "NSDictionary+PMUtils.h"
#import "NSManagedObject+PMUtils.h"
#import "UIImageView+PMUtils.h"
#import "PMPair.h"

#if DEBUG
#define DLog(args...)   NSLog(args)
#else
#define DLog(args...)
#endif

#define DEF_weakSelf    __weak __typeof(self) weakSelf = self;

extern NSTimeInterval const PMOneHour;
extern NSTimeInterval const PMOneDay;
extern NSTimeInterval const PMOneWeek;
extern NSUInteger const PMBytesPerMegabyte;

extern NSInteger PMShortestCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange);
extern NSInteger PMReverseCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange);
extern NSInteger PMForwardCircularDistance(NSInteger fromIndex, NSInteger toIndex, NSRange inRange);

#endif
