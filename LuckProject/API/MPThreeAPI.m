//
//  MPThreeAPI.m
//  LuckProject
//
//  Created by moxi on 2017/9/12.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "MPThreeAPI.h"

#import "ShiCiDetialModel.h"

@implementation MPThreeAPI

+(void)getShiCiListBy:(NSInteger)page dataBlock:(void (^)(NSMutableArray *data,NSString *error))block{
    
    NSString *str = [NSString string];
    str = [NSString stringWithFormat:SHICI_URL,page];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [MXHttpRequestManger GET:str parameters:@{} success:^(id responseObject) {
        
        NSArray *arr = responseObject[@"items"];
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            ShiciModel *model = [[ShiciModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [modelArray addObject:model];
        }
        block(modelArray,nil);
        
    } failure:^(NSError *error) {
        
        block(nil,error.userInfo[@"NSLocalizedDescription"]);

    }];
}

+(void)getShiCiDetialListByModel:(ShiciModel *)model page:(NSInteger)page callBlack:(void (^)(NSMutableArray *data,NSString *error))block{
    
    NSString *url = @"album.list.php?";
    NSDictionary *dic = @{
                          @"albumId":[NSString stringWithFormat:@"%ld",model.id],
                          @"albumTitle":model.title,
                          @"p":[NSString stringWithFormat:@"%ld",page],
                          @"pagesize":[NSString stringWithFormat:@"%d",20]
                          };
    
    [MXHttpRequestManger GET:[BASE_URL stringByAppendingString:url] parameters:dic success:^(id responseObject) {
        
        NSArray *arr = responseObject[@"items"];
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            ShiCiDetialModel*model = [[ShiCiDetialModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [modelArray addObject:model];
        }
        block(modelArray,nil);
        
    } failure:^(NSError *error) {
        block(nil,error.userInfo[@"NSLocalizedDescription"]);

    }];
    
}

+(void)getBangDanBy:(NSInteger)bd_id page:(NSInteger)page dataBlock:(void (^)(NSMutableArray *data,NSString *error))block{
    
    NSString *band_id;
    
    if (bd_id == 0) {
       band_id = @"relation";
    }else if (bd_id==1){
       band_id = @"play";
    }else{
       band_id = @"recent";
    }
    NSString *url = @"search.track.php?";
    NSDictionary *dic = @{
                          @"orderby":band_id,
                          @"keyword":@"诗词",
                          @"p":[NSString stringWithFormat:@"%ld",page],
                          @"pagesize":@"20"
                          };
    
    [MXHttpRequestManger GET:[BASE_URL stringByAppendingString:url] parameters:dic success:^(id responseObject) {
        
        NSArray *arr = responseObject[@"items"];
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            ShiCiDetialModel *model = [[ShiCiDetialModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [modelArray addObject:model];
        }
        block(modelArray,nil);
        
    } failure:^(NSError *error) {
        
        block(nil,error.userInfo[@"NSLocalizedDescription"]);

    }];
}

+ (void)getSearchMainListDataBlock:(void(^)(NSMutableArray *data,NSString *error))block{
    
    NSString *url = @"tags.php?";
    NSDictionary *dic = @{
                          @"appname":@"国学诗词",
                          @"keyword":@"诗词"
                          };
    
    [MXHttpRequestManger GET:[BASE_URL stringByAppendingString:url] parameters:dic success:^(id responseObject) {
        
        NSMutableArray *dataArr = [NSMutableArray arrayWithArray:responseObject];
        block(dataArr,nil);
        
    } failure:^(NSError *error) {
        
        block(nil,error.userInfo[@"NSLocalizedDescription"]);
    }];
}

+ (void)getSearchResultListBykeyword:(NSString *)keyword isTrack:(BOOL)istrack page:(NSInteger)page callblock:(void(^)(NSMutableArray *data,NSString *error))block{
    
    NSString *url;
    if (istrack) {
        url = @"search.track.php?";
    }else{
       url = @"search.album.php?";
    }
    NSDictionary *dic = @{
                          @"keyword":keyword,
                          @"p":[NSString stringWithFormat:@"%ld",page],
                          @"pagesize":@"20"
                          };
    [MXHttpRequestManger GET:[BASE_URL stringByAppendingString:url] parameters:dic success:^(id responseObject) {
        
        NSArray *arr = responseObject[@"items"];
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            ShiCiDetialModel*model = [[ShiCiDetialModel alloc]init];
            ShiciModel *model1 = [[ShiciModel alloc]init];
            if (istrack) {
                [model setValuesForKeysWithDictionary:dic];
                [modelArray addObject:model];
            }else{
                [model1 setValuesForKeysWithDictionary:dic];
                [modelArray addObject:model1];
            }
            
        }
        block(modelArray,nil);
        
    } failure:^(NSError *error) {
        block(nil,error.userInfo[@"NSLocalizedDescription"]);
    }];
}

@end
