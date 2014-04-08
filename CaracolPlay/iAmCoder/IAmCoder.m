//
//  IAmCoder.m
//  
//
//  Created by Andrés Abril on 26/07/12.
//
//

#import "IAmCoder.h"
//#import "NSData+AES.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
//#import "NSData+CommonCrypto.h"
@implementation IAmCoder
static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+(NSString *)encodeURL:(NSString *)url{
    NSString *stringEncoded=[[[[[[[url stringByReplacingOccurrencesOfString:@"http" withString:@"HH"]stringByReplacingOccurrencesOfString:@"/" withString:@"SS"]stringByReplacingOccurrencesOfString:@"?" withString:@"II"]stringByReplacingOccurrencesOfString:@"=" withString:@"EE"]stringByReplacingOccurrencesOfString:@":" withString:@"DD"]stringByReplacingOccurrencesOfString:@" " withString:@"sS"]stringByReplacingOccurrencesOfString:@"." withString:@"pP"];
    return stringEncoded;
}
+(NSString *)decodeURL:(NSString *)url{
    NSString *stringDecoded=[[[[[[[url stringByReplacingOccurrencesOfString:@"HH" withString:@"http"]stringByReplacingOccurrencesOfString:@"SS" withString:@"/"]stringByReplacingOccurrencesOfString:@"II" withString:@"?"]stringByReplacingOccurrencesOfString:@"EE" withString:@"="]stringByReplacingOccurrencesOfString:@"DD" withString:@":"]stringByReplacingOccurrencesOfString:@"sS" withString:@" "]stringByReplacingOccurrencesOfString:@"pP" withString:@"."];
    return stringDecoded;
}
+(NSString *)encodeCoordinate:(NSString *)coordinate{
    NSString *stringEncoded=[[[coordinate stringByReplacingOccurrencesOfString:@"g" withString:@"º"] stringByReplacingOccurrencesOfString:@"m" withString:@"'"] stringByReplacingOccurrencesOfString:@"s" withString:@"\""];
    return stringEncoded;
}
+(NSString *)hash256:(NSString *)parameters{
    NSString *key = @"d4fe34231";
    NSString *parameterParsed=[parameters stringByReplacingOccurrencesOfString:@"/" withString:@"|"];
    NSLog(@"parsed %@",parameterParsed);
    NSString *data = [NSString stringWithFormat:@"%@%@%@", @"sha256", parameterParsed, key];
    //const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    //const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    /*NSString *hash = [[[[[[[[[[[self base64EncodeData:HMAC]
                    stringByReplacingOccurrencesOfString:@"+" withString:@""]
                    stringByReplacingOccurrencesOfString:@"$" withString:@""]
                    stringByReplacingOccurrencesOfString:@"=" withString:@""]
                    stringByReplacingOccurrencesOfString:@"&" withString:@""]
                    stringByReplacingOccurrencesOfString:@"?" withString:@""]
                    stringByReplacingOccurrencesOfString:@"." withString:@""]
                    stringByReplacingOccurrencesOfString:@"@" withString:@""]
                    stringByReplacingOccurrencesOfString:@"/" withString:@""]
                    stringByReplacingOccurrencesOfString:@"#" withString:@""]
                    stringByReplacingOccurrencesOfString:@"%%" withString:@""];*/
    NSString *hash =[self base64EncodeData:HMAC];
    //NSLog(@"hash %@",hash);
    return hash;
}
+ (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSUTF8StringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (NSString *) base64EncodeString: (NSString *) strData {
	return [self base64EncodeData: [strData dataUsingEncoding: NSUTF8StringEncoding] ];
}

+ (NSString *) base64EncodeData: (NSData *) objData {
	const unsigned char * objRawData = [objData bytes];
	char * objPointer;
	char * strResult;
    
	// Get the Raw Data length and ensure we actually have data
	int intLength = [objData length];
	if (intLength == 0) return nil;
    
	// Setup the String-based Result placeholder and pointer within that placeholder
	strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
	objPointer = strResult;
    
	// Iterate through everything
	while (intLength > 2) { // keep going until we have less than 24 bits
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
		*objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
		*objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
		// we just handled 3 octets (24 bits) of data
		objRawData += 3;
		intLength -= 3; 
	}
    
	// now deal with the tail end of things
	if (intLength != 0) {
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		if (intLength > 1) {
			*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
			*objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
			*objPointer++ = '=';
		} else {
			*objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
			*objPointer++ = '=';
			*objPointer++ = '=';
		}
	}
    
	// Terminate the string-based result
	*objPointer = '\0';
    
	// Return the results as an NSString object
	return [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}

+ (NSString *) base64DecodeString: (NSString *) strBase64 {
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	int intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
    
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
    
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
        
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
        
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
                
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
                
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
                
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
    
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
                
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
    
	// Cleanup and setup the return NSData
	NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
    NSString *str=[[NSString alloc]initWithBytes:[objData bytes] length:[objData length] encoding:NSASCIIStringEncoding];
	free(objResult);
	return str;
}
+(NSString*)dateString{
    //    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
    //    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //    [formatter setTimeZone:timeZone];
    //    NSDate *now = [[NSDate alloc] init];
    //    NSString *date=[formatter stringFromDate:now];
    //    NSDate *date2=[formatter dateFromString:date];
    //    NSTimeInterval seconds = [date2 timeIntervalSince1970];
    //    NSString *date3=[NSString stringWithFormat:@"%.0f",seconds];
    //    NSLog(@"segundos entre fechas %@",date3);
    //    return date3;
    
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval seconds = [now timeIntervalSince1970];
    NSString *date3=[NSString stringWithFormat:@"%.0f",seconds];
    return date3;
}
#pragma mark - AES Crypt
//+(NSString *)AESEncryptWithMessage:(NSString *)message andPassword:(NSString *)password{
//    return [AESCrypt encrypt:message password:password];
//}
//+(NSString *)AESDecryptWithMessage:(NSString *)message andPassword:(NSString *)password{
//    return [AESCrypt decrypt:message password:password];
//}
+ (NSData *) transform:(CCOperation) encryptOrDecrypt data:(NSData *) inputData andKey:(NSString*)key{
    // kCCKeySizeAES128 = 16 bytes
    // CC_MD5_DIGEST_LENGTH = 16 bytes
    NSData* secretKey = [IAmCoder md5:key];
    //NSData* secretKey = [[key dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash];
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    //uint8_t iv[kCCBlockSizeAES128];
    //memset((void *) iv, 0x0, (size_t) sizeof(iv));
    const char iv[16] = {1,1,0,1,0,1,0,0,0,1,0,1,0,1,1,1};
    NSLog(@"CHAR %s llave hash %@",iv,secretKey);
    status = CCCryptorCreate(encryptOrDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                             [secretKey bytes], kCCKeySizeAES128, iv, &cryptor);
    if (status != kCCSuccess) {
        return nil;
    }
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[inputData length], true);
    void * buf = malloc(bufsize * sizeof(uint8_t));
    memset(buf, 0x0, bufsize);
    size_t bufused = 0;
    size_t bytesTotal = 0;
    status = CCCryptorUpdate(cryptor, [inputData bytes], (size_t)[inputData length],
                             buf, bufsize, &bufused);
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    bytesTotal += bufused;
    status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    bytesTotal += bufused;
    CCCryptorRelease(cryptor);
    return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}
+ (NSData *) ecb_transform:(CCOperation) encryptOrDecrypt data:(NSData *) inputData andKey:(NSString*)key{
    // kCCKeySizeAES128 = 16 bytes
    // CC_MD5_DIGEST_LENGTH = 16 bytes
    //NSData* secretKey = [IAmCoder md5:key];
    NSData* secretKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    //NSData* secretKey = [[key dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash];
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    //uint8_t iv[kCCBlockSizeAES128];
    //memset((void *) iv, 0x0, (size_t) sizeof(iv));
    const char iv[16] = {1,1,0,1,0,1,0,0,0,1,0,1,0,1,1,1};
    NSLog(@"CHAR %s llave hash %@",iv,secretKey);
    //status = CCCryptorCreate(encryptOrDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
    //                         [secretKey bytes], kCCKeySizeAES128, iv, &cryptor);
    status = CCCryptorCreate(encryptOrDecrypt, kCCAlgorithmAES128, kCCOptionECBMode,
                             [secretKey bytes], kCCKeySizeAES128, nil, &cryptor);
    if (status != kCCSuccess) {
        return nil;
    }
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[inputData length], true);
    void * buf = malloc(bufsize * sizeof(uint8_t));
    memset(buf, 0x0, bufsize);
    size_t bufused = 0;
    size_t bytesTotal = 0;
    status = CCCryptorUpdate(cryptor, [inputData bytes], (size_t)[inputData length],
                             buf, bufsize, &bufused);
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    bytesTotal += bufused;
    status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    if (status != kCCSuccess) {
        free(buf);
        CCCryptorRelease(cryptor);
        return nil;
    }
    bytesTotal += bufused;
    CCCryptorRelease(cryptor);
    return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}
