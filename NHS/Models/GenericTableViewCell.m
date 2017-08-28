//
//  GenericTableViewCell.m
//  NHS
//
//  Created by Nicholas Wong on 10/17/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import "GenericTableViewCell.h"

@interface GenericTableViewCell ()




@end

@implementation GenericTableViewCell

@synthesize nameLabel = _nameLabel;
@synthesize NRICLabel = _NRICLabel;
@synthesize dateLabel = _dateLabel;
@synthesize regLabel = _regLabel;
@synthesize yearLabel = _yearLabel;
@synthesize verticalLine = _verticalLine;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Fix the bug in iOS7 - initial constraints warning
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//- (void)setEntity:(GenericEntity *)entity
//{
//    _entity = entity;
//    
//    self.nameLabel.text = entity.name;
//    self.NRICLabel.text = entity.nric;
//    
//    //Remove the time component from NSDate
//    NSArray *array = [entity.date componentsSeparatedByString:@" "];
//    NSString *dateOnly = array[0];
//    self.dateLabel.text = dateOnly;
//}

// If you are not using auto layout, override this method, enable it by setting
// "fd_enforceFrameLayout" to YES.
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    totalHeight += [self.nameLabel sizeThatFits:size].height;
    totalHeight += [self.NRICLabel sizeThatFits:size].height;
    totalHeight += [self.dateLabel sizeThatFits:size].height;
    totalHeight += 40; // margins
    return CGSizeMake(size.width, totalHeight);
}

@end
