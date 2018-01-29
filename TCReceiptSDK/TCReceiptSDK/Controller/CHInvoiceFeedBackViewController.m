//
//  CHInvoiceFeedBackViewController.m
//  TouchCPlatform
//
//  Created by weiguang on 2017/6/30.
//  Copyright © 2017年 changhong. All rights reserved.
//

#import "CHInvoiceFeedBackViewController.h"
#import "TCRequestManager.h"

@interface CHInvoiceFeedBackViewController ()<UITextViewDelegate>
{
    BOOL textHasCut;
    int cutIndex;
    UILabel *placeholderLab;
}
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBackView;

@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *IDNum;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *openBank;
@property (weak, nonatomic) IBOutlet UILabel *bankAccount;

@end

@implementation CHInvoiceFeedBackViewController

- (void)loadView {
    
    [super loadView];
    self.view = [[[TCBundleTool getBundle] loadNibNamed:@"CHInvoiceFeedBackViewController" owner:self options:nil] lastObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"意见反馈";
    
    [self setupUI];
    [self setupDetailInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)setupUI{
    UIImage *image = [TCBundleTool getBundleImage:@"IOS_back@2x"];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClicked)];
    
    leftBarBtn.tintColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    self.view.backgroundColor = RGB(0xEF, 0xEF, 0xEF);
    
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(sendBtnClicked)];
    sendBtn.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = sendBtn;
    


    // _inputTextView.placeholder = @"请输入意见反馈（100字以内）";
    _inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _inputTextView.layer.borderWidth = 1;
    _inputTextView.layer.cornerRadius = 5;
    _inputTextView.delegate = self;
    //
    placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    placeholderLab.text = @"请输入意见反馈（100字以内）";
    placeholderLab.textColor = [UIColor lightGrayColor];
    placeholderLab.backgroundColor = [UIColor clearColor];
    placeholderLab.font = [UIFont systemFontOfSize:14];
    [_inputTextView addSubview:placeholderLab];
    
    _infoView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _infoView.layer.borderWidth = 1;
    _infoView.layer.cornerRadius = 5;
}

- (void)setupDetailInfo{
    
    _companyName.text = [NSString stringWithFormat:@"名称：%@",_infoDict[@"companyName"]];
    _IDNum.text = [NSString stringWithFormat:@"税号：%@",_infoDict[@"identifyNum"]];
    _address.text = [NSString stringWithFormat:@"单位地址：%@",_infoDict[@"companyAddress"]];
    _phone.text = [NSString stringWithFormat:@"电话号码：%@",_infoDict[@"telephone"]];
    _openBank.text = [NSString stringWithFormat:@"开户银行：%@",_infoDict[@"openBank"]];
    _bankAccount.text = [NSString stringWithFormat:@"银行账号：%@",_infoDict[@"bankAccount"]];
    
}

- (void)keyboardChange:(NSNotification *)note {
    NSDictionary *dict = note.userInfo;
    
    CGRect endframe = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endframe.origin.y;
    
    if (y == SCREEN_HEIGHT) {
        _constraintBackView.constant = 0;
        
    } else{
        _constraintBackView.constant = 100;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (void)leftBarBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendBtnClicked
{
    if (_inputTextView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入反馈意见"];
        return;
    }
    
    NSString *content = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,意见：%@",_companyName.text,_IDNum.text,_address.text,_phone.text,_openBank.text,_bankAccount.text,_inputTextView.text];
    [SVProgressHUD showWithStatus:@"提交中..."];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithLong:[TCUserManager getEmployeeNum]] forKey:@"employeeNumber"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:@"IOS" forKey:@"source"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/feedback",BaseUrl];

    [[TCRequestManager sharedManager] postPath:urlStr token:[TCUserManager getToken] paramters:parameters completeHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"提交失败"];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           [SVProgressHUD showSuccessWithStatus:@"提交成功"];
            [self leftBarBtnClicked];
        });
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.inputTextView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    placeholderLab.hidden = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    placeholderLab.hidden = textView.text.length != 0;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        NSString *toBeString = textView.text;
        int totalLen = 0;
        for (int i = 0; i<toBeString.length; i++) {
            //截取字符串中的每一个字符
            totalLen++;
            if (totalLen >= 100) {
                [SVProgressHUD showErrorWithStatus:@"输入字符不能超过100个"];
                if (!textHasCut) {
                    cutIndex = i;
                    textHasCut = YES;
                }
                textView.text = [toBeString substringToIndex:cutIndex+1];
                return;
            }
            textHasCut = NO;
        }
    }
    
}



@end
