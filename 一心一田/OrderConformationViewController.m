//
//  OrderConformationViewController.m
//  kitchen
//
//  Created by xipin on 15/12/15.
//  Copyright © 2015年 gy. All rights reserved.
//

#import "OrderConformationViewController.h"
#import "OrderllistTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "AddInOrderTableViewCell.h"
#import "WXApi.h"
#import "MutipleGoodsViewController.h"
#import "NewAddressViewController.h"
@interface OrderConformationViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
   
    int quantity;
    double totaltopay;
    NSMutableArray *addlistarray;
    UIView *v;
    NSString *letters;
    NSString *deliveryId;
    int deliveryaddindex;
    NSDictionary *orderinfo;
    MBProgressHUD *hud1;
     UIView *dimview;
    NSString *paymode;
}
@property (weak, nonatomic) IBOutlet UITableView *goodslisttableview;
@property (weak, nonatomic) IBOutlet UILabel *allmoneytopay;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
- (IBAction)payBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *receiverlab;
@property (weak, nonatomic) IBOutlet UILabel *phonelab;
@property (weak, nonatomic) IBOutlet UILabel *addresslab;
- (IBAction)payModeBtnClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *yueimg;
@property (weak, nonatomic) IBOutlet UIImageView *wechatimg;

@property (weak, nonatomic) IBOutlet UITableView *deliverylisttableview;
- (IBAction)dismissview:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *addressnoticelab;

@end

@implementation OrderConformationViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
    [super viewWillAppear:animated];
}

-(instancetype)init{
   if(self=[super init])
       self.automaticallyAdjustsScrollViewInsets=NO;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"得到的tabledata=%@",_tabledata);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addaddressrefresh) name:@"newaddresssucceed" object:nil];
    
    self.navigationItem.title=@"订单确认";
    
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem itemWithImageName:@"back" highImageName:@"" target:self action:@selector(backBtnClicked)];
    [self initparas];
    [self setbottombar];
    [self setdeliveryaddress];
    
}

-(void)addaddressrefresh{
    [self setdeliveryaddress];
}

-(void)initparas{
    addlistarray=[NSMutableArray array];
    deliveryaddindex=0;
    orderinfo=[NSDictionary dictionary];
    paymode=@"BA";

}

