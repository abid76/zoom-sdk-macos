//
//  NSGalleryWindow.m
//  ZoomSDKSample
//
//  Created by Abid Hussain on 04.04.20.
//  Copyright © 2020 TOTTI. All rights reserved.
//

#import "ZMSDKGalleryWindowController.h"
#import "ZMSDKThumbnailCollectionViewItem.h"
#import "ZMSDKButton.h"

@interface ZMSDKGalleryWindowController ()

@end

@class ZMSDKMeetingMainWindowController;

@implementation ZMSDKGalleryWindowController
@synthesize collectionView;
@synthesize meetingMainWindowController = _meetingMainWindowController;
NSSet<NSIndexPath *> * draggingIndexPaths;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
    
    draggingIndexPaths = [NSSet<NSIndexPath *> set];
    NSLog(@"initWithWindow: %@", self);
    
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

- (void)initUI
{
    [collectionView registerForDraggedTypes:@[NSPasteboardTypeString]];
    
    _splitButton.target = self;
    _splitButton.action = @selector(onSplitButtonClicked:);
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
    thumbnailView.videoView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [item.view addSubview:thumbnailView.videoView];
    
    NSLog(@"View: Width: %f, Height: %f", item.view.frame.size.width, item.view.frame.size.height);
    NSLog(@"VideoView: Width: %f, Height: %f", thumbnailView.videoView.frame.size.width, thumbnailView.videoView.frame.size.height);
    
    return item;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 200;// self.view.frame.size.width / _videoArray.count;
    CGFloat height = 200; //self.view.frame.size.height / _videoArray.count;
    
    NSLog(@"sizeForItemAtIndexPath: %f, %f", width, height);
    
    return NSMakeSize(width, height);
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"pasteboardWriterForItemAtIndexPath: %@", self);
    
    NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
    ZoomSDKNormalVideoElement *element = [_videoArray objectAtIndex:indexPath.item];
    [item setString:[NSString stringWithFormat:@"%d", element.userid] forType:NSPasteboardTypeString];
    
    return item;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath * _Nonnull *)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    NSWindow* window = draggingInfo.draggingDestinationWindow;
    if ([window.windowController isKindOfClass:ZMSDKGalleryWindowController.class])
    {
        NSLog(@"validateDrop (NSDragOperationMove): %@", self);
        return NSDragOperationMove;
    }
    
    NSLog(@"validateDrop (NSDragOperationNone): %@", self);
    return NSDragOperationNone;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSLog(@"draggingSession: %@", self);
    
    draggingIndexPaths = indexPaths;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation
{
    NSLog(@"endedAtPoint: %@", self);

    if (operation == NSDragOperationMove)
    {
        for (NSIndexPath *indexPath in draggingIndexPaths) {
            [_videoArray removeObjectAtIndex:indexPath.item];
        }
        
        [collectionView reloadData];
    }
    draggingIndexPaths = [NSSet<NSIndexPath *> set];
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    NSLog(@"acceptDrop: %@", self);
    
    if (draggingInfo.draggingPasteboard.pasteboardItems) {
        NSPasteboardItem *item = [draggingInfo.draggingPasteboard.pasteboardItems objectAtIndex:0];
        NSString *str = [item stringForType:NSPasteboardTypeString];
        
        int userId = [str intValue];
        [self onUserVideoStatusChange:YES UserID:userId];
    }
    
    [collectionView reloadData];
    
    return YES;
}

- (void)onSplitButtonClicked:(id)sender
{
    ZMSDKGalleryWindowController *galleryWindow = [[ZMSDKGalleryWindowController alloc] initWithWindowNibName:@"ZMSDKGalleryWindowController"];
    galleryWindow.meetingMainWindowController = self.meetingMainWindowController;
    
    [galleryWindow showSelf];
    
    for (int i = 0; i < _videoArray.count; i++) {
        
        ZoomSDKVideoElement *videoElement = [_videoArray objectAtIndex:i];
        if (i > _videoArray.count / 2) {
            [self onUserleft:videoElement.userid];
            [galleryWindow onUserVideoStatusChange:YES UserID:videoElement.userid];
        }
    }
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
        ZoomSDKNormalVideoElement* videoItem = [[ZoomSDKNormalVideoElement alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
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
