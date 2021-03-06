//
//  NewFuturesViewController.m
//  一心一田
//
//  Created by xipin on 16/3/7.
//  Copyright © 2016年 xipin. All rights reserved.
//

#import "NewFuturesViewController.h"
#import "ExinEtianTabbarcontroller.h"
#define NewFuturesCount 4
@interface NewFuturesViewController ()<UIScrollViewDelegate>{
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *forwardimg;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
- (IBAction)startBtnClicked:(id)sender;



@end

@implementation NewFuturesViewController
-(instancetype)init{
  if(self=[super init])
      self.automaticallyAdjustsScrollViewInsets=NO;
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    _startBtn.hidden=YES;
    [self setupScrollView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)setupScrollView{

    _scrollview.contentSize=CGSizeMake(MAIN_WIDTH*NewFuturesCount, 0);
    _scrollview.pagingEnabled=YES;
    _scrollview.showsHorizontalScrollIndicator=NO;
    _forwardimg.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d",11]];
    for (int i=0;i<NewFuturesCount;i++){
        UIImageView *imgview=[[UIImageView alloc]initWithFrame:CGRectMake(i*MAIN_WIDTH, 0,MAIN_WIDTH,MAIN_HEIGHT)];
        imgview.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]];
        [_scrollview addSubview:imgview];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int pagnum=scrollView.contentOffset.x/scrollView.width;
    _forwardimg.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d",pagnum+11]];
    if (pagnum==NewFuturesCount-1){
        _forwardimg.hidden=YES;
        _startBtn.hidden=NO;
    }
    else
    {
        _forwardimg.hidden=NO;
        _startBtn.hidden=YES;
    }
    NSLog(@"当前滚到第%d页",pagnum);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)startBtnClicked:(id)sender {
    ExinEtianTabbarcontroller *vc = [[ExinEtianTabbarcontroller alloc] init];
    
    // 切换控制器
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = vc;
    
}
@end