+ (NSData *) md5:(NSString *) stringToHash {
    
    const char *src = [stringToHash UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(src, strlen(src), result);
    
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    //return [stringToHash dataUsingEncoding:NSUTF8StringEncoding];
}

+(NSString*)encryptAndBase64:(NSString *)message withKey:(NSString*)key{
    NSData *encrypted = [self transform:kCCEncrypt data:[message dataUsingEncoding:NSUTF8StringEncoding] andKey:key];
    NSLog(@"Encriptado Hexa: %@",encrypted);
    return [NSString base64StringFromData:encrypted length:[encrypted length]];
}
+(NSString *)base64AndDecrypt:(NSString *)message withKey:(NSString*)key{
    NSData *decrypted = [self transform:kCCDecrypt data:[NSData base64DataFromString:message] andKey:key];
    NSLog(@"Desencriptado Hexa: %@",decrypted);
    return [[NSString alloc]initWithData:decrypted encoding:NSUTF8StringEncoding];
}
+(NSString*)ecb_encryptAndBase64:(NSString *)message withKey:(NSString*)key{
    NSData *encrypted = [self ecb_transform:kCCEncrypt data:[message dataUsingEncoding:NSUTF8StringEncoding] andKey:key];
    NSLog(@"Encriptado ECB Hexa: %@",encrypted);
    return [NSString base64StringFromData:encrypted length:[encrypted length]];
}
+(NSString *)ecb_base64AndDecrypt:(NSString *)message withKey:(NSString*)key{
    NSData *decrypted = [self ecb_transform:kCCDecrypt data:[NSData base64DataFromString:message] andKey:key];
    NSLog(@"Desencriptado ECB Hexa: %@",decrypted);
    return [[NSString alloc]initWithData:decrypted encoding:NSUTF8StringEncoding];
}
+(NSData *)data_decrypt:(NSData *)data withKey:(NSString*)key{
    return [self transform:kCCDecrypt data:data andKey:key];
}
+(NSData*)data_encrypt:(NSData *)data withKey:(NSString*)key{
    return [self transform:kCCEncrypt data:data andKey:key];
}
#pragma mark - fecha
+(NSString*)dateKey{
    NSDate * selected = [NSDate date];
    //NSString * dateString = [selected description];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];//HH:mm
    NSString *strDate = [formatter stringFromDate:selected];
    return strDate;
}
@end
