//
//  peripheralListView.h
//  WKBlueToothDemo
//
//  Created by 王珂 on 2020/12/23.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectedPeripheralBlock)(NSArray *dataArr, NSInteger index);

@interface PeripheralListView : UIView

@property (nonatomic, copy) NSArray *dataArr;

@property (nonatomic, copy) SelectedPeripheralBlock selectedPeripheralBlock;

@end

NS_ASSUME_NONNULL_END
