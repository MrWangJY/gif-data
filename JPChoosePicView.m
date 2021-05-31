//
//  JPChoosePicView.m
//  
//
//  Created by Keep丶Dream on 2017/10/18.
//  Copyright © 2017年 dong. All rights reserved.
//

#import "JPChoosePicView.h"
#import "JPPhoto.h"
#import "JPShowBigImageView.h"
#import "JPPhotoAuthor.h"
#import "TZImagePickerController.h"

@interface JPChoosePicView()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,JPPhotoManagerDelegate,TZImagePickerControllerDelegate>
/** addBtn */
@property(nonatomic,weak) UIButton *addBtn;
/** collection */
@property(nonatomic,weak) UICollectionView *collectionView;

@end

@implementation JPChoosePicView
{
    CGFloat _viewWidth;
    CGFloat _itemW;
}

-(NSMutableArray *)imageArray {
    
    if (!_imageArray) {
        
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
-(NSMutableArray *)imageFilePathArray {
    
    if (!_imageFilePathArray) {
        
        _imageFilePathArray = [NSMutableArray array];
    }
    return _imageFilePathArray;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        [self p_SetupUI];
    }
    return self;
}

#pragma mark -UI
- (void)p_SetupUI {
    
    _viewWidth = self.frame.size.width;
    _itemW = (_viewWidth-10*2)/3.0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(_itemW, _itemW);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, self.frame.size.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _itemW, _itemW)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_pic"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(p_AddBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addBtn];
    self.addBtn = addBtn;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    if (cell.subviews.count) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    UIImage *image = (UIImage *)self.imageArray[indexPath.item];
    imageView.image = image;
    [cell.contentView addSubview:imageView];
    
    UIButton *closeImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20)];
    [closeImageBtn setBackgroundImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [closeImageBtn addTarget:self action:@selector(p_CloseImage:) forControlEvents:UIControlEventTouchUpInside];
    closeImageBtn.tag = indexPath.item;
    
    imageView.userInteractionEnabled = YES;
    [imageView addSubview:closeImageBtn];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *image = (UIImage *)self.imageArray[indexPath.item];
    [JPShowBigImageView showBigImageWithImage:image];
}


#pragma mark -changeBtn
- (void)p_ChangeBtnFrame {
    
    NSInteger arrCount = self.imageArray.count;
    
    if (arrCount >= 9) {
        self.addBtn.hidden = YES;
    }else {
        self.addBtn.hidden = NO;
    }
    NSInteger btnX = (_itemW+10)*(arrCount%3);
    NSInteger btnY = (_itemW+10)*(arrCount/3);
    [UIView animateWithDuration:0.3 animations:^{
        self.addBtn.frame = CGRectMake(btnX, btnY, _itemW, _itemW);
    }];
}

#pragma mark -删除
- (void)p_CloseImage:(UIButton *)closeBtn {
    
    [self.collectionView  performBatchUpdates:^ {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:closeBtn.tag inSection:0];
        [self.imageArray removeObjectAtIndex:closeBtn.tag];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self.collectionView  reloadData];
        
    }];
    [self p_ChangeBtnFrame];
}

#pragma mark -p_AddBtnClick
- (void)p_AddBtnClick {
    WeakSelf(self);
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself pushImagePickerController];
        //启动图片选择器
//        [[JPPhotoManager sharedPhotoManager] jp_OpenPhotoListWithController:self.superViewController MaxImageCount:9-self.imageArray.count];
//        //设置代理
//        [JPPhotoManager sharedPhotoManager].delegate = self;
        
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [JPPhotoAuthor checkCameraAuthorSuccess:^{
            UIImagePickerController *cameraCtrl = [[UIImagePickerController alloc] init];
            cameraCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraCtrl.allowsEditing = NO;
            cameraCtrl.delegate = self;
            [self.superViewController  presentViewController:cameraCtrl animated:YES completion:nil];

        } Failure:^(NSString *message) {
            NSLog(@"%@",message);
        }];
    }]];
        
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.superViewController presentViewController:alertCtrl animated:YES completion:nil];
}
/**
 选取手机图片
 */
