//
//  YPhotoAlbum.m
//  YPhotoPicker
//
//  Created by Yuuki on 2019/8/15.
//  Copyright © 2019 Yuuki. All rights reserved.
//

#import "YPhotoAlbum.h"

@implementation YPhotoAlbum

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ -- %ld", self.title, self.assets.count];
}

@end
