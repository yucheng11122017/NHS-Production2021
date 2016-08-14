//
//  ScreeningSectionTableViewController.m
//  NHS
//
//  Created by Mac Pro on 8/14/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "ScreeningSectionTableViewController.h"
#import "ScreeningFormViewController.h"
@interface ScreeningSectionTableViewController ()


@property (strong, nonatomic) NSArray *rowTitles;
@end

@implementation ScreeningSectionTableViewController {
    NSNumber *selectedRow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rowTitles = @[@"Neighbourhood",@"Resident Particulars", @"Clinical Results",@"Screening of Risk Factors", @"Diabetes Mellitus", @"Hyperlipidemia", @"Hypertension", @"Cancer Screening", @"Other Medical Issues", @"Primary Care Source", @"My Health and My Neighbourhood", @"Demographics", @"Current Physical Issues", @"Current Socioeconomics Situation", @"Social Support Assessment", @"Referral for Doctor Consultation", @"Submit"];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
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
    return 17;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    cell.textLabel.text = [self.rowTitles objectAtIndex:indexPath.row];
     [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
//    } else {
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//    }

    
    selectedRow = [NSNumber numberWithInteger:indexPath.row];
    
    [self performSegueWithIdentifier:@"screeningSectionToFormSegue" sender:self];
    NSLog(@"Form segue performed!");

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setSectionID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setSectionID:)
                                              withObject:selectedRow];
    }
}


@end
