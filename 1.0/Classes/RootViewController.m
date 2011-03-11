//
//  RootViewController.m
//  The Citizen
//
//  Created by Harry Maclean on 14/09/2010.
//  Copyright City of London School 2010. All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "DownloadPDF.h"
#import "MyTableViewCell.h"


@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib {
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
	UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.rightBarButtonItem = refreshButtonItem;
	[refreshButtonItem release];
	UIBarButtonItem * downloadAllButtonItem = [[UIBarButtonItem alloc] init];
	[downloadAllButtonItem setTarget:self];
	[downloadAllButtonItem setAction:@selector(downloadAll)];
	downloadAllButtonItem.title = @"Download All";
	self.navigationItem.leftBarButtonItem = downloadAllButtonItem;
	[downloadAllButtonItem release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"%@", [DownloadPDF getLocalDocPath:nil]);
	fileManager = [NSFileManager defaultManager];
	downloadPDF = [[DownloadPDF alloc] init];
	totalFileList = [[NSMutableArray alloc] init];
	
	// Check internet connectivity
	connected = YES;
	if (![downloadPDF connectedToInternet]) {
		connected = NO;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"No Internet Connection" message: @"You are not connected to the internet. No issues can be downloaded." delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView  show];
		[alertView  release];
	}
	
	[downloadPDF setDownloadPDFDelegate:self];
	[downloadPDF startAsynchronousOperation:@"files.txt"];
}

- (void)fillTotalFileList {
	[totalFileList removeAllObjects];
	NSString * remoteFileString = [NSString stringWithContentsOfFile:[DownloadPDF getLocalDocPath:@"files.txt"] encoding:NSUTF8StringEncoding error:NULL];
	NSArray * remoteFileList = [remoteFileString componentsSeparatedByString:@"\n"];
	NSMutableArray * tempfileList = [NSMutableArray arrayWithCapacity:[remoteFileList count]];
	
	// Correct ".pdf" inconsistencies
	for (NSString * str in remoteFileList) {
		if ([str pathExtension] != @"pdf") {
			str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; 
			str = [str stringByAppendingString:@".pdf"];
		}
		[tempfileList addObject:str];
	}
	remoteFileList = [tempfileList copy];
	
	localFileSet = [NSMutableSet setWithArray:[fileManager contentsOfDirectoryAtPath:[DownloadPDF getLocalDocPath:nil] error:NULL]];
	NSNumber * num;
	for (NSString * str in remoteFileList) {
		if ([localFileSet containsObject:str]) {
			num = [NSNumber numberWithBool:YES];
		}
		else {
			num = [NSNumber numberWithBool:NO];
		}
		
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:str, @"filename", num, @"hasBeenDownloaded", nil];
		[totalFileList addObject:dict];
	}
	[self.tableView reloadData];
	[remoteFileList release];
}

- (void)fileWasDownloaded:(NSString *)filename {
	[self fillTotalFileList];
}

- (void)refresh {
	connected = YES;
	if (![downloadPDF connectedToInternet]) {
		connected = NO;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"No Internet Connection" message: @"You are not connected to the internet. No issues can be downloaded." delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView  show];
		[alertView  release];
	}
	else {
		[downloadPDF startAsynchronousOperation:@"files.txt"];
	}	
}

- (void)downloadAll {
	for (MyTableViewCell * cell in [self.tableView visibleCells]) {
		NSLog(@"%@", [cell class]);
		if (cell.button.enabled == YES) {
			//cell.enabled = NO;
			[cell startAnimation];
		}
	}
	for (NSDictionary * dict in totalFileList) {
		if ([dict objectForKey:@"hasBeenDownloaded"] == [NSNumber numberWithBool:NO]) {
			[downloadPDF startAsynchronousOperation:[dict objectForKey:@"filename"]];
		}
	}
}

- (void)downloadFile:(UIButton *)sender {
	if (connected) {
		sender.enabled = NO;
		NSNumber * index = [NSNumber numberWithInt:[sender tag]];
		NSLog(@"%i", index);
		NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[index intValue] inSection:0];
		MyTableViewCell * cell = (MyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		NSLog(@"%@", cell);
		[cell startAnimation];
		NSDictionary * dict = [totalFileList objectAtIndex:[sender tag]];
		[downloadPDF startAsynchronousOperation:[dict objectForKey:@"filename"]];
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [totalFileList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MyTableViewCell";
    MyTableViewCell *cell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:nil options:nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (MyTableViewCell *) currentObject;
				break;
			}
		}
    }
	cell.button.tag = indexPath.row;
	[cell.button addTarget:self action:@selector(downloadFile:) forControlEvents:UIControlEventTouchUpInside];
	UIImage * img = [UIImage imageNamed:@"download_button.png"];
	[cell.button setImage:img forState:UIControlStateNormal];
	
	NSDictionary * dict = [totalFileList objectAtIndex:indexPath.row];
	
	if ([fileManager fileExistsAtPath:[DownloadPDF getLocalDocPath:[dict objectForKey:@"filename"]]]) {
		[cell stopAnimation];
	}
	
	NSMutableString * dateLabel = [NSMutableString stringWithString:[[[dict objectForKey:@"filename"] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"citizen" withString:@""]];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd"];
	NSDate *myDate = [df dateFromString: dateLabel];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setDateFormat:@"dd MMMM, yyyy"];
	NSMutableString *stringLabel = [NSMutableString stringWithString:[df stringFromDate:myDate]];
	[df release];
	
	stringLabel = [NSMutableString stringWithString:[stringLabel stringByDeletingPathExtension]];
	cell.button.enabled = NO;
	cell.button.alpha = 0;
	[cell.title setTextColor:[UIColor blackColor]];
	if ([dict objectForKey:@"hasBeenDownloaded"] == [NSNumber numberWithBool:NO]) {
		cell.button.alpha = 1;
		if (connected) {
			cell.button.enabled = YES;
		}
		[cell.title setTextColor:[UIColor lightGrayColor]];
	}
	cell.title.text = stringLabel;
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary * dict = [totalFileList objectAtIndex:indexPath.row];
	if ([dict objectForKey:@"hasBeenDownloaded"] == [NSNumber numberWithBool:YES]) {
		FirstViewController *firstViewController = [[FirstViewController alloc] initWithNibName:@"firstViewController" bundle:nil];
		[firstViewController setFilename:[dict objectForKey:@"filename"]];

		[self.navigationController pushViewController:firstViewController animated:YES];
		[firstViewController release];
	}
	else {
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[totalFileList release];
	[downloadPDF release];
    [super dealloc];
}


@end

