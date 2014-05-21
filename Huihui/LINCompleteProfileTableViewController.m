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
#import "CXAlertView.h"
#import "UIAlertView+Block.h"
#define ORIGINAL_MAX_WIDTH 640.0f


NSString *const __apiCompleteProfile = @"index.php/User/completeProfile";

@interface LINCompleteProfileTableViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

//@property (strong, nonatomic) IBOutlet UITextField *inputUserNameTextField;
//@property (strong, nonatomic) IBOutlet UILabel *title_1;
//@property (strong, nonatomic) IBOutlet UILabel *title_3;
//@property (strong, nonatomic) IBOutlet UIView *title_4;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

///*              3个宿舍信息的TextField            */
//@property (strong, nonatomic) IBOutlet UITextField *louhaoTextField;
//@property (strong, nonatomic) IBOutlet UITextField *quhaoTextField;
//@property (strong, nonatomic) IBOutlet UITextField *sushehaoTextField;



//@property (strong, nonatomic) IBOutlet UILabel *school;
//@property (strong, nonatomic) IBOutlet UITextField *hometownTextField;
//
//@property (strong, nonatomic) IBOutlet UIButton *logoutButton;


/*          图片保存相关      */
@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) NSString *savedImagePath;
@property (nonatomic) BOOL avatarUpdated;
@property (nonatomic) BOOL avatarSetted;


//@property (nonatomic) NSInteger tableViewRows;
@property (nonatomic) BOOL pickerCellShown;

@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSArray *dormitoryNumbers;
@property (strong, nonatomic) NSArray *schools;
@property (strong, nonatomic) NSArray *dormitoryDomains;

@property (strong, nonatomic) NSMutableDictionary *dicForPost;
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
    
    NSLog(@"%@", self.userInfo);
    
    if ([self.userInfo[@"pic"] rangeOfString:@"png"].location != NSNotFound || [self.userInfo[@"pic"] rangeOfString:@"png"].location != NSNotFound) {
        self.avatarSetted = true;
    }
  //  self.tableViewRows = 8;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.avatarImageView.image = [UIImage imageNamed:@"placeholder.png"];
    

   // [self.logoutButton setBackgroundImageWithColor:[UIColor preferredColor]];
//    [self.logoutButton.layer setCornerRadius:6];
//    [self.logoutButton.layer setBorderWidth:1.0f];
//    [self.logoutButton.layer setBorderColor:[UIColor preferredColor].CGColor];
    
//    if (self.userInfo) {
//        if (![self.userInfo[@"building"] isEqualToString:@"0"] && ![self.userInfo[@"buildingarea"] isEqualToString:@"0"]  && ![self.userInfo[@"houseid"] isEqualToString:@"0"]) {
//            self.louhaoTextField.text = self.userInfo[@"building"];
//            self.quhaoTextField.text = self.userInfo[@"buildingarea"];
//            self.sushehaoTextField.text = self.userInfo[@"houseid"];
//        }
//        
//
//        [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.userInfo[@"pic"]]];
//        
//        NSNumber *schoolid = self.userInfo[@"schoolid"];
//        if ([schoolid integerValue] == 1) {
//            self.school.text = @"西电新校区";
//        }else if([schoolid integerValue] == 2){
//            self.school.text = @"西电老校区";
//        }
//        self.school.tag = [schoolid integerValue];
//        
//        NSString *userName = self.userInfo[@"username"];
//        if (![userName isEqualToString:@""]) {
//            self.inputUserNameTextField.text = userName;
//        }
//        
//        NSString *hometown = self.userInfo[@"hometown"];
//        if (![hometown isEqualToString:@""]) {
//            self.hometownTextField.text = hometown;
//        }
//    }
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

- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (NSArray *)dormitoryNumbers{
    if (!_dormitoryNumbers) {
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 1; i <= 18; i++) {
            NSString *s = [NSString stringWithFormat:@"%i号楼", i];
            [array addObject:s];
        }
        return array;
    }
    return _dormitoryNumbers;
}

- (NSArray *)dormitoryDomains{
    if (!_dormitoryDomains) {
        _dormitoryDomains = @[@"1区",@"2区",@"3区"];
    }
    return _dormitoryDomains;
}

