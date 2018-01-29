//
//  CHQueryViewController.m
//  TouchCPlatform
//
//  Created by weiguang on 2017/6/28.
//  Copyright © 2017年 changhong. All rights reserved.
//

#import "CHQueryViewController.h"
#import "CHQueryCell.h"
#import "CHQueryDetailViewController.h"
#import "TCSearch.h"


typedef NS_ENUM(NSInteger, OperationType) {
    searchOperation = 1,
    detailOperation
};

static NSInteger const itemNum = 10.0;

@interface CHQueryViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    int currentPage;
    BOOL isMore;
    int totalPages;
}
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UILabel *placeholderLable;
@property (nonatomic,strong) UITextField *searchField;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UITableView *myTableView;



@end

@implementation CHQueryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setupUI];
    [self setupTableView];
    [self setupRefresh];
    [self querydatalistWithPage:currentPage companyName:@""];
    
    [TCUserManager setToken:_token];
    [TCUserManager setEmployeeNum:[NSNumber numberWithInteger:_employeeNum]];
   
    // 适配iOS 11
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (version >= 11.0) {
        self.myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _myTableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        _myTableView.scrollIndicatorInsets = _myTableView.contentInset;
    }
}


- (void)setupUI{
    currentPage = 1;
    self.dataArray = [NSMutableArray array];
    self.title = @"公司开票信息查询";
    
    UIImage *image = [TCBundleTool getBundleImage:@"IOS_back@2x"];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClicked)];
    
    leftBarBtn.tintColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    self.view.backgroundColor = RGB(0xEF, 0xEF, 0xEF);
    
    [self.view addSubview:self.searchBar];
    
}

- (void)setupRefresh{
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.myTableView.mj_header = header;
    self.myTableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatas)];
    self.myTableView.mj_footer.automaticallyHidden = YES;
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)refreshData {
    [self querydatalistWithPage:currentPage companyName:[self filterWhitespace:_searchBar.text]];
    
}

#pragma mark - refreshTable
// 创建tableView
- (void)setupTableView{
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame) + 13, SCREEN_WIDTH, SCREEN_HEIGHT - 120) style:UITableViewStylePlain];
    
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.tableFooterView = [UIView new];
    _myTableView.rowHeight = 65;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.myTableView];
}


- (void)querydatalistWithPage:(int)pageNum companyName:(NSString *)companyName{
   
    isMore = NO;
    [TCSearch queryCompanylist:companyName pageSize:itemNum currentPage:currentPage token:_token completeHandler:^(NSDictionary *responseObject, NSError *error) {
        
        //结束刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            
        });
        
        if (error != nil) {
            NSLog(@"%@",responseObject[@"reason"]);
            return;
        }
        
        if ([responseObject[@"code"] integerValue] == 1 || [responseObject[@"code"] integerValue] == 999) {
            return;
        }
        
        NSDictionary *dict = responseObject;
        
        int totalPageCount = [[dict objectForKey:@"totalPages"] intValue];
        totalPages = totalPageCount;
        if (totalPageCount > pageNum) {
            isMore = YES;
        }else {
            isMore = NO;
        }
        if (pageNum == 1) {
            [_dataArray removeAllObjects];
        }
        
        NSArray *tempArray = [dict objectForKey:@"content"];
        if (tempArray.count > 0) {
            [_dataArray addObjectsFromArray:tempArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTableView reloadData];
        });
        
    }];
    
}

- (void)loadMoreDatas{
    // 结束下拉
    [self.myTableView.mj_header endRefreshing];
    if (isMore) {
        currentPage++;
        [self querydatalistWithPage:currentPage companyName:[self filterWhitespace:_searchBar.text]];
    }else{
        [self.myTableView.mj_footer endRefreshingWithNoMoreData];
        
    }
}


- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(15, 77, SCREEN_WIDTH - 30, 30)];
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.delegate = self;
        
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        if (searchField) {
            searchField.layer.cornerRadius = 5;
            searchField.layer.borderWidth = 1;
            searchField.layer.borderColor = RGB(205, 205, 205).CGColor;
            searchField.layer.masksToBounds = YES;

            [searchField setLeftViewMode:UITextFieldViewModeNever];
            
        }
        self.searchField = searchField;
        
        //自定义placeholder text
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(50, 0, 180, 28);
        label.text = @"请输入关键字";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = RGB(0x99, 0x99, 0x99);
        [_searchBar addSubview:label];
        self.placeholderLable = label;
        
        UIImage *image = [TCBundleTool getBundleImage:@"sousuo@2x"];
        UIImageView *iView = [[UIImageView alloc] initWithImage:image];
        iView.frame = CGRectMake(20, 6, image.size.width , image.size.height);
        [_searchBar addSubview:iView];
        _searchBar.searchTextPositionAdjustment = UIOffsetMake(33, 0);
        
    }
    return _searchBar;
}

//统计详情
- (void)searchTextStatistics:(NSString *)content opreation:(OperationType)opreation{
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/invoice/log",BaseUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    request.allHTTPHeaderFields = @{@"Content-Type" : @"application/json",
                                    @"X-CH-TouchC-Token" : _token,
                                    @"X-CH-TouchC-OS" : @"ios"};
    request.HTTPMethod = @"POST";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(_employeeNum) forKey:@"userId"];  
    [params setValue:@(opreation) forKey:@"operation"];
    [params setValue:content forKey:@"content"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    [request setHTTPBody:data];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"%@",error.localizedDescription);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode != 200) {
                NSLog(@"统计失败");
                return;
            }
        }
        NSLog(@"统计成功: %@",content);
        
    }];
    
    [task resume];
}


#pragma  mark ---TableView delegate--
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    static NSString *identify = @"cell";

    CHQueryCell *cell = (CHQueryCell *)[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[CHQueryCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identify];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *separtor = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height - 1, SCREEN_WIDTH, 1)];
        separtor.backgroundColor = UIColorFromRGB(0xF5F5F5);
        [cell.contentView addSubview:separtor];
        
    }
    NSDictionary *dict = self.dataArray[indexPath.row];
    NSString *companyName = dict[@"companyName"];
    
    // 关键字高亮显示
    NSRange range = [companyName rangeOfString:[self filterWhitespace:_searchBar.text]];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:companyName];
    
    //设置标签文字属性
    [attributeString setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:range];
    cell.lab.attributedText = attributeString;
    
    // 显示或隐藏footer
    if (currentPage >= totalPages) {
        self.myTableView.mj_footer.hidden = YES;
    } else{
        self.myTableView.mj_footer.hidden = NO;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataArray[indexPath.row];
    [self searchTextStatistics:dict[@"companyName"] opreation:detailOperation];
    CHQueryDetailViewController *detailVC = [[CHQueryDetailViewController alloc] init];
    detailVC.infoDict = dict;
    [self.navigationController pushViewController:detailVC animated:YES];
}


- (void) leftBarBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark searchBar 代理
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.placeholderLable.hidden = self.searchField.hasText;

    [self querydatalistWithPage:currentPage companyName:[self filterWhitespace:searchBar.text]];

    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];

    [self querydatalistWithPage:currentPage companyName:[self filterWhitespace:searchBar.text]];
    
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.placeholderLable.hidden = YES;
    currentPage = 1;
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

//过滤空格
- (NSString *)filterWhitespace:(NSString *)str{
    //过滤字符串前后的空格
    NSString *urlStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //过滤中间空格
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return urlStr;
}


@end
