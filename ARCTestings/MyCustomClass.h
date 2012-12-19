//
//  MyCustomClass.h
//  ARCTestings
//
//  Created by Martin Lequeux--Gruninger on 12/19/12.
//  Copyright (c) 2012 __C4MProd__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomClass : NSObject

@property(nonatomic, strong)NSString*   mFirstName;
@property(nonatomic, strong)NSString*   mLastName;
@property(nonatomic, strong)NSDate*     mBirthDate;

/* Equivalent of 
 @property(nonatomic)NSString*      mFirstName;
 @property(nonatomic)NSString*      mLastName;
 @property(nonatomic)NSDate*        mBirthDate;
 */

+ (MyCustomClass *)singleton;

-(BOOL)performOperationWithError:(NSError * __autoreleasing *)error;

@end
