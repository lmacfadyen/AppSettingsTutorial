/*  SettingsViewController.m
  Created by Lawrence MacFadyen using custom Nib for each UITableViewCell.
  Inline UIDatePicker design based on both sources as listed below.
*/

//  Based on MyTableViewController by Ajay Gautam on 3/9/14.
//
// BASED on Apple's DateCell source code
//

/*
 File: MyTableViewController.m
 Abstract: The main table view controller of this app.
 Version: 1.5

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2013 Apple Inc. All Rights Reserved.

 */

#import "SettingsViewController.h"
#import "OGLSettingsConstants.h"
#import "OGLDevices.h"
#import "DateTableViewCell.h"
#import "DatePickerTableViewCell.h"
#import "ButtonTableViewCell.h"
#import "SwitchTableViewCell.h"
#import "UIColor+OGLExtensions.h"

#define kPickerAnimationDuration                                                                   \
    0.40 // duration for the animation to slide the date picker into view

// Needed for the DatePickerTableViewCell xib since it is used twice
#define kDateTitleTag 105
#define kDateDetailTag 106

#define kTitleKey @"title" // key for obtaining the data source item's title
#define kDateKey @"date"   // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow 1
#define kDateEndRow 2

static NSString *kDateCellID = @"dateCellCustom";
static NSString *kDatePickerID = @"datePicker";           // the cell containing the date picker
static NSString *kSwitchCell = @"switchCell";         // switch cell
static NSString *kSomeButtonCell = @"someButtonCell"; // mark previous day cell

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *dataArray2;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) UIDatePicker *pickerView;

@end

@implementation SettingsViewController

#pragma mark - Initialization and Data Source Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self)
    {
    }
    return self;
}

- (void)setupDataSource
{
    NSDate *firstTimeCurrent = (NSDate *)
        [[NSUserDefaults standardUserDefaults] objectForKey:OGLSettingsConstantsFirstDateKey];
    if (firstTimeCurrent == nil)
    {
        firstTimeCurrent = [NSDate date];
    }

    NSDate *secondTimeCurrent = (NSDate *)
        [[NSUserDefaults standardUserDefaults] objectForKey:OGLSettingsConstantsSecondDateKey];
    if (secondTimeCurrent == nil)
    {
        secondTimeCurrent = [NSDate date];
    }

    BOOL enableSwitchCurrent =
        [[NSUserDefaults standardUserDefaults] boolForKey:OGLSettingsConstantsSwitchKey];

    // setup our data source
    NSMutableDictionary *itemOne = [@{
        kTitleKey : @"Some Switch",
        OGLSettingsConstantsSwitchKey : [NSNumber numberWithBool:enableSwitchCurrent]
    } mutableCopy];

    NSMutableDictionary *itemTwo =
        [@{ kTitleKey : @"First Date",
            kDateKey : firstTimeCurrent } mutableCopy];
    NSMutableDictionary *itemThree =
        [@{ kTitleKey : @"Second Date",
            kDateKey : secondTimeCurrent } mutableCopy];
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"Some Button" } mutableCopy];
    self.dataArray = @[ itemOne, itemTwo, itemThree ];
    self.dataArray2 = @[ itemFour ];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"hh:mm a"]; // show short-style date format

    // obtain the picker view cell's height, works because the cell was pre-defined
    UITableViewCell *pickerViewCellToCheck = [self createCellWithIdentifier:kDatePickerID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDataSource];

    self.title = @"Settings";
    if (IS_IPAD)
    {
        self.tableView.rowHeight = 64.0;
    }
}

