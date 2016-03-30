//
//  MutipleGoodsViewController.m
//  kitchen
//
//  Created by xipin on 15/12/23.
//  Copyright © 2015年 gy. All rights reserved.
//

#import "MutipleGoodsViewController.h"
#import "OrderllistTableViewCell.h"
#import "WXApiManager.h"
#import "WXPayTool.h"
@interface MutipleGoodsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary *orderinfo;
    int statusoforder;
    UIView *dimview;
    MBProgressHUD *hud1;
    NSDictionary *wxpaydict;
}

@property (weak, nonatomic) IBOutlet UILabel *receiverlab;
@property (weak, nonatomic) IBOutlet UILabel *addresslab;
@property (weak, nonatomic) IBOutlet UILabel *ordercodelab;
@property (weak, nonatomic) IBOutlet UILabel *orderdealtimelab;
//自动收货时间
@property (weak, nonatomic) IBOutlet UILabel *automaticalreceivetimelab;
//共几件商品
@property (weak, nonatomic) IBOutlet UILabel *totalgoodscountlab;
//共计多少钱
@property (weak, nonatomic) IBOutlet UILabel *summarylab;

//订单金额，含运费
@property (weak, nonatomic) IBOutlet UILabel *totaltopaylab;
@property (weak, nonatomic) IBOutlet UILabel *statuslab;
@property (weak, nonatomic) IBOutlet UIImageView *statusimgview;
@property (weak, nonatomic) IBOutlet UILabel *phonelab;
@property (weak, nonatomic) IBOutlet UITableView *orderdetailtableview;
//点击了确认收货
- (IBAction)receivegoodBtnClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *receiveBtn;
//点击了取消订单
- (IBAction)cancelorderBtnClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *cancelorderBtn;
//点击了去支付
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
- (IBAction)payBtnClicked:(id)sender;
//tableviewheader订单编号lab
@property (weak, nonatomic) IBOutlet UILabel *ordercodelabinheader;

@end

@implementation MutipleGoodsViewController


-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden=YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view from its nib.
    if([WXApi isWXAppInstalled]){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(paysucceedoption) name:@"paysucceed" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(payfailedoption) name:@"payfailed" object:nil];
    }

    self.navigationItem.title=@"订单详情";
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem itemWithImageName:@"backpretty" highImageName:@"" target:self action:@selector(backBtnClicked)];
    [self initparas];
    [self getdatafromweb];
}
-(void)initparas{
    orderinfo=[NSDictionary dictionary];
    wxpaydict=[NSDictionary dictionary];
    self.automaticallyAdjustsScrollViewInsets=NO;
    _orderdetailtableview.backgroundColor=[UIColor whiteColor];
}

