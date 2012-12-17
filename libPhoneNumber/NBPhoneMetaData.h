//
//  M2PhoneMetaData.h
//  libPhoneNumber
//
//  Created by ishtar on 12. 12. 11..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NBPhoneNumberDesc, NBNumberFormat;

@interface NBPhoneMetaData : NSObject

@property (nonatomic, strong, readwrite) NSString *name, *fullName;
@property (nonatomic, strong, readwrite) NSString *carrierCodeFormattingRule;
@property (nonatomic, strong, readwrite) NSNumber *nationalPrefixOptionalWhenFormatting;

- (void)setAttributes:(NSDictionary*)data;
- (BOOL)setChilds:(id)data;

// from phonemetadata.pb.js
@property (nonatomic, strong, readwrite) NBPhoneNumberDesc *generalDesc, *fixedLine, *mobile, *tollFree, *premiumRate, *sharedCost, *personalNumber, *voip, *pager, *uan, *emergency, *voicemail, *noInternationalDialling ;
@property (nonatomic, strong, readwrite) NSString *codeID, *countryCode;
@property (nonatomic, strong, readwrite) NSString *preferredInternationalPrefix, *internationalPrefix, *leadingDigits;
@property (nonatomic, strong, readwrite) NSString *nationalPrefix, *preferredExtnPrefix, *nationalPrefixForParsing, *nationalPrefixTransformRule, *nationalPrefixFormattingRule;
@property (nonatomic, strong, readwrite) NSNumber *sameMobileAndFixedLinePattern, *mainCountryForCode, *leadingZeroPossible;
@property (nonatomic, strong, readwrite) NSMutableArray *numberFormats;
//@property (nonatomic, strong, readwrite) NSMutableArray *intlNumberFormats;

@end
