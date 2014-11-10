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
#import "CHRAuthorViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHRMasterViewController.h"
#import "NSString+FontAwesome.h"




@interface CHRMenuViewController ()<UISearchBarDelegate>

@property(nonatomic, weak) IBOutlet UISearchBar *srchBar;
@property(nonatomic,weak) IBOutlet UIButton *theme;
@property(nonatomic,weak) IBOutlet UIButton *author;
@property(nonatomic,weak) IBOutlet UIButton *favourite;
@property(nonatomic,weak) IBOutlet UIButton *citation;

@property (nonatomic, strong) UIButton *transparentButtonView;
@property (nonatomic, strong) UIButton *searchButton;

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
    [self registerForKeyboardNotifications];
    
    [self setButtonFonts];
//    [self.view addGestureRecognizer:self.slidingViewController.leftPanGesture];
//    [self.view addGestureRecognizer:self.slidingViewController.rightPanGesture];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterForKeyboardNotifications];
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

- (void)setButtonFonts
{
    [[_theme titleLabel] setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [[_author titleLabel] setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [[_favourite titleLabel] setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    [[_citation titleLabel] setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    
    NSString *book = [NSString fontAwesomeIconStringForEnum:FABook];
    NSString *tematik = [NSString stringWithFormat:@"%@ Tematike", book];
    [_theme setTitle:tematik forState:UIControlStateNormal];
    
    NSString *group = [NSString fontAwesomeIconStringForEnum:FAGroup];
    NSString *autor = [NSString stringWithFormat:@"%@ Autori", group];
    [_author setTitle:autor forState:UIControlStateNormal];
    
    NSString *heart = [NSString fontAwesomeIconStringForEnum:FAHeart];
    NSString *favor = [NSString stringWithFormat:@"%@ Zabilješke", heart];
    [_favourite setTitle:favor forState:UIControlStateNormal];
    
    NSString *quot = [NSString fontAwesomeIconStringForEnum:FAQuoteRight];
    NSString *cit = [NSString stringWithFormat:@"%@ Citati", quot];
    [_citation setTitle:cit forState:UIControlStateNormal];

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
    //[controller setValue:[NSNumber numberWithBool:YES] forKey:@"svi"];
    controller.svi=CHRResultSetTypeAll;
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}


- (IBAction)favouriteButtonPressed:(id)sender
{
    CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
    //[controller setValue:[NSNumber numberWithBool:NO] forKey:@"svi"];
    controller.svi=CHRResultSetTypeFavorites;
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}

- (IBAction)authorButtonPressed:(id)sender
{
    CHRAuthorViewController *controller = [[CHRAuthorViewController alloc] init];
    //[controller setValue:[NSNumber numberWithBool:NO] forKey:@"svi"];
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    //[self.slidingViewController setUnderLeftViewController:menuController];
    [self.slidingViewController resetTopViewAnimated:YES];
    
}

#pragma mark - SearchBar delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self showUnderView];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self removeUnderView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length>0){
        [self showSearchButton];
    }else{
        [self.searchButton removeFromSuperview];
        self.searchButton = nil;
    }
}

#pragma mark - keyboard methods

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize _kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat _kbHeight = _kbSize.height;
    
    
    CGRect frame = self.transparentButtonView.frame;
    frame.size.height = self.view.frame.size.height - _kbHeight - 64;
    [_transparentButtonView setFrame:frame];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void) showUnderView
{
    if(!self.transparentButtonView){
        CGRect buttonFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        self.transparentButtonView = [[UIButton alloc] initWithFrame:buttonFrame];
        _transparentButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [_transparentButtonView addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.transparentButtonView];
    }
}

- (void)removeUnderView
{
    [self.transparentButtonView removeFromSuperview];
    self.transparentButtonView = nil;
    [self.searchButton removeFromSuperview];
    self.searchButton = nil;
}

- (void)dismissKeyboard:(id)sender
{
    [self.srchBar resignFirstResponder];
}

- (void) showSearchButton
{
    if(!self.searchButton){
        CGFloat width = self.view.frame.size.width, height = 44;
        
        CGRect buttonFrame = CGRectMake(self.view.frame.size.width / 2.0f - width / 2.0f, 64, width, height);
        
        self.searchButton = [[UIButton alloc] initWithFrame:buttonFrame];
        self.searchButton.backgroundColor = [UIColor colorWithRed:51/255.0 green:153/255.0 blue:204/255.0 alpha:1];
        [self.searchButton setTitle:@"TRAŽI" forState:UIControlStateNormal];
        [self.searchButton setTitleColor:[UIColor colorWithRed:169.0/255.0 green:196.0/255.0 blue:246.0/255.0 alpha:1] forState:UIControlStateNormal];
        [self.searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.searchButton];
    }

}

- (void)search:(id)sender
{
    [self.srchBar resignFirstResponder];
    CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
    controller.svi=CHRResultSetTypeSearch;
    controller.searchString = self.srchBar.text;
    self.srchBar.text = nil;
    [self.slidingViewController setTopViewController:controller];
    [self.slidingViewController resetTopViewAnimated:YES];
}



@end
