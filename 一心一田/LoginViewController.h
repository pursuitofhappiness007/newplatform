//
//  LoginViewController.h
//  广盐健康大厨房
//
//  Created by xipin on 15/11/24.
//  Copyright © 2015年 xipin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (nonatomic,weak)NSString *source;
- (IBAction)loginBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *accounttextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdtextfield;

@end
