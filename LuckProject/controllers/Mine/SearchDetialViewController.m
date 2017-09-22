//
//  SearchDetialViewController.m
//  LuckProject
//
//  Created by moxi on 2017/9/20.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "SearchDetialViewController.h"
#import "MPThreeAPI.h"
#import "MPThreeDetialTableViewCell.h"
#import "ZYFPopview.h"
#import "MpThreeDetialViewController.h"

@interface SearchDetialViewController ()

@property (nonatomic, assign)NSInteger page;

@property (nonatomic, strong)NSMutableArray *dataSouce;

@property (nonatomic, strong)ZYFPopview *popView;

@property (nonatomic, assign)BOOL isTrack;

@property (nonatomic, copy)NSString *flag;

@property (nonatomic, strong)NSIndexPath *selectFlag;

@end

@implementation SearchDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSouce = [NSMutableArray array];
    self.navigationItem.title = [self.keyword stringByAppendingString:@".单曲"];
    self.isTrack = YES;
    [self createUI];
    
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = right;
    
    
}

-(void)fetchDataIsTracck:(BOOL)istrack page:(NSInteger)page{

    [self showBaseHud];
    
    [MPThreeAPI getSearchResultListBykeyword:self.keyword isTrack:istrack page:page callblock:^(NSMutableArray *data, NSString *error) {
        if (data) {
            [self.dataSouce removeAllObjects];
            [self.dataSouce addObjectsFromArray:data];
            [self dismissHudWithSuccessTitle:@"" After:1.f];
            
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}

-(void)loadDataIsTrack:(BOOL)istrack page:(NSInteger)page{
    
    [self showBaseHud];
    
    [MPThreeAPI getSearchResultListBykeyword:self.keyword isTrack:istrack page:page callblock:^(NSMutableArray *data, NSString *error) {
        if (data) {
            [self.dataSouce addObjectsFromArray:data];
            [self dismissHudWithSuccessTitle:@"" After:1.f];
            
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark -tableview

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
    if (self.isTrack) {
        ShiCiDetialModel *model = self.dataSouce[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
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
        
    }else{
        ShiciModel *model = self.dataSouce[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.headView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
        cell.titleLable.text = model.title;
        cell.timeLable.text = self.keyword;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isTrack) {
        
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
        
    }else{
        
        ShiciModel *model = self.dataSouce[indexPath.row];
        MpThreeDetialViewController *vc = [[MpThreeDetialViewController alloc]init];
        vc.model = model;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

-(void)tableViewHeadRefresh{
    
    self.page  = 1;
    [self fetchDataIsTracck:self.isTrack page:self.page];
}
-(void)tableViewFootRefresh{
    
    self.page++;
    [self loadDataIsTrack:self.isTrack page:self.page];
}


#pragma mark -click

-(void)changeClick:(UIButton*)button{
    

    self.popView = [[ZYFPopview alloc]initInView:[UIApplication sharedApplication].keyWindow tip:@"选择类型" images:(NSMutableArray*)@[] rows:(NSMutableArray*)@[@"单曲",@"专辑"] doneBlock:^(NSInteger selectIndex) {
        self.page = 1;
        if (selectIndex) {
            self.isTrack = NO;
            self.navigationItem.title = [self.keyword stringByAppendingString:@".专辑"];
        }else{
            self.isTrack = YES;
            self.navigationItem.title = [self.keyword stringByAppendingString:@".单曲"];
        }
        [self.tableView.mj_header beginRefreshing];
        
    } cancleBlock:^{
        
        
    }];
    [self.popView showPopView];
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
