//
//  PlayerViewController.h
//  LuckProject
//
//  Created by moxi on 2017/9/12.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "BaseViewController.h"

#import "ShiCiDetialModel.h"

@interface PlayerViewController : BaseViewController

@property (nonatomic, strong)ShiCiDetialModel *model;

@property (nonatomic, strong)NSMutableArray *modelArr;
@property (nonatomic, assign)NSInteger currtenflag;



+ (instancetype)sharedInstance;

-(void)playCurrtnItem:(ShiCiDetialModel*)model;

//-(void)fetchDataFromServce;
//-(void)rotatationKeyFrameAnimation;

@end
