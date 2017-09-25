//
//  PlayerViewController.m
//  LuckProject
//
//  Created by moxi on 2017/9/12.
//  Copyright © 2017年 moxi. All rights reserved.
//

#import "PlayerViewController.h"
#import "ZYFPopview.h"

@interface PlayerViewController ()

@property (nonatomic, assign)BOOL isPlay;
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVPlayerItem *playItem;
@property (nonatomic, assign)NSInteger music_id;
@property (nonatomic, strong)UIImageView *baseView;
@property (nonatomic, strong)UIImageView *headView;
@property (nonatomic, strong)UILabel *titleLable;
@property (nonatomic, strong)UIButton *playBtn;
@property (nonatomic, strong)UIButton *lastBtn;
@property (nonatomic, strong)UIButton *nextBtn;
@property (nonatomic, strong)UIButton *playStyleBtn;
@property (nonatomic, strong)UIButton *listBtn;
@property (nonatomic, assign)BOOL isSXPlay;
@property (nonatomic, strong)UIView *baseV;
@property (nonatomic, strong)UIButton *backBtn;
@property (nonatomic, strong)UIProgressView *progressView;
@property (nonatomic, strong)UISlider *slider;
@property (nonatomic, strong)UILabel *currtenLable;
@property (nonatomic, strong)UILabel *dutionLable;
@property(nonatomic,strong) id timeObserver;

@property (nonatomic, strong)ZYFPopview *popView;


@end

@implementation PlayerViewController


+ (instancetype)sharedInstance{
    
    
    static PlayerViewController *once_player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        once_player = [[PlayerViewController alloc]init];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        //类型是:播放和录音。
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        //而且要激活，音频会话。
        [session setActive:YES error:nil];
    });
    
    return once_player;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self roatationAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createUI];
    if (self.model) {
       self.dutionLable.text = self.model.duration;
    }else{
        self.dutionLable.text = @"00:00:00";
    }
    
    [self setHeadviewImageBy:self.model];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -createPlayer



-(void)playCurrtnItem:(ShiCiDetialModel*)model{
    
    self.model = model;
    self.isPlay = YES;
    self.isSXPlay = YES;
    
    self.currtenLable.text = @"00:00:00";
    self.dutionLable.text = model.duration;
    self.progressView.progress = 0;
    self.slider.value = 0;
    

    
    [self removePlayLoadTime];
    //移除监听音乐播放进度
    [self removeTimeObserver];
    
    [self removePlayStatus];
    
    [self roatationAnimation];
    
    [self setHeadviewImageBy:model];
    
    if (self.player) {
        
        if (self.music_id == model.id) {
         
            [self.player play];
        }else{
            [self showBaseHudWithTitle:@""];
            self.playItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:model.playurl]];
            [self.player replaceCurrentItemWithPlayerItem:self.playItem];
            [self.player play];
        }
        
    }else{
        [self showBaseHudWithTitle:@""];
        self.playItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:model.playurl]];
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.playItem];
 
        [self.player play];
    }
    
    
    
    self.music_id = model.id;
    
    [self addNSNotificationForPlayMusicFinish];
    
    //监听播放器状态
    [self addPlayStatus];
    
    //监听音乐缓冲进度
    [self addPlayLoadTime];
    
    //监听音乐播放的进度
    [self addMusicProgressWithItem:self.player.currentItem];
}


#pragma mark -createUI

