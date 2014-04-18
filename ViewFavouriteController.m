//
//  ViewFavouriteController.m
//  CitatiHR
//
//  Created by Zoran Pleško on 09/04/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//


#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHRAppDelegate.h"
#import "ViewFavouriteController.h"
#import "CHRCitatCell.h"
#import "CHRMasterViewController.h"

@interface ViewFavouriteController () {
    
    NSMutableArray *favoriti;
    
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionf;


@end

@implementation ViewFavouriteController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [self.view addGestureRecognizer:self.slidingViewController.leftPanGesture];
    [self.view addGestureRecognizer:self.slidingViewController.rightPanGesture];
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self fetchContext];
    [self prepareCitati];
    [self.collectionf registerNib:[UINib nibWithNibName:@"CHRCitatCell" bundle:nil] forCellWithReuseIdentifier:@"CitatCell"];
	

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return favoriti.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CitatCell";
    
    CHRCitatCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    NSManagedObject *citatObject = favoriti[indexPath.row];
    cell.citat.text = [citatObject valueForKey:@"text"];
    cell.author.text = [citatObject valueForKey:@"author"];
    return cell;
}



#pragma mark - data preparation

-(void)prepareCitati
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Citation"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    favoriti = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
}

- (BOOL) fetchCitation{
	
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Citation"];
    
    NSError *error;
    favoriti = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    
    if(favoriti.count == 0)
        return NO;
    else
        return YES;
    
}



#pragma mark - DB methods

- (void) fetchContext{
    
    CHRAppDelegate *appDelegate = (CHRAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
}

- (void)saveContext
{
    CHRAppDelegate *appDelegate = (CHRAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
}



@end
