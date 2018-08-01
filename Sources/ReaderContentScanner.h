//
//  ReaderContentScanner.h
//  Sales
//
//  Created by Brian Grimal on 5/22/18.
//  Copyright © 2018 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FontCollection.h"
#import "RenderingState.h"
#import "RenderingStateStack.h"
#import "Selection.h"
#import "PartNumberDetector.h"

@interface ReaderContentScanner : NSObject <PartNumberDetectorDelegate> {
    CGPDFPageRef pdfPage;
    Selection *possibleSelection;
}

+ (ReaderContentScanner *)scannerWithPage:(CGPDFPageRef)page;

- (NSArray<Selection *> *) selectPartNumbers;

@property (nonatomic, readonly) RenderingState *renderingState;
@property (nonatomic, retain) RenderingStateStack *renderingStateStack;
@property (nonatomic, retain) FontCollection *fontCollection;
@property (nonatomic, retain) PartNumberDetector *partNumberDetector;
@property (nonatomic, retain) NSMutableString *content;
@property (nonatomic, retain) NSMutableArray<Selection *> *selections;
@property (nonatomic, readonly) CGAffineTransform pageMatrix;

@end
