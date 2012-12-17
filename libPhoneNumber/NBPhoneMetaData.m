//
//  NBPhoneMetaData.m
//  libPhoneNumber
//
//  Created by ishtar on 12. 12. 11..
//  Copyright (c) 2012년 NHN. All rights reserved.
//

#import "NBPhoneMetaData.h"
#import "NBPhoneNumberDesc.h"
#import "NBNumberFormat.h"


@interface NBPhoneMetaData ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *numberDescriptions;

@end


@implementation NBPhoneMetaData

@synthesize name, fullName;
@synthesize codeID, countryCode;
@synthesize preferredInternationalPrefix, internationalPrefix, leadingDigits;
@synthesize nationalPrefix, nationalPrefixForParsing, nationalPrefixTransformRule;
@synthesize preferredExtnPrefix, nationalPrefixFormattingRule, carrierCodeFormattingRule;
@synthesize mainCountryForCode, nationalPrefixOptionalWhenFormatting, leadingZeroPossible;
@synthesize numberFormats;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setNumberFormats:[[NSMutableArray alloc] init]];
        [self setNumberDescriptions:[[NSMutableDictionary alloc] init]];
        
        [self setName:@"PhoneMetadata"];
        [self setFullName:@"i18n.phonenumbers.PhoneMetadata"];
    }
    
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"---------------------------------------------------------------------------------------------------\n[%@ (%@)\n--- %@ (%@) leadingDigits[%@], pEP:(%@), iP(%@), nP(%@), nPFP(%@), nPTR(%@), nPFR(%@), cCFR(%@)]\n--- mCFC[%@], nPOWF[%@], lZP[%@]\n--- AavailableFormats:%@\n--- NnumberDescriptions:%@",
            self.name, self.fullName, self.codeID, self.countryCode, self.leadingDigits, self.preferredExtnPrefix, self.internationalPrefix,
            self.nationalPrefix, self.nationalPrefixForParsing, self.nationalPrefixTransformRule,
            self.nationalPrefixFormattingRule, self.carrierCodeFormattingRule,
            [self.mainCountryForCode boolValue]?@"Y":@"N",
            [self.nationalPrefixOptionalWhenFormatting boolValue]?@"Y":@"N",
            [self.leadingZeroPossible boolValue]?@"Y":@"N", self.numberFormats, self.numberDescriptions];
}


- (void)setAttributes:(NSDictionary*)data
{
    NSString *attributeName = [data valueForKey:@"attributeName"];
    id attributeContent = [data valueForKey:@"nodeContent"];
    
    if (attributeName && [attributeName isKindOfClass:[NSString class]] && [attributeName length]  > 0 && [attributeName isEqualToString:@"id"] &&
        attributeContent && [attributeContent isKindOfClass:[NSString class]] && [attributeContent length] > 0)
    {
        [self setCodeID:attributeContent];
    }
    else if (attributeName && [attributeName isKindOfClass:[NSString class]] && [attributeName length]  > 0 && attributeContent && [attributeContent isKindOfClass:[NSString class]] && [attributeContent length] > 0)
    {
        @try {
            if ([[attributeContent lowercaseString] isEqualToString:@"true"])
            {
                [self setValue:[NSNumber numberWithBool:YES] forKey:attributeName];
            }
            else if ([[attributeContent lowercaseString] isEqualToString:@"false"])
            {
                [self setValue:[NSNumber numberWithBool:NO] forKey:attributeName];
            }
            else
            {
                [self setValue:attributeContent forKey:attributeName];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"setAttributes setValue:%@ forKey:%@ error [%@]", attributeContent, attributeName, [attributeContent class]);
        }
    }
}


- (BOOL)setChilds:(id)data
{
    if (data && [data isKindOfClass:[NSDictionary class]])
    {
        NSString *nodeName = [data valueForKey:@"nodeName"];
        id nodeContent = [data valueForKey:@"nodeContent"];
        // [TYPE] PhoneNumberDesc
        if ([nodeName isEqualToString:@"generalDesc"] || [nodeName isEqualToString:@"fixedLine"] || [nodeName isEqualToString:@"mobile"] || [nodeName isEqualToString:@"shortCode"] || [nodeName isEqualToString:@"emergency"] || [nodeName isEqualToString:@"voip"] || [nodeName isEqualToString:@"voicemail"] || [nodeName isEqualToString:@"uan"] || [nodeName isEqualToString:@"premiumRate"] || [nodeName isEqualToString:@"nationalNumberPattern"] || [nodeName isEqualToString:@"sharedCost"] || [nodeName isEqualToString:@"tollFree"] || [nodeName isEqualToString:@"noInternationalDialling"] || [nodeName isEqualToString:@"personalNumber"] || [nodeName isEqualToString:@"pager"] || [nodeName isEqualToString:@"areaCodeOptional"])
        {
            [self setNumberDesc:data];
            return YES;
        }
        else if ([nodeName isEqualToString:@"availableFormats"])
        {
            [self setNumberFormats:data];
            return YES;
        }
        else if ([nodeName isEqualToString:@"comment"] == NO && [nodeContent isKindOfClass:[NSString class]])
        {
            [self setValue:nodeContent forKey:nodeName];
            return YES;
        }
        else if ([nodeName isEqualToString:@"comment"])
        {
            return YES;
        }
    }
    
    return NO;
}


