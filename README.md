
# YPhotoPicker

[![Pod Version](http://img.shields.io/cocoapods/v/YPhotoPicker.svg?style=flat)](http://cocoadocs.org/docsets/YPhotoPicker/)
[![Pod Platform](http://img.shields.io/cocoapods/p/YPhotoPicker.svg?style=flat)](http://cocoadocs.org/docsets/SDWebImage/)

A simple image and video picker for user library.This picker allow multiple selection. 

## Requirements

- iOS 9.0 or later

## Installation

There are four ways to use SDWebImage in your project:

- using CocoaPods
- manual install

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](http://cocoapods.org/#get_started) section for more details.

#### Podfile
```
platform :ios, '9.0'
pod 'YPhotoPicker'
```
#### Manual Install

Drop `YPhotoPicker/Picker` folder to your project and add import `CoreServices.framework` to your project.

## How To Use


Add `NSPhotoLibraryUsageDescription` key to info.plist

* Show picker

```objective-c
#import "YPhotoPickerController.h"
...
YPhotoPickerController *picker = [[YPhotoPickerController alloc] init];
picker.delegate = self;
picker.maxCount = 3;
picker.allowMultipleSelection = YES;
picker.mediaType = YPhotoPickerMediaTypeAll;
[self presentViewController:picker animated:YES completion:^{
}];
```

* Add delegate

```objective-c
#pragma mark - YPhotoPickerControllerDelegate

- (void)photoPickerControllerDidCancel:(YPhotoPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)photoPickerController:(YPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray<NSDictionary<YPhotoPickerControllerInfoKey,id> *> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@", picker);
    }];
}
```

* YPhotoPickerControllerInfoKey

key		                                 | class              | mark
---	|---| ---
YPhotoPickerControllerOriginalImage		| UIImage            | object of the selected image
YPhotoPickerControllerMediaURL			| NSURL              | file path for video file
YPhotoPickerControllerMediaType		   	| NSString           | media type of select object(`kUTTypeImage`,`kUTTypeVideo`)
YPhotoPickerControllerImageOrientation 	| UIImageOrientation | image orientation

* YPhotoPickerMediaType

key									| mark
---	|---
YPhotoPickerMediaTypeAll		| show all
YPhotoPickerMediaTypePhotos	| only images
YPhotoPickerMediaTypeVideos	| only videos

## Licenses

All source code is licensed under the [MIT License](https://raw.githubusercontent.com/mmk982380365/YPhotoPicker/master/LICENSE).


## Author
- [Yuuki](https://github.com/mmk982380365)







