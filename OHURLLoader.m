//
//  OHURLLoader.m
//  OHURLLoader
//
//  Created by Olivier on 09/01/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "OHURLLoader.h"


@implementation OHURLLoader

#if ! NS_BLOCKS_AVAILABLE
#warning Blocks are only available starting OSX 10.6+ and iOS4.0+
#endif

// NSNotification names
static NSString* const OHURLLoaderResponseReceived = @"OHURLLoaderResponseReceived";
static NSString* const OHURLLoaderDataReceived = @"OHURLLoaderDataReceived";
static NSString* const OHURLLoaderSuccess = @"OHURLLoaderSuccess";
static NSString* const OHURLLoaderError = @"OHURLLoaderError";

@synthesize response = _response;


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Constructors
/////////////////////////////////////////////////////////////////////////////

+(id)URLLoaderWithRequest:(NSURLRequest*)req
{
	return [[[self alloc] initWithRequest:req] autorelease];
}

-(id)initWithRequest:(NSURLRequest*)req
{
	self = [super init];
	if (self != nil) {
		_request = [req retain];
	}
	return self;
}



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Sending & Cancelling the request
/////////////////////////////////////////////////////////////////////////////

-(void)startRequestWithCompletion:(void (^)(NSData* receivedData,NSInteger httpStatusCode))completionHandler
					 errorHandler:(void (^)(NSError* error))errorHandler
{
	[self startRequestWithResponseHandler:nil
								 progress:nil
							   completion:completionHandler
							 errorHandler:errorHandler];
}

-(void)startRequestWithResponseHandler:(void (^)(NSURLResponse* response))responseReceivedHandler
							  progress:(void (^)(NSUInteger receivedBytes, long long expectedBytes))progressHandler
							completion:(void (^)(NSData* receivedData,NSInteger httpStatusCode))completionHandler
						  errorHandler:(void (^)(NSError* error))errorHandler
{
	[_connection cancel]; // Cancel previous connection

#if NS_BLOCKS_AVAILABLE
	[_responseReceivedBlock release];
	_responseReceivedBlock = [responseReceivedHandler copy];
	[_progressBlock release];
	_progressBlock = [progressHandler copy];
	[_completionBlock release];
	_completionBlock = [completionHandler copy];
	[_errorBlock release];
	_errorBlock = [errorHandler copy];
#endif
	[_response release];
	_response = nil;
	[_data release];
	_data = [[NSMutableData alloc] init];

	[_connection release];
	_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
}

-(void)cancelRequest {
	[_connection cancel];
}

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NSURLConnection Delegate Methods
/////////////////////////////////////////////////////////////////////////////


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_data setLength:0];
	_response = [response retain];
#if NS_BLOCKS_AVAILABLE
	if (_responseReceivedBlock) {
		_responseReceivedBlock(response);
	}
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:OHURLLoaderResponseReceived object:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
#if NS_BLOCKS_AVAILABLE
	if (_progressBlock) {
		_progressBlock([self.receivedData length],[self.response expectedContentLength]);
	}
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:OHURLLoaderDataReceived object:self];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if NS_BLOCKS_AVAILABLE
	if (_completionBlock) {
		_completionBlock(self.receivedData,self.httpStatusCode);
	}
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:OHURLLoaderSuccess object:self];
	[_connection release];
	_connection = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if NS_BLOCKS_AVAILABLE
	if (_errorBlock) {
		_errorBlock(error);
	}
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:OHURLLoaderError object:self
													  userInfo:[NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey]];
	[_connection release];
	_connection = nil;
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Accessors
/////////////////////////////////////////////////////////////////////////////

-(NSData*)receivedData {
	return (NSData*)_data;
}

-(NSInteger)httpStatusCode {
	if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
		return ((NSHTTPURLResponse*)_response).statusCode;
	} else {
		return 0;
	}
}

-(NSString*)receivedString {
	NSStringEncoding enc = NSISOLatin1StringEncoding; // Default fallback
	
	NSString* textEncodingName = _response.textEncodingName;
	if (textEncodingName) {
		CFStringEncoding cfEnc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName);
		enc = CFStringConvertEncodingToNSStringEncoding(cfEnc);
	}
	return [[[NSString alloc] initWithData:self.receivedData encoding:enc] autorelease];
}

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Dealloc
/////////////////////////////////////////////////////////////////////////////

-(void)dealloc {
	[_request release];
	[_connection cancel];
	[_connection release];
	[_data release];
	[_response release];
#if NS_BLOCKS_AVAILABLE
	[_responseReceivedBlock release];
	[_progressBlock release];
	[_completionBlock release];
	[_errorBlock release];
#endif
	[super dealloc];
}

@end
