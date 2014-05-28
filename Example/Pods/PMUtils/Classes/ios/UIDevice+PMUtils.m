//
//  UIDevice+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import "UIDevice+PMUtils.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/mount.h>

@implementation UIDevice (PMUtils)

+ (BOOL) isPad
{
    return [[self currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL) isPhone
{
    return [[self currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

+ (NSString *) systemVersion
{
	return [[self currentDevice] systemVersion];
}

+ (int)hardwareCores
{
    size_t len;
    unsigned int numberOfCores;
	
    len = sizeof(numberOfCores);
    sysctlbyname("hw.ncpu", &numberOfCores, &len, NULL, 0);
	
    return numberOfCores;
}

+ (size_t)hardwareRam
{
	int mib[] = { CTL_HW, HW_PHYSMEM };
	size_t mem;
	size_t len = sizeof(mem);
	sysctl(mib, 2, &mem, &len, NULL, 0);
	
	return mem;
}

+ (NSString *) machine
{
    struct utsname systemInfo;
    if ( !uname(&systemInfo) ) {
        NSString *model = [NSString stringWithUTF8String:systemInfo.machine];
        return model;
    }
	
	return @"Unknown";
}

+ (uint64_t)availableSpaceForRootVolume
{
	struct statfs		sfs;
	NSString			*path		= [[NSBundle mainBundle] bundlePath];
	
	if ( !statfs([path UTF8String], &sfs))
	{
		uint64_t availableBytes = sfs.f_bsize * sfs.f_bavail;
		return availableBytes;
	}
	
	return 0;
}


@end
