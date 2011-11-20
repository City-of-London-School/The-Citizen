//
//  DYGroupedViewController.m
//  The Citizen
//
//  Created by Harry Maclean on 19/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DYGroupedViewController.h"
#import "NSDate+Conveniences.h"
#import "ProgressCell.h"

@implementation DYGroupedViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize year = _year;
@synthesize server = _server;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Issues";
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        downloading = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.server monthsForYear:self.year] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Returns section title
    NSArray *months = [self.server months];
    NSArray *monthsForYear = [self.server monthsForYear:self.year];
    int month = [[monthsForYear objectAtIndex:section] intValue];
    return [months objectAtIndex:month-1];
//    return [[self.server months] objectAtIndex:[[[self.server monthsForYear:self.year] objectAtIndex:section] intValue]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int month = [[[self.server monthsForYear:self.year] objectAtIndex:section] intValue];
    int i = [[self.server issuesForYear:self.year month:month] count];
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgressCell";
    
    ProgressCell *cell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:self options:nil];
        cell = (ProgressCell *)[nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath :(NSIndexPath *)indexPath {
    int month = [[[self.server monthsForYear:self.year] objectAtIndex:indexPath.section] intValue];
    NSArray *arr = [self.server issuesForYear:self.year month:month];
    Issue * issue = [arr objectAtIndex:indexPath.row];
    cell.textLabel.text = [issue.date stringValueWithFormat:@"EEEE d"];
    if (![issue.existsLocally boolValue]) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int month = [[[self.server monthsForYear:self.year] objectAtIndex:indexPath.section] intValue];
    Issue *issue = [[self.server issuesForYear:self.year month:month] objectAtIndex:indexPath.row];
    if (![issue.existsLocally boolValue]) {
        [self.server downloadIssue:issue sender:self];
        // Get the currently selected cell
        for (ProgressCell *c in [self.tableView visibleCells]) {
            if (c.isSelected) {
                [c startProgressBar];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:issue, @"issue", c, @"cell", nil];
                [downloading addObject:dict];
                break;
            }
        }
//        ProgressCell *cell = (ProgressCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if (!self.detailViewController) {
        self.detailViewController = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
        self.detailViewController.navBar = YES;
    }
    NSURL *path = [[[[[UIApplication sharedApplication] delegate] performSelector:@selector(applicationDocumentsDirectory)] URLByAppendingPathComponent:issue.pdfPath] URLByAppendingPathExtension:@"pdf"];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)path);
    self.detailViewController.pdf = pdf;
    self.detailViewController.navBar = YES;
    [self.detailViewController renderIssue];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    return;
}

#pragma mark - Server delegate

- (void)download:(NSDictionary *)response progressed:(float)progress {
    NSDictionary *data = [response objectForKey:@"userData"];
    Issue *issue = [data objectForKey:@"issue"];
    for (NSDictionary *dict in downloading) {
        if ([[[dict objectForKey:@"issue"] date] isEqualToDate:issue.date]) {
            if (progress == 1) {
                [(ProgressCell *)[dict objectForKey:@"cell"] stopProgressBar];
            }
            else {
                [(ProgressCell *)[dict objectForKey:@"cell"] incrementProgressBarByAmount:progress];
            }
            return;
        }
    }
}

#pragma mark - Issue sorting

- (NSArray *)issuesForYear:(int)year month:(int)month {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [self allIssueDates]) {
        if (year == [[dict objectForKey:@"year"] intValue] && month == [[dict objectForKey:@"month"] intValue]) {
            [arr addObject:dict];
        }
    }
    return (NSArray *)arr;
}

- (NSArray *)monthsForYear:(int)year {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [self allIssueDates]) {
        if ([[dict objectForKey:@"year"] intValue] != year) {
            continue;
        }
        BOOL isThere = NO;
        for (NSNumber *n in arr) {
            if ([n intValue] == [[dict objectForKey:@"month"] intValue]) {
                isThere = YES;
            }
        }
        if (!isThere) {
            [arr addObject:[dict objectForKey:@"month"]];
        }
    }
    return (NSArray *)arr;
}

// Todo: Optimise this by fetching only issues of the right year from Core Data
- (NSArray *)allIssueDates {
    if (_dates) {
        return _dates;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (Issue *issue in [self.fetchedResultsController fetchedObjects]) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:issue.date];
        NSInteger theYear = [components year];
        NSInteger theMonth = [components month];
        NSInteger theDay = [components day];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:theYear], @"year", [NSNumber numberWithInteger:theMonth], @"month", [NSNumber numberWithInteger:theDay], @"day", issue, @"issue", nil];
        [arr addObject:dict];
    }
    _dates = (NSArray *)arr;
    return _dates;
}

- (NSArray *)months {
    return [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
}

- (NSIndexPath *)indexPathForIssue:(Issue *)issue {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:issue.date];
    NSInteger theMonth = [components month];
    NSInteger theDay = [components day];
    NSArray *issues = [self issuesForYear:self.year month:theMonth];
    int index = 0;
    for (NSDictionary *dict in issues) {
        if ([[dict objectForKey:@"day"] intValue] == theDay) {
            break;
        }
        index++;
    }
    Issue *i = [[issues objectAtIndex:index] objectForKey:@"issue"];
    NSDate *date = i.date;
    if (![date isEqualToDate:issue.date]) {
        NSLog(@"Issue not found.");
        return nil;
    }
    NSArray *months = [self monthsForYear:self.year];
    int j = 0;
    for (NSNumber *n in months) {
        if ([n intValue] == theMonth) {
            break;
        }
        j++;
    }
    return [NSIndexPath indexPathForRow:index inSection:j];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"MMMMEEEEd" options:0 locale:[NSLocale currentLocale]];
    [f setDateFormat:format];
    return [f stringFromDate:date];
}

#pragma mark Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
} 

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            indexPath = [self indexPathForIssue:(Issue *)anObject];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

@end
