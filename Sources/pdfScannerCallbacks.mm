#import "ReaderContentScanner.h"

#pragma - mark Function Prototypes
BOOL isSpace(float width, ReaderContentScanner *scanner);
void didScanSpace(float value, void *info);
void didScanString(CGPDFStringRef pdfString, void *info);
void didScanNewLine(CGPDFScannerRef pdfScanner, ReaderContentScanner *scanner, BOOL persistLeading);
CGPDFStringRef getString(CGPDFScannerRef pdfScanner);
CGPDFReal getNumber(CGPDFScannerRef pdfScanner);
CGPDFArrayRef getArray(CGPDFScannerRef pdfScanner);
CGPDFObjectRef getObject(CGPDFArrayRef pdfArray, int index);
CGPDFStringRef getStringValue(CGPDFObjectRef pdfObject);
float getNumericalValue(CGPDFObjectRef pdfObject, CGPDFObjectType type);
CGAffineTransform getTransform(CGPDFScannerRef pdfScanner);
void setHorizontalScale(CGPDFScannerRef pdfScanner, void *info);
void setTextLeading(CGPDFScannerRef pdfScanner, void *info);
void setFont(CGPDFScannerRef pdfScanner, void *info);
void setTextRise(CGPDFScannerRef pdfScanner, void *info);
void setCharacterSpacing(CGPDFScannerRef pdfScanner, void *info);
void setWordSpacing(CGPDFScannerRef pdfScanner, void *info);
void newLine(CGPDFScannerRef pdfScanner, void *info);
void newLineWithLeading(CGPDFScannerRef pdfScanner, void *info);
void newLineSetLeading(CGPDFScannerRef pdfScanner, void *info);
void beginTextObject(CGPDFScannerRef pdfScanner, void *info);
void endTextObject(CGPDFScannerRef pdfScanner, void *info);
void setTextMatrix(CGPDFScannerRef pdfScanner, void *info);
void printString(CGPDFScannerRef pdfScanner, void *info);
void printStringNewLine(CGPDFScannerRef scanner, void *info);
void printStringNewLineSetSpacing(CGPDFScannerRef scanner, void *info);
void printStringsAndSpaces(CGPDFScannerRef pdfScanner, void *info);
void pushRenderingState(CGPDFScannerRef pdfScanner, void *info);
void popRenderingState(CGPDFScannerRef pdfScanner, void *info);
void applyTransformation(CGPDFScannerRef pdfScanner, void *info);


#pragma - mark Function Definitions
BOOL isSpace(float width, ReaderContentScanner *scanner) {
    return fabsf(width) >= scanner.renderingState.font.widthOfSpace;
}

void didScanSpace(float value, void *info) {
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
    float width = [scanner.renderingState convertToUserSpace:value];
    [scanner.renderingState translateTextPosition:CGSizeMake(-width, 0)];
    if (isSpace(value, scanner)) {
        [scanner.partNumberDetector reset];
    }
}

void didScanString(CGPDFStringRef pdfString, void *info) {
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	PartNumberDetector *partNumberDetector = scanner.partNumberDetector;
	Font *font = scanner.renderingState.font;
    NSString *string =  [font stringWithPDFString:pdfString];

    // If this is a part number, say something!
    if ([font.baseFont containsString:@"Swiss721BT"]) {
//        NSLog(@"%s - Found part number: %@ (%@) [%@]", __PRETTY_FUNCTION__, string, font.baseFont, font.baseFontName);

        [partNumberDetector detectedString:string withFontName:font.baseFont];
    }

//    if (string) {
//        [partNumberDetector appendString:string];
//        [scanner.content appendString:string];
//    }
}

void didScanNewLine(CGPDFScannerRef pdfScanner, ReaderContentScanner *scanner, BOOL persistLeading) {
	CGPDFReal tx, ty;
	CGPDFScannerPopNumber(pdfScanner, &ty);
	CGPDFScannerPopNumber(pdfScanner, &tx);
	[scanner.renderingState newLineWithLeading:-ty indent:tx save:persistLeading];
}

CGPDFStringRef getString(CGPDFScannerRef pdfScanner) {
	CGPDFStringRef pdfString;
	CGPDFScannerPopString(pdfScanner, &pdfString);

	return pdfString;
}

CGPDFReal getNumber(CGPDFScannerRef pdfScanner) {
	CGPDFReal value;
	CGPDFScannerPopNumber(pdfScanner, &value);
	return value;
}

CGPDFArrayRef getArray(CGPDFScannerRef pdfScanner) {
	CGPDFArrayRef pdfArray;
	CGPDFScannerPopArray(pdfScanner, &pdfArray);
	return pdfArray;
}

CGPDFObjectRef getObject(CGPDFArrayRef pdfArray, int index) {
	CGPDFObjectRef pdfObject;
	CGPDFArrayGetObject(pdfArray, index, &pdfObject);
	return pdfObject;
}

CGPDFStringRef getStringValue(CGPDFObjectRef pdfObject) {
	CGPDFStringRef string;
	CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeString, &string);
	return string;
}

float getNumericalValue(CGPDFObjectRef pdfObject, CGPDFObjectType type) {
	if (type == kCGPDFObjectTypeReal) {
		CGPDFReal tx;
		CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeReal, &tx);
		return tx;
	}
	else if (type == kCGPDFObjectTypeInteger) {
		CGPDFInteger tx;
		CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeInteger, &tx);
		return tx;
	}

	return 0;
}

