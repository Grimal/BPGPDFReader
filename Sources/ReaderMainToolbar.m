//
//	ReaderMainToolbar.m
//	Reader v2.9.0
//
//	Created by Julius Oklamcak on 2011-07-01.
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
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"

#import <MessageUI/MessageUI.h>

@implementation ReaderMainToolbar
{
    UIBarButtonItem *markButton;
    UIImage *markImageN;
    UIImage *markImageY;

    UIBarButtonItem *favoriteButton;
    UIImage *addFavorite;
    UIImage *removeFavorite;
}

@dynamic delegate;

#pragma mark - ReaderMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame document:nil];
}

- (instancetype)initWithFrame:(CGRect)frame document:(ReaderDocument *)document
{
    assert(document != nil); // Must have a valid ReaderDocument
    
    if ((self = [super initWithFrame:frame]))
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSMutableArray *leftBarButtonItems = [[NSMutableArray alloc] init];
        NSMutableArray *rightBarButtonItems = [[NSMutableArray alloc] init];
#if (READER_STANDALONE == FALSE)
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(doneButtonTapped:)];
        [leftBarButtonItems addObject:doneButton];
#endif
#if (READER_ENABLE_THUMBS == TRUE)
        UIBarButtonItem *thumbsButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Thumbs"] style:UIBarButtonItemStylePlain target:self.delegate action:@selector(thumbsButtonTapped:)];
        [leftBarButtonItems addObject:thumbsButton];
#endif
#if (READER_BOOKMARKS == TRUE)
        markImageN = [UIImage imageNamed:@"Reader-Mark-N"]; // N image
        markImageY = [UIImage imageNamed:@"Reader-Mark-Y"]; // Y image
        
        UIBarButtonItem *flagButton =[[UIBarButtonItem alloc] initWithImage:markImageN style:UIBarButtonItemStylePlain target:self.delegate action:@selector(markButtonTapped:)];
        [rightBarButtonItems addObject:flagButton];
        markButton = flagButton; markButton.enabled = NO; markButton.tag = NSIntegerMin;
#endif
        if (document.canEmail == YES) // Document email enabled
        {
            if ([MFMailComposeViewController canSendMail] == YES) // Can email
            {
                unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
                if (fileSize < 15728640ull) // Check attachment size limit (15MB)
                {
                    UIBarButtonItem *emailButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Email"] style:UIBarButtonItemStylePlain target:self.delegate action:@selector(emailButtonTapped:)];
                    [rightBarButtonItems addObject:emailButton];
                    
                }
            }
        }
        if ((document.canPrint == YES) && (document.password == nil)) // Document print enabled
        {
            Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
            
            if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable]) {
                UIBarButtonItem *printButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Print"] style:UIBarButtonItemStylePlain target:self.delegate action:@selector(printButtonTapped:)];
                
                [rightBarButtonItems addObject:printButton];
                
            }
        }
        if (document.canExport == YES) // Document export enabled
        {
            UIBarButtonItem *exportButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Export"] style:UIBarButtonItemStylePlain target:self.delegate action:@selector(exportButtonTapped:)];
            [rightBarButtonItems addObject:exportButton];
        }

        // Document favorites
        addFavorite = [UIImage imageNamed:@"addFavorite"];
        removeFavorite = [UIImage imageNamed:@"removeFavorite"];

        favoriteButton = [[UIBarButtonItem alloc] initWithImage:addFavorite style:UIBarButtonItemStylePlain target:self.delegate action:@selector(favoriteButtonTapped:)];
        [rightBarButtonItems addObject:favoriteButton];
        favoriteButton.enabled = YES; markButton.tag = NSIntegerMin;

//        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[document.fileName stringByDeletingPathExtension]];
        UINavigationItem *item = [[UINavigationItem alloc] init];
        item.leftBarButtonItems = leftBarButtonItems;
        item.rightBarButtonItems = rightBarButtonItems;
        
        item.hidesBackButton = YES;
        [self pushNavigationItem:item animated:NO];
    }
    
    return self;
}

- (void)setBookmarkState:(BOOL)state {
#if (READER_BOOKMARKS == TRUE) // Option

    if (state != markButton.tag) // Only if different state
    {
        if (self.hidden == NO) // Only if toolbar is visible
        {
            markButton.image = state ? markImageY : markImageN;
        }

        markButton.tag = state; // Update bookmarked state tag
    }

    if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}
- (void)updateBookmarkImage {
#if (READER_BOOKMARKS == TRUE) // Option

    if (markButton.tag != NSIntegerMin) // Valid tag
    {
        BOOL state = markButton.tag; // Bookmarked state

        markButton.image = state ? markImageY : markImageN;
    }

    if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)setFavoriteState:(BOOL)state {
    favoriteButton.image = state ? removeFavorite : addFavorite;
    favoriteButton.tintColor = state ? [UIColor redColor] : nil;
}

- (void)hideToolbar
{
    if (self.hidden == NO)
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
    }
}

- (void)showToolbar
{
    if (self.hidden == YES)
    {
        [self updateBookmarkImage]; // First

        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
    }
}

- (void)addLeftToolbarItems:(NSArray<UIBarButtonItem *> *)barButtonItems
{
    self.topItem.leftBarButtonItems = [self.topItem.leftBarButtonItems arrayByAddingObjectsFromArray:barButtonItems];
}

- (void)addRightToolbarItems:(NSArray<UIBarButtonItem *> *)barButtonItems
{
    self.topItem.rightBarButtonItems = [self.topItem.rightBarButtonItems arrayByAddingObjectsFromArray:barButtonItems];
}


@end
