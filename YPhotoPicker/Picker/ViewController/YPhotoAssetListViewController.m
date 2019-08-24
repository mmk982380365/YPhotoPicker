//
//  YPhotoAssetListViewController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAssetListViewController.h"
#import "YPhotoAssetListCell.h"
#import "YPhotoAssetListToolView.h"
#import "YPhotoAssetDetailViewController.h"

@interface YPhotoAssetListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, YPhotoAssetListCellDelegate>

@property (strong, nonatomic) UIBarButtonItem *cancelItem;

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YPhotoAssetListToolView *toolView;

@property (nonatomic,assign) BOOL isPop;

@end

@implementation YPhotoAssetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.album.title;
    
    self.cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAct:)];
    self.navigationItem.rightBarButtonItem = self.cancelItem;
    
    CGFloat margin = 5;
    CGFloat column = 3;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - margin * (column + 1)) / column;
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize = CGSizeMake(width, width);
    self.layout.minimumLineSpacing = margin;
    self.layout.minimumInteritemSpacing = margin;
    self.layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:YPhotoAssetListCell.class forCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetListCell.class)];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.navigationController.manager.allowMultipleSelection) {
        self.toolView = [[YPhotoAssetListToolView alloc] initWithStyle:YPhotoAssetListToolViewStyleWhite];
        [self.view addSubview:self.toolView];
        [self.toolView.confirmBtn addTarget:self action:@selector(confirmAct:) forControlEvents:UIControlEventTouchUpInside];
        self.toolView.confirmBtn.enabled = NO;
        self.toolView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.collectionView.bottomAnchor constraintEqualToAnchor:self.toolView.topAnchor],
                                                  [self.toolView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                                  [self.toolView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                                  [self.toolView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                                  ]];
        
    } else {
        if (@available(iOS 11.0, *)) {
            [NSLayoutConstraint activateConstraints:@[
                                                      [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                                      ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                                                      [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                                      ]];
        }
    }
    
    
    
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor]
                                                  ]];
    } else {
        // Fallback on earlier versions
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.collectionView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor]
                                                  ]];
    }
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              ]];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.album.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    });
}

- (void)cancelAct:(UIBarButtonItem *)btn {
    [self.navigationController closeViewController];
}

- (void)confirmAct:(UIButton *)btn {
    NSInteger selectedCount = [[self.album.assets valueForKeyPath:@"@sum.isSelected"] integerValue];
    if (selectedCount > 0) {
        [self.navigationController presentSelectedAssetsWithAlbum:self.album];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isPop = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;//获取当前的视图控制其
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        //当前视图控制器在栈中，故为push操作
        self.isPop = NO;
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        //当前视图控制器不在栈中，故为pop操作
        self.isPop = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isPop) {
        [self.album.assets setValue:@(NO) forKey:@"isSelected"];
    }
}

#pragma mark - YPhotoAssetListCellDelegate

- (void)cellDidSelectAsset:(YPhotoAsset *)asset {
    if (!asset.isSelected) {
        self.toolView.confirmBtn.enabled = YES;
        if (self.navigationController.maxCount == 0) {
            //不限
             asset.isSelected = YES;
        } else {
            NSInteger selectedCount = [[self.album.assets valueForKeyPath:@"@sum.isSelected"] integerValue];
            if (selectedCount < self.navigationController.maxCount) {
                asset.isSelected = YES;
            } else {
                //show alert
                NSString *hint = [NSString stringWithFormat:@"您最多可以选择%td张图片。", self.navigationController.maxCount];
                [self showHint:hint];
            }
        }
    } else {
        asset.isSelected = NO;
        NSInteger selectedCount = [[self.album.assets valueForKeyPath:@"@sum.isSelected"] integerValue];
        if (selectedCount == 0) {
            self.toolView.confirmBtn.enabled = NO;
        } else {
            self.toolView.confirmBtn.enabled = YES;
        }
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YPhotoAssetListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(YPhotoAssetListCell.class) forIndexPath:indexPath];
    cell.manager = self.navigationController.manager;
    YPhotoAsset *asset = self.album.assets[indexPath.item];
    cell.asset = asset;
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.album.assets.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    YPhotoAsset *asset = self.album.assets[indexPath.item];
//    if (asset.asset.mediaType == PHAssetMediaTypeVideo) {
//        YPhotoVideoDetailViewController *vc = [[YPhotoVideoDetailViewController alloc] init];
//        vc.asset = asset;
//        [self.navigationController pushViewController:vc animated:YES];
//    } else {
        YPhotoAssetDetailViewController *vc = [[YPhotoAssetDetailViewController alloc] init];
        vc.album = self.album;
        vc.selectedIndex = indexPath.item;
        [self.navigationController pushViewController:vc animated:YES];
//    }
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
