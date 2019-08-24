//
//  NextViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/24.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "NextViewController.h"
#import "YPhotoPickerController.h"
#import "DetailViewController.h"

@interface NextViewController () <YPhotoPickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *maxCountTextField;

@property (weak, nonatomic) IBOutlet UISwitch *allowMultipleSelectionSwitch;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%ld", self.type);
}

- (IBAction)showPicker:(id)sender {
    NSInteger maxCount = self.maxCountTextField.text.integerValue;
    BOOL allowMultipleSelection = self.allowMultipleSelectionSwitch.isOn;
    YPhotoPickerController *picker = [[YPhotoPickerController alloc] init];
    picker.maxCount = maxCount;
    picker.allowMultipleSelection = allowMultipleSelection;
    picker.mediaType = self.type;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark - YPhotoPickerControllerDelegate

- (void)photoPickerControllerDidCancel:(YPhotoPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)photoPickerController:(YPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray<NSDictionary<YPhotoPickerControllerInfoKey,id> *> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass(DetailViewController.class)];
        vc.dataArray = info;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