- (NSString*)stringByTrimming:(NSString*)aString
{
    NSString *aRes = [aString stringByReplacingOccurrencesOfString:@" " withString:@""];
    aRes = [aRes stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    aRes = [aRes stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    aRes = [aRes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return aRes;
}


- (void)setNumberFormats:(id)data
{
    NSArray *nodeChildArray = [data valueForKey:@"nodeChildArray"];
    
    for (id childNumberFormat in nodeChildArray)
    {
        NSArray *nodeChildAttributeNumberFormatArray = [childNumberFormat valueForKey:@"nodeAttributeArray"];
        NSArray *nodeChildNodeNumberFormatArray = [childNumberFormat valueForKey:@"nodeChildArray"];
        
        NSString *nodeName = [childNumberFormat valueForKey:@"nodeName"];
        
        if ([nodeName isEqualToString:@"numberFormat"])
        {
            NBNumberFormat *newNumberFormat = [[NBNumberFormat alloc] init];
            
            for (id childAttribute in nodeChildAttributeNumberFormatArray)
            {
                NSString *childNodeName = [childAttribute valueForKey:@"attributeName"];
                NSString *childNodeContent = nil;
                
                if ([childNodeName isEqualToString:@"comment"])
                {
                    continue;
                }
                
                if ([childNodeName isEqualToString:@"format"] == NO)
                {
                    childNodeContent = [self stringByTrimming:[childAttribute valueForKey:@"nodeContent"]];
                }
                else
                {
                    childNodeContent = [childAttribute valueForKey:@"nodeContent"];
                }
                
                @try {
                    [newNumberFormat setValue:childNodeContent forKey:childNodeName];
                }
                @catch (NSException *ex) {
                    NSLog(@"nodeChildAttributeArray setValue:%@ forKey:%@ error [%@] %@", childNodeContent, childNodeName, [childNodeContent class], childAttribute);
                }
            }
            
            for (id childNode in nodeChildNodeNumberFormatArray)
            {
                NSString *childNodeName = [childNode valueForKey:@"nodeName"];
                NSString *childNodeContent = nil;
                
                if ([childNodeName isEqualToString:@"comment"])
                {
                    continue;
                }
                
                if ([childNodeName isEqualToString:@"format"] == NO)
                {
                    childNodeContent = [self stringByTrimming:[childNode valueForKey:@"nodeContent"]];
                }
                else
                {
                    childNodeContent = [childNode valueForKey:@"nodeContent"];
                }
                
                @try {
                    if ([childNodeName isEqualToString:@"leadingDigits"])
                    {
                        [newNumberFormat.leadingDigitsPattern addObject:[childNodeContent copy]];
                    }
                    else
                    {
                        if ([[childNodeContent lowercaseString] isEqualToString:@"true"])
                        {
                            [newNumberFormat setValue:[NSNumber numberWithBool:YES] forKey:childNodeName];
                        }
                        else if ([[childNodeContent lowercaseString] isEqualToString:@"false"])
                        {
                            [newNumberFormat setValue:[NSNumber numberWithBool:NO] forKey:childNodeName];
                        }
                        else
                        {
                            [newNumberFormat setValue:childNodeContent forKey:childNodeName];
                        }
                    }
                }
                @catch (NSException *ex) {
                    NSLog(@"nodeChildArray setValue:%@ forKey:%@ error [%@] %@", childNodeContent, childNodeName, [childNodeContent class], childNode);
                }
            }
            [self.numberFormats addObject:newNumberFormat];
        }
        else if ([nodeName isEqualToString:@"comment"] == NO)
        {
            NSLog(@"process ========== %@", childNumberFormat);
        }
    }
}


- (void)setNumberDesc:(id)data
{
    NSString *nodeName = [data valueForKey:@"nodeName"];
    NSArray *nodeChildArray = [data valueForKey:@"nodeChildArray"];
    
    NBPhoneNumberDesc *newNumberDesc = [[NBPhoneNumberDesc alloc] init];
    
    for (id childNode in nodeChildArray)
    {
        NSString *childNodeName = [childNode valueForKey:@"nodeName"];
        NSString *childNodeContent = [self stringByTrimming:[childNode valueForKey:@"nodeContent"]];
        
        if ([childNodeName isEqualToString:@"comment"])
        {
            continue;
        }
        
        @try {
            [newNumberDesc setValue:childNodeContent forKey:childNodeName];
        }
        @catch (NSException *ex) {
            NSLog(@"setNumberDesc setValue:%@ forKey:%@ error [%@]", childNodeContent, childNodeName, [childNodeContent class]);
        }
    }
    
    [self.numberDescriptions setObject:newNumberDesc forKey:nodeName];
}


@end


/*
 goog.proto2.Message.set$Metadata(i18n.phonenumbers.NumberFormat, {
 0: {
 name: 'NumberFormat',
 fullName: 'i18n.phonenumbers.NumberFormat'
 },
 1: {
 name: 'pattern',
 required: true,
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 2: {
 name: 'format',
 required: true,
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 3: {
 name: 'leading_digits_pattern',
 repeated: true,
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 4: {
 name: 'national_prefix_formatting_rule',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 6: {
 name: 'national_prefix_optional_when_formatting',
 fieldType: goog.proto2.Message.FieldType.BOOL,
 type: Boolean
 },
 5: {
 name: 'domestic_carrier_code_formatting_rule',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 }
 });
 
 
 goog.proto2.Message.set$Metadata(i18n.phonenumbers.PhoneNumberDesc, {
 0: {
 name: 'PhoneNumberDesc',
 fullName: 'i18n.phonenumbers.PhoneNumberDesc'
 },
 2: {
 name: 'national_number_pattern',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 3: {
 name: 'possible_number_pattern',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 6: {
 name: 'example_number',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 }
 });
 
 
 goog.proto2.Message.set$Metadata(i18n.phonenumbers.PhoneMetadata, {
 0: {
 name: 'PhoneMetadata',
 fullName: 'i18n.phonenumbers.PhoneMetadata'
 },
 1: {
 name: 'general_desc',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 2: {
 name: 'fixed_line',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 3: {
 name: 'mobile',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 4: {
 name: 'toll_free',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 5: {
 name: 'premium_rate',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 6: {
 name: 'shared_cost',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 7: {
 name: 'personal_number',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 8: {
 name: 'voip',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 21: {
 name: 'pager',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 25: {
 name: 'uan',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 27: {
 name: 'emergency',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 28: {
 name: 'voicemail',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 24: {
 name: 'no_international_dialling',
 required: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneNumberDesc
 },
 9: {
 name: 'id',
 required: true,
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 10: {
 name: 'country_code',
 required: true,
 fieldType: goog.proto2.Message.FieldType.INT32,
 type: Number
 },
 11: {
 name: 'international_prefix',
 required: true,
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 17: {
 name: 'preferred_international_prefix',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 12: {
 name: 'national_prefix',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 13: {
 name: 'preferred_extn_prefix',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 15: {
 name: 'national_prefix_for_parsing',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 16: {
 name: 'national_prefix_transform_rule',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 18: {
 name: 'same_mobile_and_fixed_line_pattern',
 fieldType: goog.proto2.Message.FieldType.BOOL,
 defaultValue: false,
 type: Boolean
 },
 19: {
 name: 'number_format',
 repeated: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.NumberFormat
 },
 20: {
 name: 'intl_number_format',
 repeated: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.NumberFormat
 },
 22: {
 name: 'main_country_for_code',
 fieldType: goog.proto2.Message.FieldType.BOOL,
 defaultValue: false,
 type: Boolean
 },
 23: {
 name: 'leading_digits',
 fieldType: goog.proto2.Message.FieldType.STRING,
 type: String
 },
 26: {
 name: 'leading_zero_possible',
 fieldType: goog.proto2.Message.FieldType.BOOL,
 defaultValue: false,
 type: Boolean
 }
 });
 
 
 goog.proto2.Message.set$Metadata(i18n.phonenumbers.PhoneMetadataCollection, {
 0: {
 name: 'PhoneMetadataCollection',
 fullName: 'i18n.phonenumbers.PhoneMetadataCollection'
 },
 1: {
 name: 'metadata',
 repeated: true,
 fieldType: goog.proto2.Message.FieldType.MESSAGE,
 type: i18n.phonenumbers.PhoneMetadata
 }
 });
 */