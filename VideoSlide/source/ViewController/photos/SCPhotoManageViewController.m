//
//  SCPhotoManageViewController.m
//  SlideshowCreator
//
//  Created 11/19/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoManageViewController.h"

@interface SCPhotoManageViewController () <SCPhotoAlbumViewControllerDelegate>
@property (nonatomic,strong) SCPhotoAlbumViewController *photoAlbumViewController;
@end

@implementation SCPhotoManageViewController
@synthesize navigationController = _navigationController;
@synthesize photoAlbumViewController = _photoAlbumViewController;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.photoAlbumViewController = [[SCPhotoAlbumViewController alloc] initWithNibName:@"SCPhotoAlbumViewController" bundle:nil];
    self.photoAlbumViewController.delegate = self;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.photoAlbumViewController];
    self.navigationController.navigationBar.hidden = YES;
    
    [self.view addSubview:self.navigationController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Photo Album delegate methods
- (void)dismissPhotoAlbumWithData:(NSArray *)array {
    [self.delegate dismissPhotoManageWithData:array];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissPhotoAlbum {
    
    if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
            [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        if ([self.delegate respondsToSelector:@selector(dismissWithNoPhoto)]) {
            [self.delegate dismissWithNoPhoto];
        }
    }

}

// this delegate method just for single picker from main editor view
- (void)dismissPhotoPickerWithSlideComposition:(SCSlideComposition *)slideComposition {
   /* [[SCScreenManager getInstance].rootViewController dismissPresentScreenWithAnimated:YES
                                                                            completion:^{
                                                                                [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
                                                                            }];
*/
    /*
    [[SCScreenManager getInstance].rootViewController dismissPresentScreenWithAnimated:YES
                                                                            completion:^{
                                                                                [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
                                                                            }];
*/
    
    
    //[[SCScreenManager getInstance].rootViewController dismissPresentScreenWithAnimated:NO completion:nil];
    
    [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
}

@end
