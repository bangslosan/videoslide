//
//  SCScreenManager.m
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCScreenManager.h"
// import all viewcontrollers
#import "SCViewController.h"
#import "SCRootViewController.h"
#import "SCCreatorTestViewController.h"
#import "SCHomeViewController.h"
#import "SCExporterViewController.h"
#import "SCSettingViewController.h"
#import "SCVineAuthenticateViewController.h"

static SCScreenManager *instance;


@interface SCScreenManager ()  <UINavigationControllerDelegate>

@property (nonatomic, strong) MPMoviePlayerController *player;

@end

@implementation SCScreenManager

@synthesize currentScreen = _currentScreen;
@synthesize lastScreen    = _lastScreen;
@synthesize lastRelatedScreen = _lastRelatedScreen;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.currentScreen = SCEnumNoneScreen;
        self.lastScreen    = SCEnumNoneScreen;
        self.rootViewController = [[SCRootViewController alloc]initWithNibName:@"SCRootViewController" bundle:nil];
    }
    return self;
}

+ (SCScreenManager*)getInstance
{
    @synchronized([SCScreenManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    return nil;
    
}
- (void)clearAllHistory
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
}

#pragma mark - playing movie
- (void)playMovieWithUrl:(NSURL*)url
{
    if(self.player)
    {
        [self.player stop];
        [self.player setContentURL:nil];
        self.player = nil;
    }
    MPMoviePlayerViewController* controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
	controller.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.3) {
		controller.moviePlayer.allowsAirPlay = YES;
	}
	self.player = controller.moviePlayer;
    [controller.moviePlayer play];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:controller.moviePlayer];
    
	[self.rootViewController presentMoviePlayerViewControllerAnimated:controller];
}

- (void)movieFinishCallback:(NSNotification*)notification
{
	int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	if (reason == MPMovieFinishReasonPlaybackEnded) {
		NSLog(@"media finished playing");
		return;
	}
	if (reason == MPMovieFinishReasonPlaybackError) {
		NSLog(@"failed to play media");
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [_player stop];
			[_player setContentURL:nil];
			_player = nil;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable Play" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			alert = nil;
		});
	}
}


#pragma mark - screen actions

- (void)backToHome
{
    while(self.navController.viewControllers.count > 1)
    {
        SCViewController *lastVC = [self.navController.viewControllers objectAtIndex:self.navController.viewControllers.count - 1];
        [lastVC clearAll];
        [self.navController popViewControllerAnimated:NO];
    }

}

- (void)popToScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data
{
    [self backToHome];
    [self gotoScreen:screenName data:data];
}

- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
    
    self.transitData = data;

    SCViewController *viewController;
    switch (screenName)
    {
        case SCenumStartScreen:
        {
            viewController = [[SCStartViewController alloc]initWithNibName:@"SCStartViewController" bundle:nil];
        }
            break;
        case SCEnumHomeScreen:
        {
            viewController = [[SCHomeViewController alloc]initWithNibName:@"SCHomeViewController" bundle:nil];
        }
            break;
        case SCEnumPhotoAlbumScreen:
        {
            viewController = [[SCPhotoAlbumViewController alloc]initWithNibName:@"SCPhotoAlbumViewController" bundle:nil];
        }
            break;
        case SCEnumEditorScreen:
        {
            viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController" bundle:nil];
        }
            break;
        case SCEnumExportScreen:
        {
            viewController = [[SCExporterViewController alloc]initWithNibName:@"SCExporterViewController" bundle:nil];
        }
            break;
        case SCEnumSettingScreen:
        {
            viewController = [[SCSettingViewController alloc]initWithNibName:@"SCSettingViewController" bundle:nil];
        }
            break;
        case SCEnumVineAuthenticateScreen:
        {
            viewController = [[SCVineAuthenticateViewController alloc]initWithNibName:@"SCVineAuthenticateViewController" bundle:nil];
        }
            break;
        
        default:
            break;
    }
    SCViewController  *temp = self.currentPresentVC;
    self.currentPresentVC = viewController;
    [self.rootViewController presentViewController:self.currentPresentVC animated:YES completion:nil];
    viewController = nil;
    [temp clearAll];
    temp = nil;
}

- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data animated:(BOOL)animated
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
    
    self.transitData = data;
    
    SCViewController *viewController;
    switch (screenName)
    {
        case SCenumStartScreen:
        {
            viewController = [[SCStartViewController alloc]initWithNibName:@"SCStartViewController" bundle:nil];
        }
            break;
        case SCEnumHomeScreen:
        {
            viewController = [[SCHomeViewController alloc]initWithNibName:@"SCHomeViewController" bundle:nil];
        }
            break;
        case SCEnumPhotoAlbumScreen:
        {
            viewController = [[SCPhotoAlbumViewController alloc]initWithNibName:@"SCPhotoAlbumViewController" bundle:nil];
        }
            break;
        case SCEnumEditorScreen:
        {
            viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController" bundle:nil];
        }
            break;
        case SCEnumExportScreen:
        {
            viewController = [[SCExporterViewController alloc]initWithNibName:@"SCExporterViewController" bundle:nil];
        }
            break;
        case SCEnumSettingScreen:
        {
            viewController = [[SCSettingViewController alloc]initWithNibName:@"SCSettingViewController" bundle:nil];
        }
            break;
         case SCEnumVineAuthenticateScreen:
        {
            viewController = [[SCVineAuthenticateViewController alloc]initWithNibName:@"SCVineAuthenticateViewController" bundle:nil];
        }
            break;
            
        default:
            break;
    }
    if(self.presentNavController)
    {
        [self.presentNavController popToRootViewControllerAnimated:NO];
        [self.presentNavController removeFromParentViewController];
        [self.navController.view removeFromSuperview];
        self.presentNavController = nil;
    }
    self.presentNavController = [[SCNavigationController alloc]initWithRootViewController:viewController];
    SCViewController  *temp = self.currentPresentVC;
    //self.currentPresentVC = viewController;
    [self.rootViewController presentViewController:self.presentNavController animated:animated completion:nil];
    viewController = nil;
    [temp clearAll];
    temp = nil;
}

- (void)switchScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
    
    self.transitData = data;
    self.lastScreen = self.currentScreen;
    self.currentScreen  = screenName;
    
    SCViewController *viewController;
    switch (screenName)
    {
        case SCenumStartScreen:
        {
            viewController = [[SCStartViewController alloc]initWithNibName:@"SCStartViewController" bundle:nil];
        }
            break;
        case SCEnumHomeScreen:
        {
            viewController = [[SCHomeViewController alloc]initWithNibName:@"SCHomeViewController" bundle:nil];
        }
            break;
        case SCEnumEditorScreen:
        {
            if(SC_IS_IPHONE5)
                viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController" bundle:nil];
            else
                viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController_Iphone4" bundle:nil];
        }
            break;
        case SCEnumExportScreen:
        {
            viewController = [[SCExporterViewController alloc]initWithNibName:@"SCExporterViewController" bundle:nil];
        }
            break;
        case SCEnumSettingScreen:
        {
            viewController = [[SCSettingViewController alloc]initWithNibName:@"SCSettingViewController" bundle:nil];
        }
            break;
        case SCEnumVineAuthenticateScreen:
        {
            viewController = [[SCVineAuthenticateViewController alloc]initWithNibName:@"SCVineAuthenticateViewController" bundle:nil];
        }
            break;
        default:
            break;
    }
    
    if(self.navController )
    {
        [self.navController popToRootViewControllerAnimated:NO];
        [self.navController removeFromParentViewController];
        [self.navController.view removeFromSuperview];
        self.navController = nil;
    }
    if(self.currentVC)
    {
        self.currentVC.isActive = NO;
        self.currentVC = nil;
    }
    self.navController = [[SCNavigationController alloc]initWithRootViewController:viewController];
    self.navController.delegate = self;
    viewController.lastScreen = self.lastScreen;
    viewController.screenNameType = self.currentScreen;
    self.currentVC = viewController;
    self.currentVC.isActive = YES;
    self.rootViewController.topViewController = (SCViewController*)self.navController.topViewController;
}


