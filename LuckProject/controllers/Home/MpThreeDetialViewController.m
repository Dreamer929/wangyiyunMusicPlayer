//
//  MpThreeDetialViewController.m
//  LuckProject
//
//  Created by moxi on 2017/9/12.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "MpThreeDetialViewController.h"

#import "PlayerViewController.h"
#import "MPThreeDetialTableViewCell.h"
#import "MPThreeAPI.h"
#import "ShiCiDetialModel.h"

@interface MpThreeDetialViewController ()

@property (nonatomic, assign)NSInteger page;

@property (nonatomic, strong)NSMutableArray *dataSouce;

@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerItem *item;
@property (nonatomic, copy)NSString *flag;

@property (nonatomic, strong)NSIndexPath *selectFlag;

@end

@implementation MpThreeDetialViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = self.model.title;
    [self createUI];
    
    self.flag = nil;
    
    self.dataSouce = [NSMutableArray array];
    self.page = 1;
    
    [self.tableView.mj_header beginRefreshing];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UI

-(void)createUI{
    
    [self initTableViewWithFrame:CGRectMake(0, 0, DREAMCSCREEN_W, DREAMCSCREEN_H) WithHeadRefresh:YES WithFootRefresh:YES WithScrollIndicator:NO];
    [self.tableView registerNib:[UINib nibWithNibName:@"MPThreeDetialTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 32, 32);
    [rightBtn setImage:ECIMAGENAME(@"music") forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(popPlayerClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)popPlayerClick:(UIButton*)button{
    
    PlayerViewController *vc = [PlayerViewController sharedInstance];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -freshAndLoadData

-(void)fetch{
    
    self.page = 1;
    [self showBaseHud];
    [MPThreeAPI getShiCiDetialListByModel:self.model page:self.page callBlack:^(NSMutableArray *data,NSString*error) {
        if (data) {
            [self.dataSouce removeAllObjects];
            [self.dataSouce addObjectsFromArray:data];
            [self.tableView reloadData];
            [self dismissHudWithSuccessTitle:@"" After:1.f];
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        
        [self.tableView.mj_header endRefreshing];
    }];
    
}

-(void)loadData{
    
    self.page++;
    [self showBaseHud];
    [MPThreeAPI getShiCiDetialListByModel:self.model page:self.page callBlack:^(NSMutableArray *data,NSString*error) {
        if (data) {
            [self.dataSouce addObjectsFromArray:data];
            [self.tableView reloadData];
            [self dismissHudWithSuccessTitle:@"" After:1.f];
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        
        [self.tableView.mj_footer endRefreshing];
    }];
}

-(void)tableViewHeadRefresh{
    
    [self fetch];
}

-(void)tableViewFootRefresh{
    
    [self loadData];
}

#pragma mark -tableviewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSouce.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MPThreeDetialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MPThreeDetialTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    ShiCiDetialModel *model = self.dataSouce[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.headView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
    cell.titleLable.text = model.title;
    cell.timeLable.text = model.duration;
    
    if (self.flag == nil) {
        
    }else{
        
        if (indexPath.row == self.selectFlag.row) {
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.fromValue = @(0.0);
            rotationAnimation.toValue   = @(M_PI*2);
            rotationAnimation.duration  = 20;
            rotationAnimation.repeatCount = HUGE_VAL;
            [cell.headView.layer addAnimation:rotationAnimation forKey:@"playAnimation"];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShiCiDetialModel *model = self.dataSouce[indexPath.row];
    
    PlayerViewController *vc = [PlayerViewController sharedInstance];
    vc.modelArr = [NSMutableArray arrayWithArray:self.dataSouce];
    vc.currtenflag = indexPath.row;
    [vc playCurrtnItem:model];
    self.hidesBottomBarWhenPushed = YES;

    [self.navigationController presentViewController:vc animated:YES completion:nil];

    
    if (self.flag == nil) {
        
        
    }else{
        
        MPThreeDetialTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectFlag];
        CALayer *presentLayer = (CALayer*)cell.layer.presentationLayer;
        [cell.headView.layer removeAnimationForKey:@"playAnimation"];
        cell.headView.layer.transform = presentLayer.transform;
    }
    
    self.selectFlag = indexPath;

    self.flag = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    MPThreeDetialTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(0.0);
    rotationAnimation.toValue   = @(M_PI*2);
    rotationAnimation.duration  = 20;
    rotationAnimation.repeatCount = HUGE_VAL;
    [cell.headView.layer addAnimation:rotationAnimation forKey:@"playAnimation"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
