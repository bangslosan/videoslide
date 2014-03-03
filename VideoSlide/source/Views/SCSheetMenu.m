//
//  SCSheetMenu.m
//  SlideshowCreator
//
//  Created 10/11/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSheetMenu.h"

@implementation SCSheetMenu
@synthesize isShow;
@synthesize containerView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCSheetMenu" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        self.hidden = YES;
        self.isShow = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame buttons:(NSArray*)buttons cancelButton:(NSString*)cancelButton {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCSheetMenu" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        self.hidden = YES;
        self.isShow = NO;
        
        // create items and content of sheet menu
        if ((buttons.count > 0) && (cancelButton != nil) && ![cancelButton isEqualToString:@""]) {
            int numItems = buttons.count + 1; // num main items + 1 cancel item
            self.containerView.frame = CGRectMake(frame.size.width/2 - SC_SHEET_MENU_ITEM_WIDTH/2,
                                                  frame.size.height/2 - (SC_SHEET_MENU_ITEM_HEIGHT * numItems)/2,
                                                  SC_SHEET_MENU_ITEM_WIDTH,
                                                  SC_SHEET_MENU_ITEM_HEIGHT * numItems);

            for (int i = 0; i < buttons.count; i++) {
                UIButton *menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
                [menuItem setTitle:(NSString*)[buttons objectAtIndex:i] forState:UIControlStateNormal];
                [menuItem setTitleColor:SC_SHEET_MENU_ITEM_COLOR forState:UIControlStateNormal];
                [menuItem setTitleColor:SC_SHEET_MENU_ITEM_HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
                [menuItem setBackgroundImage:[UIImage imageNamed:[self buttonBackgroundIndex:i]] forState:UIControlStateNormal];
                [menuItem setBackgroundImage:[UIImage imageNamed:[self buttonBackgroundIndex:i]] forState:UIControlStateHighlighted];
                menuItem.tag = i;
                menuItem.frame = CGRectMake(0, i * SC_SHEET_MENU_ITEM_HEIGHT, SC_SHEET_MENU_ITEM_WIDTH, SC_SHEET_MENU_ITEM_HEIGHT);
                [menuItem addTarget:self action:@selector(onMenuItemTap:) forControlEvents:UIControlEventTouchUpInside];
                [self.containerView addSubview:menuItem];
            }
            
            UIButton *cancelMenuItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancelMenuItem setTitle:cancelButton forState:UIControlStateNormal];
            [cancelMenuItem setTitleColor:SC_SHEET_MENU_ITEM_CANCEL_COLOR forState:UIControlStateNormal];
            [cancelMenuItem setTitleColor:SC_SHEET_MENU_ITEM_CANCEL_HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
            cancelMenuItem.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            [cancelMenuItem setBackgroundImage:[UIImage imageNamed:[self cancelBackground]] forState:UIControlStateNormal];
            [cancelMenuItem setBackgroundImage:[UIImage imageNamed:[self cancelBackground]] forState:UIControlStateHighlighted];
            cancelMenuItem.tag = buttons.count;
            cancelMenuItem.frame = CGRectMake(0, buttons.count * SC_SHEET_MENU_ITEM_HEIGHT, SC_SHEET_MENU_ITEM_WIDTH, SC_SHEET_MENU_ITEM_HEIGHT);
            [cancelMenuItem addTarget:self action:@selector(onCancelTap:) forControlEvents:UIControlEventTouchUpInside];
            [self.containerView addSubview:cancelMenuItem];
            
            [self addSubview:self.containerView];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame images:(NSArray*)images buttons:(NSArray*)buttons cancelButton:(NSString*)cancelButton {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"SCSheetMenu" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        self.hidden = YES;
        self.isShow = NO;
        
        // create items and content of sheet menu
        if ((buttons.count > 0) && (cancelButton != nil) && ![cancelButton isEqualToString:@""]) {
            int numItems = buttons.count + 1; // num main items + 1 cancel item
            self.containerView.frame = CGRectMake(frame.size.width/2 - SC_SHEET_MENU_ITEM_WIDTH/2,
                                                  frame.size.height/2 - (SC_SHEET_MENU_ITEM_HEIGHT * numItems)/2,
                                                  SC_SHEET_MENU_ITEM_WIDTH,
                                                  SC_SHEET_MENU_ITEM_HEIGHT * numItems);
            
            for (int i = 0; i < buttons.count; i++) {
                
                // text button
                UIButton *menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
                [menuItem setTitle:(NSString*)[buttons objectAtIndex:i] forState:UIControlStateNormal];
                [menuItem setTitleColor:SC_SHEET_MENU_ITEM_COLOR forState:UIControlStateNormal];
                [menuItem setTitleColor:SC_SHEET_MENU_ITEM_HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
                [menuItem setBackgroundImage:[UIImage imageNamed:[self buttonBackgroundIndex:i]] forState:UIControlStateNormal];
                [menuItem setBackgroundImage:[UIImage imageNamed:[self buttonBackgroundIndex:i]] forState:UIControlStateHighlighted];
                menuItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                menuItem.contentEdgeInsets = UIEdgeInsetsMake(0, 65, 0, 0);
                menuItem.tag = i;
                menuItem.frame = CGRectMake(0, i * SC_SHEET_MENU_ITEM_HEIGHT, SC_SHEET_MENU_ITEM_WIDTH, SC_SHEET_MENU_ITEM_HEIGHT);
                [menuItem addTarget:self action:@selector(onMenuItemTap:) forControlEvents:UIControlEventTouchUpInside];
                [self.containerView addSubview:menuItem];
                
                // icon for button
                UIImageView *imageButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[images objectAtIndex:i]]];
                imageButton.frame = CGRectMake(20, i * SC_SHEET_MENU_ITEM_HEIGHT + 7, SC_SHEET_MENU_ICON_WIDTH, SC_SHEET_MENU_ICON_HEIGHT);
                [self.containerView addSubview:imageButton];
                
            }
            
            UIButton *cancelMenuItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancelMenuItem setTitle:cancelButton forState:UIControlStateNormal];
            [cancelMenuItem setTitleColor:SC_SHEET_MENU_ITEM_CANCEL_COLOR forState:UIControlStateNormal];
            [cancelMenuItem setTitleColor:SC_SHEET_MENU_ITEM_CANCEL_HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
            cancelMenuItem.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            [cancelMenuItem setBackgroundImage:[UIImage imageNamed:[self cancelBackground]] forState:UIControlStateNormal];
            [cancelMenuItem setBackgroundImage:[UIImage imageNamed:[self cancelBackground]] forState:UIControlStateHighlighted];
            cancelMenuItem.tag = buttons.count;
            cancelMenuItem.frame = CGRectMake(0, buttons.count * SC_SHEET_MENU_ITEM_HEIGHT, SC_SHEET_MENU_ITEM_WIDTH, SC_SHEET_MENU_ITEM_HEIGHT);
            [cancelMenuItem addTarget:self action:@selector(onCancelTap:) forControlEvents:UIControlEventTouchUpInside];
            [self.containerView addSubview:cancelMenuItem];
            
            [self addSubview:self.containerView];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UI methods
- (NSString*)buttonBackgroundIndex:(int)index {
    if (index == 0) {
        return @"bg_sheet_menu_item_top.png";
    } else {
        return @"bg_sheet_menu_item_middle.png";
    }
}

- (NSString*)cancelBackground {
    return @"bg_sheet_menu_item_bottom.png";
}

#pragma mark - Local methods of Sheet menu
- (void)show {
    if (self.isShow) {
        return;
    }
    
    self.alpha = 0.0;
    self.hidden = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         self.isShow = YES;
                     }];
}

- (void)hide {
    if (!self.isShow) {
        return;
    }
    
    self.alpha = 1.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                         self.isShow = NO;
                     }];
}

#pragma mark - IBActions on Sheet menu
- (void)onMenuItemTap:(id)sender {
    [self.delegate onTapSheetMenuAtIndex:((UIButton*)sender).tag];
}

- (void)onCancelTap:(id)sender {
    [self.delegate onTapSheetCancel];
}
@end
