//
//  ViewController.h
//  Test
//
//  Created by Yifan on 2017/11/20.
//  Copyright © 2017年 Yifan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController : UIViewController{
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double lowPassResults;
}

- (void)levelTimerCallback:(NSTimer *)timer;

@end

