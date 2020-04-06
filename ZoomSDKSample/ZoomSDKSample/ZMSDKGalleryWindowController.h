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

@interface ZMSDKGalleryWindowController : NSWindowController<NSCollectionViewDelegate, NSCollectionViewDataSource>
{
    ZMSDKThumbnailVideoItemView*  itemThumbnailView;
    NSMutableArray*        _videoArray;//All Video user array
    ZMSDKMeetingMainWindowController* _meetingMainWindowController;
}
@property (assign) IBOutlet NSCollectionView *collectionView;

- (void)showSelf;
- (void)onUserJoin:(unsigned int)userID;
- (void)onUserleft:(unsigned int)userID;

- (void)onUserVideoStatusChange:(BOOL)videoOn UserID:(unsigned int)userID;
- (void)resetInfo;
- (void)setMeetingMainWindowController:(ZMSDKMeetingMainWindowController*)meetingMainWindowController;

@end

NS_ASSUME_NONNULL_END
