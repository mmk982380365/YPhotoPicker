//
//  YPhotoAlbumListViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAlbumListViewController.h"
#import "YPhotoAlbumCell.h"
#import "YPhotoAssetListViewController.h"

@interface YPhotoAlbumListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIBarButtonItem *cancelItem;

@property (assign, nonatomic) BOOL isAlbumLoaded;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation YPhotoAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAct:)];
    self.navigationItem.rightBarButtonItem = self.cancelItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:YPhotoAlbumCell.class forCellReuseIdentifier:NSStringFromClass(YPhotoAlbumCell.class)];
    [self.view addSubview:self.tableView];
    [self.navigationController showLoading];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isAlbumLoaded) {
        self.isAlbumLoaded = YES;
        [self loadData];
    }
}

- (void)loadData {
    
    

    [self.navigationController.manager requestAuthorization:^(BOOL authorized) {
        if (authorized) {
            NSLog(@"success");
            YPhotoPickerManager *manager = self.navigationController.manager;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [manager requestAlbumList:^(NSArray * _Nonnull albums) {
                    NSLog(@"1");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController hideLoading];
                        [self.tableView reloadData];
                    });
                }];
            });
            
        } else {
            NSLog(@"Fail");
            [self.navigationController hideLoading];
        }
    }];
}

- (void)cancelAct:(UIBarButtonItem *)btn {
    [self.navigationController closeViewController];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YPhotoAlbumCell.class) forIndexPath:indexPath];
    YPhotoAlbum *album = self.navigationController.manager.albums[indexPath.row];
    cell.manager = self.navigationController.manager;
    cell.album = album;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.navigationController.manager.albums.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YPhotoAssetListViewController *vc = [[YPhotoAssetListViewController alloc] init];
    vc.album = self.navigationController.manager.albums[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
