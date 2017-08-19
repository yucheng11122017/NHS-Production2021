//
//  HealthAssessAndRiskTableVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/8/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "HealthAssessAndRiskTableVC.h"
#import "AppConstants.h"

@interface HealthAssessAndRiskTableVC () {
    NSNumber *destinationFormID;
    NSNumber *age;
}

@property (strong, nonatomic) NSArray *rowLabelsText;

@end

@implementation HealthAssessAndRiskTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    age = (NSNumber *) [[NSUserDefaults standardUserDefaults]
                        stringForKey:kResidentAge];
    
    self.navigationItem.title = @"Health Assessment and Risk Stratisfaction";
    _rowLabelsText= [[NSArray alloc] initWithObjects:@"Medical History",@"Geriatric Depression Assessment",@"Risk Stratification", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
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
    return [_rowLabelsText count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    
    NSString *text = [_rowLabelsText objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:text];
    
    if (indexPath.row == 1) {   //Geriatric Depression Assessment
        if ([age intValue] <65) {
            [cell.textLabel setTextColor:[UIColor grayColor]];
        }
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        [self performSegueWithIdentifier:@"HARSToMedHistSegue" sender:self];
    else {
        if (indexPath.row == 1) {   //Geriatric Depression Assessment
            if ([age intValue] <65) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return; //do nothing
            }
        }
        
        NSInteger targetRow = indexPath.row + 2;
        destinationFormID = [NSNumber numberWithInteger:targetRow];
        [self performSegueWithIdentifier:@"HARSToFormSegue" sender:self];
    }
    
    
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
    if ([segue.destinationViewController respondsToSelector:@selector(setFormID:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setFormID:)
                                              withObject:destinationFormID];
    }
}


@end
