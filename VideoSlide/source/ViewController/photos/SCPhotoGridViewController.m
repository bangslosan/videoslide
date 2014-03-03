//
//  SCPhotoGridViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/10/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCPhotoGridViewController.h"

@interface SCPhotoGridViewController () <SCItemGridViewProtocol>

@property (nonatomic, strong) IBOutlet UIView   *contentView;
@property (nonatomic, strong) IBOutlet UIButton *doneBtn;
@property (nonatomic, strong) IBOutlet UILabel  *photoSelectedLb;

@property (nonatomic, strong) SCItemGridView    *gridView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end

@implementation SCPhotoGridViewController

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
    self.photos = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_ARRAY];
    self.selectedPhotos = [[NSMutableArray alloc] init];
    
    //gridview init
    self.gridView = [[SCItemGridView alloc] initWith:self.contentView.bounds
                                             andType:SCGridViewTypeVertical
                                   numberItemPerPage:self.photos.count];
    [self.gridView setDelegate:self];
    [self.gridView setData:self.photos];
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    [self.gridView setEnableEditing:YES];
    //add to View
    [self.contentView addSubview:self.gridView];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - actions

- (IBAction)onBack:(id)sender
{
    [self goBack];
}

- (void)onDone:(id)sender
{
    [self dismissPresentScreen];
    [self sendNotification:SCNotificationDidFinishSelectPhotos body:self.selectedPhotos type:nil];
}
#pragma mark - item grid view

- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCPhotoItemView *cell = (SCPhotoItemView*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCItemGridViewCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
    SCSlideComposition *slideComposition = (SCSlideComposition*)[self.photos objectAtIndex:index];
    cell.photoImgView.image = slideComposition.thumbnailImage;
    cell.checkMarkImgView.hidden = YES;
    cell.checkMarkView.hidden = YES;
    return cell;
    
}

- (CGSize)sizeForItemCell
{
    return CGSizeMake(80, 80);
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView loadDataAtfirstTimeWith:(int)numberPage
{
    if(itemGridView.data.count == 0)
    {
        [self.gridView setData:self.photos];
    }
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView didSelectItemAtIndex:(int)index withCell:(SCItemGridViewCell *)cell
{
    SCPhotoItemView *itemCell = (SCPhotoItemView*)cell;
    itemCell.checkMarkView.hidden = !itemCell.checkMarkView.hidden;
    itemCell.checkMarkImgView.hidden = !itemCell.checkMarkImgView.hidden;
    SCSlideComposition *slide = [self.photos objectAtIndex:index];

    if(itemCell.checkMarkImgView.hidden)
    {
        [self.selectedPhotos removeObject:slide];
    }
    else
    {
        [self.selectedPhotos addObject:slide];
    }
    self.photoSelectedLb.text = [NSString stringWithFormat:@"%d selected", self.selectedPhotos.count];

}


@end
