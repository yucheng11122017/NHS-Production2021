#import "LoginCollectionViewController.h"

@import Form;
@import NSJSONSerialization_ANDYJSONFile;
@import Hex;

@interface LoginCollectionViewController ()

@property (nonatomic) NSArray *JSON;
@property (nonatomic) FORMDataSource *dataSource;
@property (nonatomic) FORMLayout *layout;
@property NSIndexPath *indexPathButton;

@end

@implementation LoginCollectionViewController

#pragma mark - Getters

- (FORMDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    _dataSource = [[FORMDataSource alloc] initWithJSON:self.JSON
                                        collectionView:self.collectionView
                                                layout:self.layout
                                                values:nil
                                              disabled:NO];
    
    __weak typeof(self)weakSelf = self;
    
    _dataSource.configureCellBlock = ^(FORMBaseFieldCell *cell, NSIndexPath *indexPath, FORMField *field) {
        cell.field = field;
        
        if (field.type == FORMFieldTypeButton) {
            weakSelf.indexPathButton = indexPath;
        }
    };
    
    _dataSource.fieldUpdatedBlock = ^(FORMBaseFieldCell *cell, FORMField *field) {
        if ([field.fieldID isEqualToString:@"email"] ||
            [field.fieldID isEqualToString:@"password"]) {
            [weakSelf updateLoginButtonState];
            
        } else if ([field.fieldID isEqualToString:@"login"]) {      //login button is tapped!
//            [weakSelf showLoginSuccessAlert];
            [weakSelf performSegueWithIdentifier:@"loginToOptionSegue" sender:weakSelf];
            
        }
    };
    
    return _dataSource;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FORMLayout *layout = [FORMLayout new];
    self.JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"Login.json"];
    self.layout = layout;
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.contentInset = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.width/4, 0, 0, 0);        //previously divide by 3.
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //No background photo for now...
    
//    UIImageView *formLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NUS Logo"]];
////    formLogo.contentMode = UIViewContentModeTop
//    formLogo.contentMode = UIViewContentModeScaleAspectFit;
//    formLogo.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*8/10);
//    NSLog(@"%f, %f", [UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height*8/10);
//    self.collectionView.backgroundView = formLogo;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource sizeForFieldAtIndexPath:indexPath];
}

#pragma mark - Private methods

- (void)updateLoginButtonState {
    FORMButtonFieldCell *loginButtonCell = (FORMButtonFieldCell *)[self.collectionView cellForItemAtIndexPath:self.indexPathButton];
    loginButtonCell.disabled = ![self.dataSource isValid];
}

- (void)showLoginSuccessAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey"
                                                                             message:@"You just logged in! Congratulations"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *niceAction = [UIAlertAction actionWithTitle:@"Nice!"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [alertController dismissViewControllerAnimated:YES
                                                completion:^{}
                                                            ];
                                                       }];
    
    [alertController addAction:niceAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Just in case I need...
    
}
@end