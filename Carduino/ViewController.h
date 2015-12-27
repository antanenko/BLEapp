//
//  ViewController.h
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//
// test change for commit

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBPeripheralDelegate, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableDictionary *devices;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (readonly, nonatomic) CFUUIDRef UUID;
@property (strong, nonatomic) CBCharacteristic *characteristics;
@property (strong, nonatomic) NSMutableData *data;


@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (strong, nonatomic) IBOutlet UIView *devicesView;
@property (strong, nonatomic) IBOutlet UILabel *RSSI;
@property (strong, nonatomic) IBOutlet UILabel *rxDataLabel;

@property (nonatomic, retain) NSString *rxData;
//@property int previousAccelerationSlider;
//@property int counter;

// Timers.
@property (nonatomic, retain) NSTimer *rssiTimer;
@property (nonatomic, retain) NSTimer *rxResponseTimer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//Outlets.
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *steerLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

//Buttons in Devices Table.
@property (strong, nonatomic) IBOutlet UIButton *backFromDevices;
@property (strong, nonatomic) IBOutlet UIButton *test;

//BLE
@property (strong, nonatomic) IBOutlet UIButton *scanForDevices;

// Menu
- (IBAction)menuButtonTouchUp:(id)sender;

- (void)tick;

@property (assign, nonatomic) short int mycmd;

@property (assign, nonatomic) short int tt;

- (IBAction)pressButton:(id)sender;
- (IBAction)pressButtonWave:(id)sender;
- (IBAction)pressButtonVFL:(id)sender;
- (IBAction)pressButtonDBm:(id)sender;
- (IBAction)changeBackLight:(id)sender;
- (IBAction)pressButtonOff:(id)sender;

- (void)sendValue;
- (void)sendCmd:(char) cmd;


@end

//Holds steering slider value as an integer.
//short int steeringValue;

//Holds acceleration slider value as an integer.
//short int accelerationValue;


//int counter;
