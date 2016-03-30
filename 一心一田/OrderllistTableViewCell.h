//
//  OrderllistTableViewCell.h
//  kitchen
//
//  Created by xipin on 15/12/16.
//  Copyright © 2015年 gy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderllistTableViewCell : UITableViewCell
@property (weak,nonatomic)NSString *image;
@property (weak,nonatomic)NSString *name;
@property (weak, nonatomic) IBOutlet UIButton *goodspicBtn;
//卖了多少件
@property (weak,nonatomic)NSString *hasbeensaled;
//规格乘以单价
@property (weak,nonatomic)NSString *specifciandprice;
@property (weak,nonatomic)NSString *toatalmoney;
+ (instancetype)cellWithTableView:(UITableView *)tableview cellwithIndexPath:(NSIndexPath *)indexpath;
@end
