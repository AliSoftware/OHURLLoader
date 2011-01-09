/***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Created by Olivier Halligon  (AliSoftware) on Jan. 2011.
 * Any comment or suggestion welcome. Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/

/***********************************************************************************
 *
 *   This class make it easier to perform URL requests by using blocks
 * (A new feature/syntax introduced with GCD in OSX 10.6 and iOS4)
 *
 *   To use it, you simply have to use one of the three constructor methods,
 * providing the NSURLRequest to perform and the blocks of code to execute
 * on success and on error.
 *
 *   If you want to, you can also provide blocks of code to execute when receiving
 * each chunk of data, to be notified of the progress of the download. This can
 * be useful for long downloads, for example to update a progressbar on the screen.
 *   If needed, you may also provide a block of code to execute when the response
 * header is received, at which stage you are able to known the expectedContentLength
 * or the MimeType of the response (and some other headers).
 *
 * Sample code 1:
 * <code>
 *	NSURL* url = ...
 *	NSURLRequest* req = [NSURLRequest requestWithURL:url];
 *
 *	[OHURLLoader URLLoaderWithRequest:req completion:^(OHURLLoader *loader) {
 *		outputTextView.text = loader.receivedString; // OK
 *	} errorHandler:^(NSError *error) {
 *		outputTextView.text = [error localizedDescription]; // Error
 *	}];
 * </code>
 *
 * Sample code 2:
 * <code>
 *	NSURL* url = ...
 *	NSURLRequest* req = [NSURLRequest requestWithURL:url];
 *	
 *	[OHURLLoader URLLoaderWithRequest:req responseReceived:^(OHURLLoader* loader, NSURLResponse* response) {
 *		NSLog(@"Expected ContentLength: %ld",[response expectedContentLength]);
 *		progressView.progress = 0.f;
 *	} progress:^(OHURLLoader* loader, NSUInteger receivedBytesCount) {
 *		long long expectedTotal = [loader.response expectedContentLength]; // warning: may be NSURLResponseUnknownLength
 *		if (expectedTotal > 0) progressView.progress = receivedBytesCount / (float)expectedTotal;
 *	} completion:^(OHURLLoader* loader) {
 *		progressView.progress = 1.f;
 *		NSLog(@"Download Done (%@, statusCode:%d)",url,loader.httpStatusCode);
 *		outputTextView.text = loader.receivedString;
 *	} errorHandler:^(NSError* error) {
 *		outputTextView.text = [error localizedDescription];
 *	}];
 * </code>
 *
 ***********************************************************************************/


#import <Foundation/Foundation.h>


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: OH URL Loader Class
/////////////////////////////////////////////////////////////////////////////

@class OHURLLoader;
@interface OHURLLoader : NSObject {
@private
#if NS_BLOCKS_AVAILABLE
	void (^_responseReceivedBlock)(OHURLLoader*,NSURLResponse*);
	void (^_progressBlock)(OHURLLoader*,NSUInteger);
	void (^_completionBlock)(OHURLLoader*);
	void (^_errorBlock)(NSError*);
#endif
	NSMutableData* _data;
	NSURLResponse* _response;
}

/////////////////////////////////////////////////////////////////////////////

+(id)URLLoaderWithRequest:(NSURLRequest*)req
			   completion:(void (^)(OHURLLoader* loader))completionHandler
			 errorHandler:(void (^)(NSError* error))errorHandler;

+(id)URLLoaderWithRequest:(NSURLRequest*)req
		 responseReceived:(void (^)(OHURLLoader* loader,NSURLResponse* response))responseReceivedHandler
				 progress:(void (^)(OHURLLoader* loader,NSUInteger receivedBytesCount))progressHandler
			   completion:(void (^)(OHURLLoader* loader))completionHandler
			 errorHandler:(void (^)(NSError* error))errorHandler;

-(id)initWithRequest:(NSURLRequest*)req
	responseReceived:(void (^)(OHURLLoader* loader,NSURLResponse* response))responseReceivedHandler
			progress:(void (^)(OHURLLoader* loader,NSUInteger receivedBytesCount))progressHandler
		  completion:(void (^)(OHURLLoader* loader))completion
		errorHandler:(void (^)(NSError* error))errorHandler;

/////////////////////////////////////////////////////////////////////////////

@property(readonly) NSData* receivedData;
@property(readonly) NSURLResponse* response;

// Commodity accesors to "response" values :
@property(readonly) NSInteger httpStatusCode;
@property(readonly) NSString* receivedString; // NSString built using receivedData and response.textEncodingName
@end
