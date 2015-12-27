//
//  ViewController.m
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

//  STUFF TO ADD:
// 1. Periodic refresh timer on devices list.  Then, remove "Scan" button.  This will refresh device list for RSSI as well.


#import "ViewController.h"
//#import "CarduinoViewCell.h"
//#import "drawView.h"


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];


    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                    target:self
                                                  selector:@selector(tick)
                                                  userInfo:nil
                                                   repeats:YES];
    
    self.mycmd=0;
    self.tt = 0;
    
    self.devices = [NSMutableDictionary dictionaryWithCapacity:6];
    
    NSLog(@"viewDidLoad run");
    
    
    self.rxDataLabel.numberOfLines = 0;
    self.rxDataLabel.text = @"Test\r\nTest2\r\nTest3\r\nTest4\r\nTest5";
}



- (IBAction)pressButton:(id)sender{
/*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Message1"
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
 */
     [self sendCmd:'r'];
}

- (IBAction)pressButtonWave:(id)sender {
    [self sendCmd:'w'];
}

- (IBAction)pressButtonVFL:(id)sender {
    [self sendCmd:'f'];
}

- (IBAction)pressButtonDBm:(id)sender {
    [self sendCmd:'d'];
}

- (IBAction)changeBackLight:(id)sender {
    [self sendCmd:'b'];
}

- (IBAction)pressButtonOff:(id)sender {
    [self sendCmd:'o'];
}


- (void)tick {
   // NSLog(@"Time tick");
    NSString *tm = [NSString stringWithFormat:@"%d",self.tt];
    
    int a;
    if (self.selectedPeripheral!=nil) {
        a = [ self readRSSI ];
        tm = [NSString stringWithFormat:@"%d",a];
    }
    
    self.RSSI.text = tm;
    self.tt++;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - BLE

////////////////////// Bluetooth Low Energy /////////////////////

- (int)readRSSI
{
    CBPeripheral *thisPer = self.selectedPeripheral;
    [thisPer readRSSI];
    
    int RSSI = [thisPer.RSSI intValue];
    return RSSI;
}


// Make sure iOS BT is on.  Then start scanning.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Bluetooth is off"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        // In case Bluetooth is off.
        return;
        // Need to add code here stating unable to access Bluetooth.
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        //If it's on, scan for devices.
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    NSLog(@"One  -- centralManagerDidUpdateState!!!!");
    //NSLog(@"One");
}


// Report what devices have been found.
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    // Set peripheral.
    self.discoveredPeripheral = peripheral;
    
    // Create a string for the conneceted peripheral.
    NSString * uuid = [[peripheral identifier] UUIDString];
    
    if (uuid) //Make sure we got the UUID.
    {
        //This sets the devices object.peripheral = uuid
        [self.devices setObject:peripheral forKey:uuid];
    }
    
    //Refresh data in the table.
    [self.tableView reloadData];
    
    //NSLog(@"centralManager didDiscoverPeripheral");
    //NSLog(@"Two -- centralManager didDiscoverPeripheral");
}


