//
//  NSManagedObject+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 5/5/14.
//
//

#import "NSManagedObject+PMUtils.h"

@implementation NSManagedObject (PMUtils)

- (BOOL) save
{
    NSError *error = nil;
    BOOL succeeded = [self.managedObjectContext save:&error];
    NSAssert(succeeded, @"Error saving Managed Object: %@ to context. Error: %@", self, error);
    return succeeded;
}

@end