-(void)getdatafromweb{
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"]stringForKey:@"token"];
    paras[@"order_id"]=_order_id;
    NSLog(@"订单id=%@",_order_id);
    paras[@"isParent"]=_isparent;
    [HttpTool post:@"get_order_detail" params:paras success:^(id responseObj) {
        NSLog(@"获取订单详情=%@ 参数＝%@",responseObj,paras);
        if([responseObj int32ForKey:@"result"]==0&&([[[[responseObj dictionaryForKey:@"data"]dictionaryForKey:@"order_detail"]arrayForKey:@"orderDetailList"]count]>0))
        orderinfo=[[responseObj dictionaryForKey:@"data"]dictionaryForKey:@"order_detail"];
        wxpaydict=[[responseObj dictionaryForKey:@"data"]dictionaryForKey:@"wechat_param"];
        [self setlocalcontent];
        [_orderdetailtableview reloadData];
    } failure:^(NSError *error) {
        NSLog(@"获取详情失败%@",error);
    } controler:self];
}
-(void)setstatuslabtext:(int)i{
    UIView *view=[[UIView alloc]init];
    int kcount=[[orderinfo arrayForKey:@"orderDetailList"]count];
    NSString *payamount=[[orderinfo dictionaryForKey:@"orderHeader"]stringForKey:@"paymentAmount"];
    switch (i) {
        case 0:{
        _statuslab.text=@"待付款";
            view=[[[NSBundle mainBundle]loadNibNamed:@"twoBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];
            
        }
            break;
        case 2:{
        _statuslab.text=@"待发货";
            view=[[[NSBundle mainBundle]loadNibNamed:@"zeroBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];
        }
            break;
        case 6:{
        _statuslab.text=@"待收货";
            view=[[[NSBundle mainBundle]loadNibNamed:@"oneBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];
        }
            break;
        case 8:{
        _statuslab.text=@"已完成";
        view=[[[NSBundle mainBundle]loadNibNamed:@"zeroBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];
            
        }
            break;
        case -1:{
        _statuslab.text=@"已取消";
        view=[[[NSBundle mainBundle]loadNibNamed:@"zeroBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];

        }
            break;
        case -2:{
            _statuslab.text=@"无效订单";
            view=[[[NSBundle mainBundle]loadNibNamed:@"zeroBtn" owner:self options:nil]firstObject];
            view.frame=CGRectMake(0, MAIN_HEIGHT-49, MAIN_WIDTH, 49);
            _totalgoodscountlab.text=[NSString stringWithFormat:@"共%d件商品",kcount];
            _summarylab.text=[NSString stringWithFormat:@"¥%@",payamount];
            [self.view addSubview:view];

        }
            break;
        
        default:
            break;
    }
}
-(void)setlocalcontent{
    NSDictionary *dict=[orderinfo dictionaryForKey:@"orderHeader"];
    statusoforder=[dict int32ForKey:@"businessStatus"];
    [self setstatuslabtext:statusoforder];
    
    _totaltopaylab.text=[NSString stringWithFormat:@"订单金额(含运费)¥%@",[dict stringForKey:@"paymentAmount"]];
    
    _receiverlab.text=[dict stringForKey:@"marketName"];
    _addresslab.text=[dict stringForKey:@"address"];
    _phonelab.text=[dict stringForKey:@"consigneeTel1"];
    _ordercodelab.text=[dict stringForKey:@"orderCode"];
 }

-(void)backBtnClicked{
    //直接pop一个，不跳
    if(_backtoprevious==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    //跳2个
    else if (_backtoprevious==2){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-4] animated:YES];
       
    }
    //默认是跳1个
    else{
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3] animated:YES];
    }
    
    
    self.tabBarController.tabBar.hidden=NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return [[orderinfo arrayForKey:@"orderDetailList"]count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        OrderllistTableViewCell *cell=[OrderllistTableViewCell cellWithTableView:tableView cellwithIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *dict=[orderinfo arrayForKey:@"orderDetailList"][indexPath.section];
        cell.image=[dict stringForKey:@"goodsPic"];
        cell.name=[dict stringForKey:@"goodsName"];
        cell.toatalmoney=[NSString stringWithFormat:@"¥%.2f",[dict doubleForKey:@"frontPrice"]*[dict int32ForKey:@"frontQuantity"]];
    
    cell.specifciandprice=[NSString stringWithFormat:@"%@件X%.2f",[dict stringForKey:@"frontQuantity"],[dict doubleForKey:@"frontPrice"]];
    cell.hasbeensaled=[NSString stringWithFormat:@"已售%@件",[dict stringForKey:@"frontWeight"]];
    
        return cell;
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==[[orderinfo arrayForKey:@"orderDetailList"]count]-1) {
        return  MAIN_HEIGHT*0.12;
    }
    else
        return 5;
  
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  MAIN_HEIGHT*0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view=nil;
    if (section==[[orderinfo arrayForKey:@"orderDetailList"]count]-1){
        view=[[[NSBundle mainBundle]loadNibNamed:@"commonfooter" owner:self options:nil]firstObject];
        view.frame=CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT*0.12);
        NSDictionary *dict=[orderinfo dictionaryForKey:@"orderHeader"];
        //支付编号
        _ordercodelab.text=[NSString stringWithFormat:@"支付编号:%@",[dict stringForKey:@"orderCode"]];
        //订单时间啊
        _orderdealtimelab.text=[NSString stringWithFormat:@"订单时间:%@",[dict stringForKey:@"createTime"]];
        //自动收货时间
        _automaticalreceivetimelab.text=[NSString stringWithFormat:@"自动收货时间:%@",[dict stringForKey:@"buyerReceiveTime"]];
    }
    else{
       view=[[[NSBundle mainBundle]loadNibNamed:@"blank" owner:nil options:nil]firstObject];
        view.frame=CGRectMake(0, 0, MAIN_WIDTH,5);
        
    }
    
    return view;
 
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return MAIN_HEIGHT*0.037;
    }
    else{
        return 0;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==0){
    UIView *v=[[[NSBundle mainBundle]loadNibNamed:@"headerfortableview" owner:self options:nil]firstObject];
    v.frame=CGRectMake(0, 0, MAIN_WIDTH,MAIN_HEIGHT*0.037);
    NSDictionary *dict=[orderinfo dictionaryForKey:@"orderHeader"];
    _ordercodelabinheader.text=[NSString stringWithFormat:@"订单编号:%@",[dict stringForKey:@"orderCode"]];
    return v;
    }
    else
        return nil;
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
//确认收货
- (IBAction)receivegoodBtnClicked:(UIButton *)sender {
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"]stringForKey:@"token"];
    paras[@"orderId"]=_order_id;
    [HttpTool post:@"confirm_order" params:paras success:^(id responseObj) {
        if([responseObj int32ForKey:@"result"]==-1){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText =[[responseObj dictionaryForKey:@"data"]stringForKey:@"error_msg"];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.2];
            
        }
        else{
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"修改成功";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:0.8];
            [UIView animateWithDuration:.3 animations:^{
                _receiveBtn.x=MAIN_WIDTH;
            } completion:^(BOOL finished) {
                [_receiveBtn removeFromSuperview];
                _statuslab.text=@"已收货";
            }];
        }
    } failure:^(NSError *error) {
        NSLog(@"确认收货失败%@",error);
    } controler:self];

}
//取消订单
- (IBAction)cancelorderBtnClicked:(UIButton *)sender {
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"]stringForKey:@"token"];
    paras[@"orderId"]=_order_id;
    [HttpTool post:@"cancel_order" params:paras success:^(id responseObj) {
        if([responseObj int32ForKey:@"result"]==-1){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText =[[responseObj dictionaryForKey:@"data"]stringForKey:@"error_msg"];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.2];
            
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText =@"已取消";
            _statuslab.text=@"已取消";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:.8];
            [UIView animateWithDuration:.3 animations:^{
                _payBtn.x+=MAIN_WIDTH-_payBtn.x;
                _cancelorderBtn.x+=MAIN_WIDTH-_payBtn.x;
            } completion:^(BOOL finished) {
                [_payBtn removeFromSuperview];
                [_cancelorderBtn removeFromSuperview];
            }];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"发送取消失败%@",error);
    } controler:self];

}
//去支付
- (IBAction)payBtnClicked:(UIButton *)sender {
    //调起微信支付
    //1.没有安装微信，直接返回
    if(![WXApi isWXAppInstalled]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText =@"您未安装微信!";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1.2];
        return;
    }
    //2.安装了微信，进入支付
    dimview=[[UIView alloc]initWithFrame:self.view.bounds];
    dimview.backgroundColor=[UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:0.6];
    [self.view addSubview:dimview];
    
    hud1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud1.labelText = NSLocalizedString(@"正在支付...", @"HUD loading title");
    
    if([WXPayTool wxpaywithdict:wxpaydict]){
        [hud1 removeFromSuperview];
        [dimview removeFromSuperview];
        
    }

}

//支付成功后回调
-(void)paysucceedoption{
    [dimview removeFromSuperview];
    [hud1 removeFromSuperview];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =@"支付成功！";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:.8];
    _statuslab.text=@"已完成";
    [UIView animateWithDuration:.3 animations:^{
        _payBtn.x+=MAIN_WIDTH-_payBtn.x;
        _cancelorderBtn.x+=MAIN_WIDTH-_payBtn.x;
    } completion:^(BOOL finished) {
        [_payBtn removeFromSuperview];
        [_cancelorderBtn removeFromSuperview];
    }];
}
//支付失败后回调
-(void)payfailedoption{
    [dimview removeFromSuperview];
    [hud1 removeFromSuperview];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =@"支付失败!";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0];
}


@end
