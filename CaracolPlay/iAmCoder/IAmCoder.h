//
//  IAmCoder.h
//  
//
//  Created by Andrés Abril on 26/07/12.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
//#import "AESCrypt.h"

@interface IAmCoder : NSObject

+(NSString *)encodeURL:(NSString*)url;
+(NSString *)encodeCoordinate:(NSString*)coordinate;

+(NSString *)decodeURL:(NSString*)url;
+(NSString *)hash256:(NSString*)parameters;
+(NSString *)base64EncodeString:(NSString *)strData;
+(NSString *)base64EncodeData: (NSData *) objData;
+(NSString *)dateString;
+(NSString *)base64String:(NSString*)str;
+(NSString *)sha256:(NSString *)clear;
+(NSString *)base64DecodeString: (NSString*) strBase64 ;
+(NSString *)AESEncryptWithMessage:(NSString*)message andPassword:(NSString*)password;
+(NSString *)AESDecryptWithMessage:(NSString*)message andPassword:(NSString*)password;

//AES
+(NSData *)transform:(CCOperation) encryptOrDecrypt data:(NSData *) inputData andKey:(NSString*)key;
+(NSData *)ecb_transform:(CCOperation) encryptOrDecrypt data:(NSData *) inputData andKey:(NSString*)key;
+(NSString *)encryptAndBase64:(NSString*)message withKey:(NSString*)key;
+(NSString *)base64AndDecrypt:(NSString*)message withKey:(NSString*)key;
+(NSString *)ecb_encryptAndBase64:(NSString*)message withKey:(NSString*)key;
+(NSString *)ecb_base64AndDecrypt:(NSString*)message withKey:(NSString*)key;
+(NSData *)md5:(NSString *) stringToHash;
+(NSData *)data_decrypt:(NSData *)data withKey:(NSString*)key;
+(NSData *)data_encrypt:(NSData *)data withKey:(NSString*)key;
+(NSString*)dateKey;
@end
