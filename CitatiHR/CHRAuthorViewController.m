//
//  CHRAuthorViewController.m
//  CitatiHR
//
//  Created by Zoran Pleško on 27/04/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRAuthorViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHRAppDelegate.h"
#import "CHRMasterViewController.h"

@interface CHRAuthorViewController ()

@property (nonatomic,strong) NSMutableDictionary *dictionary;
@property (nonatomic,strong) NSArray *tblData;
@property (nonatomic,strong) NSMutableArray *tblKeys;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;


@end

@implementation CHRAuthorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:[UIColor colorWithRed:51/255.0 green:153/255.0 blue:204/255.0 alpha:1]];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    //[self.view addGestureRecognizer:self.slidingViewController.leftPanGesture];
    //[self.view addGestureRecognizer:self.slidingViewController.rightPanGesture];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self fetchAuthor];
    
}


- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContext];
    //[self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];



    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//   return _tblKeys[section];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1]]; /*#3399cc*/
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    [sectionLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    sectionLabel.text = _tblKeys[section];
    [sectionView addSubview:sectionLabel];
    return sectionView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _tblKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sect = _tblKeys[section];
    NSArray *data = [_dictionary objectForKey:sect];
    return data.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _tblKeys;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:
                CellIdentifier];
    }
    NSString *sect = _tblKeys[indexPath.section];
    NSArray *data = [_dictionary objectForKey:sect];
    
    NSManagedObject *managedObject = data[indexPath.row];
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    [cell.textLabel setFont:[UIFont fontWithName:@"FontAwesome" size:16]];
    
    // Configure the cell...
    
    return cell;
    
    
}

-(void) fetchAuthor
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Author"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc] init];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    _tblData = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    _tblKeys = [[NSMutableArray alloc] init];
    
    _dictionary = [[NSMutableDictionary alloc] init];
    
    for(NSManagedObject *aut in _tblData){
        NSString *author =[aut valueForKey:@"name"];
        NSString *key = [author substringToIndex:1];
        
        if(![_tblKeys containsObject:key]){
            [_tblKeys addObject:key];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", key];
            NSArray *section = [_tblData filteredArrayUsingPredicate:predicate];
            [_dictionary setObject:section forKey:key];
        }
        
    }
    [self.tableView reloadData];
    
    
    
    
}

- (void) fetchContext{
    
    CHRAppDelegate *appDelegate = (CHRAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
}

- (void)saveContext
{
    CHRAppDelegate *appDelegate = (CHRAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Navigation logic may go here, for example:
     Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    Pass the selected object to the new view controller.
    
    Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
 
   */
    CHRMasterViewController *controller = [[CHRMasterViewController alloc] init];
    controller.svi=CHRResultSetTypeAll;
    
    NSString *sect = _tblKeys[indexPath.section];
    NSArray *data = [_dictionary objectForKey:sect];
    
    NSManagedObject *managedObject = data[indexPath.row];
    controller.autor = [managedObject valueForKey:@"name"];
    
    //[controller setValue:[NSNumber numberWithBool:NO] forKey:@"svi"];
    //CHRMenuViewController *menuController = [[CHRMenuViewController alloc] init];
    [self.slidingViewController setTopViewController:controller];
    
    //[self.slidingViewController setUnderLeftViewController:menuController];
    //[self.slidingViewController resetTopViewAnimated:YES];
    
    
 
}
 


@end
