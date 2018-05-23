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
        self.unicodeContent = [NSMutableString string];
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

- (NSString *)appendString:(NSString *)inputString
{
    NSString *lowercaseString = [inputString lowercaseString];
    int position = 0;

    if (lowercaseString)
    {
        [unicodeContent appendString:lowercaseString];
    }

    while (position < inputString.length)
    {
        unichar inputCharacter = [inputString characterAtIndex:position];
        unichar actualCharacter = [lowercaseString characterAtIndex:position++];
        unichar expectedCharacter = [fontName characterAtIndex:keywordPosition];

        if (actualCharacter != expectedCharacter)
        {
            if (keywordPosition > 0)
            {
                // Read character again
                position--;
            }
            else if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)])
            {
                [delegate detector:self didScanCharacter:inputCharacter];
            }

            // Reset keyword position
            keywordPosition = 0;
            continue;
        }

        if (keywordPosition == 0 && [delegate respondsToSelector:@selector(detectorDidStartMatching:)])
        {
            [delegate detectorDidStartMatching:self];
        }

        if ([delegate respondsToSelector:@selector(detector:didScanCharacter:)])
        {
            [delegate detector:self didScanCharacter:inputCharacter];
        }

        if (++keywordPosition < fontName.length)
        {
            // Keep matching keyword
            continue;
        }

        // Reset keyword position
        keywordPosition = 0;

        if ([delegate respondsToSelector:@selector(detectorFoundString:)])
        {
            [delegate detectorFoundString:self];
        }
    }

    return inputString;
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
