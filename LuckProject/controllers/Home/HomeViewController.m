//
//  HomeViewController.m
//  LuckProject
//
//  Created by moxi on 2017/6/25.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "HomeViewController.h"

#import "MPThreeAPI.h"
#import "ShiciModel.h"
#import "MpThreeDetialViewController.h"
#import "MPThreeCollectionViewCell.h"


@interface HomeViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)NSMutableArray *dataSouce;
@property (nonatomic, assign)NSInteger page;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSouce = [NSMutableArray array];
    self.page = 1;
    [self createUI];

    [self.collectionView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -UI

-(void)createUI{
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    bgImage.image = ECIMAGENAME(@"bg2");
    bgImage.userInteractionEnabled = YES;
    
    [self.view addSubview:bgImage];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 32, 32);
    [rightBtn setImage:ECIMAGENAME(@"music") forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(popPlayerClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    [self createCollectionView];
}

-(void)createCollectionView{
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 15;
    flowLayout.minimumLineSpacing = 15;
    flowLayout.itemSize = CGSizeMake(DREAMCSCREEN_W/2-25,(DREAMCSCREEN_H - 113)/2);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, DREAMCSCREEN_W, DREAMCSCREEN_H - 64 - 49) collectionViewLayout:flowLayout];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(collectionHeadView)];
    self.collectionView.mj_footer = [MJRefreshBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(collectionFootView)];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MPThreeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark -fetchData

-(void)collectionHeadView{
    [self showBaseHud];
    [self fetchData];
}

-(void)collectionFootView{
    
    [self showBaseHud];
    
    self.page++;
    [MPThreeAPI getShiCiListBy:self.page dataBlock:^(NSMutableArray *data,NSString *error) {
        if (data) {
            [self dismissHudWithSuccessTitle:@"" After:1.f];
            [self.dataSouce addObjectsFromArray:data];
            [self.collectionView reloadData];
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        [self.collectionView.mj_footer endRefreshing];
    }];
}
-(void)fetchData{
    
    self.page = 1;
    [MPThreeAPI getShiCiListBy:self.page dataBlock:^(NSMutableArray *data,NSString*error) {
        if (data) {
            [self dismissHudWithSuccessTitle:@"" After:1.f];
            [self.dataSouce removeAllObjects];
            [self.dataSouce addObjectsFromArray:data];
            [self.collectionView reloadData];
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        
        [self.collectionView.mj_header endRefreshing];
    }];
    
    
}


-(void)popPlayerClick:(UIButton*)button{
    
    PlayerViewController *vc = [PlayerViewController sharedInstance];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -collectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  self.dataSouce.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShiciModel *model = self.dataSouce[indexPath.row];
    MPThreeCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.headView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:nil];
    cell.titleLable.text = model.title;
    cell.layer.borderColor = ECCOLOR(220, 20, 100, 1).CGColor;
    cell.layer.borderWidth = 1.0;
    cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    [UIView animateWithDuration:1 animations:^{
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ShiciModel *model = self.dataSouce[indexPath.row];
    MpThreeDetialViewController *vc = [[MpThreeDetialViewController alloc]init];
    vc.model = model;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
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
