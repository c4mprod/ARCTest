//
//  ViewController.m
//  ARCTestings
//
//  Created by Martin Lequeux--Gruninger on 12/18/12.
//  Copyright (c) 2012 __C4MProd__. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mStrongClass;
@synthesize mWeakClass;
@synthesize mScalarInt;
@synthesize mScalarFloat;
@synthesize mScalarStruct;
@synthesize mSomeBlock;
@synthesize mButton;
@synthesize mOperationQueue;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(IBAction)launchTests:(id)sender
{
    /* Check the profiler to see that when you're even launching tests multiples times in a row, Live bytes remains stable even if Overall bytes size increase each time the button is pressed. */
    [self performTests];
}

-(void)performTests
{
    [self testARC];
    [self initTest];
    [self weakStrongProperties];
    [self objectsPassedByReference];
    [self autoReleasePools];
    [self blockTests];
    [self toolFreeBridging];
    [self parametersCast];
}

/*  -_- ARC NEW RULES -_-
 
 You cannot explicitly invoke dealloc, or implement or invoke retain, release, retainCount, or autorelease.
 The prohibition extends to using @selector(retain), @selector(release), and so on.
 
 You may implement a dealloc method if you need to manage resources other than releasing instance variables. You do not have to (indeed you cannot) release instance variables, but you may need to invoke [systemClassInstance setDelegate:nil] on system classes and other code that isn’t compiled using ARC.
 
 Custom dealloc methods in ARC do not require a call to [super dealloc] (it actually results in a compiler error). The chaining to super is automated and enforced by the compiler.
 
 You can still use CFRetain, CFRelease, and other related functions with Core Foundation-style objects (see “Managing Toll-Free Bridging”).
 
 You cannot use NSAllocateObject or NSDeallocateObject.
 You create objects using alloc; the runtime takes care of deallocating objects.
 
 You cannot use object pointers in C structures.
 Rather than using a struct, you can create an Objective-C class to manage the data instead.
 
 There is no casual casting between id and void *.
 You must use special casts that tell the compiler about object lifetime. You need to do this to cast between Objective-C objects and Core Foundation types that you pass as function arguments. For more details, see “Managing Toll-Free Bridging.”
 
 You cannot use NSAutoreleasePool objects.
 ARC provides @autoreleasepool blocks instead. These have an advantage of being more efficient than NSAutoreleasePool.
 
 You cannot use memory zones.
 There is no need to use NSZone any more—they are ignored by the modern Objective-C runtime anyway.
 
 To allow interoperation with manual retain-release code, ARC imposes a constraint on method naming:
 
 You cannot give an accessor a name that begins with new. This in turn means that you can’t, for example, declare a property whose name begins with new unless you specify a different getter:
 
 */

#pragma mark -

#pragma mark TESTINGS

/* REFERENCES
 
 http://clang.llvm.org/docs/AutomaticReferenceCounting.html
 
 http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
 
 http://amattn.com/2011/12/07/arc_best_practices.html
 
 */

/*
 Use Compiler Flags to Enable and Disable ARC
 You enable ARC using a new -fobjc-arc compiler flag. You can also choose to use ARC on a per-file basis if it’s more convenient for you to use manual reference counting for some files. For projects that employ ARC as the default approach, you can disable ARC for a specific file using a new -fno-objc-arc compiler flag for that file.
 
 ARC is supported in Xcode 4.2 and later OS X v10.6 and later (64-bit applications) and for iOS 4 and later. Weak references are not supported in OS X v10.6 and iOS 4. There is no ARC support in Xcode 4.1 and earlier.
 */

/*
 assign implies __unsafe_unretained ownership.
 copy implies __strong ownership, as well as the usual behavior of copy semantics on the setter.
 retain implies __strong ownership.
 strong implies __strong ownership.
 unsafe_unretained implies __unsafe_unretained ownership.
 weak implies __weak ownership.
 */

-(void)testARC //Check if ARC is enabled
{
   //If ARC is enabled, __has_feature(objc_arc) will expand to 1 in the preprocessor
    if (__has_feature(objc_arc) == 1)
    {
        NSLog(@"ARC is enabled");
    }
    else
    {
        NSLog(@"ARC isn't enabled");
    }
}

