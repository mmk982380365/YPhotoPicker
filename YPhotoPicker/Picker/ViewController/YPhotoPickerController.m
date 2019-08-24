//
//  YPhotoPickerController.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoPickerController.h"
#import "YPhotoAlbumListViewController.h"
#import "YPhotoPickerController+Private.h"
#import "YProgressHUD.h"
#import <CoreServices/CoreServices.h>

YPhotoPickerControllerInfoKey const YPhotoPickerControllerOriginalImage = @"YPhotoPickerControllerOriginalImage";
YPhotoPickerControllerInfoKey const YPhotoPickerControllerMediaURL = @"YPhotoPickerControllerMediaURL";
YPhotoPickerControllerInfoKey const YPhotoPickerControllerMediaType = @"YPhotoPickerControllerMediaType";
YPhotoPickerControllerInfoKey const YPhotoPickerControllerImageOrientation = @"YPhotoPickerControllerImageOrientation";

@interface YPhotoPickerController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic, readwrite) YPhotoPickerManager *manager;

@property (strong, nonatomic) dispatch_queue_t exportQueue;

@property (strong, nonatomic) dispatch_source_t timer;

@property (strong, nonatomic) AVAssetExportSession *currentExportSession;

@property (assign, nonatomic) NSInteger currentIndex;

@property (assign, nonatomic) NSInteger totalVideoIndex;

@property (strong, nonatomic) YProgressHUD *hud;

@end

@implementation YPhotoPickerController
@synthesize delegate = _delegate;

- (void)dealloc
{
    NSLog(@"Class %@ dealloc", NSStringFromClass(self.class));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        YPhotoAlbumListViewController *vc = [[YPhotoAlbumListViewController alloc] init];
        self.viewControllers = @[vc];
        
        self.manager = [[YPhotoPickerManager alloc] init];
        self.allowMultipleSelection = YES;

        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hud = [[YProgressHUD alloc] init];
    [self.view addSubview:self.hud];
    
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.navigationBar.tintColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            switch (traitCollection.userInterfaceStyle) {
            case UIUserInterfaceStyleDark:
                return UIColorFromRGB(0xFFFFFF);
                break;
                
            default:
                return UIColorFromRGB(0x333333);
                break;
            }
        }];
    } else {
        self.navigationBar.tintColor = UIColorFromRGB(0x333333);
    }
    
#else
    self.navigationBar.tintColor = UIColorFromRGB(0x333333);
#endif
    self.interactivePopGestureRecognizer.delegate = self;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.hud];
}

- (void)showExportLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"index = %ld", self.currentIndex);
        self.hud.mode = YProgressHUDModeProgress;
        [self.hud showWithAnimated:YES];
        [self.view bringSubviewToFront:self.hud];
        
        [self.hud setLabelText:@"正在导入项目"];
        
        [self.hud setLabelDetailText:[NSString stringWithFormat:@"%td/%td %.1f%%", self.currentIndex + 1, self.totalVideoIndex, self.currentIndex * (1.0/ self.totalVideoIndex) * 100]];
        
    });
}

- (void)showLoading {
    self.hud.mode = YProgressHUDModeIndicator;
    [self.hud showWithAnimated:YES];
}

- (void)hideLoading {
    [self.hud hideWithAnimated:YES];
}

