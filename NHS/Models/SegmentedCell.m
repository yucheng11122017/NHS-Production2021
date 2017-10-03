//
//  SegmentedCell.m
//  NHS
//
//  Created by Nicholas Wong on 10/3/17.
//  Copyright © 2017 NUS. All rights reserved.
//

#import "SegmentedCell.h"

@implementation SegmentedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)segmentCtrlChanged:(UISegmentedControl *)sender {
    NSNumber *number;
    if (sender.selectedSegmentIndex == 0) {
        number = [NSNumber numberWithBool:true];
    } else {
        number = [NSNumber numberWithBool:false];
    }
    
    NSDictionary *userInfo = @{@"value":number};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SegmentedCtrlChange" object:nil userInfo:userInfo];
    
}
@end
