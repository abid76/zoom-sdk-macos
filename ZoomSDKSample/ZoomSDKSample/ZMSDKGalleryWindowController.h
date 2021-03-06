//
//  NSGalleryWindow.h
//  ZoomSDKSample
//
//  Created by Abid Hussain on 04.04.20.
//  Copyright © 2020 TOTTI. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZMSDKMeetingMainWindowController.h"
#import "ZMSDKThumbnailVideoItemView.h"

NS_ASSUME_NONNULL_BEGIN

static const int MIN_ITEM_WIDTH = 200;
static const int MIN_ITEM_HEIGHT = 200;

@interface ZMSDKGalleryWindowController : NSWindowController<NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout>
{
    ZMSDKThumbnailVideoItemView*  itemThumbnailView;
    NSMutableArray*        _videoArray;//All Video user array
    ZMSDKMeetingMainWindowController* _meetingMainWindowController;
}

@property (assign) IBOutlet NSButton *splitButton;
@property (assign) IBOutlet NSView *view;
@property (assign) IBOutlet NSScrollView *scrollView;
@property (assign) IBOutlet NSCollectionView *collectionView;
@property (assign) IBOutlet NSCollectionViewFlowLayout *flowLayout;
@property(nonatomic, retain, readwrite)ZMSDKMeetingMainWindowController* meetingMainWindowController;

- (void)showSelf;
- (void)onUserJoin:(unsigned int)userID;
- (void)onUserleft:(unsigned int)userID;

- (void)onUserVideoStatusChange:(BOOL)videoOn UserID:(unsigned int)userID;
- (void)resetInfo;
- (void)setMeetingMainWindowController:(ZMSDKMeetingMainWindowController*)meetingMainWindowController;

@end

NS_ASSUME_NONNULL_END
