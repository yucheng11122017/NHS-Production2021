//
//  GenericTableViewCell.h
//  NHS
//
//  Created by Nicholas Wong on 10/17/16.
//  Copyright © 2016 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *NRICLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *regLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *verticalLine;

@end