- (NSArray *)schools{
    if (!_schools) {
        _schools = @[@"西电新校区", @"西电老校区"];
    }
    return _schools;
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

- (NSMutableDictionary *)dicForPost{
    if (!_dicForPost) {
        _dicForPost = [NSMutableDictionary new];
        if (self.userInfo) {
                NSNumber *schoolid = self.userInfo[@"schoolid"];
            if ([schoolid integerValue] != 0) {
                [_dicForPost setValue:schoolid forKey:@"schoolid"];
            }

            if (![self.userInfo[@"building"] isEqualToString:@""] && ![self.userInfo[@"buildingarea"] isEqualToString:@""]  && ![self.userInfo[@"houseid"] isEqualToString:@"0"]){
                [_dicForPost setValue:self.userInfo[@"building"] forKey:@"building"];
                [_dicForPost setValue:self.userInfo[@"buildingarea"] forKey:@"buildingarea"];
                [_dicForPost setValue:self.userInfo[@"houseid"] forKey:@"houseid"];
            }
            
        }
    }
    return _dicForPost;
}
- (NSString *)savedImagePath{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savedImagePath = [docPath stringByAppendingPathComponent:@"avatar.png"];
    return savedImagePath;
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if(self.pickerCellShown){
            return 9;
        }else{
            return 8;
        }
    }else if (section == 1){
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 76.0f;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f]];
        return view;
    }
    return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%li", (long)(indexPath.row + 1)]];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
        if (indexPath.row == 0) {
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
            if (imageView.layer.borderWidth != 2.0f) {
                [imageView.layer setCornerRadius:(imageView.frame.size.height/2)];
                [imageView.layer setMasksToBounds:YES];
                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                [imageView setClipsToBounds:YES];
                imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
                imageView.layer.borderWidth = 2.0f;
            }

            if (!self.avatarUpdated && self.avatarSetted) {
                [imageView setImageWithURL:[NSURL URLWithString:self.userInfo[@"pic"]]];
            }else{
                
                imageView.image = [UIImage imageNamed:@"placeholder.png"];
            }
            if (self.avatarUpdated) {
                imageView.image = self.pickedImage;
            }
        }else if (indexPath.row == 1){
            if (self.userInfo) {
                        NSString *userName = self.userInfo[@"username"];
                        if (![userName isEqualToString:@""]) {
                            label.text = userName;
                        }
            }
        }else if (indexPath.row == 2){
                    NSString *hometown = self.userInfo[@"hometown"];
                    if (![hometown isEqualToString:@""]) {
                        label.text = hometown;
                    }
        }else if (indexPath.row == 3){
            NSNumber *schoolid = self.userInfo[@"schoolid"];
            if ([schoolid integerValue] == 1) {
                label.text = @"西电新校区";
            }else if([schoolid integerValue] == 2){
                label.text = @"西电老校区";
            }
        }else if (indexPath.row == 4){
            NSString *academy = self.userInfo[@"academy"];
            if (![academy isEqualToString:@""]) {
                label.text = academy;
            }
        }else if (indexPath.row == 5){
            if(![self.userInfo[@"building"] isEqualToString:@"0"]){
                label.text = self.userInfo[@"building"];
            }
        }else if (indexPath.row == 6){
            if(![self.userInfo[@"buildingarea"] isEqualToString:@"0"]){
                label.text = self.userInfo[@"buildingarea"];
            }
        }else if (indexPath.row == 7){
            if (![self.userInfo[@"houseid"] isEqualToString:@"0"]) {
                label.text = self.userInfo[@"houseid"];
            }
        }
        return cell;
        
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logout"];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"西电新校区",@"西电老校区", nil];
//        [actionSheet showInView:self.view];
        if (indexPath.row == 0) {
            [self editPortrait];
        }else if (indexPath.row == 1){          /*      昵称      */
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入昵称" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    label.text = textField.text;
                    [self.dicForPost setValue:label.text forKey:@"username"];
                                [self.rightBarButton setEnabled:YES];
                }
            }];
        }else if (indexPath.row == 2){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入家乡, 汇惠将在以后的版本为您寻找老乡" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    label.text = textField.text;
                    [self.dicForPost setValue:label.text forKey:@"hometown"];
                                [self.rightBarButton setEnabled:YES];
                }
            }];
        }else if (indexPath.row == 3){
                        self.pickerView.tag = indexPath.row;
            CXAlertView *alert = [[CXAlertView alloc] initWithTitle:nil
                                                        contentView:self.pickerView
                                                  cancelButtonTitle:@"取消"];
            [self.pickerView reloadAllComponents];
            [alert addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                NSInteger index = [self.pickerView selectedRowInComponent:0];
                label.text = self.schools[index];
                [self.dicForPost setValue:@(index+1) forKey:@"schoolid"];
                            [self.rightBarButton setEnabled:YES];
                [alertView dismiss];
            }];
            [alert show];
        }else if (indexPath.row == 4){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入学院" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    label.text = textField.text;
                    [self.dicForPost setValue:label.text forKey:@"academy"];
                                [self.rightBarButton setEnabled:YES];
                }
            }];
        }else if (indexPath.row == 5){      /*     宿舍楼号   */
            self.pickerView.tag = indexPath.row;
            CXAlertView *alert = [[CXAlertView alloc] initWithTitle:nil
                                                        contentView:self.pickerView
                                                  cancelButtonTitle:@"取消"];
                        [self.pickerView reloadAllComponents];
            [alert addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                NSInteger index = [self.pickerView selectedRowInComponent:0];
                label.text = self.dormitoryNumbers[index];
                [self.dicForPost setValue:label.text forKey:@"building"];
                            [self.rightBarButton setEnabled:YES];
                [alertView dismiss];
            }];
            [alert show];
        }else if (indexPath.row == 6){
                        self.pickerView.tag = indexPath.row;
            CXAlertView *alert = [[CXAlertView alloc] initWithTitle:nil
                                                        contentView:self.pickerView
                                                  cancelButtonTitle:@"取消"];
                        [self.pickerView reloadAllComponents];
            [alert addButtonWithTitle:@"确定" type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                NSInteger index = [self.pickerView selectedRowInComponent:0];
                label.text = self.dormitoryDomains[index];
                [self.dicForPost setValue:label.text forKey:@"buildingarea"];
                            [self.rightBarButton setEnabled:YES];
                [alertView dismiss];
            }];
            [alert show];
        }else if (indexPath.row == 7){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入门牌号(3位数)" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    label.text = textField.text;
                    [self.dicForPost setValue:label.text forKey:@"houseid"];
                                [self.rightBarButton setEnabled:YES];
                }
            }];

        }
    }else if (indexPath.section == 1){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self logout:nil];
    }
}


