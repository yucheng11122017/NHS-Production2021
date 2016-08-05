//
//  SearchResultsTableController.m
//  NHS
//
//  Created by Mac Pro on 8/5/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "SearchResultsTableController.h"

@interface SearchResultsTableController ()

@end

@implementation SearchResultsTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // we use a nib which contains the cell's view and this class as the files owner
//    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];      //must have subtitle settings
    }
    NSDictionary *patientDetails = [[NSDictionary alloc] init];
    patientDetails = self.filteredProducts[indexPath.row];
    [self configureCell:cell forProduct:patientDetails];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forProduct:(NSDictionary *)patientDetails {
    cell.textLabel.text = [patientDetails objectForKey:@"resident_name"];
    cell.detailTextLabel.text = [patientDetails objectForKey:@"nric"];
    
    // build the price and year string
    // use NSNumberFormatter to get the currency format out of this NSNumber (product.introPrice)
    //
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
//    NSString *priceString = [numberFormatter stringFromNumber:product.introPrice];
//    
//    NSString *detailedStr = [NSString stringWithFormat:@"%@ | %@", priceString, (product.yearIntroduced).stringValue];
//    cell.detailTextLabel.text = detailedStr;
}




@end
