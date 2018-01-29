//
//  CHQueryDetailViewController.m
//  TouchCPlatform
//
//  Created by weiguang on 2017/6/29.
//  Copyright © 2017年 changhong. All rights reserved.
//

#import "CHQueryDetailViewController.h"
#import "CHInvoiceFeedBackViewController.h"
#import "TCSearch.h"


@interface CHQueryDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *IDNum;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *openBank;
@property (weak, nonatomic) IBOutlet UILabel *bankAccount;
@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;


@end

@implementation CHQueryDetailViewController

- (void)loadView {
    [super loadView];
    
    self.view = [[[TCBundleTool getBundle] loadNibNamed:@"CHQueryDetailViewController" owner:self options:nil] lastObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发票抬头";
    
    [self setupUI];
    
    [self setupDetailInfo];
    
    [self loadQRImageView];
    
}

- (void)setupUI{
    UIImage *image = [TCBundleTool getBundleImage:@"IOS_back@2x"];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClicked)];
    
    leftBarBtn.tintColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    self.view.backgroundColor = RGB(0xEF, 0xEF, 0xEF);
    
}

- (void)setupDetailInfo{
    
    _companyName.text = [NSString stringWithFormat:@"%@",_infoDict[@"companyName"]];
    _IDNum.text = [NSString stringWithFormat:@"%@",_infoDict[@"identifyNum"]];
    _address.text = [NSString stringWithFormat:@"%@",_infoDict[@"companyAddress"]];
    _phone.text = [NSString stringWithFormat:@"%@",_infoDict[@"telephone"]];
    _openBank.text = [NSString stringWithFormat:@"%@",_infoDict[@"openBank"]];
    _bankAccount.text = [NSString stringWithFormat:@"%@",_infoDict[@"bankAccount"]];
}

- (void)loadQRImageView{
    
    NSString *companyName = [NSString stringWithFormat:@"名称：%@",_infoDict[@"companyName"]];
    NSString *IDNum = [NSString stringWithFormat:@"税号：%@",_infoDict[@"identifyNum"]];
    NSString *address = [NSString stringWithFormat:@"单位地址：%@",_infoDict[@"companyAddress"]];
    NSString *phone = [NSString stringWithFormat:@"电话号码：%@",_infoDict[@"telephone"]];
    NSString *openBank = [NSString stringWithFormat:@"开户银行：%@",_infoDict[@"openBank"]];
    NSString *bankAccount = [NSString stringWithFormat:@"银行账户：%@",_infoDict[@"bankAccount"]];
    
    NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",companyName,IDNum,address,phone,openBank,bankAccount];
    UIImage *QRImage = [TCSearch generateQRCode:content width:200 height:200];
    
    self.QRImageView.image = QRImage;
    
}

- (void) leftBarBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)feedback:(UIButton *)sender {
    CHInvoiceFeedBackViewController *feedbackVC = [[CHInvoiceFeedBackViewController alloc] init];
    feedbackVC.infoDict = self.infoDict;
    
    [self.navigationController pushViewController:feedbackVC animated:YES];
}



@end
