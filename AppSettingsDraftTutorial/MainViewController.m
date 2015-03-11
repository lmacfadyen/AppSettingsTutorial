//
//  MainViewController.m
//  AppSettingsDraftTutorial
//
//  Created by Lawrence F MacFadyen on 2015-03-11.
//  Copyright (c) 2015 LawrenceM. All rights reserved.
//

#import "MainViewController.h"
#import "SettingsViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        
    self.title = @"Main Screen";
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSettings:)];
    
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:settingsButton, nil];
    
    [[self navigationItem] setLeftBarButtonItems:buttonArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSettings:(UIBarButtonItem *)sender
{
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
