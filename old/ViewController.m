//
//  ViewController.m
//  BonjourWeb
//
//  Created by Klaus Engel on 6/1/12.
//  Copyright (c) 2012 __Angisoft__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    checkForRunningBehaviors = false;
    
    NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.getRunningBehaviors()",
                        baseURL?baseURL:@""];
    
    [self sendRequest:string];
    
    [content addSubview:naoInfo];
    [content addSubview:control];
    [content addSubview:table];
    [tabbar setSelectedItem:[tabbar.items objectAtIndex:0]];
        
    [string release];
   
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [behaviors release];
    [receivedData release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [behaviors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *tableCellIdentifier = @"UITableViewCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}
	
    cell.textLabel.text = [behaviors objectAtIndex:[indexPath row]];

     return cell;
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sb = [behaviors objectAtIndex:[indexPath row]];
	
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.runBehavior(%%22%@\%%22)",
                        baseURL?baseURL:@"",
                        sb?sb:@""];
        
    checkForRunningBehaviors = true;
    [self sendRequest:string];

	[string release];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sb = [behaviors objectAtIndex:[indexPath row]];
	
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.stopBehavior(%%22%@\%%22)",
                        baseURL?baseURL:@"",
                        sb?sb:@""];
    
    checkForRunningBehaviors = true;
    [self sendRequest:string];

	[string release];
}

- (void)setBehaviors:(NSString *)behave
{
    behaviors = [[NSMutableArray alloc] init];
    [behaviors retain];
    
    NSRange range;
    bool inString = false;
    for (int i=0;i<behave.length;i++)
    {
        if ([behave characterAtIndex:i] == '"')
        {
            inString = !inString;
            if (!inString)
            {
                range.length = i - range.location;
                [behaviors addObject:[behave substringWithRange:range]];
            }
            else 
            {
                range.location = i+1;
            }
        }
    }
    [behaviors addObject:@""];
    [behaviors addObject:@""];
    [behaviors addObject:@""];
    
}

- (void)setBaseURL:(NSString *)url
{
    baseURL = url;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);

    unsigned char byteBuffer[[receivedData length]];
    [receivedData getBytes:byteBuffer];
    NSLog(@"Output: %s", (char *)byteBuffer);
        
    if (checkForRunningBehaviors)
    {
        checkForRunningBehaviors = false;
        NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.getRunningBehaviors()",
                            baseURL?baseURL:@""];
        
        [self sendRequest:string];

        [string release];
    }
    else 
    {
        NSString *behave = [NSString stringWithFormat:@"%s",byteBuffer];
        NSMutableArray *runningBehaviors = [[NSMutableArray alloc] init];

        NSRange range;
        bool inString = false;
        for (int i=0;i<behave.length;i++)
        {
            if ([behave characterAtIndex:i] == '"')
            {
                inString = !inString;
                if (!inString)
                {
                    range.length = i - range.location;
                    [runningBehaviors addObject:[behave substringWithRange:range]];
                }
                else 
                {
                    range.location = i+1;
                }
            }
        }
        
        NSLog(@"Checking for running behaviors");
        for(int j = 0; j < [behaviors count]; j++)
        {
            [table deselectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:YES];
            for(int i = 0; i < [runningBehaviors count]; i++)
            {
                if ([[behaviors objectAtIndex:j] isEqualToString:[runningBehaviors objectAtIndex:i]])
                {
                    [table selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    
        [runningBehaviors release];
    }
    
    // release the connection, and the data object
    [connection release];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = [[tabBar items] indexOfObject:item];
    if (tag == 0)
    {
        [content bringSubviewToFront:table];
    }
    else
    if (tag == 1)
    {
        [content bringSubviewToFront:control];
        NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.setStiffnesses(%%22Body%%22,1.0)",
                            baseURL?baseURL:@""];
        [self sendRequest:string];
        [string release];
    }
    else
    if (tag == 2)
    {
        [content bringSubviewToFront:naoInfo];
                 
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:baseURL];
                    
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
                    
        //Load the request in the UIWebView.
        [webView loadRequest:requestObj];
    }
}

- (void)sendRequest:(NSString*) urlString
{
	NSURL *url = [[NSURL alloc] initWithString:urlString];
    //	[[UIApplication sharedApplication] openURL:url];
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
    }
    
	[url release];

}

- (IBAction)OnSpeakButton:(id)sender
{
    NSString *sb = [text.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALTextToSpeech.say(%%22%@\%%22)",
                        baseURL?baseURL:@"",
                        sb?sb:@""];
    
    [self sendRequest:string];
	[string release];
}

- (IBAction)OnLeftButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(0,1,0)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];
}
- (IBAction)OnRightButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(0,-1,0)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];
}
- (IBAction)OnForwardButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(1,0,0)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];
}
- (IBAction)OnBackwardButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(-1,0,0)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];    
}
- (IBAction)OnTurnLeftButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(0,0,1)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];
}
- (IBAction)OnTurnRightButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.walkTo(0,0,-1)",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];    
}
- (IBAction)OnStandUpButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.runBehavior(%%22standup%%22)",
                        baseURL?baseURL:@""];
    
    [self sendRequest:string];
    
	[string release];
}
- (IBAction)OnSitDownButton:(id)sender
{
	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALBehaviorManager.runBehavior(%%22sitdown%%22)",
                        baseURL?baseURL:@""];
    
    [self sendRequest:string];
    
	[string release];
}

- (IBAction)OnStopButton:(id)sender
{
  	NSString* string = [[NSString alloc] initWithFormat:@"%@?eval=ALMotion.stopWalk()",
                        baseURL?baseURL:@""];
    [self sendRequest:string];
	[string release];  
}

@end