-(void)initTest //Variable Qualifiers
{
    /*
     __strong is the default. An object remains “alive” as long as there is a strong pointer to it.
     __weak specifies a reference that does not keep the referenced object alive. A weak reference is set to nil when there are no strong references to the object.
     __unsafe_unretained specifies a reference that does not keep the referenced object alive and is not set to nil when there are no strong references to the object. If the object it references is deallocated, the pointer is left dangling.
     __autoreleasing is used to denote arguments that are passed by reference (id *) and are autoreleased on return.
     */
    
    NSNumber*       __strong test1; //DEFAULT IF __qualifier NOT SPECIFIED
    NSNumber*       __weak test2;
    NSNumber*       __unsafe_unretained test3;
    NSNumber*       __autoreleasing test4;
    
    NSLog(@"BEFORE\n__strong (Default) -> %@\n__weak -> %@\n__unsafe_unretained -> %@\n__autoreleasing -> %@", test1, test2, test3, test4);
    
    test1 = [NSNumber numberWithInt:1];
    test2 = [NSNumber numberWithInt:2];
    test3 = [NSNumber numberWithInt:3];
    test4 = [NSNumber numberWithInt:4];
    
    NSLog(@"AFTER\n__strong (Default) -> %@\n__weak -> %@\n__unsafe_unretained -> %@\n__autoreleasing -> %@", test1, test2, test3, test4);

    //Be carful with __weak (xCode warns you) ->immediately deallocated.
    NSString * __weak string = [[NSString alloc] initWithFormat:@"First Name: %@", @"ARCTestings"];
    NSLog(@"__weak string: %@", string);
    
    NSString * __strong string2 = [[NSString alloc] initWithFormat:@"First Name: %@", @"ARCTestings"];
    NSLog(@"__strong string: %@", string2);
}

-(void)weakStrongProperties //see ViewController.h
{
    /*
     Under ARC, strong is the default for object types.
     */  
    
    NSLog(@"BEFORE ALLOC\nstrong class -> %@\nweak class -> %@", mStrongClass, mWeakClass);
    
    mStrongClass = [[MyCustomClass alloc] init];
    mWeakClass = [[MyCustomClass alloc] init];
    
    NSLog(@"AFTER ALLOC\nstrong class -> %@\nweak class -> %@", mStrongClass, mWeakClass);
}

-(void)objectsPassedByReference
{
    MyCustomClass* lErrorTester = [[MyCustomClass alloc] init]; //implicit __strong
    
    NSError *error; //implicit __strong
    NSLog(@"Pointer passed by reference -> %@", error);
    
    BOOL OK = [lErrorTester performOperationWithError:&error];
    if (!OK)
    {
        NSLog(@"Retrieved error -> %@", error.description);
        // handle the error.
    }
    
    /*
     As the prototype is -(BOOL)performOperationWithError:(NSError * __autoreleasing *)error;

     The compiler therefore rewrites the code:
     
     NSError * __strong error;
     NSLog(@"Pointer passed by reference -> %@", error);

     NSError * __autoreleasing tmp = error;
     BOOL OK = [myObject performOperationWithError:&tmp];
     error = tmp;
     if (!OK)
     {
        NSLog(@"Retrieved error -> %@", error.description);
        // handle the error.
     }
     
     The mismatch between the local variable declaration (__strong) and the parameter (__autoreleasing) causes the compiler to create the temporary variable. You can get the original pointer by declaring the parameter id __strong * when you take the address of a __strong variable. Alternatively you can declare the variable as __autoreleasing.
     */
}

-(void)autoReleasePools
{
    /*
     This syntax is available in all Objective-C modes. It is more efficient than using the NSAutoreleasePool class; you are therefore encouraged to adopt it in place of using the NSAutoreleasePool.
     */
    
    NSString*     lBaseString[1000];
    for (int i = 0; i < 1000; i++)
    {
        lBaseString[i] = [NSString stringWithFormat:@"%d", i];
    }
    
    NSArray* lHugeArray = [[NSArray alloc] initWithObjects:lBaseString count:1000];
    
    /*
    If a variable is declared in the condition of an Objective-C fast enumeration loop, and the variable has no explicit ownership qualifier, then it is qualified with const __strong and objects encountered during the enumeration are not actually retained.
    
    Rationale
    This is an optimization made possible because fast enumeration loops promise to keep the objects retained during enumeration, and the collection itself cannot be synchronously modified. It can be overridden by explicitly qualifying the variable with __strong, which will make the variable mutable again and cause the loop to retain the objects it encounters.
     */
    for (NSString* __strong lString in lHugeArray)
    {
        @autoreleasepool //Note the use of @autoreleasepool instead of NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; and then [pool drain];
        {
            MyCustomClass* lTmpClass = [[MyCustomClass alloc] init];
            lString = [lString stringByAppendingFormat:@" -> New class is %@", lTmpClass];
            NSLog(@"%@", lString);
            //You are creating lots of temporary objects here...
            //Creating and destroying autorelease pools using the @autoreleasepool directive is cheaper than a blue light special. Don’t worry about doing it inside the loop. If you are super-paranoid, at least check the profiler first.
            //You can see in the logs that the class can have the same memory adress than a previous one
        }
    }
}

-(void)displayStatus:(NSInteger)_Status
{
    NSLog(@"The received status is %d", _Status);
}

