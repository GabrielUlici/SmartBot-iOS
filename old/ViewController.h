//
//  ViewController.h
//  BonjourWeb
//
//  Created by Klaus Engel on 6/1/12.
//  Copyright (c) 2012 __Angisoft__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    NSMutableArray *behaviors;
    NSString *baseURL;
    NSMutableData *receivedData;
    bool checkForRunningBehaviors;
    IBOutlet UITableView *table;
    IBOutlet UIView* content;
    IBOutlet UIView* control;
    IBOutlet UIView* naoInfo;
    IBOutlet UITabBar* tabbar;
    IBOutlet UIButton* speakButton;
    IBOutlet UITextView *text;
    IBOutlet UIWebView *webView;
}

- (void)sendRequest:(NSString*) urlString;
- (void)setBehaviors:(NSString *)behave;
- (void)setBaseURL:(NSString *)url;
- (IBAction)OnSpeakButton:(id)sender;
- (IBAction)OnLeftButton:(id)sender;
- (IBAction)OnRightButton:(id)sender;
- (IBAction)OnForwardButton:(id)sender;
- (IBAction)OnBackwardButton:(id)sender;
- (IBAction)OnTurnLeftButton:(id)sender;
- (IBAction)OnTurnRightButton:(id)sender;
- (IBAction)OnStandUpButton:(id)sender;
- (IBAction)OnSitDownButton:(id)sender;
- (IBAction)OnStopButton:(id)sender;

@end