// Run this whenever we have connected to a device.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    // Set the peripheral delegate.
    peripheral.delegate = self;
    // Set the peripheral method's discoverServices to nil,
    // this searches for all services, its slower but inclusive.
    [peripheral discoverServices:nil];
    
    self.statusLabel.text = @"Connected";
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // Enumerate through all services on the connected peripheral.
    for (CBService * service in [peripheral services])
    {
        // Discover all characteristics for this service.
        [self.selectedPeripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    // Enumerate through all services on the connected peripheral.
    for (CBCharacteristic * character in [service characteristics])
    {
        // Discover all descriptors for each characteristic.
        [self.selectedPeripheral discoverDescriptorsForCharacteristic:character];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    //Store data from the UUID in byte format, save in the bytes variable.
    const char * bytes =[(NSData*)[[characteristic UUID] data] bytes];
    //Check to see if it is two bytes long, and they are FF and E1.
    if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225)
    {
        // Send the peripheral data to the MainViewController.
        self.selectedPeripheral = peripheral;
        for (CBService * service in [_selectedPeripheral services])
        {

            for (CBCharacteristic * characteristic in [service characteristics])
            {
                // For every characteristic on every service, on the connected peripheral
                // set the setNotifyValue to true.
                NSLog(@"%c", bytes[1]);
                
                [self.selectedPeripheral setNotifyValue:true forCharacteristic:characteristic];
            }
        }
    }
}


- (void)sendValue
{
    for (CBService * service in [_selectedPeripheral services])
    {
        for (CBCharacteristic * characteristic in [service characteristics])
        {
 
            NSString *str;
           
            str = self.myTextField.text;
            str = [str stringByAppendingString:@"\r\n"];
            
            // Write the str variable with all our movement data.
            [_selectedPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding]
                          forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
                self.rxData = @" ";
        }
    }
}



- (void)sendCmd:(char) cmd
{
    for (CBService * service in [_selectedPeripheral services])
    {
        for (CBCharacteristic * characteristic in [service characteristics])
        {
            
            unichar myc[6]={'p','m','w','\r','\n'};
            
            myc[2] = cmd;
            
            NSString *str  = [NSString stringWithCharacters:myc length:5];
            
            // Write the str variable with all our movement data.
            [_selectedPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding]
                          forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
            self.rxData = @" ";
        }
    }
}




//// Receive from BLE
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString * str = [[NSString alloc] initWithData:[characteristic value] encoding:NSUTF8StringEncoding];
    self.rxData = [self.rxData stringByAppendingString:str];
    self.rxDataLabel.text = self.rxData;
   
}

////////////////////// Bluetooth Low Energy End //////////////////


#pragma mark textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
    
}


# pragma mark - table controller
////////////////////// Device Table View //////////////////
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.devices count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This gets a sorted array from NSMutableDictionary.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    // Setup a devices instance.
    CBPeripheral * devices = nil;
    
    
    // Go until we run out of devices.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripherals based upon indexPath # from uuids array.
        devices = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
    }
    
    /////////////////////////LOADS CUSTOM CELL/////////////////////////////
    
    // This is a handle for the tableView.
    static NSString * myTableIdentifier = @"myCell";
    
    
    // Get cell objects.;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myTableIdentifier];
    
    
    if(!cell) {
        NSLog(@"Create cell %ld,%ld", indexPath.section,indexPath.row);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myTableIdentifier];
    }

    
    /////////////////////////END/////////////////////////////
    
    // List all the devices in the table view.
    if([indexPath row] < [uuids count]){
        // Don't list a device if there isn't one.
        if (devices)
        {
           cell.textLabel.text = [devices name];
           cell.detailTextLabel.text = [uuids objectAtIndex:[indexPath row]];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a sorted array of the found UUIDs.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];

    // Only get enough devices or listed cells.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripheral based upon the indexPath; uuid being the array.
        _selectedPeripheral = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
        
        // If there is a peripheral.
        if (_selectedPeripheral)
        {
            // Close current connection.
            [_centralManager cancelPeripheralConnection:_selectedPeripheral];
            // Connect to selected peripheral.
            [_centralManager connectPeripheral:_selectedPeripheral options:nil];
            // Hide the devices list.            
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:1.0];
            self.devicesView.alpha = 0;
            [UIView commitAnimations];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  cell.backgroundColor = self.randomColor;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Sets the height for each row to 90, the same size as the custom cell.
    return 50;
}

////////////////////// Device Table View End///////////////









# pragma mark - misc

// Menu button
- (IBAction)menuButtonTouchUp:(id)sender {
    //ViewController * fade = [[ViewController alloc] init];
    //[fade fadeDeviceMenuIn];
    
    // Hide the devices list.
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:1];
    self.devicesView.alpha = 1;
    [UIView commitAnimations];
}

- (IBAction)backFromDevices:(id)sender
{

    // Hide the devices list.
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:1];
    self.devicesView.alpha = 0;
    [UIView commitAnimations];
}

- (IBAction)test:(id)sender
{
    [self sendValue];
    NSLog(@"Devices: %@", self.devices);
    NSLog(@"Count devices=%d", [self.devices count]);
}




@end

