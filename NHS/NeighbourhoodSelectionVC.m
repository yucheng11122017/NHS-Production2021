//
//  NeighbourhoodSelectionVC.m
//  NHS
//
//  Created by Nicholas Wong on 8/12/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "NeighbourhoodSelectionVC.h"
#import "PatientScreeningListTableViewController.h"

@interface NeighbourhoodSelectionVC () {
    NSString *selectedNeighbourhood;
}

@end

@implementation NeighbourhoodSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)eunosCresBtnPressed:(id)sender {
    selectedNeighbourhood = @"EC";
    [self performSegueWithIdentifier:@"neighbourhoodToScreeningListSegue" sender:self];
}
- (IBAction)kampGlamBtnPressed:(id)sender {
    selectedNeighbourhood = @"KGL";
    [self performSegueWithIdentifier:@"neighbourhoodToScreeningListSegue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setNeighbourhood:)]) {    //view submitted form
        [segue.destinationViewController performSelector:@selector(setNeighbourhood:)
                                              withObject:selectedNeighbourhood];
    }
}


@end