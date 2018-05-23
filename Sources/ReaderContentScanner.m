//
//  ReaderContentScanner.m
//  Sales
//
//  Created by Brian Grimal on 5/22/18.
//  Copyright © 2018 All rights reserved.
//

#import "ReaderContentScanner.h"
#import "pdfScannerCallbacks.mm"

@implementation ReaderContentScanner

+ (ReaderContentScanner *)scannerWithPage:(CGPDFPageRef)page {
    return [[ReaderContentScanner alloc] initWithPage:page];
}

- (id)initWithPage:(CGPDFPageRef)page {
    if (self = [super init]) {
        pdfPage = page;
        self.fontCollection = [self fontCollectionWithPage:page];
        self.selections = [NSMutableArray array];
    }

    return self;
}

- (NSArray<Selection *> *)selectPartNumbers {

    self.partNumberDetector = [PartNumberDetector detectorWithFontName:@"Swiss712BT" delegate:self];
    self.renderingStateStack = [RenderingStateStack stack];
    self.selections = [NSMutableArray new];

    if (pdfPage == NULL) { NSLog(@"%s - page is NULL, cannot scan", __PRETTY_FUNCTION__); return nil; }
    CGPDFPageRef scanningPage = CGPDFPageRetain(pdfPage);
    CGPDFOperatorTableRef operatorTable = [self newOperatorTable];
    CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(scanningPage);
    CGPDFScannerRef scanner = CGPDFScannerCreate(contentStream, operatorTable, (__bridge void *)(self));
    CGPDFScannerScan(scanner);
    // Magic happens here
    CGPDFScannerRelease(scanner);
    CGPDFContentStreamRelease(contentStream);
    CGPDFOperatorTableRelease(operatorTable);
    CGPDFPageRelease(scanningPage);

    // we have all of our selections outlined here, draw link annotations for them:
    NSLog(@"%s - Located %i part numbers", __PRETTY_FUNCTION__, (int)self.selections.count);
    return self.selections;
}

- (CGPDFOperatorTableRef)newOperatorTable {
    CGPDFOperatorTableRef operatorTable = CGPDFOperatorTableCreate();

    // Text-showing operators
    CGPDFOperatorTableSetCallback(operatorTable, "Tj", printString);
    CGPDFOperatorTableSetCallback(operatorTable, "\'", printStringNewLine);
    CGPDFOperatorTableSetCallback(operatorTable, "\"", printStringNewLineSetSpacing);
    CGPDFOperatorTableSetCallback(operatorTable, "TJ", printStringsAndSpaces);

    // Text-positioning operators
    CGPDFOperatorTableSetCallback(operatorTable, "Tm", setTextMatrix);
    CGPDFOperatorTableSetCallback(operatorTable, "Td", newLineWithLeading);
    CGPDFOperatorTableSetCallback(operatorTable, "TD", newLineSetLeading);
    CGPDFOperatorTableSetCallback(operatorTable, "T*", newLine);

    // Text state operators
    CGPDFOperatorTableSetCallback(operatorTable, "Tw", setWordSpacing);
    CGPDFOperatorTableSetCallback(operatorTable, "Tc", setCharacterSpacing);
    CGPDFOperatorTableSetCallback(operatorTable, "TL", setTextLeading);
    CGPDFOperatorTableSetCallback(operatorTable, "Tz", setHorizontalScale);
    CGPDFOperatorTableSetCallback(operatorTable, "Ts", setTextRise);
    CGPDFOperatorTableSetCallback(operatorTable, "Tf", setFont);

    // Graphics state operators
    CGPDFOperatorTableSetCallback(operatorTable, "cm", applyTransformation);
    CGPDFOperatorTableSetCallback(operatorTable, "q", pushRenderingState);
    CGPDFOperatorTableSetCallback(operatorTable, "Q", popRenderingState);

    CGPDFOperatorTableSetCallback(operatorTable, "BT", newParagraph);

    return operatorTable;
}

/* Create a font dictionary given a PDF page */
- (FontCollection *)fontCollectionWithPage:(CGPDFPageRef)page {
    CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
    if (!dict)     {
        NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing");
        return nil;
    }

    CGPDFDictionaryRef resources;
    if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources)) {
        NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing Resources dictionary");
        return nil;
    }

    CGPDFDictionaryRef fonts;
    if (!CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) {
        return nil;
    }

    FontCollection *collection = [[FontCollection alloc] initWithFontDictionary:fonts];
    return collection;
}


- (void)detectorFoundString:(PartNumberDetector *)detector
{
    possibleSelection = [Selection selectionWithState:self.renderingState];
    possibleSelection.text = [detector.unicodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    possibleSelection.finalState = self.renderingState;
    [self.selections addObject:possibleSelection];
    possibleSelection = nil;
}

- (RenderingState *)renderingState
{
    return [self.renderingStateStack topRenderingState];
}

@end
