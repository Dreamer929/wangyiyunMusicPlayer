//
//  PindaoViewController.m
//  LuckProject
//
//  Created by moxi on 2017/9/19.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "PindaoViewController.h"

#import "BangDanTableViewCell.h"
#import "MPThreeAPI.h"
#import "MpThreeDetialViewController.h"

@interface PindaoViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)NSMutableArray *defaultArr;
@property (nonatomic, strong)NSMutableArray *hotArr;
@property (nonatomic, strong)NSMutableArray *recentArr;

@property (nonatomic, strong)UIScrollView *baseScrollview;

@property (nonatomic, strong)UITableView *detaultTab;
@property (nonatomic, strong)UITableView *hotTab;
@property (nonatomic, strong)UITableView *recentTab;


@property (nonatomic, assign)NSInteger defaultPage;
@property (nonatomic, assign)NSInteger hotPage;
@property (nonatomic, assign)NSInteger recentPage;

@property (nonatomic, assign)BOOL hotSelectect;
@property (nonatomic, assign)BOOL recentSelect;

@end

@implementation PindaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultArr = [NSMutableArray array];
    self.hotArr = [NSMutableArray array];
    self.recentArr = [NSMutableArray array];
    
    self.hotSelectect = NO;
    self.recentSelect = NO;
    
    [self createUI];
    
    [self.detaultTab.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -createUI

-(void)createUI{
    
    NSArray *titleArr = @[@"传统",@"热门",@"新颖"];
    CGFloat buttonH = 38;
    CGFloat buttonW = DREAMCSCREEN_W/titleArr.count;
    
    
    for (NSInteger index = 0; index<titleArr.count; index++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (index == 0) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [button setTitle:titleArr[index] forState:UIControlStateNormal];
        button.frame = CGRectMake(index*buttonW, 64, buttonW, buttonH);
        button.tag = index + 10;
        button.backgroundColor = ECCOLOR(230, 230, 230, 1);
        [button addTarget:self action:@selector(transformClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    
    }
    
    
    [self createScrollview];
    
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

-(void)createScrollview{
    
    self.baseScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 104, DREAMCSCREEN_W, DREAMCSCREEN_H - 104 -49)];
    self.baseScrollview.contentSize = CGSizeMake(DREAMCSCREEN_W*3, DREAMCSCREEN_H - 104 - 49);
    self.baseScrollview.delegate = self;
    self.baseScrollview.scrollEnabled = NO;
    self.baseScrollview.bounces = NO;
    self.baseScrollview.showsHorizontalScrollIndicator = NO;
    self.baseScrollview.showsVerticalScrollIndicator = NO;
    self.baseScrollview.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.baseScrollview];
    
    [self createTab];
}

-(void)createTab{
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.detaultTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DREAMCSCREEN_W, self.baseScrollview.frame.size.height) style:UITableViewStylePlain];
    [self.detaultTab registerNib:[UINib nibWithNibName:@"BangDanTableViewCell" bundle:nil] forCellReuseIdentifier:@"detialcell"];
    self.detaultTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.detaultTab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(defaltableViewHeadRefresh)];
    self.detaultTab.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(defaltableviewFootLood)];
    
    [self createTablviewWith:self.detaultTab isshowVerScroll:NO];
    
    self.hotTab = [[UITableView alloc] initWithFrame:CGRectMake(DREAMCSCREEN_W, 0, DREAMCSCREEN_W, self.baseScrollview.frame.size.height) style:UITableViewStylePlain];
    self.hotTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.hotTab registerNib:[UINib nibWithNibName:@"BangDanTableViewCell" bundle:nil] forCellReuseIdentifier:@"detialcell"];
    self.hotTab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(hotableViewHeadRefresh)];
    self.hotTab.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(hotableviewFootLood)];
   [self createTablviewWith:self.hotTab isshowVerScroll:NO];
    
    self.recentTab = [[UITableView alloc] initWithFrame:CGRectMake(DREAMCSCREEN_W*2, 0, DREAMCSCREEN_W, self.baseScrollview.frame.size.height) style:UITableViewStylePlain];
    self.recentTab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(recenttableViewHeadRefresh)];
    self.recentTab.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(recenttableviewFootLood)];
    self.recentTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.recentTab registerNib:[UINib nibWithNibName:@"BangDanTableViewCell" bundle:nil] forCellReuseIdentifier:@"detialcell"];
    
    
    [self createTablviewWith:self.recentTab isshowVerScroll:NO];
}


-(void)createTablviewWith:(UITableView*)tableview isshowVerScroll:(BOOL)isShow{
    
    
    tableview.backgroundColor = [UIColor whiteColor];
    
    tableview.delegate = self;
    tableview.dataSource = self;
    
    tableview.showsVerticalScrollIndicator = isShow;
    
    tableview.tableHeaderView = [[UIView alloc]init];
    tableview.tableFooterView = [[UIView alloc]init];
    
    [self.baseScrollview addSubview:tableview];
}


#pragma mark -clcik

