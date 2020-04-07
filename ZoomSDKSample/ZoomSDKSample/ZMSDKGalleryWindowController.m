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
    
    float xpos = self.window.contentView.frame.size.width/2;
    float xposLeft = xpos;
    float xposRight = xpos;
    float yPos = 2;
    float width = 80;
    float height = 60;
    float margin = 30;
    ZMSDKButton* theButton = nil;
    
    ZMSDKBackgroundView* toolbarBackgroundView = [[ZMSDKBackgroundView alloc] initWithFrame:NSMakeRect(0, 0, self.window.frame.size.width, height + yPos)];
    toolbarBackgroundView.backGroundColor = [NSColor blackColor];
    [self.view addSubview:toolbarBackgroundView];
    [toolbarBackgroundView release];
    
    NSColor* titleColor = [NSColor whiteColor];
    NSColor* pressTitleColor = [NSColor colorWithRed:145/225 green:145/225 blue:145/225 alpha:0];
    NSColor* pressBgColor = nil;
    NSColor* hoverBgColor = nil;
    hoverBgColor = [NSColor colorWithCalibratedWhite:0 alpha:0.5];
    pressBgColor = [NSColor colorWithCalibratedWhite:0 alpha:0.5];
    NSFont* theFont = [NSFont systemFontOfSize:12];
    
    theButton = [[ZMSDKButton alloc] initWithFrame:NSMakeRect(xpos, yPos, width, height)];
    theButton.tag = BUTTON_TAG_AUDIO;
    theButton.title = @"Split";
    theButton.titleColor = titleColor;
    theButton.disableTitleColor = [NSColor grayColor];
    theButton.pressTitleColor = pressTitleColor;
    theButton.font = theFont;
    theButton.hoverBackgroundColor = hoverBgColor;
    theButton.pressBackgoundColor = pressBgColor;
    theButton.imagePosition = NSImageAbove;
    theButton.image = [NSImage imageNamed:@"toolbar_mute_voip_normal"];
    theButton.pressImage = [NSImage imageNamed:@"toolbar_mute_voip_press"];
    theButton.autoresizingMask = NSViewMaxXMargin;
    [theButton setTarget:self];
    [theButton setAction:@selector(onSplitButtonClicked:)];
    // [theButton setHidden:YES];
    [self.view addSubview:theButton];
    [theButton release];
    theButton = nil;
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
    // NSLog(@"validateDrop: %@", self);
    return NSDragOperationMove;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSLog(@"willBeginAtPoint: %@", self);
    draggingIndexPaths = indexPaths;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation
{
    NSLog(@"endedAtPoint: %@", self);
    for (NSIndexPath *indexPath in draggingIndexPaths) {
        [_videoArray removeObjectAtIndex:indexPath.item];
    }
    
    draggingIndexPaths = [NSSet<NSIndexPath *> set];
    [collectionView reloadData];
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
        if (i < _videoArray.count / 2) {
            [self onUserleft:videoElement.userid];
        } else {
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
