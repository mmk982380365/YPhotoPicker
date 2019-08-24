//
//  YPhotoBaseController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoBaseController.h"

@interface YPhotoBaseController ()

@end

@implementation YPhotoBaseController

- (void)dealloc
{
    NSLog(@"Class %@ dealloc", NSStringFromClass(self.class));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                switch (traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    return UIColorFromRGB(0x000000);
                    break;
                    
                default:
                    return UIColorFromRGB(0xFFFFFF);
                    break;
                }
            }];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
#else
    self.view.backgroundColor = [UIColor whiteColor];
#endif
}

- (YPhotoPickerController *)navigationController {
    return (YPhotoPickerController *)[super navigationController];
}

- (void)showHint:(NSString *)hint {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:hint preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
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
