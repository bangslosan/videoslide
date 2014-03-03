//
//  SCPhotoAlbumViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/10/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCPhotoAlbumViewController.h"

@interface SCPhotoAlbumViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *albumTableView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

@property (nonatomic,strong) ALAssetsLibrary    *assetsLibrary;
@property (nonatomic,strong) ALAssetsGroup      *assetGroup;
@property (nonatomic,strong) NSMutableArray     *albums;


- (IBAction)onBack:(id)sender;

@end

@implementation SCPhotoAlbumViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.navBar setTintColor:[UIColor blueColor]];
    self.albums = [[NSMutableArray alloc] init];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];

    // emumerate through our groups and only add groups that contain photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary
     enumerateGroupsWithTypes:groupTypes
     usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
         [group setAssetsFilter:onlyPhotosFilter];
         if (group)
         {
             if ([group numberOfAssets] > 0)
             {
                 if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                     [self.albums insertObject:group atIndex:0];
                 }
                 else {
                     [self.albums addObject:group];
                 }
             }
         }
         else
         {
             NSLog(@"Susscess");
             [self.albumTableView reloadData];
         }
     }
     failureBlock:^(NSError *error) {
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)onBack:(id)sender
{
    [self dismissPresentScreenWithAnimated:YES completion:nil];
}

#pragma mark - table view

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SCPhotoAlbumCellIdentifier"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoAlbumCell" owner:self options:nil] objectAtIndex:0];
    }
    
    ALAssetsGroup *groupForCell = self.albums[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell.coverImgView.image = posterImage;
    cell.albumMetaLb.text = [NSString stringWithFormat:@"%@", [groupForCell valueForProperty:ALAssetsGroupPropertyName]];
    cell.albumNumberPhotosLb.text = [NSString stringWithFormat:@"%d", groupForCell.numberOfAssets];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.albums.count > 0)
    {
        NSMutableArray *bufferPhotos = [[NSMutableArray alloc] init];
        self.assetGroup = [self.albums objectAtIndex:indexPath.row];
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [self.assetGroup setAssetsFilter:onlyPhotosFilter];
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
         {
             if (result)
             {
                 if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
                 {
                     
                     NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                     UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                     SCSlideComposition *slideComposition = [[SCSlideComposition alloc] initWithThumbnailImage:thumbnailImage assetURL:url];
                     [bufferPhotos addObject:slideComposition];
                     
                     thumbnailImage = nil;
                 }
             }
             else
             {
                 NSLog(@"Finish loading photos");
                 [self gotoScreen:SCEnumPhotoGridViewScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:bufferPhotos,SC_TRANSIT_KEY_SLIDE_ARRAY, nil]];
                 
            }
         }];

    }
    
}


@end


