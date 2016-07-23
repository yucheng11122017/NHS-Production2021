//
//  ScreeningSectionTableViewController.m
//  Demo
//
//  Created by Nicholas on 7/17/16.
//
//

#import "ScreeningSectionTableViewController.h"
#import "ScreeningQuestionViewController.h"

@interface ScreeningSectionTableViewController ()

@property (strong, nonatomic) NSArray *sectionTitles;

@end

@implementation ScreeningSectionTableViewController {
    NSNumber *sectionIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionTitles = @[@"Neighbourhood",@"Resident Particulars",@"Clinical Results (general)",@"Screening of Risk Factors", @"Diabetes Mellitus", @"Hyperlipidemia (high cholesterol)", @"Hypertension", @"Cancer Screening", @"Other Medical Issues", @"Primary Care Source", @"My Health and My Neighbourhood", @"Demographics", @"Current Physical Issues", @"Current Socioeconomic Situation", @"Social Support Assessment", @"Referral for Doctor Consult", @"Submit"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sectionTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    //cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat:@"Scene %ld", (long)indexPath.row+1];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.sectionTitles objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    // Configure the cell...
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.cellSubtitles objectAtIndex:indexPath.row]];
    //    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    //If image is required...
    //    UIImage *theImage = [UIImage imageNamed:@"Gallery Color_icon"];
    //    cell.imageView.image = theImage;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    sectionIndex = [NSNumber numberWithInteger:indexPath.row];
    [self performSegueWithIdentifier:@"sectionToQuestionsSegue" sender:self];
    NSLog(@"segue performed!");
//    [self.navigationController popViewControllerAnimated:YES];      //Go back to Assessment Page
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setQuestionsFromSection:)]) {
        [segue.destinationViewController performSelector:@selector(setQuestionsFromSection:)
                                              withObject:sectionIndex];
    }
    
}


@end
