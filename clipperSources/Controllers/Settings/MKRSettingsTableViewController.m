//
//  MKRSettingsTableViewController.m
//  clipper
//
//  Created by Anton Zlotnikov on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSettingsTableViewController.h"
#import "MKRSettingsManager.h"

@interface MKRSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *saveOriginalVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveClippedVideoSwitch;
- (IBAction)saveClippedVideoChange:(id)sender;
- (IBAction)saveOriginalVideoChange:(id)sender;

- (IBAction)closeButtonClick:(id)sender;
@end

@implementation MKRSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.saveOriginalVideoSwitch setOn:[MKRSettingsManager getBoolValueForKey:kMKRSaveOriginalVideoKey]];
    [self.saveClippedVideoSwitch setOn:[MKRSettingsManager getBoolValueForKey:kMKRSaveClippedVideoKey]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveClippedVideoChange:(id)sender {
    [MKRSettingsManager setBoolValue:self.saveClippedVideoSwitch.isOn forKey:kMKRSaveClippedVideoKey];
}

- (IBAction)saveOriginalVideoChange:(id)sender {
    [MKRSettingsManager setBoolValue:self.saveOriginalVideoSwitch.isOn forKey:kMKRSaveOriginalVideoKey];
}

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
