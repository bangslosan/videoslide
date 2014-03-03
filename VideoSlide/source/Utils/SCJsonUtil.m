//
//  SCJsonUtil.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCJsonUtil.h"
#import "SBJSON.h"


@implementation SCJsonUtil


/*
 *Get dictionary from json data file
 *
 */
+ (NSDictionary*)dictionaryFromJsonFileInBundle:(NSString *)filename
{
    
    NSString *textPAth = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:textPAth encoding:NSUTF8StringEncoding error:&error];  //error checking omitted
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *json = [parser objectWithString: content];
    
    return json;
}
/*
 *get the dictionary from the json file intuongthi
 */
+ (NSDictionary*)dictionaryFromJsonFileInDocument:(NSString*)fileName
{
    //get the full path of the file in document folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",fileName]];
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];  //error checking omitted
    
    //parse the json file with SBJson
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString: content];
    
    return json;
}


/*
 *Write json to file
 *@Param data : NSDictionary object detail
 *@Param file name : name of file will be write
 */
+ (void)writeDictToJsonFile:(NSDictionary *)data fileName:(NSString *)fileName
{
    NSError* error;
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    //print out the data contents
    //    NSString *jSonStr = [[NSString alloc] initWithData:jsonData ∫encoding:NSUTF8StringEncoding];
    
    //get the name of file
    NSString* name = [NSString stringWithFormat:@"%@.json",fileName];
    //locate the full path (document folder)
    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [applicationDocumentsDir stringByAppendingPathComponent:name];
    
    if(jsonData)
    {
        [jsonData writeToFile:fullPath atomically:YES];
    }
}


@end
