//
//  BangDanTableViewCell.h
//  LuckProject
//
//  Created by moxi on 2017/9/19.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BangDanTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headview;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@end
