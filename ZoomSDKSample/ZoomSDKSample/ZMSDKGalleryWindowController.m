//
//  NSGalleryWindow.m
//  ZoomSDKSample
//
//  Created by Abid Hussain on 04.04.20.
//  Copyright © 2020 TOTTI. All rights reserved.
//

#import "ZMSDKGalleryWindowController.h"
#import "ZMSDKThumbnailCollectionViewItem.h"

@interface ZMSDKGalleryWindowController ()

@end

@implementation ZMSDKGalleryWindowController
@synthesize collectionView;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // [collectionView registerClass:ZMSDKThumbnailCollectionViewItem.class forItemWithIdentifier:@"Item"];
    // [collectionView registerClass:ZMSDKThumbnailCollectionViewItem.class forItemWithIdentifier:@"item"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if(self)
    {
        _videoArray = [[NSMutableArray alloc] init];
        [self initUI];
    }
    return self;
}
- (void)awakeFromNib
{
    [self initUI];
}
- (void)dealloc
{
    [self cleanUp];
    [super dealloc];
}
- (void)cleanUp
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(_videoArray)
    {
        ZoomSDKVideoContainer* videoContainer = [[[ZoomSDK sharedSDK] getMeetingService] getVideoContainer];
        for(ZoomSDKVideoElement* videoElement in _videoArray)
        {
            [videoContainer cleanVideoElement:videoElement];
            NSView* videoview = [videoElement getVideoView];
            [videoview removeFromSuperview];
            [videoElement release];
            videoElement = nil;
        }
        [_videoArray removeAllObjects];
        [_videoArray release];
        _videoArray = nil;
    }
}

- (void)showSelf
{
    [self.window makeKeyAndOrderFront:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _videoArray.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    ZMSDKThumbnailCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"ZMSDKThumbnailCollectionViewItem" forIndexPath:indexPath];
    ZoomSDKVideoElement* thumbnailView = [_videoArray objectAtIndex:indexPath.item];
    [item.view addSubview:[thumbnailView getVideoView]];
    
    return item;
}

- (void)initUI
{
}

- (void)onUserJoin:(unsigned int)userID
{
    return;
}
- (void)setMeetingMainWindowController:(ZMSDKMeetingMainWindowController*)meetingMainWindowController
{
    _meetingMainWindowController = meetingMainWindowController;
}
- (void)onUserleft:(unsigned int)userID
{
    ZoomSDKVideoElement *videoElement = nil;
    int index = -1;
    for(ZoomSDKVideoElement* item in _videoArray)
    {
        if(item.userid == userID)
        {
            videoElement = item;
            index = (int)[_videoArray indexOfObject:item];
        }
    }
    if(videoElement)
    {
        if ([videoElement getVideoView].superview)
           [[videoElement getVideoView] removeFromSuperview];
        [_videoArray removeObjectAtIndex:index];
        [videoElement release];
        
        [collectionView reloadData];
    }
}

- (void)onUserVideoStatusChange:(BOOL)videoOn UserID:(unsigned int)userID
{
    BOOL hasExist = NO;
    for(ZoomSDKVideoElement* thumbnailVideoView in _videoArray)
    {
        if (thumbnailVideoView.userid == userID)
        {
            hasExist = YES;
        }
    }
    if(!hasExist)
    {
        ZoomSDKNormalVideoElement* videoItem = [[ZoomSDKNormalVideoElement alloc] initWithFrame:NSMakeRect(0, 0, 150, 150)];
        ZoomSDKVideoContainer* videoContainer = [[[ZoomSDK sharedSDK] getMeetingService] getVideoContainer];
        [videoContainer createVideoElement:&videoItem];
        videoItem.userid = userID;
        [_videoArray addObject:videoItem];
        
        [collectionView reloadData];
    }
}

- (void)resetInfo
{
    if(_videoArray)
    {
        ZoomSDKVideoElement *videoElement = nil;
        for(int i = (int)_videoArray.count - 1; i >= 0; i--)
        {
            videoElement = [_videoArray objectAtIndex:i];
            if(videoElement)
            {
                if([videoElement getVideoView].superview)
                    [[videoElement getVideoView] removeFromSuperview];
                [_videoArray removeObjectAtIndex:i];
                [videoElement release];
            }
        }
        [_videoArray removeAllObjects];
        [collectionView reloadData];
    }
}
- (BOOL)isUserAlreadyExist:(unsigned int)inUserId inArray:(NSArray*)inArray
{
    if(!inArray || inArray.count<=0)
        return NO;
    for(ZoomSDKVideoElement* item in inArray)
    {
        if(item.userid == inUserId)
            return YES;
    }
    return NO;
}
- (ZoomSDKVideoElement*)getUserVideoViewById:(unsigned int)userID inArray:(NSArray<ZoomSDKVideoElement*>*)inArray
{
    if(index<0 || !inArray || !userID)
        return nil;
    for(ZoomSDKVideoElement* item in inArray)
    {
        unsigned int userid = item.userid;
        if(userid == userID)
            return item;
    }
    return nil;
}
- (int)getUserVideoViewIndexById:(unsigned int)userID inArray:(NSArray<ZoomSDKVideoElement*>*)inArray
{
    if(inArray.count == 0 || !inArray || !userID)
        return -1;
    for(int i = 0; i < inArray.count; i++)
    {
        unsigned int userid = [inArray objectAtIndex:i].userid;
        if(userid == userID)
            return i;
    }
    return -1;
}
@end
