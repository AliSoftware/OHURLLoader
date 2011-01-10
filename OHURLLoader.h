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
 ************
 *
 * Sample code 1:
 * <code>
 *	NSURL* url = ...
 *	NSURLRequest* req = [NSURLRequest requestWithURL:url];
 *
 *	OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:req];
 *	[loader startRequestWithCompletion:^(NSData* receivedData, NSInteger httpStatusCode) {
 *		NSLog(@"Download of %@ done.",url);
 *		if (httpStatusCode == 200) {
 *			outputTextView.text = loader.receivedString;
 *		} else {
 *			outputTextView.text = [NSString stringWithFormat:@"HTTP Status code: %d",httpStatusCode];
 *		}
 *	} errorHandler:^(NSError *error) {
 *		NSLog(@"Error while downloading %@: %@",url,error);
 *		outputTextView.text = [error localizedDescription];
 *	}];
 * </code>
 *
 * Sample code 2:
 * <code>
 *	NSURL* url = ...
 *	NSURLRequest* req = [NSURLRequest requestWithURL:url];
 *	
 *	OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:req];
 *	[loader startRequestWithResponseHandler:^(NSURLResponse* response) {
 *		NSLog(@"Expected ContentLength: %ld",[response expectedContentLength]);
 *		progressView.progress = 0.f;
 *	} progress:^(NSUInteger receivedBytes, long long expectedBytes) {
 *		if (expectedBytes > 0) progressView.progress = receivedBytes / (float)expectedBytes;
 *	} completion:^(NSData* receivedData, NSInteger statusCode) {
 *		progressView.progress = 1.f;
 *		NSLog(@"Download Done (%@, statusCode:%d)",url,statusCode);
 *		outputTextView.text = loader.receivedString;
 *	} errorHandler:^(NSError* error) {
 *		outputTextView.text = [error localizedDescription];
 *	}];
 * </code>
 *
 ************
 *
 * Note: for a list of possible httpStatusCode values, see the HTTP specification at
 *       http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 *
 * Note: This class can still be used before OSX 10.6 and iOS4 by replacing blocks usage
 *       with NSNotification handlers (as NSNotification are send for each corresponding block)
 *       but not using blocks obviously reduces the advantage of using this class
 * 
 * Note: Even if this would be a feature easy to add, the current version of this class
 *       does not handle "Authentication Challenges" (when URL requests credentials to be accessed).
 *       This is a design choice to keep the class API as simple as possible
 *       (as this feature is rarely used in practice)
 ***********************************************************************************/





#import <Foundation/Foundation.h>

// NSNotification names
static NSString* const OHURLLoaderResponseReceived;
static NSString* const OHURLLoaderDataReceived;
static NSString* const OHURLLoaderSuccess;
static NSString* const OHURLLoaderError;

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: URL Loader Class
/////////////////////////////////////////////////////////////////////////////

@class OHURLLoader;
@interface OHURLLoader : NSObject {
@private
#if NS_BLOCKS_AVAILABLE
	void (^_responseReceivedBlock)(NSURLResponse*);
	void (^_progressBlock)(NSUInteger,long long);
	void (^_completionBlock)(NSData*,NSInteger);
	void (^_errorBlock)(NSError*);
#endif
	NSURLRequest* _request;
	NSURLConnection* _connection;
	NSMutableData* _data;
	NSURLResponse* _response;
}

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Constructors
/////////////////////////////////////////////////////////////////////////////

+(id)URLLoaderWithRequest:(NSURLRequest*)req;
-(id)initWithRequest:(NSURLRequest*)req;

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Starting & Cancelling the request
/////////////////////////////////////////////////////////////////////////////

-(void)startRequestWithCompletion:(void (^)(NSData* receivedData,NSInteger httpStatusCode))completionHandler
					 errorHandler:(void (^)(NSError* error))errorHandler;

-(void)startRequestWithResponseHandler:(void (^)(NSURLResponse* response))responseReceivedHandler
							  progress:(void (^)(NSUInteger receivedBytes, long long expectedBytes))progressHandler
							completion:(void (^)(NSData* receivedData,NSInteger httpStatusCode))completionHandler
						  errorHandler:(void (^)(NSError* error))errorHandler;

-(void)cancelRequest;

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Properties
/////////////////////////////////////////////////////////////////////////////

@property(readonly) NSData* receivedData;
@property(readonly) NSURLResponse* response;

// Commodity accesors to "response" values :
@property(readonly) NSInteger httpStatusCode;
@property(readonly) NSString* receivedString; // NSString built using receivedData and response.textEncodingName
@end