- (void)addTimer {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (self.currentExportSession) {
            CGFloat progress = self.currentExportSession.progress / self.totalVideoIndex + self.currentIndex * (1.0/ self.totalVideoIndex);
            self.hud.progress = progress;
            [self.hud setLabelDetailText:[NSString stringWithFormat:@"%td/%td %.1f%%", self.currentIndex + 1, self.totalVideoIndex, progress * 100]];
        }
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)removeTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)closeViewController {
    if ([self checkDelegateForSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.delegate photoPickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)presentSelectedAssetsWithAlbum:(YPhotoAlbum *)album {
    if ([self checkDelegateForSelector:@selector(photoPickerController:didFinishPickingMediaWithInfo:)]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.currentIndex = 0;
            
            NSMutableArray<NSDictionary<YPhotoPickerControllerInfoKey, id> *> *resultArray = [NSMutableArray arrayWithCapacity:0];
            
            NSArray *selectedAssets = [album.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isSelected = YES"]];
            NSArray *videoAssets = [selectedAssets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"asset.mediaType = %ld", PHAssetMediaTypeVideo]];
            NSArray *imageAssets = [selectedAssets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"asset.mediaType != %ld", PHAssetMediaTypeVideo]];
            self.totalVideoIndex = videoAssets.count;
            
            //Setting Images
            dispatch_group_t group = dispatch_group_create();
            for (YPhotoAsset *asset in imageAssets) {
                dispatch_group_async(group, dispatch_queue_create("get photos", DISPATCH_QUEUE_CONCURRENT), ^{
                    @autoreleasepool {
                        dispatch_semaphore_t flag = dispatch_semaphore_create(0);
                        [self.manager getImageDataWithAsset:asset callback:^(NSData * _Nullable imageData, UIImageOrientation orientation) {
                            NSMutableDictionary<YPhotoPickerControllerInfoKey, id> *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];
                            infoDic[YPhotoPickerControllerOriginalImage] = [UIImage imageWithData:imageData];
                            infoDic[YPhotoPickerControllerMediaType] = (__bridge id _Nullable)(kUTTypeImage);
                            infoDic[YPhotoPickerControllerImageOrientation] = @(orientation);
                            [resultArray addObject:infoDic];
                            dispatch_semaphore_signal(flag);
                        }];
                        dispatch_semaphore_wait(flag, DISPATCH_TIME_FOREVER);
                    }
                });
            }
            
            //Setting Videos
            NSMutableArray *exportSessions = [NSMutableArray arrayWithCapacity:0];
            
            if (self.totalVideoIndex > 0) {
                for (YPhotoAsset *asset in videoAssets) {
                    dispatch_semaphore_t flag = dispatch_semaphore_create(0);
                    [self.manager getVideoWithAsset:asset callback:^(AVAsset * _Nullable videoAsset) {
                        
                        if ([videoAsset isKindOfClass:AVURLAsset.class]) {
                            AVURLAsset *urlAsset = (AVURLAsset *)videoAsset;
                            NSMutableDictionary<YPhotoPickerControllerInfoKey, id> *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];
                            infoDic[YPhotoPickerControllerMediaURL] = urlAsset.URL;
                            infoDic[YPhotoPickerControllerMediaType] = (__bridge id _Nullable)(kUTTypeVideo);
                            [resultArray addObject:infoDic];
                            dispatch_semaphore_signal(flag);
                        } else {
                            if (!self.videoExportPreset) {
                                self.videoExportPreset = AVAssetExportPresetPassthrough;
                            }
                            [self.manager getVideoExportSessionWithAsset:asset exportPreset:self.videoExportPreset callback:^(AVAssetExportSession * _Nullable exportSession) {
                                exportSession.outputFileType = AVFileTypeMPEG4;
                                exportSession.outputURL = [NSURL fileURLWithPath:[self.manager videoPathWithAsset:asset]];
                                [exportSessions addObject:exportSession];
                                dispatch_semaphore_signal(flag);
                            }];
                        }
                        
                        
                    }];
                    dispatch_semaphore_wait(flag, DISPATCH_TIME_FOREVER);
                }
            }
            
            if (exportSessions.count > 0) {
                [self addTimer];
                if (!self.exportQueue) {
                    self.exportQueue = dispatch_queue_create("exporting", DISPATCH_QUEUE_SERIAL);
                }
                for (AVAssetExportSession *exportSession in exportSessions) {
                    dispatch_group_async(group, self.exportQueue, ^{
                        [self showExportLoading];
                        self.currentExportSession = exportSession;
                        dispatch_semaphore_t flag = dispatch_semaphore_create(0);
                        [exportSession exportAsynchronouslyWithCompletionHandler:^{
                            self.currentExportSession = nil;
                            self.currentIndex++;
                            NSMutableDictionary<YPhotoPickerControllerInfoKey, id> *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];
                            infoDic[YPhotoPickerControllerMediaURL] = exportSession.outputURL;
                            infoDic[YPhotoPickerControllerMediaType] = (__bridge id _Nullable)(kUTTypeVideo);
                            [resultArray addObject:infoDic];
                            dispatch_semaphore_signal(flag);
                        }];
                        dispatch_semaphore_wait(flag, DISPATCH_TIME_FOREVER);
                    });
                }
                
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                [self removeTimer];
                [self.delegate photoPickerController:self didFinishPickingMediaWithInfo:resultArray];
            });
            
        });
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.viewControllers.count > 1 ? YES : NO;
}

- (BOOL)checkDelegateForSelector:(SEL)selector {
    return self.delegate && [self.delegate conformsToProtocol:@protocol(YPhotoPickerControllerDelegate)] && [self.delegate respondsToSelector:selector];
}

- (void)setMediaType:(YPhotoPickerMediaType)mediaType {
    self.manager.mediaType = mediaType;
}

- (void)setAllowMultipleSelection:(BOOL)allowMultipleSelection {
    self.manager.allowMultipleSelection = allowMultipleSelection;
}

- (BOOL)allowMultipleSelect {
    return self.manager.allowMultipleSelection;
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
