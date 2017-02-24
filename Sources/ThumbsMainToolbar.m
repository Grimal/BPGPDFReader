//
//	ThumbsMainToolbar.m
//	Reader v2.9.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"

@implementation ThumbsMainToolbar
@dynamic delegate;

#pragma mark - ThumbsMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame title:nil];
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
	if ((self = [super initWithFrame:frame]))
	{
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:title];
        item.hidesBackButton = YES;
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(doneButtonTapped:)];
        item.leftBarButtonItem = doneButton;
#if (READER_BOOKMARKS == TRUE)
        UIImage *thumbsImage = [UIImage imageNamed:@"Reader-Thumbs"];
        UIImage *bookmarkImage = [UIImage imageNamed:@"Reader-Mark-Y"];
        UISegmentedControl *showControl = [[UISegmentedControl alloc] initWithItems:@[thumbsImage, bookmarkImage]];
        showControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        showControl.selectedSegmentIndex = 0; // Default segment index
        showControl.exclusiveTouch = YES;
        [showControl addTarget:self.delegate action:@selector(showControlChanged:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:showControl];
        item.rightBarButtonItem = controlItem;
#endif
        [self pushNavigationItem:item animated:NO];
	}

	return self;
}

@end
