//
//  CHRMasterViewController.m
//  CitatiHR
//
//  Created by Zoran Pleško on 22/02/14.
//  Copyright (c) 2014 Zoran Pleško. All rights reserved.
//

#import "CHRMasterViewController.h"

#import "CHRDetailViewController.h"
#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHRAppDelegate.h"
#import "CHRCitatCell.h"
#import "CHREmptyCitationCell.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "Citation.h"
#import "Author.h"
#import "Theme.h"

@interface CHRMasterViewController (){
    
    NSMutableArray *citati;
    
    
}

@property (nonatomic, weak) IBOutlet UICollectionView *collection;




@end

@implementation CHRMasterViewController

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
    self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    


    
    [self fetchContext];
    //[self createTestData];
    [self prepareCitati];
    [self.collection registerNib:[UINib nibWithNibName:@"CHRCitatCell" bundle:nil] forCellWithReuseIdentifier:@"CitatCell"];
    [self.collection registerNib:[UINib nibWithNibName:@"CHREmptyCitationCell" bundle:nil] forCellWithReuseIdentifier:@"EmptyCell"];
	

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    switch (_svi) {
        case CHRResultSetTypeAll:
            return citati.count;
            break;
        case CHRResultSetTypeSearch:
        case CHRResultSetTypeFavorites:
            if( citati.count == 0 ) return 1;
            else return citati.count;
            break;
        default:
            return citati.count;
            break;
    }
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_svi) {
        case CHRResultSetTypeSearch:
            if( citati.count == 0 ) return [self collectionView:cv emptyCellForIndexPath:indexPath];
            else return [self collectionView:cv CitationForIndexPath:indexPath];
            break;
        case CHRResultSetTypeAll:
            return [self collectionView:cv CitationForIndexPath:indexPath];
            break;
        case CHRResultSetTypeFavorites:
            if( citati.count == 0 ) return [self collectionView:cv emptyCellForIndexPath:indexPath];
            else return [self collectionView:cv CitationForIndexPath:indexPath];
            break;
        default:
            return nil;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv emptyCellForIndexPath:(NSIndexPath *)indexPath{
    static NSString *EmptyCellIdentifier = @"EmptyCell";
    CHREmptyCitationCell *cell;
    cell = [cv dequeueReusableCellWithReuseIdentifier:EmptyCellIdentifier forIndexPath:indexPath];
    if(_svi == CHRResultSetTypeSearch){
        NSString *msgText = [NSString stringWithFormat:@"Nema nijednog citata koji sadrži \"%@\"", _searchString];
        cell.messageView.text = msgText;
    }
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv CitationForIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CitatCell";
    CHRCitatCell *cell;
    cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    Citation *citatObject = citati[indexPath.row];
    cell.citat.text = citatObject.text;
    cell.author.text = citatObject.author.name;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString  *favouriteText;
    NSArray *indexPaths = [self.collection indexPathsForSelectedItems];
    Citation  *selectedCitation = [citati objectAtIndex:[indexPaths[0] row]];

    if (selectedCitation.favourite.boolValue)
        favouriteText = @"Makni iz zabiljeski";
    else
        favouriteText = @"Zabiljezi";
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Odustani"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Podijeli na Facebook",favouriteText, nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}



#pragma mark - data preparation

-(void)prepareCitati
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Citation"];
    switch (_svi) {
        case CHRResultSetTypeAll:
            if(self.autor) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author.name = %@", self.autor];
                [fetchRequest setPredicate:predicate];
            }
            if(self.tematika) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"theme.text = %@", self.tematika];
                [fetchRequest setPredicate:predicate];
                
            }
            break;
        case CHRResultSetTypeSearch:
            [fetchRequest setPredicate:[self createPredicateFromSearchString]];
            break;
        case CHRResultSetTypeFavorites:{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favourite = %@", [NSNumber numberWithBool:YES]];
            [fetchRequest setPredicate:predicate];
            }
            break;
        default:
            break;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    citati = [[_managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
}

-(NSPredicate *)createPredicateFromSearchString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@", _searchString];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"author.name contains[cd] %@", _searchString];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, predicate2]];
    return compoundPredicate;
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


#pragma mark - Test Data

- (void)createTestData
{
    if(![self fetchCitation]){
        
        [self staviCitat];
    }
}

- (BOOL) fetchCitation{
	
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Citation"];
	   
    
    NSError *error;
    citati = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];

    if(citati.count == 0)
        return NO;
    else
        return YES;
    
}


