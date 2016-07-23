#import "ScreeningQuestionViewController.h"
#import "NSJSONSerialization+ANDYJSONFile.h"


@implementation ScreeningQuestionViewController




@synthesize dataSource = _dataSource;

- (FORMDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    FORMLayout *layout = [FORMLayout new];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    [self chooseJSONFile];
    
    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:self.JSONFilename];
    _dataSource = [[FORMDataSource alloc] initWithJSON:JSON
                                        collectionView:self.collectionView
                                                layout:layout
                                                values:nil
                                              disabled:NO];
    
    return _dataSource;
}

- (void) chooseJSONFile {
    int index = [self.questionsFromSection intValue];
    NSLog(@"Section Index is %d", index);
    switch (index) {
        case 0: self.JSONFilename = @"Neighbourhood.json";
            break;
        case 1: self.JSONFilename = @"Residents Particulars.json";
            break;
        case 2: self.JSONFilename = @"Clinical Results.json";
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.JSONFilename = [[NSString alloc]init];
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
}

@end
