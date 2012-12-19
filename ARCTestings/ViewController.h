//
//  ViewController.h
//  ARCTestings
//
//  Created by Martin Lequeux--Gruninger on 12/18/12.
//  Copyright (c) 2012 __C4MProd__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCustomClass.h"

@interface ViewController : UIViewController

// The following declaration is a synonym for: @property(nonatomic, retain)MyCustomClass*   myObject;
@property(nonatomic, strong)MyCustomClass*      mStrongClass;

// The following declaration is similar to "@property(nonatomic, assign)MyCustomClass*  myObject;"
// except that if the MyCustomClass instance is deallocated,
// the property value is set to nil instead of remaining as a dangling pointer.
@property(nonatomic, weak)MyCustomClass*        mWeakClass;

//scalar ivar properties should use assign.
@property(nonatomic, assign)NSInteger           mScalarInt;
@property(nonatomic, assign)CGFloat             mScalarFloat;
@property(nonatomic, assign)CGPoint             mScalarStruct;

//Blocks should still use copy
typedef void (^SomeBlock)(NSInteger status);
@property(nonatomic, copy)SomeBlock             mSomeBlock;
@property(nonatomic, strong)NSOperationQueue*   mOperationQueue;

//IBOutlets should be weak except for top-level IBOutlets, which should be strong.
@property(nonatomic, weak)IBOutlet UIButton*    mButton;

-(IBAction)launchTests:(id)sender;
@end