- (void)pushImagePickerController
{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9-self.imageArray.count delegate:self];
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    // imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    // imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    //     imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    //     imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    //     imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
//    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = YES;
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [self.imageArray addObjectsFromArray:photos];
        [self.imageFilePathArray addObjectsFromArray:photos];
        [self.collectionView reloadData];
        [self p_ChangeBtnFrame];
        //NSLog(@"assets");
    }];
    [imagePickerVc setDidFinishPickingGifImageHandle:^(UIImage *animatedImage, id sourceAssets) {
        NSData *da = UIImagePNGRepresentation(animatedImage);
        __block NSMutableArray *datas = [[NSMutableArray alloc] init];

                // UIImage *thumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                // PHAsset 没有thumbnail 这个方法 用的photos
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{ @"type":@"album", @"thumb":animatedImage, @"isUploaded" : @"0"}];

                NSArray *resourceList = [PHAssetResource assetResourcesForAsset:sourceAssets];
                [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHAssetResource *resource = obj;
                    PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
                    option.networkAccessAllowed = YES;
                    // 首先,需要获取沙盒路径
                    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    // 拼接图片名为resource.originalFilename的路径
                    NSString *imageFilePath = [path stringByAppendingPathComponent:resource.originalFilename];
                    [data setValue:imageFilePath forKey:@"path"];
                    [self.imageArray addObject:animatedImage];
                    [self.imageFilePathArray addObject:imageFilePath];
                    [self.collectionView reloadData];
                    [self p_ChangeBtnFrame];
                }];
    

//        [self.imageArray addObject:animatedImage];
//        [self.collectionView reloadData];
//        [self p_ChangeBtnFrame];
        NSLog(@"");
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.superViewController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageArray addObject:image];
    [self.collectionView reloadData];
    [self p_ChangeBtnFrame];
}
#pragma mark - JPPhotoManagerDelegate
- (void)jp_ImagePickerControllerDidFinishPickingMediaWithThumbImages:(NSArray *)thumbImages originalImages:(NSArray *)originalImages {
    
    [self.imageArray addObjectsFromArray:originalImages];
    [self.collectionView reloadData];
    [self p_ChangeBtnFrame];

}

- (void)jp_ImagePickerControllerDidCancel {
    
}
#pragma mark - gif转data
// 获取gif图片对应的PHAsset之后
// eg:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    // 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
    __block NSMutableArray *datas = [[NSMutableArray alloc] init];
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *innerStop) {
        if (asset) {
            UIImage *thumbnail = photos[index];
            // UIImage *thumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
            // PHAsset 没有thumbnail 这个方法 用的photos
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{ @"type":@"album", @"thumb":thumbnail, @"isUploaded" : @"0"}];

            NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
            [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PHAssetResource *resource = obj;
                PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                // 首先,需要获取沙盒路径
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                // 拼接图片名为resource.originalFilename的路径
                NSString *imageFilePath = [path stringByAppendingPathComponent:resource.originalFilename];
                [data setValue:imageFilePath forKey:@"path"];
                
               NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];

                if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
                    NSLog(@"为gif");

                    __block NSData *datagif = [[NSData alloc]init];
                    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:imageFilePath]  options:option completionHandler:^(NSError * _Nullable error) {
                        if (error) {
                            // NSLog(@"error:%@",error);
                            if(error.code == -1){//文件已存在
                                datagif = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                            }
                            // NSLog(@"datagif%@",datagif);
                            [data setValue:datagif forKey:@"scale_image"];
                            [data setValue:@1 forKey:@"is_gif"];
                        } else {
                            datagif = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath]];
                            // NSLog(@"datagif%@",datagif);
                            [data setValue:datagif forKey:@"scale_image"];
                            [data setValue:@1 forKey:@"is_gif"];
                        }
                    }];
                }else{
                    NSLog(@"jepg");
                    UIImage *originalImage = photos[index];
                    [data setValue:originalImage forKey:@"scale_image"];
                }
                [datas addObject:data];
            }];
        }
    }];

//    if ([datas count] > 0) {
//        DhFeedPublishController *vc = [[DhFeedPublishControlleralloc] init];
//        vc.mDatas = [[NSMutableArray alloc] initWithArray:datas];
//        DhNavigationController *nav = [[DhNavigationControlleralloc] initWithRootViewController:vc];
//        // for ios 7
//        [self presentViewController:nav animated:YEScompletion:nil];
//        [picker dismissViewControllerAnimated:YEScompletion:^(){
//        }];
//    }
}
@end
