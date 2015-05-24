//
//  DateTableViewCell.h
//
//  Created by Lawrence F MacFadyen on 2015-01-31.
//  Copyright (c) 2015 larrymac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
