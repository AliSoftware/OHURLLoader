//
//  OHURLLoaderAppDelegate.m
//  OHURLLoader
//
//  Created by Olivier on 09/01/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "OHURLLoaderAppDelegate.h"
#import "OHURLLoader.h"

@implementation OHURLLoaderAppDelegate

NSString* NSStringFromBytes(long long bytes) {
	// Format a count of bytes as a readable string
	if (bytes == NSURLResponseUnknownLength) return @"??";
	if (bytes > 1024*1024) return [NSString stringWithFormat:@"%ld Mb",(bytes/(1024*1024))];
	if (bytes > 1024) return [NSString stringWithFormat:@"%ld Kb",(bytes/1024)];
	return [NSString stringWithFormat:@"%ld bytes",bytes];
}

/////////////////////////////////////////////////////////////////////////////

-(IBAction)startDownload:(id)sender {
	[urlField resignFirstResponder];
	NSURL* url = [NSURL URLWithString:urlField.text];
	NSURLRequest* req = [NSURLRequest requestWithURL:url];
	
	statusCodeLabel.text = @"-";
	outputTextView.text = @"";

	[OHURLLoader URLLoaderWithRequest:req responseReceived:^(OHURLLoader* loader, NSURLResponse* response) {
		
		// Response received, data is comming
		
		NSLog(@"[Example 1] Response received.");
		NSLog(@"[Example 1] -- Expected Content Length: %@",NSStringFromBytes([response expectedContentLength]));
		NSLog(@"[Example 1] -- Received MimeType: %@",[loader.response MIMEType]);
		NSLog(@"[Example 1] -- Encoding Name: %@",[loader.response textEncodingName]);

		progressView.progress = 0.f;
		
	} progress:^(OHURLLoader* loader, NSUInteger receivedBytes, long long expectedBytes) {
		
		// Receiving some data. Can be called multiple times (each time a chunk of data arrives)
		
		long long expectedTotal = [loader.response expectedContentLength];
		if (expectedTotal > 0) {
			// Compute percentage
			float p = receivedBytes / (float)expectedTotal;
			NSLog(@"[Example 1] Progress: %@ / %@ (%.1f%%)",NSStringFromBytes(receivedBytes),NSStringFromBytes(expectedTotal),100*p);
			progressView.progress = p;
		} else {
			NSLog(@"[Example 1] Progress: %@ received",NSStringFromBytes(receivedBytes));
		}
		outputTextView.text = loader.receivedString;
		
	} completion:^(OHURLLoader* loader) {
		
		// All the data has arrived, we are done here
		
		progressView.progress = 1.f;
		NSLog(@"[Example 1] Download Done (%@, statusCode:%d)",url,loader.httpStatusCode);
		statusCodeLabel.text = [NSString stringWithFormat:@"%d" , loader.httpStatusCode];
		outputTextView.text = loader.receivedString;
		
	} errorHandler:^(NSError* error) {
		
		// A problem occurred during the download
		
		NSLog(@"[Example 1] Error while performing request to url %@ : %@",url,error);
		outputTextView.text = [NSString stringWithFormat:@"[ERROR] %@",[error localizedDescription]];
		
	}];
}

/////////////////////////////////////////////////////////////////////////////

-(IBAction)startDownload2:(id)sender {
	NSURL* url = [NSURL URLWithString:urlField.text];
	NSURLRequest* req = [NSURLRequest requestWithURL:url];
	
	progressView.progress = 0.f;
	statusCodeLabel.text = @"-";
	outputTextView.text = @"Loading…";
	NSLog(@"[Example 2] Starting request for %@…",url);

	[OHURLLoader URLLoaderWithRequest:req completion:^(OHURLLoader *loader) {
		NSLog(@"[Example 2] Download done.");
		progressView.progress = 1.f;
		statusCodeLabel.text = [NSString stringWithFormat:@"%d" , loader.httpStatusCode];
		outputTextView.text = loader.receivedString;
	} errorHandler:^(NSError *error) {
		NSLog(@"[Example 2] Download error! %@",error);
		statusCodeLabel.text = @"/!\\";
		outputTextView.text = [NSString stringWithFormat:@"[ERROR] %@",[error localizedDescription]];
	}];
}

/////////////////////////////////////////////////////////////////////////////

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self startDownload:nil];
	return NO;
}

@end
