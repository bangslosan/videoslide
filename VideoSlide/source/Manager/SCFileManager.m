//
//  SCFileManager.m
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCFileManager.h"

static SCFileManager *instance;

@implementation SCFileManager

@synthesize projects    = _projects;
@synthesize projectRootDir = _projectRootDir;
@synthesize slideShows = _slideShows;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.assetLibrary = [[ALAssetsLibrary alloc] init];

        self.projectRootDir = [SCFileManager URLFromLibraryWithName:SC_DIR_PROJECT];
        if(![SCFileManager exist:self.projectRootDir])
        {
            self.projectRootDir = [SCFileManager createFolderFromLibraryWithName:SC_DIR_PROJECT];
        }
        [self updateProjects];
        [self updateSlideShows];
        
    }
    
    
    return self;
}

+ (SCFileManager*)getInstance
{
    @synchronized([SCFileManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    return nil;
}


- (BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL
{
    return YES;
}


#pragma mark  - instance methods

- (void)updateProjects
{
    _projects = [SCFileManager subDirectoriesFromDir:self.projectRootDir];
}

- (void)updateSlideShows
{
    [self updateProjects];
    if(self.slideShows.count > 0)
    {
        [self.slideShows removeAllObjects];
    }
    self.slideShows = nil;
    _slideShows = [[NSMutableArray alloc] init];
    for(int i = 0; i< self.projects.count; i++)
    {
        NSURL *projectURL = [self.projects objectAtIndex:i];
        //get project plist file
        NSURL *item = [SCFileManager urlFromDir:projectURL withName:SC_PROJECT_NAME];
        NSDictionary *itemDict = [[NSDictionary alloc] initWithContentsOfURL:item];
        SCSlideShowModel *slideShowModel = [[SCSlideShowModel alloc] initWithDictionary:itemDict];
        [self.slideShows addObject:slideShowModel];
    }
}

#pragma mark - static methods

+ (BOOL)exist:(NSURL*)URL
{
    if([[NSFileManager defaultManager] fileExistsAtPath:URL.path])
        return YES;
    
    return NO;
}
#pragma mark - delete

+ (BOOL)deleteFileWithURL:(NSURL*)url
{
    NSError *error = [[NSError alloc]init];
    if([[NSFileManager defaultManager] fileExistsAtPath:url.path])
    {
        return [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    }
    return NO;
}
/************************************
 *
 *Delete file in document Dir
 *
 *
 *************************************/
+ (void)deleteFileFromDocumentWithName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([filename isEqualToString:name]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}
+ (void)deleteAllFileFromDocument
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
    }

}

+ (void)deleteAllfileFromDocumentWithExtension:(NSString*)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    

}

/************************************
 *
 *Delete file in Temp Dir
 *
 *
 *************************************/
+ (void)deleteFileFromTempWithName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        
        if ([filename isEqualToString:name]) {
            
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename] error:NULL];
        }
    }

}

+ (void)deleteAllFileFromTemp
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
                    
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename] error:NULL];
    }
}

+ (void)deleteAllfileFromTempWithExtension:(NSString*)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}


/*
 *Delete file from library
 *
 *
 */
+ (void)deleteFileFromLibraryWithName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDir = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:libraryDir error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        
        if ([filename isEqualToString:name]) {
            
            [fileManager removeItemAtPath:[libraryDir stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

+ (void)deleteFileFromDir:(NSURL*)file
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:file.path])
    {
        [fileManager removeItemAtPath:file.path error:NULL];

    }
}

/**
 *
 *Delete all files from dir
 *
 */

+ (void)deleteAllFileFromDir:(NSURL *)dir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:dir.path error:nil];
    
    NSEnumerator *e = [files objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        [fileManager removeItemAtPath:[dir.path stringByAppendingPathComponent:filename] error:nil];
    }
}

+ (void)deleteAllFileFromDir:(NSURL*)dir withExtension:(NSString*)extension
{
    if([SCFileManager exist:dir])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:dir.path error:nil];
        
        NSEnumerator *e = [files objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject]))
        {
            if([[filename pathExtension] isEqualToString:extension])
                [fileManager removeItemAtPath:[dir.path stringByAppendingPathComponent:filename] error:nil];
        }
    }
}

#pragma mark - create URL

+ (NSURL*)createURLFromDocumentWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@", documentsDirectory,name];
    
    return [NSURL fileURLWithPath:outputPath];
}

+ (NSURL *)createURLFromTempWithName:(NSString *)name
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *filePath = [tmpDirectory stringByAppendingPathComponent:name];
    
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - get URL

+ (NSURL*)URLFromDocumentWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
    
    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
    
    return outputURL;
}

