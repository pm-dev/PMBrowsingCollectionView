//
//  NSFileManager+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (PMUtils)

- (NSDate *)fileModificationDateForPath:(NSString *)path;

/**
 *
 * Only removes files directly underneath the specified directory. This method will *not* recurse into subdirectories.
 *
 *
 *  @param path
 */
- (void)shallowRemoveAllFilesInDirectory:(NSString *)path;

- (NSString *)xattrStringValueForKey:(NSString *)key atPath:(NSString *)path;

- (void)setXAttrStringValue:(NSString *)value forKey:(NSString *)key atPath:(NSString *)path;

+ (NSString *) pathForCreatedCachesDirectoryWithName:(NSString *)name;

+ (NSURL *) URLForCreatedCachesDirectoryWithName:(NSString *)name;

@end
