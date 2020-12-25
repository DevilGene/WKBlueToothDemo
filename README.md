# WKBlueToothDemo
蓝牙的demo ---- OC
使用`CBCentralMannager`模式

---
1.导入CoreBluetooth框架

```
#import <CoreBluetooth/CoreBluetooth.h>
``` 
2.遵守`CBCentralManagerDelegate`,`CBPeripheralDelegate`协议

```
@interface ViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>
```
3.检测蓝牙状态

```
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
```
4.建立中心角色

```
self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
```
5.扫描设备

```
if (self.peripheralState == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
```
6.发现外设

```
/**
 扫描到设备
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",[NSString stringWithFormat:@"发现设备,设备名:%@",peripheral.name]);
}
```
7.连接外设  
&nbsp;&nbsp;7.1连接成功
```
/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接设备:%@成功",peripheral.name);
    [self.centralManager stopScan];
}
```
&nbsp;&nbsp;7.2连接失败
```
/**
 连接失败
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@",@"连接失败");
}
```
&nbsp;&nbsp;7.3连接断开
```
/**
 连接断开
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@",@"断开连接");
}
```
8.扫描外设中的服务
```
// 设置设备的代理
peripheral.delegate = self;
// services:传入nil  代表扫描所有服务
[peripheral discoverServices:nil];
```
&nbsp;&nbsp;8.1发现并获取外设中的服务
```
/**
 扫描到服务
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 遍历所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"服务:%@",service.UUID.UUIDString);
    }
}
```
9.扫描外设对应服务的特征
```
// 根据服务去扫描特征
[peripheral discoverCharacteristics:nil forService:service];
```
&nbsp;&nbsp;9.1发现并获取外设对应服务的特征
```
/**
 扫描到对应的特征
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%@",peripheral);
}
```
&nbsp;&nbsp;9.2给对应特征写数据
```
[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
```
10.订阅特征的通知
```
if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID]){
  [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}
```
&nbsp;&nbsp;10.1根据特征读取数据 `didUpdateValueForCharacteristic`
```
/**
 根据特征读到数据
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if ([characteristic.UUID.UUIDString isEqualToString:kNotifyCharacteristicUUID])
    {
        NSData *data = characteristic.value;
        NSLog(@"%@",data);
    }
}
```