CGAffineTransform getTransform(CGPDFScannerRef pdfScanner) {
	CGAffineTransform transform;
	transform.ty = getNumber(pdfScanner);
	transform.tx = getNumber(pdfScanner);
	transform.d = getNumber(pdfScanner);
	transform.c = getNumber(pdfScanner);
	transform.b = getNumber(pdfScanner);
	transform.a = getNumber(pdfScanner);
	return transform;
}

#pragma mark Text parameters

void setHorizontalScale(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setHorizontalScaling:getNumber(pdfScanner)];
}

void setTextLeading(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setLeading:getNumber(pdfScanner)];
}

void setFont(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	CGPDFReal fontSize;
	const char *fontName;
	CGPDFScannerPopNumber(pdfScanner, &fontSize);
	CGPDFScannerPopName(pdfScanner, &fontName);

	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	RenderingState *state = scanner.renderingState;
	Font *font = [scanner.fontCollection fontNamed:[NSString stringWithUTF8String:fontName]];

//    NSLog(@"%s - Setting font to: %@ (%s)", __PRETTY_FUNCTION__, font.baseFont, fontName);

    [state setFont:font];
	[state setFontSize:fontSize];
}

void setTextRise(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setTextRise:getNumber(pdfScanner)];
}

void setCharacterSpacing(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setCharacterSpacing:getNumber(pdfScanner)];
}

void setWordSpacing(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setWordSpacing:getNumber(pdfScanner)];
}


#pragma mark Set position

void newLine(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState newLine];
}

void newLineWithLeading(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	didScanNewLine(pdfScanner, (__bridge ReaderContentScanner *) info, NO);
}

void newLineSetLeading(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	didScanNewLine(pdfScanner, (__bridge ReaderContentScanner *) info, YES);
}

void setTextMatrix(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingState setTextMatrix:getTransform(pdfScanner) replaceLineMatrix:YES];
}

void beginTextObject(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
    // Reset the text matrix to identity
    ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
    [scanner.renderingState setTextMatrix:CGAffineTransformIdentity replaceLineMatrix:YES];
}

void endTextObject(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
    // Discard the text matrix (reset to CTM)
    ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
    [scanner.renderingState setTextMatrix:scanner.renderingState.ctm replaceLineMatrix:YES];
}

#pragma mark Print strings

void printString(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	didScanString(getString(pdfScanner), info);
}

void printStringNewLine(CGPDFScannerRef scanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	newLine(scanner, info);
	printString(scanner, info);
}

void printStringNewLineSetSpacing(CGPDFScannerRef scanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	setWordSpacing(scanner, info);
	setCharacterSpacing(scanner, info);
	printStringNewLine(scanner, info);
}

void printStringsAndSpaces(CGPDFScannerRef pdfScanner, void *info) {
#ifdef DEBUGLOG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
	CGPDFArrayRef array = getArray(pdfScanner);
	for (int i = 0; i < CGPDFArrayGetCount(array); i++) {
		CGPDFObjectRef pdfObject = getObject(array, i);
		CGPDFObjectType valueType = CGPDFObjectGetType(pdfObject);

		if (valueType == kCGPDFObjectTypeString) {
			didScanString(getStringValue(pdfObject), info);
		}
		else {
			didScanSpace(getNumericalValue(pdfObject, valueType), info);
		}
	}
}


#pragma mark Graphics state operators

void pushRenderingState(CGPDFScannerRef pdfScanner, void *info)
{
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	RenderingState *state = [scanner.renderingState copy];
    state.pageMatrix = scanner.pageMatrix;
	[scanner.renderingStateStack pushRenderingState:state];
#ifdef DEBUGLOG
    NSLog(@"%s - CTM now a:%f b:%f c:%f d:%f   tx:%f ty:%f", __PRETTY_FUNCTION__, state.ctm.a, state.ctm.b, state.ctm.c, state.ctm.d, state.ctm.tx, state.ctm.ty);
#endif
}

void popRenderingState(CGPDFScannerRef pdfScanner, void *info)
{
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	[scanner.renderingStateStack popRenderingState];
#ifdef DEBUGLOG
    RenderingState *state = scanner.renderingState;
    NSLog(@"%s - CTM now a:%f b:%f c:%f d:%f   tx:%f ty:%f", __PRETTY_FUNCTION__, state.ctm.a, state.ctm.b, state.ctm.c, state.ctm.d, state.ctm.tx, state.ctm.ty);
#endif
}

/* Update CTM */
void applyTransformation(CGPDFScannerRef pdfScanner, void *info)
{
	ReaderContentScanner *scanner = (__bridge ReaderContentScanner *) info;
	RenderingState *state = scanner.renderingState;
	state.ctm = CGAffineTransformConcat(getTransform(pdfScanner), state.ctm);
    state.pageMatrix = scanner.pageMatrix;
#ifdef DEBUGLOG
    NSLog(@"%s - CTM now a:%f b:%f c:%f d:%f   tx:%f ty:%f", __PRETTY_FUNCTION__, state.ctm.a, state.ctm.b, state.ctm.c, state.ctm.d, state.ctm.tx, state.ctm.ty);
#endif
}