+ (NSURL*)URLFromBundleWithName:(NSString*)name
{
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:[name stringByDeletingPathExtension]
                      ofType:name.pathExtension];
    
    // Create a new URL which points to the MIDI file
    NSURL * outputURL = [NSURL fileURLWithPath:path];
    return outputURL;
}

+ (NSURL*)URLFromTempWithName:(NSString*)name
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *filePath = [tmpDirectory stringByAppendingPathComponent:name];
    
    return [NSURL fileURLWithPath:filePath];
}

+ (NSURL*)URLFromLibraryWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *filePath = [libraryDirectory stringByAppendingPathComponent:name];
    
    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
    
    return outputURL;
}



+ (NSArray*)URLPathsFromBundleWithExtension:(NSString*)extension
{
    NSMutableArray *result= [[NSMutableArray alloc]init];
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:bundleRoot];
    NSString *filename;
    
    while ((filename = [direnum nextObject] ))
    {
        if ([filename.pathExtension isEqualToString:extension])
        {
            [result addObject:filename];
        }
    }

    return result;
}

+ (NSURL *)createIncreaseNameFromTempWith:(NSString *)name andtype:(NSString *)type
{
    NSString *filePath = nil;
	NSUInteger count = 0;
	do {
		filePath = NSTemporaryDirectory();
		NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%i", count] : @"-0";
		filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.%@",name, numberString,type]];
		count++;
	} while([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	return [NSURL fileURLWithPath:filePath];

}

#pragma mark -  folder
+ (NSURL*)createFolderFromTempWithName:(NSString*)name
{
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *filePath = [tmpDirectory stringByAppendingPathComponent:name];
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:Nil error:&error];
    
    return [NSURL fileURLWithPath:filePath];
}

+ (NSURL*)createFolderFromDocumentWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:Nil error:&error];
    
    return [NSURL fileURLWithPath:filePath];
}

+ (NSURL*)createFolderFromLibraryWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *filePath = [libraryDirectory stringByAppendingPathComponent:name];
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:Nil error:&error];
    
    return [NSURL fileURLWithPath:filePath];
}

+ (NSURL*)createFolderFromDir:(NSURL*)dir WithName:(NSString*)name
{
    NSError *error;
    NSString *filePath = [dir.path stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:Nil error:&error];
    
    return [NSURL fileURLWithPath:filePath];
}


+ (NSURL*)urlFromDir:(NSURL*)dir withName:(NSString*)name
{
    if(name && dir)
    {   NSString *filePath = [dir.path stringByAppendingPathComponent:name];
        return [NSURL fileURLWithPath:filePath];
    }
    if(name)
        return dir;
    
    return nil;
}

+ (NSURL *)createIncreaseNameFromDir:(NSURL *)dir withName:(NSString*)name andtype:(NSString *)type
{
    NSString *filePath = nil;
	NSUInteger count = 0;
	do {
        filePath = dir.path;
		NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%i", count] : @"-0";
		filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.%@",name, numberString,type]];
		count++;
	} while([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	return [NSURL fileURLWithPath:filePath];

}

+ (NSArray*)URLSFromDir:(NSURL*)url
{
    NSError *error;
    return [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
}

+ (NSArray *)subDirectoriesFromDir:(NSURL *)dir
{
    NSURL *directoryURL = dir;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *keys = [NSArray arrayWithObjects:
                     NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, nil];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                  NSDirectoryEnumerationSkipsHiddenFiles)
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator)
    {
        
        // Error-checking is omitted for clarity.
        
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue])
        {
            
            NSString *localizedName = nil;
            [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
            
            NSNumber *isPackage = nil;
            [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
            
            if ([isPackage boolValue])
            {
                NSLog(@"Package at %@", localizedName);
            }
            else {
                NSLog(@"Directory at %@", localizedName);
                [result addObject:url];
            }
            
        }
    }
    
    return result;
}

#pragma mark - read/write/copy

+ (NSURL*)writeImageIntoDir:(NSURL*)dir image:(UIImage*)image imageName:(NSString*)imageName
{
    if(image && imageName)
    {
        NSString * basePath = dir.path;
        NSData * binaryImageData = UIImagePNGRepresentation(image);
        NSString *filePath = [basePath stringByAppendingPathComponent:imageName];
        if([SCFileManager exist:[NSURL fileURLWithPath:filePath]])
        {
            [SCFileManager deleteFileWithURL:[NSURL fileURLWithPath:filePath]];
        }
        if([binaryImageData writeToFile:filePath atomically:YES])
            return [NSURL fileURLWithPath:filePath];
        binaryImageData = nil;
    }
    
    return nil;
   
}

+ (BOOL)copyFileFrom:(NSURL*)from toDir:(NSURL*)destinationDir
{
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:from.path])
    {
        return [fileManager copyItemAtURL:from toURL:destinationDir error:&error];;
    }
    
    return NO;
}


@end
