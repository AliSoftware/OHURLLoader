//
//  OHURLLoaderAppDelegate.h
//  OHURLLoader
//
//  Created by Olivier on 09/01/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OHURLLoaderViewController;

@interface OHURLLoaderAppDelegate : UIViewController <UIApplicationDelegate, UITextFieldDelegate> {
	IBOutlet UITextField* urlField;
	IBOutlet UIProgressView* progressView;
	IBOutlet UILabel* statusCodeLabel;
	IBOutlet UITextView* outputTextView;	
}

-(IBAction)startDownload:(id)sender;   
-(IBAction)startDownload2:(id)sender;

@end
