//
//  ZMSDKEmailMeetingInterface.m
//  ZoomSDKSample
//
//  Created by derain on 2018/11/26.
//  Copyright © 2018年 zoom.us. All rights reserved.
//

#import "ZMSDKEmailMeetingInterface.h"
#import "ZoomSDKWindowController.h"

@implementation ZMSDKEmailMeetingInterface
- (id)init
{
    self = [super init];
    if(self)
    {
        return self;
    }
    return nil;
}

-(void)cleanUp
{
    
}
- (void)dealloc
{
    [self cleanUp];
    [super dealloc];
}

- (void)onMeetingStatusChange:(ZoomSDKMeetingStatus)state meetingError:(ZoomSDKMeetingError)error EndReason:(EndMeetingReason)reason
{
    /*
    ZoomSDKVideoContainer* videoContainer = [[[ZoomSDK sharedSDK] getMeetingService] getVideoContainer];
    if (state == ZoomSDKMeetingStatus_Connecting)
    {
        //Usage
        ZoomSDKPreViewVideoElement* preElement = [[ZoomSDKPreViewVideoElement alloc] initWithFrame: NSMakeRect(0, 0, 320, 240)];
        [videoContainer createVideoElement: & preElement];
        [preElement startPreview: YES];
    }
    else if (state == ZoomSDKMeetingStatus_InMeeting)
    {
        ZoomSDKNormalVideoElement* normalElement = [[ZoomSDKNormalVideoElement alloc] initWithFrame: NSMakeRect(0, 0, 320, 240)];
        [videoContainer createVideoElement: &normalElement];
        [normalElement subscribeVideo: YES];
    }
     */
}

- (ZoomSDKError)startVideoMeetingForEmailUser
{
    ZoomSDKMeetingService* meetingService = [[ZoomSDK sharedSDK] getMeetingService];
    
    if (meetingService)
    {
        ZoomSDKError ret = [meetingService startMeeting:ZoomSDKUserType_ZoomUser userID:nil userToken:nil displayName:nil meetingNumber:0 isDirectShare:NO sharedApp:0 isVideoOff:NO isAuidoOff:NO vanityID:nil];
        return ret;
    }
    return ZoomSDKError_Failed;
}

- (ZoomSDKError)startAudioMeetingForEmailUser
{
    ZoomSDKMeetingService* meetingService = [[ZoomSDK sharedSDK] getMeetingService];
    if (meetingService)
    {
        ZoomSDKError ret = [meetingService startMeeting:ZoomSDKUserType_ZoomUser userID:nil userToken:nil displayName:nil meetingNumber:0 isDirectShare:NO sharedApp:0 isVideoOff:YES isAuidoOff:NO vanityID:nil];
        return ret;
    }
    return ZoomSDKError_Failed;
}

- (ZoomSDKError)joinMeetingForEmailUser:(NSString*)meetingNumber displayName:(NSString*)name password:(NSString*)psw
{
    ZoomSDKMeetingService* meetingService = [[ZoomSDK sharedSDK] getMeetingService];
    if (meetingService && meetingNumber.length > 0)
    {
        ZoomSDKError ret = [meetingService joinMeeting:ZoomSDKUserType_ZoomUser toke4enfrocelogin:nil webinarToken:nil participantId:@"" meetingNumber:meetingNumber displayName:name password:psw isDirectShare:NO sharedApp:0 isVideoOff:NO isAuidoOff:NO vanityID:nil];
        return ret;
    }
    return ZoomSDKError_Failed;
}

@end