#pragma mark - UIDatePicker Utilities

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.

 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;

    NSInteger targetedRow = indexPath.row;
    targetedRow++;

    UITableViewCell *checkDatePickerCell = [self.tableView
        cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    if ([checkDatePickerCell isKindOfClass:[DatePickerTableViewCell class]])
    {
        hasDatePicker = YES;
    }

    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell =
            [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];

        UIDatePicker *targetedDatePicker =
            [(DatePickerTableViewCell *)associatedDatePickerCell datePicker];

        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
            [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
            NSLog(@"Adding Date Picker Action");
            // set the call action for the date picker to dateAction
            [targetedDatePicker addTarget:self
                                   action:@selector(dateAction:)
                         forControlEvents:UIControlEventValueChanged];
        }
    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.

 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.

 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;

    if ((indexPath.row == kDateStartRow) ||
        (indexPath.row == kDateEndRow ||
         ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
    {
        hasDate = YES;
    }

    return hasDate;
}

#pragma mark - Conrol for Inline UIDatePicker

/*! Adds or removes a UIDatePicker cell below the given indexPath.

 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{

    [self.tableView beginUpdates];

    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0] ];

    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView endUpdates];
    [self.tableView layoutIfNeeded];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".

 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // display the date picker inline with the table content
    [self.tableView beginUpdates];

    BOOL before = NO; // indicates if the date picker is below "indexPath", help us determine which
    // row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }

    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);

    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[
            [NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]
        ] withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }

    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];

        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath =
            [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }

    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tableView endUpdates];

    // Force reload to reset content size after inline date picker removed
    [self.tableView reloadData];

    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height =
        ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([kDateCellID isEqualToString:cell.reuseIdentifier])
    {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, (IS_IPAD ? 55 : 40))];

    sectionHeaderView.backgroundColor = [UIColor defaultLightGray];
    //

    UILabel *headerLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(16, (IS_IPAD ? 25 : 15), sectionHeaderView.frame.size.width,
                                 (IS_IPAD ? 30 : 25))];

    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    if (IS_IPAD)
    {
        [headerLabel setFont:[UIFont boldSystemFontOfSize:19]];
    }
    else
    {
        [headerLabel setFont:[UIFont boldSystemFontOfSize:14]];
    }

    [headerLabel setTextColor:[UIColor grayColor]];
    [sectionHeaderView addSubview:headerLabel];
    switch (section)
    {
        case 0:
            headerLabel.text = @"Section 0 Header";
            return sectionHeaderView;
            break;
        case 1:
            headerLabel.text = @"";
            return sectionHeaderView;
            break;
        default:
            break;
    }

    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    UIView *footerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];

    footerView.backgroundColor = [UIColor defaultLightGray];

    UILabel *footerLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(16, 5, self.view.frame.size.width * .8, 65)];
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.backgroundColor = [UIColor clearColor];
    if (IS_IPAD)
    {
        [footerLabel setFont:[UIFont boldSystemFontOfSize:19]];
    }
    else
    {
        [footerLabel setFont:[UIFont boldSystemFontOfSize:14]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      footerLabel.numberOfLines = 0;
      [footerLabel sizeToFit];

    });
    [footerView addSubview:footerLabel];

    switch (section)
    {
        case 0:
            footerLabel.text = @"Section 0 Footer";
            return footerView;
            break;
        case 1:
            footerLabel.text = @"Section 1 Footer";
            return footerView;
            break;
        default:
            break;
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return (IS_IPAD ? 100 : 80);
        case 1:
            return (IS_IPAD ? 100 : 80);
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return (IS_IPAD ? 55 : 40);
        case 1:
            return 0;
        default:
            return 0;
    }
}

#pragma mark - UITableViewDataSource protocol and helpers

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    NSString *cellID = kSomeButtonCell;

    if (indexPath.section == 0)
    {
        if ([self indexPathHasPicker:indexPath])
        {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerID; // the current/opened date picker cell
        }
        else if ([self indexPathHasDate:indexPath])
        {
            // the indexPath is one that contains the date information
            cellID = kDateCellID; // the start/end date cells
        }

        if (indexPath.row == 0)
        {
            // we decide here that first cell in the table is not selectable (it's just an
            // indicator)
            cellID = kSwitchCell;
        }

        cell = [tableView dequeueReusableCellWithIdentifier:cellID];

        if (!cell)
        {
            cell = [self createCellWithIdentifier:cellID];
        }

        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        NSInteger modelRow = indexPath.row;

        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row)
        {
            modelRow--;
        }

        NSDictionary *itemData = self.dataArray[modelRow];

        // proceed to configure our cell
        if ([cellID isEqualToString:kDateCellID])
        {
            // we have either start or end date cells, populate their date field

            DateTableViewCell *dateCell = (DateTableViewCell *)cell;
            dateCell.titleLabel.text = [itemData valueForKey:kTitleKey];
            dateCell.detailLabel.text =
                [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
        }
        else if ([cellID isEqualToString:kSwitchCell])
        {
            NSNumber *num = [itemData valueForKey:OGLSettingsConstantsSwitchKey];

            BOOL value = [num boolValue];

            SwitchTableViewCell *SwitchCell = (SwitchTableViewCell *)cell;
            SwitchCell.someSwitch.on = value;
        }
    }
    if (indexPath.section == 1)
    {
        if ([cellID isEqualToString:kSomeButtonCell])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];

            if (!cell)
            {
                cell = [self createCellWithIdentifier:cellID];
            }
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0)
    {
        if ([self hasInlineDatePicker])
        {
            // we have a date picker, so allow for it in the number of rows in this section
            NSInteger numRows = self.dataArray.count;
            return ++numRows;
        }

        return self.dataArray.count;
    }

    if (section == 1)
    {
        return self.dataArray2.count;
    }

    return 0;
}

- (UITableViewCell *)createCellWithIdentifier:(NSString *)cellId
{
    if ([kDateCellID isEqualToString:cellId])
    {
        DateTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
        if (!cell)
        {
            [self.tableView registerNib:[UINib nibWithNibName:@"DateTableViewCell" bundle:nil]
                 forCellReuseIdentifier:kDateCellID];
            cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
        }
        return cell;
    }
    if ([kDatePickerID isEqualToString:cellId])
    {
        DatePickerTableViewCell *cell =
            [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
        if (!cell)
        {
            [self.tableView registerNib:[UINib nibWithNibName:@"DatePickerTableViewCell" bundle:nil]
                 forCellReuseIdentifier:kDatePickerID];
            cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
        }
        return cell;
    }
    if ([kSwitchCell isEqualToString:cellId])
    {
        SwitchTableViewCell *cell =
            [self.tableView dequeueReusableCellWithIdentifier:kSwitchCell];
        if (!cell)
        {
            [self.tableView registerNib:[UINib nibWithNibName:@"SwitchTableViewCell" bundle:nil]
                 forCellReuseIdentifier:kSwitchCell];
            cell = [self.tableView dequeueReusableCellWithIdentifier:kSwitchCell];

            UISwitch *targetedSwitch = cell.someSwitch;
            if (targetedSwitch != nil)
            {
                // set the call action for the switch to SwitchwitchChanged
                [targetedSwitch addTarget:self
                                   action:@selector(switchChanged:)
                         forControlEvents:UIControlEventValueChanged];
            }
        }
        return cell;
    }
    if ([kSomeButtonCell isEqualToString:cellId])
    {
        ButtonTableViewCell *cell =
            [self.tableView dequeueReusableCellWithIdentifier:kSomeButtonCell];
        if (!cell)
        {
            [self.tableView registerNib:[UINib nibWithNibName:@"ButtonTableViewCell"
                                                       bundle:nil]
                 forCellReuseIdentifier:kSomeButtonCell];
            cell = [self.tableView dequeueReusableCellWithIdentifier:kSomeButtonCell];

            UIButton *ButtonButton = cell.someButton;
            if (ButtonButton != nil)
            {
                // set the call action for the button to SwitchwitchChanged
                [ButtonButton addTarget:self
                                       action:@selector(showButton:)
                             forControlEvents:UIControlEventTouchDown];
            }
        }
        return cell;
    }
    return nil;
}

#pragma mark - Actions and Action Helpers

/*! User chose to change the date by changing the values inside the UIDatePicker.

 @param sender The sender for this action: UIDatePicker.
 */
- (void)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;

    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath =
            [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;

    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kDateKey];

    // update the cell's date string
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:kDateDetailTag];
    detailLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];

    // update settings

    NSDate *newFirstDate = [self firstDate];
    NSDate *newSecondDate = [self secondDate];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:newFirstDate forKey:OGLSettingsConstantsFirstDateKey];
    [defaults setObject:newSecondDate forKey:OGLSettingsConstantsSecondDateKey];

    [defaults synchronize];
}

- (NSDate *)firstDate
{
    NSMutableDictionary *itemData = self.dataArray[1];
    
    NSDate *date = [itemData valueForKey:kDateKey];
    return date;
}

- (NSDate *)secondDate
{
    NSMutableDictionary *itemData = self.dataArray[2];
    
    NSDate *date = [itemData valueForKey:kDateKey];
    return date;
}

- (void)switchChanged:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    BOOL value = switcher.on;
    if (value)
    {
        NSLog(@"Switch is ON");
    }
    else
    {
        NSLog(@"Switch is OFF");
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:OGLSettingsConstantsSwitchKey];
    [defaults synchronize];
}

- (IBAction)showButton:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some Action"
                                                    message:@"Do you really want to do some action?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // No selected so do nothing
        NSLog(@"Cancel Button Action");
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"DO Button Action");
        // Yes selected so perform the necessary action
    }
}


@end