- (void)staviCitat
{
    NSArray *tematike=@[@"Ambicija", @"Bog-Religija-Vjera", @"Cast", @"Cinizam", @"Diktatura-Tiranija", @"Egozam", @"Glupost", @"Filozofija", @"Jezik", @"Karakter", @"Ljepota", @"Mir", @"Um-Razum", @"Umjetnost", @"Zakon",@"Zlo"];
    
    NSArray *tekstCitata=@[@"Planovi na papiru, uvijek ostaju tek dobre nakane.", @"Obuzdaj gnjev, on zapovijeda, ako se ne pokorava.", @"Čuvaj se pljuvanja protiv vjera.", @"Objekt nikada nije potpuno neovisan o subjektu koji ga promatra.",@"Blagodat je jedan od najsuptilnijih znakova otmjenog i plemenitog čovjeka.", @"Čast je vanjska savjest, a savjest je unutarnja čast.", @"Sreću koju tražimo samo za sebe, nikada nećemo pronaći.",@"Nikada potpuno ne vjeruj novom prijatelju ni starom neprijatelju.",@"Ali ja postojim samo kad sam s drugim, sam nisam ništa.",@"Oni koji mogu pobijediti u ratu rijetko su dobri u stvaranju mira, a oni koji su uspješni mirotvorci, nikada ne bi pobijedili u ratu.",@"Onog dana kada znanost počne proučavati ne duhovne pojave, u deset godina napredovati će više nego u ranijim stoljećima svoje povijesti.",@"Tko započinje molitvu mora zamišljati da na radost svojega Gospodina sadi biljke u vrlo neplodnu tlu prepunom korova.",@"Ako želite da se nešto dobro napravi, napravite to sami.",@"U okolnostima mira, ratnički čovjek navaljuje na sama sebe.",@"Vjerovati u sve, sumnjati u sve; oba načina života čuvaju od razmišljanja.",@"Čelnik koji donosi mnogo odluka istodobno je lijen i nedjelotvoran."];
    NSArray *autorCitata=@[@"Peter Drucker", @"Quintus Horatius Flaccus Horacije",@"Friedrich Wilhelm Nietzsche",@"Werner Karl Heisenberg",@"Sara Miles",@"Arthur Schopenhauer",@"Thomas Merton",@"James Kelly",@"Karl Jaspers",@"Winston Churchill", @"Nikola Tesla",@"Sv. Tereza Avilska",@"Napoleon Bonaparte",@"Friedrich Wilhelm Nietzsche",@"Alfred Korzybinski",@"Peter Drucker"];
    
   
    
        for(int i=0; i<tekstCitata.count; i++)
        
        {
            NSManagedObject *theme = [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:_managedObjectContext];
            
            [theme setValue:tematike[i] forKey:@"text"];
            NSMutableSet *citations = [[NSMutableSet alloc] init];
            [theme setValue:citations forKey:@"citations"];
            
            NSManagedObject *citat = [NSEntityDescription insertNewObjectForEntityForName:@"Citation" inManagedObjectContext:_managedObjectContext];
            
            [citat setValue:[tekstCitata objectAtIndex:i] forKey:@"text"];
            [citat setValue:[autorCitata objectAtIndex:i] forKey:@"author"];
            [citat setValue:[NSNumber numberWithBool:NO] forKey:@"favourite"];
            [citat setValue:theme forKey:@"theme"];
            
            [citations addObject:citat];
            
        }
    
            
    
    [self saveContext];
    [self fetchCitation];

   }




-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    
    switch(buttonIndex) {
        case 0:{
            
            if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Molimo postavite Facebook racun u postavkama mobitela." delegate:nil cancelButtonTitle:@"Odustani" otherButtonTitles:nil];
                [alertView show];
                
            }
            else {
                NSArray *indexPaths = [self.collection indexPathsForSelectedItems];
                Citation  *selectedCitation = [citati objectAtIndex:[indexPaths[0] row]];
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [composeViewController setTitle:@"Citati"];
                [composeViewController setInitialText:[NSString stringWithFormat:@"%@ - %@",  [selectedCitation valueForKey:@"text"], [selectedCitation.author valueForKey:@"name"]]];
                
                [self presentViewController:composeViewController animated:YES completion:nil];
               
            }
        
        
        }
        
        case 1:{
            

    
            NSArray *indexPaths = [self.collection indexPathsForSelectedItems];
            Citation *selectedCitation = [citati objectAtIndex:[indexPaths[0] row]];
            NSLog(@"1 clickedButtonAtIndex() : indexPath = %ld", (long)[indexPaths[0] row]);
    
            if (selectedCitation.favourite.boolValue)
                [selectedCitation setValue:[NSNumber numberWithBool:NO] forKey:@"favourite"];
            else [selectedCitation setValue:[NSNumber numberWithBool:YES] forKey:@"favourite"];
    
            CHRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate saveContext];
    
            [self.collection reloadData];
    
            return;
        }
    }

    
    
}





@end