//- (void)updatePickerCellWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
//    if (self.pickerCellShown == false) {
//        self.pickerCellShown = true;
//        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1  inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }else{
//        self.pickerCellShown = false;
//        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]]  withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}

#pragma mark - UIPickerView

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 3) {
        return [self.schools count];
    }else if (pickerView.tag == 5){
        return [self.dormitoryNumbers count];
    }else if (pickerView.tag == 6){
        return [self.dormitoryDomains count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView.tag == 3) {
        return self.schools[row];
    }else if (pickerView.tag == 5){
        return self.dormitoryNumbers[row];
    }else if (pickerView.tag == 6){
        return self.dormitoryDomains[row];
    }
    return nil;
}


#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.rightBarButton.enabled == NO) {
        [self.rightBarButton setEnabled:YES];
    }
}


#pragma mark -
- (void)logout:(id)sender {
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
//            self.school.text = [actionSheet buttonTitleAtIndex:buttonIndex];
//            self.school.tag = buttonIndex + 1; /*       暂时用作post时的schoolid      */
//            if (self.rightBarButton.enabled == NO) {
//                [self.rightBarButton setEnabled:YES];
//            }
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


//- (NSMutableDictionary *)dicForPost{
//    
//    
//    NSMutableDictionary *result = [@{@"schoolid": @(self.school.tag),
//             @"building": self.louhaoTextField.text,
//             @"buildingarea": self.quhaoTextField.text,
//             @"houseid": self.sushehaoTextField.text,
//                               } mutableCopy];
//    
//    if (![self.inputUserNameTextField.text isEqualToString:@""]) {
//        [result setValue:self.inputUserNameTextField.text forKey:@"username"];
//    }
//    if (![self.hometownTextField.text isEqualToString:@""]) {
//        [result setValue:self.hometownTextField.text forKey:@"hometown"];
//    }
//    return result;
//}
//

- (BOOL)verifyPostDic{
    NSLog(@"%@", self.dicForPost);
    if (self.dicForPost[@"building"] && self.dicForPost[@"buildingarea"] && self.dicForPost[@"houseid"] && self.dicForPost[@"schoolid"]) {
        return true;
    }
    return false;
}

- (IBAction)postProfile:(id)sender {
    if (![self verifyPostDic]) {
        [MBProgressHUD showTextHudToView:self.view text:@"必选项没填完呢"];
        
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
    //self.avatarImageView.image = editedImage;
    /*      保存图片到本地         */
    NSData *imageData = UIImagePNGRepresentation(editedImage);
    [imageData writeToFile:self.savedImagePath atomically:YES];
    self.avatarUpdated = YES;
    self.pickedImage = editedImage;
    [self.tableView reloadData];
    
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