- (void)gotoScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
    
    self.transitData = data;
    self.lastScreen = self.currentScreen;
    self.currentScreen  = screenName;
    
    SCViewController *viewController;
    switch (screenName)
    {
        case SCenumStartScreen:
        {
            viewController = [[SCStartViewController alloc]initWithNibName:@"SCStartViewController" bundle:nil];
        }
            break;
        case SCEnumHomeScreen:
        {
            viewController = [[SCHomeViewController alloc]initWithNibName:@"SCHomeViewController" bundle:nil];
        }
            break;
        case SCEnumEditorScreen:
        {
            if(SC_IS_IPHONE5)
                viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController" bundle:nil];
            else
                viewController = [[SCVideoEditorViewController alloc]initWithNibName:@"SCVideoEditorViewController_Iphone4" bundle:nil];
        }
            break;
        case SCEnumExportScreen:
        {
            viewController = [[SCExporterViewController alloc]initWithNibName:@"SCExporterViewController" bundle:nil];
        }
            break;
        case SCEnumSettingScreen:
        {
            viewController = [[SCSettingViewController alloc]initWithNibName:@"SCSettingViewController" bundle:nil];
        }
            break;
        case SCEnumVineAuthenticateScreen:
        {
            viewController = [[SCVineAuthenticateViewController alloc]initWithNibName:@"SCVineAuthenticateViewController" bundle:nil];
        }
            break;
        case SCEnumPhotoGridViewScreen:
        {
            viewController = [[SCPhotoGridViewController alloc]initWithNibName:@"SCPhotoGridViewController" bundle:nil];
        }
            break;
        case SCEnumPreviewScreen:
        {
            viewController = [[SCPreviewViewController alloc]initWithNibName:@"SCPreviewViewController" bundle:nil];
        }
            break;
        case SCEnumVideoLengthSettingScreen:
        {
            viewController = [[SCVideoLengthSettingViewController alloc]initWithNibName:@"SCVideoLengthSettingViewController" bundle:nil];
        }
            break;
        case SCEnumMusicEditScreen:
        {
            viewController = [[SCMusicEditViewController alloc]initWithNibName:@"SCMusicEditViewController" bundle:nil];
        }
            break;
        case SCEnumSharingScreen:
        {
            viewController = [[SCSharingViewController alloc]initWithNibName:@"SCSharingViewController" bundle:nil];
        }
            break;
        default:
            break;
    }
    
    if(self.presentNavController)
    {
        [self.presentNavController pushViewController:viewController animated:YES];
        viewController = nil;
        return;
    }
    
    
    if(!self.navController)
    {
        self.navController = [[SCNavigationController alloc]initWithRootViewController:viewController];
        self.navController.delegate = self;
        self.rootViewController.topViewController = self.navController;
    }
    else
    {
        [self.navController pushViewController:viewController animated:YES];
    }
    if(self.currentVC)
    {
        self.currentVC.isActive = NO;
        self.currentVC = nil;
    }
    viewController.screenNameType = self.currentScreen;
    self.currentVC = viewController;
    self.currentVC.isActive = YES;
    self.currentVC.lastScreen = self.lastScreen;
    viewController = nil;
    
}


- (void)goBack
{
    //check if is in present view controller
    if(self.presentNavController)
    {
        [self.presentNavController popViewControllerAnimated:YES];
        if(self.transitData)
        {
            [self.transitData removeAllObjects];
            self.transitData = nil;
        }
        return;
    }
    //if not is in present navigation viewcontroller
    [self.navController popViewControllerAnimated:YES];
    if(self.navController.viewControllers.count > 1)
    {
        SCViewController *lastVC = [self.navController.viewControllers objectAtIndex:self.navController.viewControllers.count - 1];
        [lastVC viewActionAfterTurningBack];
        self.currentScreen = self.lastScreen;
        self.lastScreen = lastVC.lastScreen;
    }
    if(self.currentVC)
    {
        [self.currentVC removeFromParentViewController];
        self.currentVC  = nil;
        
    }
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }
}

- (void)dismissCurrentPresentScreenWithAnimated:(BOOL)animated completion:(void (^)(void))completionBlock
{
    if(self.transitData)
    {
        [self.transitData removeAllObjects];
        self.transitData = nil;
    }

    if(self.presentNavController)
    {
        if(animated)
            [self.presentNavController dismissViewControllerAnimated:animated completion:^{
                if(completionBlock)
                    completionBlock();
                
                [self.presentNavController popToRootViewControllerAnimated:NO];
                [self.presentNavController removeFromParentViewController];
                self.presentNavController = nil;
            }];
        else
        {
            [self.presentNavController dismissViewControllerAnimated:animated completion:nil];
            [self.presentNavController popToRootViewControllerAnimated:NO];
            [self.presentNavController removeFromParentViewController];
            self.presentNavController = nil;
        }
    }

}

#pragma mark - navigation delegate methods

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //self.currentScreen = self.lastScreen;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //self.currentScreen = self.lastScreen;
    
}

@end