-(void)createUI{
    
    self.baseView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DREAMCSCREEN_W, DREAMCSCREEN_H)];
    self.baseView.userInteractionEnabled = YES;
    [self.view addSubview:self.baseView];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = CGRectMake(0, 0, DREAMCSCREEN_W, DREAMCSCREEN_H);
    [self.baseView addSubview:effectView];
    
    
    self.baseV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DREAMCSCREEN_W, DREAMCSCREEN_H)];
    [effectView addSubview:self.baseV];
    
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:ECIMAGENAME(@"shouqi") forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.backBtn];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseV.mas_top).offset(20);
        make.left.mas_equalTo(self.baseV.mas_left);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];
    
    self.titleLable = [[UILabel alloc]init];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    self.titleLable.textColor = [UIColor whiteColor];
    self.titleLable.numberOfLines = 0;
    self.titleLable.font = [UIFont systemFontOfSize:15];
    [self.baseV addSubview:self.titleLable];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.baseV.mas_centerX);
        make.top.mas_equalTo(self.baseV.mas_top).offset(64);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(DREAMCSCREEN_W);
    }];
    
    CGFloat headW = DREAMCSCREEN_W/3*2;
    self.headView = [[UIImageView alloc]init];
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.cornerRadius = headW/2;
    [self.baseV addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.baseV.mas_centerX);
        make.width.mas_equalTo(headW);
        make.height.mas_equalTo(headW);
    }];
    
    
    [self setHeadviewImageBy:self
     .model];
    
    
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:ECIMAGENAME(@"play") forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.playBtn];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.baseV.mas_centerX);
        make.centerY.mas_equalTo(self.baseV.mas_bottom).offset(-40);
        make.width.mas_equalTo(48);
        make.height.mas_offset(48);
        
    }];
    
    self.lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lastBtn setImage:ECIMAGENAME(@"lastone") forState:UIControlStateNormal];
    [self.lastBtn addTarget:self action:@selector(lastOneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.lastBtn];
    
    [self.lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playBtn.mas_left).offset(-30);
        make.centerY.mas_equalTo(self.baseV.mas_bottom).offset(-40);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(32);
    }];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setImage:ECIMAGENAME(@"nextone") forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextOneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.nextBtn];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playBtn.mas_right).offset(30);
        make.centerY.mas_equalTo(self.baseV.mas_bottom).offset(-40);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(32);
    }];
    
    self.listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listBtn setImage:ECIMAGENAME(@"musiclist") forState:UIControlStateNormal];
    [self.listBtn addTarget:self action:@selector(showListClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.listBtn];
    
    [self.listBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nextBtn.mas_right).offset(30);
        make.centerY.mas_equalTo(self.baseV.mas_bottom).offset(-40);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(32);
    }];
    
    self.playStyleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playStyleBtn setImage:ECIMAGENAME(@"shunxu") forState:UIControlStateNormal];
    [self.playStyleBtn addTarget:self action:@selector(playStyleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseV addSubview:self.playStyleBtn];
    
    [self.playStyleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lastBtn.mas_left).offset(-30);
        make.centerY.mas_equalTo(self.baseV.mas_bottom).offset(-40);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(32);
    }];
    
    self.currtenLable = [[UILabel alloc]init];
    self.currtenLable.text = @"00:00:00";
    self.currtenLable.textAlignment = NSTextAlignmentLeft;
    self.currtenLable.font = [UIFont systemFontOfSize:10];
    self.currtenLable.textColor = [UIColor whiteColor];
    [self.baseV addSubview:self.currtenLable];
    
    [self.currtenLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.playBtn.mas_top).offset(-30);
        make.left.mas_equalTo(self.baseV.mas_left).offset(10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
    }];
    self.dutionLable = [[UILabel alloc]init];
    self.dutionLable.textAlignment = NSTextAlignmentRight;
    self.dutionLable.text = @"00:00:00";
    self.dutionLable.font = [UIFont systemFontOfSize:10];
    self.dutionLable.textColor = [UIColor whiteColor];
    [self.baseV addSubview:self.dutionLable];
    
    [self.dutionLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.playBtn.mas_top).offset(-30);
        make.right.mas_equalTo(self.baseV.mas_right).offset(-10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
    }];
    
    self.progressView = [[UIProgressView alloc]init];
    self.progressView.progress = 0;
    self.progressView.userInteractionEnabled = YES;
    self.progressView.trackTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor lightGrayColor];
    [self.baseV addSubview:self.progressView];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.currtenLable.mas_bottom).offset(10);
        make.left.mas_equalTo(self.baseV.mas_left).offset(10);
        make.right.mas_equalTo(self.baseV.mas_right).offset(-10);
        make.height.mas_equalTo(2);
    }];
    
    self.slider = [[UISlider alloc]init];
    self.slider.value = 0;
    self.slider.userInteractionEnabled = YES;
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.continuous = YES;
    [self.progressView addSubview:self.slider];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_top);
        make.left.mas_equalTo(self.progressView.mas_left);
        make.right.mas_equalTo(self.progressView.mas_right);
        make.bottom.mas_equalTo(self.progressView.mas_bottom);
    }];
    
}


