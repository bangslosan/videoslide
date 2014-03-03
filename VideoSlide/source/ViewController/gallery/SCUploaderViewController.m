//
//  SCUploaderViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCUploaderViewController.h"

@interface SCUploaderViewController ()

@property (nonatomic,strong) IBOutlet UIImageView *noUploadImgView;

@end

@implementation SCUploaderViewController
@synthesize uploadTableView;
@synthesize uploadItemCell;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.uploadTableView reloadData];
    
    // show/hide No Uploads Image
    if ([SCSocialManager getInstance].allUploadItems.count > 0) {
        self.noUploadImgView.hidden = YES;
    } else {
        self.noUploadImgView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SCSocialManager getInstance].allUploadItems.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"SCUploadItemCellIdentifier";
    
    SCUploadItemCell *cell = (SCUploadItemCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SCUploadItemCell" owner:self options:nil];
        cell = uploadItemCell;
    }
    
    SCUploadObject *uploadObject = [[SCSocialManager getInstance].allUploadItems objectAtIndex:indexPath.row];
    cell.uploadObject = uploadObject;
    /*
    cell.uploadItemNameLb.text = uploadObject.fileName;
    cell.uploadStatusLb.text = [SCUploadUtil uploadStatusString:uploadObject.uploadStatus];
    [cell uploadProgressViewWithValue:uploadObject.uploadProgress];
    cell.uploadTypeImgView.image = [UIImage imageNamed:[SCUploadUtil imageUploadType:uploadObject.uploadType]];
    [cell.uploadStatusBtn setImage:[UIImage imageNamed:[SCUploadUtil imageUploadStatus:uploadObject.uploadStatus]]
                          forState:UIControlStateNormal];
     */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)hideUploadManagerView:(id)sender {
    [self dismissPresentScreenWithAnimated:YES completion:nil];
    //[[SCScreenManager getInstance] dismissCurrentPresentScreenWithAnimated:YES];
}

@end
