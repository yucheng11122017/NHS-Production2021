//
//  PatientPreRegTableViewController.m
//  NHS
//
//  Created by Nicholas on 7/25/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "PatientPreRegTableViewController.h"
#import "PreRegPatientDetailsViewController.h"
#import "ServerComm.h"

@interface PatientPreRegTableViewController ()

@property (strong, nonatomic) NSMutableArray *patientNames;

@end

@implementation PatientPreRegTableViewController {
    NSNumber *selectedPatientID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.patientNames = [[NSMutableArray alloc] init];
    [self getAllPatients];
    
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    NSDictionary* patient = self.patients[indexPath.row];
    
    [cell.textLabel setText:[patient objectForKey:@"resident_name"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    patientIndex = [NSNumber numberWithInteger:indexPath.row];
    NSDictionary *selectedPatient = self.patients[indexPath.row];
    selectedPatientID = [selectedPatient objectForKey:@"resident_id"];
    [self performSegueWithIdentifier:@"preRegPatientListToPatientDataSegue" sender:self];
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

#pragma mark - Blocks

- (void (^)(NSProgress *downloadProgress))progressBlock {
    return ^(NSProgress *downloadProgress) {
        NSLog(@"Patients GET Request Started. In Progress.");
    };
}

- (void (^)(NSURLSessionDataTask *task, id responseObject))successBlock {
    return ^(NSURLSessionDataTask *task, id responseObject){
        NSArray *patients = responseObject[0];      //somehow double brackets... (())
//        self.patients = [self createPatients:patients];
        self.patients = [[NSMutableArray alloc] initWithArray:patients];
        NSLog(@"%@", patients);
//        [[AppData sharedAppData] setPatients:self.patients];
        [self.tableView reloadData];
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Patients data fetch was unsuccessful1");
    };
}


#pragma mark - Patient API

- (void)getAllPatients {
    ServerComm *client = [ServerComm sharedServerCommInstance];
    [client getPatient:[self progressBlock]
          successBlock:[self successBlock]
          andFailBlock:[self errorBlock]];
}

#pragma mark - Util methods

//- (NSMutableArray *)createPatients:(NSArray *)patients {
//    NSMutableArray *patObjs = [[NSMutableArray alloc] init];
//    for (id patient in patients) {
//        [patObjs addObject:[self createPatient:patient]];
//    }
//    return patObjs;
//}

//- (NSArray *) createPatient: (NSDictionary *) patient {
//    NSNumber *birth_year = [patient objectForKey:@"birth_year"];
//    NSString *gender = [patient objectForKey:@"gender"];
//    NSString *nric = [patient objectForKey:@"nric"];
//    NSNumber *resident_id = [patient objectForKey:@"resident_id"];
//    NSString *resident_name = [patient objectForKey:@"resident_name"];
//
//    return @""; //keep it this way first..
//}
//
//- (Patient *)createPatient:(NSDictionary *)patient {
//    NSString *name = [patient objectForKey:@"name"];
//    NSInteger ID = [[patient objectForKey:@"id"] integerValue];
//    NSString *homeType = [patient objectForKey:@"home"];
//    NSInteger age = [[patient objectForKey:@"age"] integerValue];
//    NSInteger height = [[patient objectForKey:@"height"] integerValue];
//    NSInteger level = [[patient objectForKey:@"level"] integerValue];
//    BOOL hasCaretaker;
//    if ([patient objectForKey:@"available"] != [NSNull null]) {
//        hasCaretaker = [[patient objectForKey:@"available"] boolValue];
//    } else {
//        hasCaretaker = NO;
//    }
//    
//    return [[Patient alloc] initWithName:name
//                                     age:(int)age
//                                      ID:ID
//                                  height:(int)height
//                                   level:(int)level
//                                homeType:homeType
//                            hasCaretaker:hasCaretaker];
//}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([segue.destinationViewController respondsToSelector:@selector(setPatientID:)]) {
        [segue.destinationViewController performSelector:@selector(setPatientID:)
                                              withObject:selectedPatientID];
    }
    
}

@end