-(void)transformClick:(UIButton*)button{
    
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    UIButton *button0;
    UIButton *button1 ;
    switch (button.tag) {
        case 10:
        {
            button0 = [self.view viewWithTag:11];
            button1 = [self.view viewWithTag:12];
            
        }
            break;
        case 11:
        {
            button0 = [self.view viewWithTag:10];
            button1 = [self.view viewWithTag:12];
            if (!self.hotSelectect) {
                [self.hotTab.mj_header beginRefreshing];
                self.hotSelectect = YES;
            }
        }
            break;
        case 12:
        {
            button0 = [self.view viewWithTag:10];
            button1 = [self.view viewWithTag:11];
            if (!self.recentSelect) {
                [self.recentTab.mj_header beginRefreshing];
                self.recentSelect = YES;
            }
        }
            break;
            
        default:
            break;
    }
    [button0 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.baseScrollview.contentOffset = CGPointMake(DREAMCSCREEN_W*(button.tag - 10), 0);

}

#pragma mark netquest

-(void)netquestById:(NSInteger)bangId page:(NSInteger)page{
    
    [self showBaseHudWithTitle:@""];
    [MPThreeAPI getBangDanBy:bangId page:page dataBlock:^(NSMutableArray *data,NSString*error) {
        
        if (data) {
            if (bangId == 0) {
                [self.defaultArr removeAllObjects];
                [self.defaultArr addObjectsFromArray:data];
                [self.detaultTab reloadData];
                [self.detaultTab.mj_header endRefreshing];
            }else if (bangId == 1){
                [self.hotArr removeAllObjects];
                [self.hotArr addObjectsFromArray:data];
                [self.hotTab reloadData];
                [self.hotTab.mj_header endRefreshing];
            }else{
                [self.recentArr removeAllObjects];
                [self.recentArr addObjectsFromArray:data];
                [self.recentTab reloadData];
                [self.recentTab.mj_header endRefreshing];
            }
            [self dismissHudWithSuccessTitle:@"" After:1.f];
        }else{
            if (bangId == 0) {
                [self.detaultTab.mj_header endRefreshing];
            }else if (bangId == 1){
                [self.hotTab.mj_header endRefreshing];
            }else{
                [self.recentTab.mj_header endRefreshing];
            }
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        
    }];
}

-(void)loadDataById:(NSInteger)bangId page:(NSInteger)page{
    [self showBaseHudWithTitle:@""];
    [MPThreeAPI getBangDanBy:bangId page:page dataBlock:^(NSMutableArray *data,NSString *error) {
        if (data) {
            if (bangId == 0) {
                [self.defaultArr addObjectsFromArray:data];
                [self.detaultTab reloadData];
                [self.detaultTab.mj_footer endRefreshing];
            }else if (bangId == 1){
                [self.hotArr addObjectsFromArray:data];
                [self.hotTab reloadData];
                [self.hotTab.mj_footer endRefreshing];
            }else{
                [self.recentArr addObjectsFromArray:data];
                [self.recentTab reloadData];
                [self.recentTab.mj_footer endRefreshing];
            }
            [self dismissHudWithSuccessTitle:@"" After:1.f];
        }else{
            if (bangId == 0) {
                [self.detaultTab.mj_footer endRefreshing];
            }else if (bangId == 1){
                [self.hotTab.mj_footer endRefreshing];
            }else{
                [self.recentTab.mj_footer endRefreshing];
            }
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        
    }];
}

#pragma mark -tableviewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.detaultTab) {
        return self.defaultArr.count;
    }else if (tableView == self.hotTab){
        return self.hotArr.count;
    }else{
        return self.recentArr.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShiCiDetialModel *model;
    if (tableView == self.detaultTab) {
        model = self.defaultArr[indexPath.row];
    }else if (tableView == self.hotTab){
        model = self.hotArr[indexPath.row];
    }else{
        model = self.recentArr[indexPath.row];
    }
    
    BangDanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detialcell"];
    if (!cell) {
        cell = [[BangDanTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"detialcell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.headview sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
    cell.titleLable.text = model.title;
    cell.timeLable.text = model.duration;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayerViewController *vc = [PlayerViewController sharedInstance];
    ShiCiDetialModel *model;
    vc.currtenflag = indexPath.row;

    if (tableView == self.detaultTab) {
        model = self.defaultArr[indexPath.row];
        vc.modelArr = [NSMutableArray arrayWithArray:self.defaultArr];
    }else if (tableView == self.hotTab){
        model = self.hotArr[indexPath.row];
        vc.modelArr = [NSMutableArray arrayWithArray:self.hotArr];
    }else{
        model = self.recentArr[indexPath.row];
        vc.modelArr = [NSMutableArray arrayWithArray:self.recentArr];
    }
    vc.model = model;
    [vc playCurrtnItem:model];
    
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)defaltableViewHeadRefresh{
    self.defaultPage = 1;
    [self netquestById:0 page:self.defaultPage];
}
-(void)defaltableviewFootLood{
    self.defaultPage++;
    [self loadDataById:0 page:self.defaultPage];
}

-(void)hotableViewHeadRefresh{
    self.hotPage = 1;
    [self netquestById:1 page:self.hotPage];
}
-(void)hotableviewFootLood{
    self.hotPage++;
    [self loadDataById:1 page:self.hotPage];

}

-(void)recenttableViewHeadRefresh{
    
    self.recentPage = 1;
    [self netquestById:2 page:self.recentPage];
}
-(void)recenttableviewFootLood{
    self.recentPage++;
    [self loadDataById:2 page:self.recentPage];

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
