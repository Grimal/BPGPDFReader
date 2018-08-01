//
//  PartNumberDetector.h
//  Sales
//
//  Created by Brian Grimal on 5/22/18.
//  Copyright © 2018 All rights reserved.
//

/**
 * A detector implementing a finite state machine with the goal of detecting part numbers identified by a specific
 * font, in a continuous stream of characters. The user of a detector can append strings, and will receive a number
 * of messages reflecting the current state of the detector.
 */

#import <Foundation/Foundation.h>
#import "Font.h"
#import "PartNumberDetectorDelegate.h"

@class PartNumberDetector;

@interface PartNumberDetector : NSObject {
    NSString *fontName;
    NSUInteger keywordPosition;
    NSMutableString *unicodeContent;
    __weak id<PartNumberDetectorDelegate> delegate;
}

+ (PartNumberDetector *)detectorWithFontName:(NSString *)baseFont delegate:(id<PartNumberDetectorDelegate>)delegate;
- (id)initWithFontName:(NSString *)needle;
- (void)setFontName:(NSString *)baseName;
- (void)reset;
- (void)detectedString:(NSString *)string withFontName:(NSString *)inFontName;

@property (nonatomic, weak) id<PartNumberDetectorDelegate> delegate;
@property (nonatomic, retain) NSMutableString *unicodeContent;

@end
