//
//  MyCustomClass.m
//  ARCTestings
//
//  Created by Martin Lequeux--Gruninger on 12/19/12.
//  Copyright (c) 2012 __C4MProd__. All rights reserved.
//

#import "MyCustomClass.h"

@implementation MyCustomClass

@synthesize mFirstName;
@synthesize mLastName;
@synthesize mBirthDate;

//SINGLETONS Only incidentally related to ARC. There is a proliferation of home grown singleton implementations (many of which unnecessarily override retain and release).

// declare the static variable outside of the singleton method
static MyCustomClass *__sharedMyClass = nil;

+ (MyCustomClass *)singleton
{
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{__sharedMyClass = [[self alloc] init];});
    return __sharedMyClass;
}

-(BOOL)performOperationWithError:(NSError * __autoreleasing *)error
{
    // ... some error occurs ...
    if (error)
    {
        // write to the out-parameter, ARC will autorelease it
        *error = [[NSError alloc] initWithDomain:@"" 
                                            code:-1 
                                        userInfo:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}


@end
