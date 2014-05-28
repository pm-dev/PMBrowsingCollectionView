//
//  NSString+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (PMUtils)

- (NSString *) encodedQuery;

- (NSString *)sha1Hash;

- (NSComparisonResult) compareWithVersion:(NSString *)otherVersion;

- (BOOL) isCapitalized;

- (BOOL) inVersion:(NSString *)baseVersion;

- (BOOL) containsEmoji;

- (NSString *) camelCaseFromUnderscores;

- (NSString *) underscoresFromCamelCase;

@end
