//
//  SetCommentTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "SetCommentTableCell.h"
#import "UIImage+Compress.h"
#import "CircleImageView.h"

@interface SetCommentTableCell () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RatingBarDelegate>

@property (nonatomic, strong) SetCommentModel *commentModel;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *imgUrlArray;

@end

@implementation SetCommentTableCell

- (void)setDataWithModel:(SetCommentModel *)model {
    _commentModel = model;
//    _commentDic = [NSMutableDictionary dictionary];
//    [_commentDic setValue:[dic objectForKey:@"id"] forKey:@"orderDetailId"];
//    NSString *userID = [YWUserDefaults objectForKey:@"UserID"];
//    [_commentDic setValue:userID forKey:@"userId"];
//    [_commentDic setValue:@[] forKey:@"files"];
    
//    _commentModel.imageArr = [NSMutableArray array];
//    _commentModel.imageUrlArr = [NSMutableArray arrayWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
    
    _textView.delegate = self;
    
    [_ratingBar setImageDeselected:@"emptyStar" halfSelected:@"halfStar" fullSelected:@"fullStar" andDelegate:self];
    _ratingBar.isIndicator = NO;
    if (model.score) {
        [_ratingBar displayRating:[model.score floatValue]];
    } else {
        [_ratingBar displayRating:5];
    }
    if (model.evaluationContent) {
        _textView.text = model.evaluationContent;
        _placeHoulderLab.hidden = YES;
    } else {
        _textView.text = @"";
        _placeHoulderLab.hidden = NO;
    }
    
    NSString *imgUrl = kAppendUrl(model.goodsImgUrl);
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:kDefaultImage];
    
    
    for (UIView *view in _imageBackView.subviews) {
        view.hidden = YES;
    }
    
    for (int i = 0; i < 5; i ++) {
        
        UIView *backView = [_imageBackView viewWithTag:i + 1000];
        UIImageView *imageView = [backView.subviews firstObject];
        UIButton *deleteBtn = [backView.subviews lastObject];
        
        if (i == 0) {
            imageView.image = [UIImage imageNamed:@"picture_add"];
        }
        
        if (i <= _commentModel.imageArr.count) {
            backView.hidden = NO;
            deleteBtn.hidden = backView.hidden;
            if (i == _commentModel.imageArr.count) {
                deleteBtn.hidden = YES;
            }
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        tapGesture.delegate = self;
        YWWeakSelf;
        [[[tapGesture rac_gestureSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            NSInteger index = x.view.superview.tag - 1000;
            if (index == _commentModel.imageArr.count) {
                [weakSelf addPictureImage];
            } else {
                CircleImageView *circleView = [[CircleImageView alloc] init];
                
                [circleView setImageArray:_commentModel.imageArr andIndex:index];
            }
            
        }];
        [imageView addGestureRecognizer:tapGesture];
        
        [[[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            NSInteger index = x.superview.tag - 1000;
            if (index < 4) {
                UIView *backView = [_imageBackView viewWithTag:i + 1001];
                backView.hidden = YES;
            } else {
                UIView *backView = [_imageBackView viewWithTag:i + 1004];
                UIImageView *imageView = [backView.subviews firstObject];
                UIButton *deleteBtn = [backView.subviews lastObject];
                imageView.image = [UIImage imageNamed:@"picture_add"];
                deleteBtn.hidden = YES;
            }
            
            [weakSelf.commentModel.imageArr removeObjectAtIndex:index];
            [weakSelf.commentModel.imageUrlArr replaceObjectAtIndex:index withObject:@"0"];
            
            [weakSelf updateImageView];
        }];
        
        [self updateImageView];
    }
}

- (void)updateImageView {
    for (int i = 0; i < _commentModel.imageArr.count + 1; i ++) {
        
        UIView *backView = [_imageBackView viewWithTag:i + 1000];
        UIImageView *imageView = [backView.subviews firstObject];
        UIButton *deleteBtn = [backView.subviews lastObject];
        
        backView.hidden = NO;
        deleteBtn.hidden = backView.hidden;
        
        if (i < _commentModel.imageArr.count) {
            imageView.image = _commentModel.imageArr[i];
        }
        if (i == _commentModel.imageArr.count) {
            deleteBtn.hidden = YES;
            imageView.image = [UIImage imageNamed:@"picture_add"];
        }
    }
    
//    NSMutableArray *compeleteURL = [NSMutableArray array];
//    for (NSString *string in _commentModel.imageUrlArr) {
//        if (![string isEqualToString:@"0"]) {
//            [compeleteURL addObject:string];
//        }
//    }
//    [_commentDic setValue:compeleteURL forKey:@"files"];
}

#pragma mark ratingBarDelegate
- (void)ratingBar:(RatingBar *)ratingBar ratingChanged:(float)newRating {
    _commentModel.score = [NSString stringWithFormat:@"%.1f", newRating];

}

#pragma mark TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _placeHoulderLab.hidden = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 200) {
        [SVProgressHUD showErrorWithStatus:@"最多输入200个字符"];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    if (textView.text.length > 200) {
        [SVProgressHUD showErrorWithStatus:@"最多输入200个字符"];
    } else {
        if (textView.text.length == 0) {
            _placeHoulderLab.hidden = NO;
        } else if (textView.text.length > 0) {
            _placeHoulderLab.hidden = YES;
        }
        _codeCountLab.text = [NSString stringWithFormat:@"%ld/200", textView.text.length];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length > 200) {
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length > 200) {
        return;
    } else if (textView.text.length == 0) {
        _placeHoulderLab.hidden = NO;
        [SVProgressHUD showErrorWithStatus:@"请输入评价内容，200字以内"];
    }
    _commentModel.evaluationContent = textView.text;
}

//添加图片
- (void)addPictureImage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            //上面這一行主要是在判斷裝置是否支援此項功能
            NSLog(@"//从相机获取");
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;//允许用户进行编辑
            //picker.cameraViewTransform = CGAffineTransformMakeScale(1.5, 1.5);//全屏的效果，同时
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            //上面這一行主要是在判斷裝置是否支援此項功能
            NSLog(@"//从相册获取");
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate=self;
            //picker.cameraViewTransform = CGAffineTransformMakeRotation(M_PI*45/180);//旋转45度的效果
            picker.allowsEditing=NO;//允许用户进行编辑
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -UIImagePickerController
-(void)imagePickerControllerDIdCancel:(UIImagePickerController*)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *scaleImage;
    if ([mediaType isEqualToString:@"public.image"]){
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        //..现在拍出来一张照片分辨率很大，如果你直接放到内存里就很容易收到内存警告(Received memory warning)，通常的处理方法是拍完照压缩并缩放
        UIImage * compressDImage = [originImage compressedImage];
        NSData * data = UIImageJPEGRepresentation(compressDImage, 0.7);
        //将二进制数据生成UIImage
        scaleImage = [UIImage imageWithData:data];
    }
    
    [_commentModel.imageArr addObject:scaleImage];
    [self updateImageView];
    
    [self uploadImage:scaleImage atIndex:[_commentModel.imageArr indexOfObject:scaleImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    /*
     //获取图片裁剪的图
     UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
     //获取图片裁剪后，剩下的图
     UIImage* crop = [info objectForKey:UIImagePickerControllerCropRect];
     //获取图片的url
     NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
     //获取图片的metadata数据信息
     NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
     //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
     UIImageWriteToSavedPhotosAlbum(edit, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     */
    
}

- (void)uploadImage:(UIImage *)image atIndex:(NSInteger)index {
    
    [_commentModel.imageUrlArr replaceObjectAtIndex:index withObject:@"1"];
    [SVProgressHUD showWithStatus:@"图片正在上传中"];
    [HttpTools UpLoadWithImage:image url:kAppendUrl(YWFileUploadString) filename:nil name:@"file" parameters:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        
    } success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSString *urlstr = [[responseObject objectForKey:@"resultData"] firstObject];
        [_commentModel.imageUrlArr replaceObjectAtIndex:index withObject:urlstr];
    } failure:^(NSError *error) {
        [_commentModel.imageArr removeObjectAtIndex:index];
        [self updateImageView];
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
