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

@synthesize response = _response;


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Constructors
/////////////////////////////////////////////////////////////////////////////

+(id)URLLoaderWithRequest:(NSURLRequest*)req
			   completion:(void (^)(OHURLLoader* loader))completionHandler
			 errorHandler:(void (^)(NSError* error))errorHandler
{
#if ! NS_BLOCKS_AVAILABLE
	return nil;
#else
	return [[[self alloc] initWithRequest:req
						 responseReceived:nil
								 progress:nil
							   completion:completionHandler
							 errorHandler:errorHandler]
			autorelease];
#endif
}

+(id)URLLoaderWithRequest:(NSURLRequest*)req
		 responseReceived:(void (^)(OHURLLoader* loader,NSURLResponse* response))responseReceivedHandler
				 progress:(void (^)(OHURLLoader* loader,NSUInteger receivedBytes, long long expectedBytes))progressHandler
			   completion:(void (^)(OHURLLoader* loader))completionHandler
			 errorHandler:(void (^)(NSError* error))errorHandler
{
#if ! NS_BLOCKS_AVAILABLE
	return nil;
#else
	return [[[self alloc] initWithRequest:req
						 responseReceived:responseReceivedHandler
								 progress:progressHandler
							   completion:completionHandler
							 errorHandler:errorHandler]
			autorelease];
#endif
}

-(id)initWithRequest:(NSURLRequest*)req
	responseReceived:(void (^)(OHURLLoader* loader,NSURLResponse* response))responseReceivedHandler
			progress:(void (^)(OHURLLoader* loader,NSUInteger receivedBytes, long long expectedBytes))progressHandler
		  completion:(void (^)(OHURLLoader* loader))completionHandler
		errorHandler:(void (^)(NSError* error))errorHandler
{
#if ! NS_BLOCKS_AVAILABLE
	return nil;
#else
	self = [super init];
	if (self != nil) {
		_responseReceivedBlock = [responseReceivedHandler copy];
		_progressBlock = [progressHandler copy];
		_completionBlock = [completionHandler copy];
		_errorBlock = [errorHandler copy];
		_response = nil;
		
		if([NSURLConnection connectionWithRequest:req delegate:self]) {
			_data = [[NSMutableData alloc] init];
			[self retain];
		} else {
			NSLog(@"OHURLLoader: Failed to create NSURLConnection object");
			if (errorHandler) {
				NSError* err = [NSError errorWithDomain:@"OHURLLoader" code:10 userInfo:
								[NSDictionary dictionaryWithObject:@"Can't create NSURLConnection object" forKey:NSLocalizedDescriptionKey]];
				errorHandler(err);
			}
		}
	}
	return self;
#endif
}

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NSURLConnection Delegate Methods
/////////////////////////////////////////////////////////////////////////////

#if NS_BLOCKS_AVAILABLE

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_data setLength:0];
	_response = [response retain];
	if (_responseReceivedBlock) {
		_responseReceivedBlock(self,response);
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
	if (_progressBlock) {
		_progressBlock(self,[self.receivedData length],[self.response expectedContentLength]);
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (_completionBlock) {
		_completionBlock(self);
	}
	[self autorelease];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (_errorBlock) {
		_errorBlock(error);
	}
	[self autorelease];
}

#endif


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