-(void)setHeadviewImageBy:(ShiCiDetialModel*)model{
    
    
    [self.headView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:ECIMAGENAME(@"guang")];
    self.titleLable.text = model.title;
    
    [self.baseView sd_setImageWithURL:[NSURL URLWithString:self.model.thumb] placeholderImage:nil];
    
    [self roatationAnimation];
}


#pragma mark -click

-(void)backClick:(UIButton*)button{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)lastOneClick:(UIButton*)button{
    
    if (self.currtenflag==0) {
        
        [self showWarningHudWithWarningTitle:@"前面没有了哟"];
        [self dismissHudAfter:1.f];
    }else{
        self.currtenflag--;
        self.model = self.modelArr[self.currtenflag];
        [self playCurrtnItem:self.model];
    }
}

-(void)playClick:(UIButton*)button{
    
    if (self.isPlay) {
        CALayer *presentLayer = (CALayer*)self.headView.layer.presentationLayer;
        [self.headView.layer removeAnimationForKey:@"playAnimation"];
        self.headView.layer.transform = presentLayer.transform;
        [self.playBtn setImage:ECIMAGENAME(@"pasu") forState:UIControlStateNormal];
        self.isPlay = NO;
        self.model = nil;
        [self.player pause];
    }else{
        
        [self roatationAnimation];
        self.isPlay = YES;
        [self.playBtn setImage:ECIMAGENAME(@"play") forState:UIControlStateNormal];
        [self.player play];
    }
    
}

-(void)nextOneClick:(UIButton*)button{
    
    if (self.modelArr.count - self.currtenflag == 1) {
        [self showWarningHudWithWarningTitle:@"后面没有了哟"];
        [self dismissHudAfter:2.f];
        CALayer *presentLayer = (CALayer*)self.headView.layer.presentationLayer;
        [self.headView.layer removeAnimationForKey:@"playAnimation"];
        self.headView.layer.transform = presentLayer.transform;
        [self.playBtn setImage:ECIMAGENAME(@"pasu") forState:UIControlStateNormal];
        self.isPlay = NO;
        self.player = nil;
    }else{
        self.currtenflag++;
        self.model = self.modelArr[self.currtenflag];
        
        [self playCurrtnItem:self.model];
    }
}

-(void)showListClick:(UIButton*)button{
   
    self.popView = [[ZYFPopview alloc]initView:[UIApplication sharedApplication].keyWindow rows:self.modelArr defaultSelectRow:self.currtenflag selectDone:^(NSInteger selectRow) {
        
        self.currtenflag = selectRow;
        self.model = self.modelArr[selectRow];
        
        [self playCurrtnItem:self.model];
        
    } canleDone:^{
        
    }];
    [self.popView showPopView];
}

-(void)playStyleClick:(UIButton*)button{
    
    NSInteger playFlag = 0;
    
    if (self.isSXPlay) {
        //随机播放
        NSInteger arrCount = self.modelArr.count;
        playFlag = self.currtenflag;
        self.currtenflag = arc4random()%(arrCount-1);
        self.isSXPlay = NO;
        [self.playStyleBtn setImage:ECIMAGENAME(@"suiji") forState:UIControlStateNormal];
    }else{
       //顺序播放
        self.currtenflag = playFlag;
        self.isSXPlay = YES;
        [self.playStyleBtn setImage:ECIMAGENAME(@"shunxu") forState:UIControlStateNormal];
    }
}