-(void)blockTests
{
    mOperationQueue = [[NSOperationQueue alloc] init];
    
    //When adding block pointers to a collection, you need to copy them first.
    NSMutableArray* lTmpArray = [[NSMutableArray alloc] init];

    SomeBlock testArrayBlock = ^(NSInteger status){
        NSLog(@"Status is %d", status);
    };
    [lTmpArray addObject:[testArrayBlock copy]];
    ((SomeBlock)[lTmpArray lastObject])(21122012); //Execution from array
    
    //CAPTURING SELF
    //Retain cycles are somewhat dangerous with blocks
    //The reason is that someBlock is strongly held by self and the block will “capture” and retain self when/if the block is copied to the heap.
    [self.mOperationQueue addOperationWithBlock:^{
        [self displayStatus:42];
    }];
    // any ivar you use will also capture the parent object:
    [self.mOperationQueue addOperationWithBlock:^{
        NSInteger test;
        test = mScalarInt;
    }];
    
    //The safer, but loquacious workaround is to use a weakSelf:
    ViewController* __weak weakSelf = self;
    
    [self.mOperationQueue addOperationWithBlock: ^{
        ViewController* strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            // The original self doesn't exist anymore.
            // Ignore, notify or otherwise handle this case.
        }
        else
        {
            [strongSelf displayStatus:1337];
        }
    }];
    
    
    //Sometimes, you need to take care to avoid retain cycles with arbitrary objects: If someObject will ever strongly hold onto the block that uses someObject, you need weakSomeObject to break the cycle.
    ViewController* someObject = self;
    ViewController* __weak weakSomeObject = someObject;
    
    [self.mOperationQueue addOperationWithBlock: ^{
        ViewController* strongSomeObject = weakSomeObject;
        if (strongSomeObject == nil)
        {
            // The original someObject doesn't exist anymore.
            // Ignore, notify or otherwise handle this case.
        }
        else
        {
            // okay, NOW we can do something with someObject
            [strongSomeObject displayStatus:-42];
        }
    }];
}

-(void)toolFreeBridging
{
    /*
     If you cast between Objective-C and Core Foundation-style objects, you need to tell the compiler about the ownership semantics of the object using either a cast (defined in objc/runtime.h) or a Core Foundation-style macro (defined in NSObject.h):
     
     __bridge transfers a pointer between Objective-C and Core Foundation with no transfer of ownership.
     
     __bridge_retained or CFBridgingRetain casts an Objective-C pointer to a Core Foundation pointer and also transfers ownership to you.
     You are responsible for calling CFRelease or a related function to relinquish ownership of the object.
     
     __bridge_transfer or CFBridgingRelease moves a non-Objective-C pointer to Objective-C and also transfers ownership to ARC.
     ARC is responsible for relinquishing ownership of the object.
     */
    
    /*BEFORE:
     NSString *name = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
     NSLog(@"Person's first name: %@", name);
     [name release];
     */
    
    ABRecordRef person = (__bridge ABRecordRef)CFBridgingRelease(ABPersonCreate()); 
    ABRecordSetValue(person, kABPersonFirstNameProperty, @"Steve Jobs", NULL);

    NSString *name = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSLog(@"Person's first name: %@", name);
}

-(void)parametersCast
{
    /*
     When you cast between Objective-C and Core Foundation objects in function calls, you need to tell the compiler about the ownership semantics of the passed object. The ownership rules for Core Foundation objects are those specified in the Core Foundation memory management rules (see Memory Management Programming Guide for Core Foundation); rules for Objective-C objects are specified in Advanced Memory Management Programming Guide.
     
     In the following code fragment, the array passed to the CGGradientCreateWithColors function requires an appropriate cast. Ownership of the object returned by arrayWithObjects: is not passed to the function, thus the cast is __bridge.
     */
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat locations[2] = {0.0, 1.0};
    NSArray *colors = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor whiteColor], [UIColor redColor], nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    gradient = gradient; //Do whatever you need with gradient
    
    CGColorSpaceRelease(colorSpace);  // Release owned Core Foundation object.
    CGGradientRelease(gradient);  // Release owned Core Foundation object.
    
    //OR 
    
    CGColorSpaceRef colorSpace2 = (__bridge CGColorSpaceRef)CFBridgingRelease(CGColorSpaceCreateDeviceGray());
    CGFloat locations2[2] = {0.0, 1.0};
    NSArray *colors2 = [NSArray arrayWithObjects:[UIColor blueColor], [UIColor whiteColor], [UIColor redColor], nil];
    CGGradientRef gradient2 = (__bridge CGGradientRef)CFBridgingRelease(CGGradientCreateWithColors(colorSpace2, (__bridge CFArrayRef)colors2, locations2));
    
    gradient2 = gradient2; //Do whatever you need with gradient2

}

#pragma mark DEALLOC

-(void)dealloc //IMPORTANT
{    
    /*
    Remove observers.
    
    Unregister for notifications.
    
    Set any non-weak delegates to nil.
    
    Invalidate any timers.
    */
}

@end
