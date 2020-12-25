//
//  peripheralListView.m
//  WKBlueToothDemo
//
//  Created by 王珂 on 2020/12/23.
//

#import "PeripheralListView.h"


@interface  PeripheralListView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation PeripheralListView

- (void)setDataArr:(NSArray *)dataArr {
    _dataArr = dataArr;
    [self.tableView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 1;
        [self initView];
    }
    return self;
}

- (void)initView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    self.tableView = tableView;
    [self addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    if ([self.dataArr[indexPath.row] isKindOfClass:[CBPeripheral class]]) {
        CBPeripheral *peripheral = self.dataArr[indexPath.row];
        cell.textLabel.text = peripheral.name;
    }
    
    if ([self.dataArr[indexPath.row] isKindOfClass:[CBService class]]) {
        CBService *service = self.dataArr[indexPath.row];
        cell.textLabel.text = service.UUID.UUIDString;
    }
    
    if ([self.dataArr[indexPath.row] isKindOfClass:[CBCharacteristic class]]) {
        CBCharacteristic *characteristic = self.dataArr[indexPath.row];
        cell.textLabel.text = characteristic.UUID.UUIDString;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedPeripheralBlock) {
        self.selectedPeripheralBlock(self.dataArr, indexPath.row);
    }
}

@end
