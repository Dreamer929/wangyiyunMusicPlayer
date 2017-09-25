//
//  ZYFPopview.m
//  ZYFPopView
//
//  Created by moxi on 2017/7/28.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "ZYFPopview.h"


@interface ZYFPopview ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UIView *hostView;

@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic, strong)UIButton *cancleButton;
@property (nonatomic, strong)UIView *popBaseView;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) NSString *tipMessage;
@property (nonatomic, assign) NSInteger tipLabHeight;

@property (nonatomic, assign) NSInteger selectedIndex;


@property (nonatomic, strong)UIButton *closeBton;
@property (nonatomic, strong)UITableView *tableView;



@end

@implementation ZYFPopview

-(instancetype)initInView:(UIView *)hostView tip:(NSString*)tipTitle images:(NSMutableArray*)images rows:(NSMutableArray*)items doneBlock:(void(^)(NSInteger selectIndex))ondoneBlock cancleBlock:(void(^)())cancleBlock{
    
    self = [super initWithFrame:hostView.bounds];
    if (self) {
        self.hostView = hostView;
        self.data = items;
        self.images = images;
        self.tipMessage = tipTitle;
        self.onDoneBlock = ondoneBlock;
        self.onCancleBlock = cancleBlock;
        
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:self.bounds];
        self.shadeView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.6];
        [self.shadeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        [self addSubview:self.shadeView];
    }
    
    
    
    if ([self.tipMessage isEqualToString:@""]) {
      
        self.tipLabHeight = 0;
    }else{
        self.tipLabHeight = 45;
    }
    
    if (!self.popBaseView) {
        self.popBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, (self.data.count + 1)*45 + (self.data.count - 1)*0.5 + 5 + self.tipLabHeight)];
        self.popBaseView.backgroundColor = [UIColor lightTextColor];
        [self.shadeView addSubview:self.popBaseView];
        
        [UIView animateWithDuration:0.3 animations:^{
           self.popBaseView.frame = CGRectMake(0, self.bounds.size.height - ((self.data.count + 1)*45 + (self.data.count - 1)*0.5 + 5 + self.tipLabHeight), self.bounds.size.width, (self.data.count + 1)*45 + self.tipLabHeight + (self.data.count - 1)*0.5 + 5);
        }];
    }
    
        
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.popBaseView.bounds.size.width, self.tipLabHeight - 0.5)];
    lable.text = self.tipMessage;
    lable.backgroundColor = [UIColor whiteColor];
    lable.textColor = [UIColor lightGrayColor];
    lable.font = [UIFont systemFontOfSize:15];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.numberOfLines = 0;
    [self.popBaseView addSubview:lable];
    
    for (NSInteger index = 0; index < self.data.count; index++) {
        UIButton *button;
        
        if (!button) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, self.tipLabHeight + index*45 + index*0.5, self.popBaseView.bounds.size.width, 45);
            [button setTitle:self.data[index] forState:UIControlStateNormal];
            button.tag = index;
            
            if (self.images.count) {
                //button 文字图片自行调整
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.titleEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width/2 - 16, 0, 0);
                button.imageEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width/2 - 32, 0, 0);
                [button setImage:[UIImage imageNamed:self.images[index]] forState:UIControlStateNormal];
            }
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor whiteColor];
            [self.popBaseView addSubview:button];
        }
    }
    
    if (!self.cancleButton) {
        self.cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancleButton.frame = CGRectMake(0, self.tipLabHeight + 45*self.data.count + (self.data.count - 1) + 5, self.popBaseView.bounds.size.width, 45);
        self.cancleButton.backgroundColor = [UIColor whiteColor];
        [self.cancleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancleButton addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.popBaseView addSubview:self.cancleButton];
        
    }
}

-(void)showPopView{
    if (self.hostView) {
        [self.hostView addSubview:self];
    }
}

#pragma mark -tap

-(void)handleTapGesture:(UITapGestureRecognizer*)tap{
    [UIView animateWithDuration:0.3 animations:^{
        self.popBaseView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, (self.data.count + 1)*45 + (self.data.count - 1)*0.5 + 5 + self.tipLabHeight);

    } completion:^(BOOL finished) {
        self.shadeView.alpha = 0;
        [self removeFromSuperview];
    }];
}

#pragma mark -click

-(void)cancleClick:(UIButton*)button{
    
    if (self.onCancleBlock) {
        self.onCancleBlock();
        [UIView animateWithDuration:0.3 animations:^{
            self.popBaseView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, (self.data.count + 1)*45 + (self.data.count - 1)*0.5 + 5 + self.tipLabHeight);
            
        } completion:^(BOOL finished) {
            self.shadeView.alpha = 0;
            [self removeFromSuperview];
        }];
    }
}

-(void)actionClick:(UIButton*)button{
  
    if (self.onDoneBlock) {
        
        self.onDoneBlock(button.tag);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.popBaseView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, (self.data.count + 1)*50 + (self.data.count - 1)*1 + 10);
            
        } completion:^(BOOL finished) {
            self.shadeView.alpha = 0;
            [self removeFromSuperview];
        }];
    }
    
}

#pragma mark ------ muscilist------

-(instancetype)initView:(UIView *)hostView rows:(NSMutableArray*)totalRows defaultSelectRow:(NSInteger)defaultSelectRow selectDone:(void (^)(NSInteger))donceBlock canleDone:(void (^)())cancleBlock{
    
    self = [super initWithFrame:hostView.bounds];
    if (self) {

    self.hostView = hostView;
    self.data = totalRows;
    self.onDoneBlock = donceBlock;
    self.onCancleBlock = cancleBlock;
    
    [self setTableViewUp];
    }
    return self;
}

-(void)setTableViewUp{
    
    
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:self.bounds];
        self.shadeView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.6];
        [self addSubview:self.shadeView];
    }

    
    if (!self.popBaseView) {
        self.popBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height/2)];
        self.popBaseView.backgroundColor = [UIColor lightTextColor];
        [self.shadeView addSubview:self.popBaseView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.popBaseView.frame = CGRectMake(0, self.bounds.size.height/2 , self.bounds.size.width, self.bounds.size.height/2);
        }];
    }
    
    if (!self.closeBton) {
        self.closeBton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBton setTitle:@"关闭" forState:UIControlStateNormal];
        self.closeBton.backgroundColor = [UIColor whiteColor];
        [self.closeBton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.closeBton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.closeBton addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.popBaseView addSubview:self.closeBton];
        
        [self.closeBton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.popBaseView.mas_bottom);
            make.left.mas_equalTo(self.popBaseView.mas_left);
            make.right.mas_equalTo(self.popBaseView.mas_right);
            make.height.mas_equalTo(50);
        }];
 
    }
    
    if (!self.tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.popBaseView.bounds.size.width, self.popBaseView.bounds.size.height - 50) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.popBaseView addSubview:self.tableView];
    }
    

}


-(void)closeClick:(UIButton*)button{
    
    if (self.onCancleBlock) {
        self.onCancleBlock();
            [UIView animateWithDuration:0.3 animations:^{
                self.popBaseView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height/2);
                
            } completion:^(BOOL finished) {
                self.shadeView.alpha = 0;
                [self removeFromSuperview];
            }];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.data.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShiCiDetialModel *model = self.data[indexPath.row];
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.duration;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.onDoneBlock) {
        
        self.onDoneBlock(indexPath.row);
            [UIView animateWithDuration:0.3 animations:^{
                self.popBaseView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height/2);
                
            } completion:^(BOOL finished) {
                self.shadeView.alpha = 0;
                [self removeFromSuperview];
            }];
    }
    
}

@end
