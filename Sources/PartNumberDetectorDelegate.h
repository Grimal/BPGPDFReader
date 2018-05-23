//
//  PartNumberDetectorDelegate.h
//  Sales
//
//  Created by Brian Grimal on 5/22/18.
//  Copyright © 2018 All rights reserved.
//

#import <Foundation/Foundation.h>

@class PartNumberDetector;

@protocol PartNumberDetectorDelegate <NSObject>
@optional
- (void)detectorDidStartMatching:(PartNumberDetector *)partNumberDetector;
- (void)detectorFoundString:(PartNumberDetector *)detector;
- (void)detector:(PartNumberDetector *)detector didScanCharacter:(unichar)character;
@end
