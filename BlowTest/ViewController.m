//
//  ViewController.m
//  Test
//
//  Created by Yifan on 2017/11/20.
//  Copyright © 2017年 Yifan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *Info;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    lowPassResults = 0.0;
    NSString *recordedAudioPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                   objectAtIndex:0];
    
    recordedAudioPath = [recordedAudioPath stringByAppendingPathComponent:@"recorded.caf"];
    NSURL *url = [NSURL fileURLWithPath:recordedAudioPath];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error!=nil) {
        NSLog(@"Error : %@", error);
    }
    if (recorder) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        
        NSTimer* deleteFileTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(removeRecordingFile) userInfo:nil repeats:NO];
    } else
        NSLog([error description]);
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    if (lowPassResults > 0.80) {
        NSLog(@"Mic blow detected %f", lowPassResults);
        self.Info.text = @"Detected!";
    } else{
        self.Info.text = @"Nothing";
    }
}

- (void)removeRecordingFile
{
    // Remove the data file from the recording.
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"cache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    BOOL success = [fileManager removeItemAtPath:recorderFilePath error:&error];
    
    if(success)
    {
        NSLog(@"Deleted recording file");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
