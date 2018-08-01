//
//  PartNumberDetector.m
//  Sales
//
//  Created by Brian Grimal on 5/22/18.
//  Copyright © 2018 All rights reserved.
//

#import "PartNumberDetector.h"

@implementation PartNumberDetector

+ (PartNumberDetector *)detectorWithFontName:(NSString *)baseFont delegate:(id<PartNumberDetectorDelegate>)delegate
{
    PartNumberDetector *detector = [[PartNumberDetector alloc] initWithFontName:baseFont];
    detector.delegate = delegate;
    return detector;
}

- (id)initWithFontName:(NSString *)string
{
    if (self = [super init])
    {
        fontName = [string lowercaseString];
    }

    return self;
}
- (void)detectedString:(NSString *)string withFontName:(NSString *)inFontName
{
    keywordPosition = 0;
    unicodeContent = string.mutableCopy;
    fontName = inFontName;
    if ([delegate respondsToSelector:@selector(detectorFoundString:)]) [delegate detectorFoundString:self];
}

- (void)setFontName:(NSString *)baseName
{
    fontName = [baseName lowercaseString];
    keywordPosition = 0;
}

- (void)reset
{
    keywordPosition = 0;
}

@synthesize delegate, unicodeContent;

@end
