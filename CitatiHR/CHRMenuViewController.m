//
//  CHRMenuViewController.m
//  CitatiHR
//
//  Created by Zoran Pleško on 22/02/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRMenuViewController.h"
#import "ECSlidingViewController.h"
#import "CHRThemeViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHRMasterViewController.h"
#import "ViewFavouriteController.h"


@interface CHRMenuViewController ()

@property(nonatomic, weak) IBOutlet UISearchBar *srchBar;
@property(nonatomic,weak) IBOutlet UIButton *theme;
@property(nonatomic,weak) IBOutlet UIButton *author;
@property(nonatomic,weak) IBOutlet UIButton *favourite;
@property(nonatomic,weak) IBOutlet UIButton *citation;

@end

@implementation CHRMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.view addGestureRecognizer:self.slidingViewController.leftPanGesture];
//    [self.view addGestureRecognizer:self.slidingViewController.rightPanGesture];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)themeButtonPressed:(id)sender
{
    CHRThemeViewController *controller = [[CHRThemeViewController alloc] init];
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}


- (IBAction)citationButtonPressed:(id)sender
{
    CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
    [controller setSvi:YES];
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}


- (IBAction)favouriteButtonPressed:(id)sender
{
    CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
    [controller setSvi:NO];
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}




@end
