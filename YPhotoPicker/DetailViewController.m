//
//  DetailViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/24.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "DetailViewController.h"
#import "YPhotoPickerController.h"
#import "DetailImageCell.h"
#import "DetailVideoCell.h"
#import <CoreServices/CoreServices.h>

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    NSString *mediaType = info[YPhotoPickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //image
        DetailImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DetailImageCell.class) forIndexPath:indexPath];
        UIImage *image = info[YPhotoPickerControllerOriginalImage];
        [cell setDetailImage:image];
        return cell;
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeVideo]) {
        //video
        DetailVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DetailVideoCell.class) forIndexPath:indexPath];
        NSURL *path = info[YPhotoPickerControllerMediaURL];
        [cell setVideoPath:path];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    NSString *mediaType = info[YPhotoPickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[YPhotoPickerControllerOriginalImage];
        CGSize size = image.size;
        CGFloat aspect = size.height / size.width;
        CGFloat width = self.view.frame.size.width - 10;
        CGFloat height = width * aspect + 10;
        return height;
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeVideo]) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * (9.0 / 16.0);
        return height;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