- (void)roatationAnimation{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue   = @(M_PI*2);
        rotationAnimation.duration  = 20;
        rotationAnimation.repeatCount = HUGE_VAL;
        [self.headView.layer addAnimation:rotationAnimation forKey:@"playAnimation"];
        
    });
    
}

#pragma mark - 监听音乐各种状态
//通过KVO监听播放器状态
-(void)addPlayStatus
{
    
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}
//移除监听播放器状态
-(void)removePlayStatus
{
    if (self.model == nil) {return;}
    
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
}

//KVO监听音乐缓冲状态
-(void)addPlayLoadTime
{
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}
//移除监听音乐缓冲状态
-(void)removePlayLoadTime
{
    if (self.model == nil) {return;}
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}


#pragma mark - NSNotification
-(void)addNSNotificationForPlayMusicFinish
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

-(void)playFinished:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //播放下一首
    [self nextOneClick:nil];
}


//监听音乐播放的进度
-(void)addMusicProgressWithItem:(AVPlayerItem *)item
{
    
    __weak typeof(self) weakSelf = self;
    self.timeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time);
        //总时间
        float total = CMTimeGetSeconds(item.duration);
        if (current) {
            float progress = current / total;
            //更新播放进度条
            weakSelf.slider.value = progress;
            weakSelf.currtenLable.text = [weakSelf timeFormatted:current];
        }
    }];
    
}

//转换成时分秒
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds/3600;
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hours,minutes, seconds];
}
//移除监听音乐播放进度
-(void)removeTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}


//观察者回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context

{
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
               
            }
                break;
            case AVPlayerStatusFailed:
            {
                
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray * timeRanges = self.player.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲进度条
        self.progressView.progress = scale;
        if (scale == 1) {
            [self dismissHud];
        }
    }
}


#pragma mark ------MBProgressHUD------

/**
 *  普通Hud
 */
- (void)showBaseHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    hud.contentColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
}

- (void)showBaseHudWithTitle:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Set the label text.
    hud.label.text = title;
    hud.label.numberOfLines = 0;
    hud.bezelView.color = ECCOLOR(0, 0, 0, .8f);
    hud.contentColor = ECCOLOR(255, 255, 255, 1.f);
}

/**
 *  成功Hud
 *
 *  @param successTitle 标题可为空，默认Success
 */
- (void)showSuccessHudWithSuccessTitle:(NSString *)successTitle
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = successTitle ? successTitle : @"Success";
    hud.label.numberOfLines = 0;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    hud.bezelView.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    hud.contentColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
}

- (void)showWarningHudWithWarningTitle:(NSString *)warningTitle
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = warningTitle ? warningTitle : @"Warning";
    hud.label.numberOfLines = 0;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:ECIMAGENAME(@"hud_warning")];
    hud.bezelView.color = ECCOLOR(0, 0, 0, .8f);
    hud.contentColor = ECCOLOR(255, 255, 255, 1.f);
}

- (void)dismissHudAfter:(NSTimeInterval)afterSecond
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES afterDelay:afterSecond];
    });
}

/**
 *  成功Hud延迟消失
 *
 *  @param successTitle 标题可为空，默认Success
 *  @param afterSecond  延迟时间
 */
- (void)dismissHudWithSuccessTitle:(NSString *)successTitle After:(NSTimeInterval)afterSecond
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.label.text = successTitle ? successTitle : @"Success";
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:ECIMAGENAME(@"hud_success")];
        [hud hideAnimated:YES afterDelay:afterSecond];
    });
    
}


/**
 *  警告Hud延迟消失
 *
 *  @param warningTitle 标题可为空，默认Warning
 *  @param afterSecond  延迟时间
 */
- (void)dismissHudWithWarningTitle:(NSString *)warningTitle After:(NSTimeInterval)afterSecond
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        hud.label.text = warningTitle ? warningTitle : @"Warning";
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:ECIMAGENAME(@"hud_warning")];
        [hud hideAnimated:YES afterDelay:afterSecond];
    });
    
}

/**
 *  Hud消失
 */
- (void)dismissHud
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud hideAnimated:YES];
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
