//
//  CHQueryCell.m
//  TouchCPlatform
//
//  Created by weiguang on 2017/6/29.
//  Copyright © 2017年 changhong. All rights reserved.
//

#import "CHQueryCell.h"

@implementation CHQueryCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, SCREEN_WIDTH - 50, 30)];
        _lab.textColor = RGB(0x33, 0x33, 0x33);
        _lab.font = [UIFont systemFontOfSize:14];
        _lab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_lab];
        
        UIImage *image = [UIImage imageNamed:@"detail"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(SCREEN_WIDTH - 16 - image.size.width, (self.frame.size.height - image.size.height)/2 + 10, image.size.width, image.size.height);
        [self.contentView addSubview:imgView];

    }
    
    return self;
}


@end
