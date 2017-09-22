//
//  MineViewController.m
//  LuckProject
//
//  Created by moxi on 2017/6/25.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "MineViewController.h"
#import "MPThreeAPI.h"
#import "SearchCollectionViewCell.h"
#import "SearchDetialViewController.h"

@interface MineViewController ()<UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong)UISearchBar *mySearch;

@property (nonatomic, strong)NSMutableArray *dataSouce;

@property (nonatomic, strong)UICollectionView *collectionView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSouce = [NSMutableArray array];
    [self createUI];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)freshData{
    [self showBaseHud];
    [MPThreeAPI getSearchMainListDataBlock:^(NSMutableArray *data, NSString *error) {
        
        if (data!=nil) {
            [self dismissHudWithSuccessTitle:@"" After:1.f];
            [self.dataSouce removeAllObjects];
            [self.dataSouce addObjectsFromArray:data];
            [self.collectionView reloadData];
            [self dismissHudWithSuccessTitle:@"" After:1.f];
        }else{
            [self dismissHudWithErrorTitle:error After:1.f];
        }
        [self.collectionView.mj_header endRefreshing];
    }];
}

#pragma mark -UI

-(void)createUI{
    
    
    self.mySearch = [[UISearchBar alloc]init];
    self.mySearch.placeholder = @"试试搜搜";
    self.mySearch.delegate = self;
    self.mySearch.barTintColor = ECCOLOR(230, 230, 230, 1);
    [self.view addSubview:self.mySearch];
    
    [self.mySearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(35);
        make.top.mas_equalTo(self.view.mas_top).offset(64);
    }];
    
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(DREAMCSCREEN_W/3,40);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 99, DREAMCSCREEN_W, DREAMCSCREEN_H - 99 - 49) collectionViewLayout:flowLayout];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(collectionHeadView)];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SearchCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"searchcell"];
    
    [self.view addSubview:self.collectionView];

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


#pragma mark -collectionHeadView

-(void)collectionHeadView{
    
    [self freshData];
}


#pragma mark -collectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  self.dataSouce.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"searchcell" forIndexPath:indexPath];
    cell.styleLable.text = self.dataSouce[indexPath.row];
    cell.layer.borderColor = ECCOLOR(220, 220, 220, 1).CGColor;
    cell.layer.borderWidth = 1.0;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchDetialViewController *vc = [[SearchDetialViewController alloc]init];
    vc.keyword = self.dataSouce[indexPath.row];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
   
}


#pragma mark -searchDelegate

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [self.mySearch resignFirstResponder];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.mySearch resignFirstResponder];
    SearchDetialViewController *vc = [[SearchDetialViewController alloc]init];
    vc.keyword = searchBar.text;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;

}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.mySearch resignFirstResponder];
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
