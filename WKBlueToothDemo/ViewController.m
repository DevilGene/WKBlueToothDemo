//
//  ViewController.m
//  WKBlueToothDemo
//
//  Created by 王珂 on 2020/12/23.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralListView.h"

@interface ViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>

// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 扫描到的服务
@property (nonatomic, strong) CBService *cbService;
// 扫描到的特征
@property (nonatomic, strong) CBCharacteristic *cbCharacteristic;
// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;
// 外设列表
@property (nonatomic, strong) PeripheralListView *peripheralsView;

@property (nonatomic, strong) UILabel *peripheralLabel;
@property (nonatomic, strong) UIButton *serviceBtn;
@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, strong) UIButton *characteristicBtn;
@property (nonatomic, strong) UILabel *characteristicLabel;

@end

@implementation ViewController

- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    
    //建立中心角色
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)initView {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(self.view.frame.size.width / 2.0 - 50, 60, 100, 100);
    label.text = @"蓝牙Demo";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBtn.frame = CGRectMake(self.view.frame.size.width / 2.0 - 50, 180, 100, 50);
    [scanBtn setTitle:@"扫描设备" forState:UIControlStateNormal];
    [scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanBtn.layer.borderWidth = 1;
    scanBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    [scanBtn addTarget:self action:@selector(scanPeripheralClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
    
    UIButton *disConnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    disConnectBtn.frame = CGRectMake(self.view.frame.size.width / 2.0 - 50, self.view.frame.size.height - 100, 100, 50);
    [disConnectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
    [disConnectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    disConnectBtn.layer.borderWidth = 1;
    disConnectBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    [disConnectBtn addTarget:self action:@selector(disConnect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:disConnectBtn];
    
    UILabel *peripheralLabel = [[UILabel alloc] init];
    peripheralLabel.frame = CGRectMake(0, 250, self.view.frame.size.width, 50);
    peripheralLabel.text = @"";
    peripheralLabel.textAlignment = NSTextAlignmentCenter;
    self.peripheralLabel = peripheralLabel;
    [self.view addSubview:peripheralLabel];
    
    UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    serviceBtn.frame = CGRectMake(self.view.frame.size.width / 2.0 - 50, 300, 100, 50);
    [serviceBtn setTitle:@"扫描服务" forState:UIControlStateNormal];
    [serviceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    serviceBtn.layer.borderWidth = 1;
    serviceBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    [serviceBtn addTarget:self action:@selector(serveClick) forControlEvents:UIControlEventTouchUpInside];
    self.serviceBtn = serviceBtn;
    self.serviceBtn.hidden = YES;
    [self.view addSubview:serviceBtn];
    
    UILabel *serviceLabel = [[UILabel alloc] init];
    serviceLabel.frame = CGRectMake(0, 370, self.view.frame.size.width, 50);
    serviceLabel.text = @"";
    serviceLabel.textAlignment = NSTextAlignmentCenter;
    self.serviceLabel = serviceLabel;
    [self.view addSubview:serviceLabel];
    
    UIButton *characteristicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    characteristicBtn.frame = CGRectMake(self.view.frame.size.width / 2.0 - 50, 420, 100, 50);
    [characteristicBtn setTitle:@"扫描特征" forState:UIControlStateNormal];
    [characteristicBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    characteristicBtn.layer.borderWidth = 1;
    characteristicBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    [characteristicBtn addTarget:self action:@selector(characteristicClick) forControlEvents:UIControlEventTouchUpInside];
    self.characteristicBtn = characteristicBtn;
    self.characteristicBtn.hidden = YES;
    [self.view addSubview:characteristicBtn];
    
    UILabel *characteristicLabel = [[UILabel alloc] init];
    characteristicLabel.frame = CGRectMake(0, 490, self.view.frame.size.width, 50);
    characteristicLabel.text = @"";
    characteristicLabel.textAlignment = NSTextAlignmentCenter;
    self.characteristicLabel = characteristicLabel;
    [self.view addSubview:characteristicLabel];
}


#pragma mark - 设备
//扫描设备
- (void)scanPeripheralClick {
    if (self.peripheralState == CBManagerStatePoweredOn){
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

/**
 扫描到设备
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name) {
        NSLog(@"%@",[NSString stringWithFormat:@"发现设备,设备名:%@",peripheral.name]);
        [self.peripherals addObject:peripheral];
        
        if (!self.peripheralsView) {
            self.peripheralsView = [[PeripheralListView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, self.view.frame.size.height - 200)];
            self.peripheralsView.dataArr = self.peripherals;
            [self.view addSubview:self.peripheralsView];
            
            __weak typeof(self) weakSelf = self;
            self.peripheralsView.selectedPeripheralBlock = ^(NSArray * _Nonnull dataArr, NSInteger index) {
                //停止扫描
                [weakSelf.centralManager stopScan];
                
                if ([dataArr[index] isKindOfClass:[CBPeripheral class]]) {
                    CBPeripheral *peripheral = dataArr[index];
                    //连接外设
                    [weakSelf.centralManager connectPeripheral:peripheral options:nil];
                }
                
                [weakSelf.peripheralsView removeFromSuperview];
                weakSelf.peripheralsView = nil;
            };
        }
        
        self.peripheralsView.dataArr = self.peripherals;
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接设备:%@成功",peripheral.name);
    self.serviceBtn.hidden = NO;
    self.peripheralLabel.text = [NSString stringWithFormat:@"已连接设备：%@",peripheral.name];
    self.cbPeripheral = peripheral;
}

/**
 连接失败
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",@"连接失败");
}

/**
 连接断开
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",@"断开连接");
}

#pragma mark - 服务
//扫描服务
- (void)serveClick {
    if (self.cbPeripheral) {
        // 设置设备的代理
        self.cbPeripheral.delegate = self;
        // services:传入nil  代表扫描所有服务
        [self.cbPeripheral discoverServices:nil];
    }
}

/**
 扫描到服务
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务:%@",service.UUID.UUIDString);
    }
    
    if (!self.peripheralsView) {
        self.peripheralsView = [[PeripheralListView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, self.view.frame.size.height - 200)];
        self.peripheralsView.dataArr = peripheral.services;
        [self.view addSubview:self.peripheralsView];
        
        __weak typeof(self) weakSelf = self;
        self.peripheralsView.selectedPeripheralBlock = ^(NSArray * _Nonnull dataArr, NSInteger index) {
            
            if ([dataArr[index] isKindOfClass:[CBService class]]) {
                CBService *service = dataArr[index];
                weakSelf.serviceLabel.text = [NSString stringWithFormat:@"已选择服务：%@",service.UUID.UUIDString];
                weakSelf.cbService = service;
                weakSelf.characteristicBtn.hidden = NO;
            }
            
            [weakSelf.peripheralsView removeFromSuperview];
            weakSelf.peripheralsView = nil;
        };
    }
}

#pragma mark - 特征
//扫描特征
- (void)characteristicClick {
    // 根据服务去扫描特征
    NSLog(@"开始扫描%@服务的特征",self.cbService.UUID.UUIDString);
    [self.cbPeripheral discoverCharacteristics:nil forService:self.cbService];
}

/**
 扫描到对应的特征
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@">>>服务:%@ 的 特征: %@",service.UUID,characteristic.UUID);
        
        //选一个订阅
        if (!self.peripheralsView) {
            self.peripheralsView = [[PeripheralListView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, self.view.frame.size.height - 200)];
            self.peripheralsView.dataArr = service.characteristics;
            [self.view addSubview:self.peripheralsView];
            
            __weak typeof(self) weakSelf = self;
            self.peripheralsView.selectedPeripheralBlock = ^(NSArray * _Nonnull dataArr, NSInteger index) {
                
                if ([dataArr[index] isKindOfClass:[CBCharacteristic class]]) {
                    CBCharacteristic *characteristic = dataArr[index];
                    weakSelf.characteristicLabel.text = [NSString stringWithFormat:@"已选择特征：%@",characteristic.UUID.UUIDString];
                    weakSelf.cbCharacteristic = characteristic;
                    
                    //订阅,实时接收
                    [weakSelf.cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                
                [weakSelf.peripheralsView removeFromSuperview];
                weakSelf.peripheralsView = nil;
            };
        }
    }
}

/**
 根据特征读到数据
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
//    NSData *data = characteristic.value;
    //    NSLog(@"%@",data);
    //接收蓝牙发来的数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
}

#pragma mark - 状态
//断开连接
- (void)disConnect{
    [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
}

// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"为知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
            NSLog(@"%ld",(long)self.peripheralState);
        }
            break;
        default:
            break;
    }
}

@end
