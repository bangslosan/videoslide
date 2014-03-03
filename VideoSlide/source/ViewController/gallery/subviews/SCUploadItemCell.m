//
//  SCUploadItemCell.m
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCUploadItemCell.h"

@implementation SCUploadItemCell
@synthesize uploadItemNameLb;
@synthesize uploadStatusLb;
@synthesize uploadProgressView;
@synthesize uploadTypeImgView;
@synthesize uploadStatusBtn;
@synthesize delegate;
@synthesize uploadObject = _uploadObject;
@synthesize testLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onUploadStatusBtn {
    if (_uploadObject.uploadStatus == SCUploadStatusFailed || _uploadObject.uploadStatus == SCUploadStatusUnknown) {
        if (_uploadObject.uploadType == SCUploadTypeYoutube) {
            [_uploadObject upload];
        } else if (_uploadObject.uploadType == SCUploadTypeFacebook) {
            [_uploadObject facebookUpload];
        } else if (_uploadObject.uploadType == SCUploadTypeVine) {
            [_uploadObject vineUpload];
        }
    }
}

- (void)uploadProgressViewWithValue:(float)progress {
    [UIView animateWithDuration:0.01
                     animations:^{
                         self.uploadProgressView.frame = CGRectMake(self.uploadProgressView.frame.origin.x,
                                                                    self.uploadProgressView.frame.origin.y,
                                                                    (260 * progress / 100),
                                                                    self.uploadProgressView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)setUploadObject:(SCUploadObject *)uploadObject {
    
    _uploadObject = uploadObject;
    _uploadObject.delegate = self;
    self.uploadItemNameLb.text = _uploadObject.fileName;
    self.uploadStatusLb.text = [SCUploadUtil uploadStatusString:_uploadObject.uploadStatus];
    self.uploadStatusLb.textColor = [SCUploadUtil colorUploadStatus:_uploadObject.uploadStatus];
    
    // when read from file, we have not save upload progress, so we check uploadStatus, if it is Uploaded -> set 100%.
    if (_uploadObject.uploadStatus == SCUploadStatusUploaded) {
        _uploadObject.uploadProgress = 100;
    }
    [self uploadProgressViewWithValue:_uploadObject.uploadProgress];
    
    self.uploadTypeImgView.image = [UIImage imageNamed:[SCUploadUtil imageUploadType:_uploadObject.uploadType]];
    [self.uploadStatusBtn setImage:[UIImage imageNamed:[SCUploadUtil imageUploadStatus:_uploadObject.uploadStatus]]
                          forState:UIControlStateNormal];
    
    
}

#pragma mark - SCUploadObject delegate methods
- (void)onUpdateUploadProgress:(float)progress {
    self.testLabel.text = [NSString stringWithFormat:@"%f", progress];
    [self uploadProgressViewWithValue:progress];
}

- (void)onUpdateUploadStatus:(SCUploadStatus)uploadStatus {
    
    [self.uploadStatusBtn setImage:[UIImage imageNamed:[SCUploadUtil imageUploadStatus:uploadStatus]]
                          forState:UIControlStateNormal];
    self.uploadStatusLb.text = [SCUploadUtil uploadStatusString:uploadStatus];
    self.uploadStatusLb.textColor = [SCUploadUtil colorUploadStatus:uploadStatus];
}

#pragma mark - Progress segment for Facebook
- (void)onUpdateUploadProgressWithSegment:(float)segment {
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.uploadProgressView.frame = CGRectMake(self.uploadProgressView.frame.origin.x,
                                                                    self.uploadProgressView.frame.origin.y,
                                                                    segment,
                                                                    self.uploadProgressView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
