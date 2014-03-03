//
//  SCFileManager.h
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCFileManager : SCBaseManager <NSFileManagerDelegate>

@property (nonatomic, strong) NSURL             *projectRootDir;
@property (nonatomic, strong) NSArray           *projects;
@property (nonatomic, strong) NSMutableArray    *slideShows;
@property (nonatomic, strong) ALAssetsLibrary   *assetLibrary;



- (void)updateProjects;

- (void)updateSlideShows;


+ (SCFileManager*)getInstance;

+ (BOOL)exist:(NSURL*)URL;

+ (NSURL*)URLFromDocumentWithName:(NSString*)name;

+ (NSURL*)URLFromBundleWithName:(NSString*)name;

+ (NSURL*)URLFromTempWithName:(NSString*)name;

+ (NSURL*)URLFromLibraryWithName:(NSString*)name;

+ (NSArray*)URLPathsFromBundleWithExtension:(NSString*)extension;

+ (NSURL*)createURLFromDocumentWithName:(NSString*)name;

+ (NSURL*)createURLFromTempWithName:(NSString*)name;


+ (NSURL*)createIncreaseNameFromTempWith:(NSString*)name andtype:(NSString*)type;

+ (NSURL*)createFolderFromTempWithName:(NSString*)name;

+ (NSURL*)createFolderFromLibraryWithName:(NSString*)name;

+ (NSURL*)createFolderFromDocumentWithName:(NSString*)name;

+ (NSURL*)createFolderFromDir:(NSURL*)dir WithName:(NSString*)name;

+ (NSURL*)urlFromDir:(NSURL*)dir withName:(NSString*)name;

+ (NSURL *)createIncreaseNameFromDir:(NSURL *)dir withName:(NSString*)name andtype:(NSString *)type;

+ (NSURL*)writeImageIntoDir:(NSURL*)dir image:(UIImage*)image imageName:(NSString*)imageName;

+ (NSArray*)URLSFromDir:(NSURL*)url;

+ (NSArray *)subDirectoriesFromDir:(NSURL*)dir;

+ (BOOL)copyFileFrom:(NSURL*)from toDir:(NSURL*)destinationDir;

+ (void)deleteFileFromDocumentWithName:(NSString*)name;

+ (void)deleteFileFromLibraryWithName:(NSString*)name;

+ (void)deleteAllFileFromDocument;

+ (void)deleteAllFileFromDir:(NSURL*)dir;

+ (void)deleteAllFileFromDir:(NSURL*)dir withExtension:(NSString*)extension;

+ (void)deleteAllfileFromDocumentWithExtension:(NSString*)extension;

+ (BOOL)deleteFileWithURL:(NSURL*)url;

+ (void)deleteFileFromTempWithName:(NSString*)name;

+ (void)deleteAllFileFromTemp;

+ (void)deleteAllfileFromTempWithExtension:(NSString*)extension;

+ (void)deleteFileFromDir:(NSURL*)file;


@end
