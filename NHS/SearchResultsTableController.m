//
//  SearchResultsTableController.m
//  NHS
//
//  Created by Mac Pro on 8/5/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "SearchResultsTableController.h"
#import "GenericTableViewCell.h"
#import "AppConstants.h"

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
    
    GenericTableViewCell *cell = (GenericTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GenericTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GenericTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *patientDetails = [[NSDictionary alloc] initWithDictionary:self.filteredProducts[indexPath.row]];
    [self configureCell:cell forProduct:patientDetails];
    
    return cell;
}

- (void)configureCell:(GenericTableViewCell *)cell forProduct:(NSDictionary *)patientDetails {
    cell.nameLabel.text = [patientDetails objectForKey:@"resident_name"];
    cell.NRICLabel.text = [patientDetails objectForKey:@"nric"];
    cell.dateLabel.text = [patientDetails objectForKey:@"last_updated_ts"];
    NSNumber *preRegCompleted = [patientDetails objectForKey:kPreregCompleted];
    NSString *serialId = [patientDetails objectForKey:@"nhs_serial_id"];
    
    if ([preRegCompleted isEqual:@1])
        cell.regLabel.hidden = NO;
    else
        cell.regLabel.hidden = YES;
    
    //default hidden
    cell.verticalLine.hidden = YES;
    cell.yearLabel.hidden = YES;
    
    if (serialId != (id) [NSNull null]) {
        if ([serialId isKindOfClass:[NSString class]]  && ![serialId isEqualToString:@""]) {  //as long as have value
            cell.verticalLine.hidden = NO;
            cell.yearLabel.hidden = NO;
        }
    }
    
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