-(void)setdeliveryaddress{
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"] stringForKey:@"token"];
    [HttpTool post:@"get_address" params:paras success:^(id responseObj) {
        NSLog(@"获取的收获地址列表 参数=%@ res= %@",paras,responseObj);
        if([responseObj int32ForKey:@"result"]==0){
            NSDictionary *dict=[responseObj dictionaryForKey:@"data"];
            
            _receiverlab.text=[NSString stringWithFormat:@"收货人:%@",[dict stringForKey:@"marketplaceName"]];
            _phonelab.text=[dict arrayForKey:@"phones"][0];
            _addresslab.text=[NSString stringWithFormat:@"%@%@%@",[dict stringForKey:@"provinceName"],[dict stringForKey:@"cityName"],[dict stringForKey:@"districtName"]];
           
        }
    } failure:^(NSError *error) {
        NSLog(@"获取收货地址失败 %@",error);
    }];

}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
     if(touch.view.tag==44)
         return YES;
    else
        return NO;
}
-(void)setbottombar{
    
    _allmoneytopay.text=[NSString stringWithFormat:@"¥%.2f",[LocalAndOnlineFileTool calculatesummoneyinshopcar]];
    [_payBtn setTitle:[NSString stringWithFormat:@"去支付(%d)",[LocalAndOnlineFileTool refreshcoungnum]] forState:UIControlStateNormal];
 
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView.tag==100)
        return addlistarray.count;
    else
    return _tabledata.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag==100){
        AddInOrderTableViewCell *cell=[AddInOrderTableViewCell cellWithTableView:tableView cellwithIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.receiver=[addlistarray[indexPath.row] stringForKey:@"receiver"];
        cell.phone=[addlistarray[indexPath.row]stringForKey:@"cellPhone"];
        cell.address=[addlistarray[indexPath.row] stringForKey:@"deliveryAddress"];
        return cell;
    }
    else{
    OrderllistTableViewCell *cell=[OrderllistTableViewCell cellWithTableView:tableView cellwithIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSDictionary *dict=_tabledata[indexPath.row];
    cell.image=[dict stringForKey:@"thumbnailImg"];
    cell.name=[dict stringForKey:@"name"];
   
    cell.price=[NSString stringWithFormat:@"¥%@",[dict stringForKey:@"price"]];
    int kcount=[LocalAndOnlineFileTool singlegoodcount:[dict stringForKey:@"goodsId"]];
    cell.count=[NSString stringWithFormat:@"X%d",kcount];
    
    cell.toatalmoney=[NSString stringWithFormat:@"总价:¥%.2f",[dict doubleForKey:@"price"]*kcount];
    cell.goodspicBtn.tag=indexPath.row;
    [cell.goodspicBtn addTarget:self action:@selector(goodspicBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
      return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"多个商品选择换的地址%@",addlistarray[indexPath.row]);
    if(tableView.tag==100){
        
           _phonelab.text=[addlistarray[indexPath.row]stringForKey:@"cellPhone"];
        _addresslab.text=[addlistarray[indexPath.row] stringForKey:@"deliveryAddress"];
        _receiverlab.text=[addlistarray[indexPath.row] stringForKey:@"receiver"];
        [v removeFromSuperview];
        deliveryId=[addlistarray[indexPath.row]stringForKey:@"id"];
        deliveryaddindex=indexPath.row;
    
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag==100){

        return MAIN_HEIGHT*0.09;
    
    }
    else
    return  MAIN_HEIGHT*0.16;
}

-(void)goodspicBtnClicked:(UIButton *)sender{
    GoodsDetailViewController *vc=[[GoodsDetailViewController alloc]init];
    vc.goodsid=[_tabledata[sender.tag] stringForKey:@"goodsId"];
    [self.navigationController pushViewController:vc animated:YES];
}





-(void)backBtnClicked{
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"backtocart" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}
- (IBAction)payBtn:(id)sender {
//    if([addlistarray count]==0)
//    {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        
//        // Configure for text only and offset down
//        hud.mode = MBProgressHUDModeText;
//        
//        hud.labelText =@"您还未添加收货地址";
//        hud.labelFont=[UIFont systemFontOfSize:14.0];
//        hud.margin = 10.f;
//        hud.removeFromSuperViewOnHide = YES;
//        
//        [hud hide:YES afterDelay:2.0];
//        return;
//        
//    }

//       if(![WXApi isWXAppInstalled]){
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        
//        // Configure for text only and offset down
//        hud.mode = MBProgressHUDModeText;
//        
//        hud.labelText =@"您未安装微信!";
//        hud.margin = 10.f;
//        hud.removeFromSuperViewOnHide = YES;
//        
//        [hud hide:YES afterDelay:1.2];
//        return;
//    }
    
    NSMutableArray *deliverlist=[NSMutableArray array];
    NSMutableArray *willberesetids=[NSMutableArray array];
    for (NSDictionary *dict in _tabledata) {
        int kcount=[LocalAndOnlineFileTool singlegoodcount:[dict stringForKey:@"goodsId"]];
        
        [deliverlist addObject:[DictionaryToJsonStr dictToJsonStr:@{@"goodsRelativeId":[dict stringForKey:@"id"],@"quantity":[NSString stringWithFormat:@"%d",kcount],@"weight":@"2",@"calculation":[dict stringForKey:@"billUnit"]}]];
        [willberesetids addObject:[dict stringForKey:@"goodsId"]];
    }
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"] stringForKey:@"token"];
    paras[@"goods_list"]=[NSString stringWithFormat:@"%@",deliverlist];
    paras[@"order_info"]=[DictionaryToJsonStr dictToJsonStr:@{@"buyerRemark":@"1",@"payMode":paymode}];
   
    [HttpTool post:@"add_order_by_goods" params:paras success:^(id responseObj) {
        NSLog(@"提交订单后%@ 参数=%@",responseObj,paras);
        if([responseObj int32ForKey:@"result"]==-1){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText =[[responseObj dictionaryForKey:@"data"]stringForKey:@"error_msg"];
            hud.labelFont=[UIFont systemFontOfSize:12.5];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:2.0];
        }
        //订单提交成功
        else {
            
            [LocalAndOnlineFileTool resetaftersuccessfulsubmit:willberesetids];
            
            [LocalAndOnlineFileTool refreshkindnum:self.tabBarController];
            //如果是微信支付
            if ([paymode isEqualToString:@"WC"]) {
                dimview=[[UIView alloc]initWithFrame:self.view.bounds];
                dimview.backgroundColor=[UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:0.6];
                [self.view addSubview:dimview];
                
                hud1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                hud1.labelText = NSLocalizedString(@"正在支付...", @"HUD loading title");
                [[SaveFileAndWriteFileToSandBox singletonInstance]savefiletosandbox:responseObj filepath:@"detailbasedinfo.txt"];
                //获得支付请求参数
                NSDictionary *tempdict=[[responseObj dictionaryForKey:@"data"] dictionaryForKey:@"wechat_param"];
                NSLog(@"fuch tepdic=%@",tempdict);
                NSString *prepayId=[tempdict stringForKey:@"prepayid"];
                NSString *noncestr=[tempdict stringForKey:@"noncestr"];
                int timestamp=[tempdict int64ForKey:@"timestamp"];
                NSString *sign=[tempdict stringForKey:@"sign"];
                if(tempdict==nil){
                    [self paysucceedoption];
                }
                else{
                    
                    PayReq *request=[[PayReq alloc]init];
                    
                    request.partnerId=@"1300204001";
                    request.package =@"Sign=WXPay";
                    request.prepayId=prepayId;
                    request.nonceStr=noncestr;
                    request.timeStamp=timestamp ;
                    request.sign=sign;
                    NSLog(@"prepayid=%@,noncestr=%@,timestamo=%d,sign=%@调用微信的返回值 %d",prepayId,noncestr,timestamp,sign,[WXApi sendReq:request]);
                    if ([WXApi sendReq:request]) {
                        [hud1 removeFromSuperview];
                        [dimview removeFromSuperview];
                    }
                    
                    
                }

            }
            //余额支付
            else {
              
            }
            
            
        }
    } failure:^(NSError *error) {
        NSLog(@"提交订单shibai%@",error);
    }];
    
    
    
}

-(void)paysucceedoption{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =@"支付成功！";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0];
    NSMutableDictionary *paras=[NSMutableDictionary dictionary];
    paras[@"token"]=[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"tokenfile.txt"]stringForKey:@"token"];
    paras[@"order_id"]=[[[[SaveFileAndWriteFileToSandBox singletonInstance]getfilefromsandbox:@"detailbasedinfo.txt"]dictionaryForKey:@"data"]stringForKey:@"order_id"];
    
    [HttpTool post:@"get_order_detail" params:paras success:^(id responseObj) {
        NSLog(@"批量下单成功后去获得详情json=%@",responseObj);
        if([responseObj int32ForKey:@"result"]==0){
            
            MutipleGoodsViewController *vc=[[MutipleGoodsViewController alloc]init];
            vc.orderinfo=[responseObj dictionaryForKey:@"data"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText =[[responseObj dictionaryForKey:@"data"] stringForKey:@"error_msg"];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.0];
            [self.navigationController  popViewControllerAnimated:YES];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"获取订单详情失败 %@",error);
    }];

}

-(void)payfailedoption{
    
    [dimview removeFromSuperview];
    [hud1 removeFromSuperview];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =@"支付失败";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0];
}


- (IBAction)changedeliveryaddressBtnClicked:(id)sender {
    //新增收货地址
    if(addlistarray.count<2){

        NewAddressViewController *vc=[[NewAddressViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
        
    }

    v=[[[NSBundle mainBundle]loadNibNamed:@"popaddresschooser" owner:self options:nil]firstObject];
    v.frame=self.view.bounds;
    [self.view addSubview:v];
    _deliverylisttableview.tag=100;
    [_deliverylisttableview reloadData];
    
}
- (IBAction)dismissview:(id)sender {
    [v removeFromSuperview];
}
- (IBAction)payModeBtnClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
         paymode=@"BA";
            _yueimg.image=[UIImage imageNamed:@"check"];
            _wechatimg.image=[UIImage imageNamed:@""];
        
        }
            break;
        case 2:
        {
            paymode=@"WC";
            _yueimg.image=[UIImage imageNamed:@""];
            _wechatimg.image=[UIImage imageNamed:@"check"];
        }
            break;
        default:
            break;
    }
}
@end
