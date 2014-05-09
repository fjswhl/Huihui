//
//  LINCompleteProfileTableViewController.m
//  Huihui
//
//  Created by Lin on 14-5-6.
//  Copyright (c) 2014年 Lin. All rights reserved.
//
#import "UIButton+Color.h"
#import "UIColor+LINColor.h"
#import "LINCompleteProfileTableViewController.h"
#import "LINRootVC.h"
#import "LINMeVC.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MKNetworkKit.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#define ORIGINAL_MAX_WIDTH 640.0f


NSString *const __apiCompleteProfile = @"index.php/User/completeProfile";

@interface LINCompleteProfileTableViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (strong, nonatomic) IBOutlet UITextField *inputUserNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *title_1;
@property (strong, nonatomic) IBOutlet UILabel *title_3;
@property (strong, nonatomic) IBOutlet UIView *title_4;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

/*              3个宿舍信息的TextField            */
@property (strong, nonatomic) IBOutlet UITextField *louhaoTextField;
@property (strong, nonatomic) IBOutlet UITextField *quhaoTextField;
@property (strong, nonatomic) IBOutlet UITextField *sushehaoTextField;



@property (strong, nonatomic) IBOutlet UILabel *school;
@property (strong, nonatomic) IBOutlet UITextField *hometownTextField;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;


/*          图片保存相关      */
@property (strong, nonatomic) NSString *savedImagePath;
@property (nonatomic) BOOL avatarUpdated;
@end

@implementation LINCompleteProfileTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.avatarImageView.image = [UIImage imageNamed:@"placeholder.png"];
    

   // [self.logoutButton setBackgroundImageWithColor:[UIColor preferredColor]];
    [self.logoutButton.layer setCornerRadius:6];
    [self.logoutButton.layer setBorderWidth:1.0f];
    [self.logoutButton.layer setBorderColor:[UIColor preferredColor].CGColor];
    
    if (self.userInfo) {
        if (![self.userInfo[@"building"] isEqualToString:@"0"] && ![self.userInfo[@"buildingarea"] isEqualToString:@"0"]  && ![self.userInfo[@"houseid"] isEqualToString:@"0"]) {
            self.louhaoTextField.text = self.userInfo[@"building"];
            self.quhaoTextField.text = self.userInfo[@"buildingarea"];
            self.sushehaoTextField.text = self.userInfo[@"houseid"];
        }
        

        [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.userInfo[@"pic"]]];
        
        NSNumber *schoolid = self.userInfo[@"schoolid"];
        if ([schoolid integerValue] == 1) {
            self.school.text = @"西电新校区";
        }else if([schoolid integerValue] == 2){
            self.school.text = @"西电老校区";
        }
        self.school.tag = [schoolid integerValue];
        
        NSString *userName = self.userInfo[@"username"];
        if (![userName isEqualToString:@""]) {
            self.inputUserNameTextField.text = userName;
        }
        
        NSString *hometown = self.userInfo[@"hometown"];
        if (![hometown isEqualToString:@""]) {
            self.hometownTextField.text = hometown;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Getter

- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView.layer.borderWidth != 2.0f) {
        [_avatarImageView.layer setCornerRadius:(_avatarImageView.frame.size.height/2)];
        [_avatarImageView.layer setMasksToBounds:YES];
        [_avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_avatarImageView setClipsToBounds:YES];
        _avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _avatarImageView.layer.borderWidth = 2.0f;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
        [_avatarImageView addGestureRecognizer:tapGesture];
    }
    return _avatarImageView;
}

- (NSString *)savedImagePath{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savedImagePath = [docPath stringByAppendingPathComponent:@"avatar.png"];
    return savedImagePath;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"西电新校区",@"西电老校区", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.rightBarButton.enabled == NO) {
        [self.rightBarButton setEnabled:YES];
    }
}


#pragma mark -
- (IBAction)logout:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认注销吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}


- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    choiceSheet.tag = 2;
    [choiceSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"%i", buttonIndex);
    if (actionSheet.tag == 0) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            self.school.text = [actionSheet buttonTitleAtIndex:buttonIndex];
            self.school.tag = buttonIndex + 1; /*       暂时用作post时的schoolid      */
            if (self.rightBarButton.enabled == NO) {
                [self.rightBarButton setEnabled:YES];
            }
        }


    }else if (actionSheet.tag == 1){
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
            [rootVC setLogged:NO];
            [self.navigationController popViewControllerAnimated:YES];
            NSInteger index = [[self.navigationController viewControllers] indexOfObject:self] - 1;
            LINMeVC *meVC = [[self.navigationController viewControllers] objectAtIndex:index];
            [meVC updateUIWhenLoginOrOut];
        }
    }else if (actionSheet.tag == 2){
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }

    }

}


- (NSMutableDictionary *)dicForPost{

    
    NSMutableDictionary *result = [@{@"schoolid": @(self.school.tag),
             @"building": self.louhaoTextField.text,
             @"buildingarea": self.quhaoTextField.text,
             @"houseid": self.sushehaoTextField.text,
                               } mutableCopy];
    
    if (![self.inputUserNameTextField.text isEqualToString:@""]) {
        [result setValue:self.inputUserNameTextField.text forKey:@"username"];
    }
    if (![self.hometownTextField.text isEqualToString:@""]) {
        [result setValue:self.hometownTextField.text forKey:@"hometown"];
    }
    return result;
}

- (IBAction)postProfile:(id)sender {
    if (self.school.tag == 0 || [self.louhaoTextField.text length] == 0 || [self.quhaoTextField.text length] == 0 || [self.sushehaoTextField.text length] == 0) {
        [MBProgressHUD showTextHudToView:self.view text:@"带*号的是必填项"];
        
        return;
    }
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.mode = MBProgressHUDModeIndeterminate;
    hud1.labelText = @"正在上传...";
    hud1.animationType = MBProgressHUDAnimationZoomOut;
    MKNetworkOperation *op = [self.engine operationWithPath:__apiCompleteProfile params:[self dicForPost] httpMethod:@"POST"];
    
    if (self.avatarUpdated) {
        [op addFile:self.savedImagePath forKey:@"pic"];
    }
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        self.avatarUpdated = NO;
        [hud1 hide:YES];
        
        [MBProgressHUD showTextHudToView:self.view text:@"个人资料已更新"];
        double delayInSeconds = 1.6;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
            NSInteger index = [[self.navigationController viewControllers] indexOfObject:self] - 1;
            LINMeVC *meVC = [[self.navigationController viewControllers] objectAtIndex:index];
            [meVC updateUIWhenLoginOrOut];
        });
        

        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.avatarImageView.image = editedImage;
    /*      保存图片到本地         */
    NSData *imageData = UIImagePNGRepresentation(editedImage);
    [imageData writeToFile:self.savedImagePath atomically:YES];
    self.avatarUpdated = YES;
    if (self.rightBarButton.enabled == NO) {
        [self.rightBarButton setEnabled:YES];
    }
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}
#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}



@end
