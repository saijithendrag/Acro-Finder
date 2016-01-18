//
//  AcroSearchTableViewController.m
//  Acro Finder
//
//  Created by Sai Gogineni on 1/18/16.
//  Copyright (c) 2016 Sai Gogineni. All rights reserved.
//

#import "AcroSearchTableViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface AcroSearchTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *acronymsArray;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@end

@implementation AcroSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _acronymsArray = [[NSMutableArray alloc] init];
}

#pragma mark - Action Methods

- (IBAction)searchClicked:(UIBarButtonItem *)sender
{
    if ([_searchTextField.text isEqualToString:@""])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Please give some input" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"sf": _searchTextField.text};
        [manager GET:@"http://www.nactem.ac.uk/software/acromine/dictionary.py" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSError *error = nil;
             [_acronymsArray removeAllObjects];
             
             NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (resultArray)
                 {
                     if (resultArray.count == 0) {
                         UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No Abbrevations found." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         [errorAlert show];
                         return;
                     }
                     
                     [_acronymsArray addObjectsFromArray:resultArray];
                 }
                 
                 if (error) {
                     UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to convert response" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [errorAlert show];
                 }
                 
                 [self.tableView reloadData];
                 
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             });
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [errorAlert show];
         }];
    });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _acronymsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[_acronymsArray[section] valueForKey:@"lfs"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AcroResultCell" forIndexPath:indexPath];
    
    NSDictionary *resultDictionary = [[[_acronymsArray objectAtIndex:indexPath.section] valueForKey:@"lfs"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [resultDictionary valueForKey:@"lf"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_acronymsArray[section] valueForKey:@"sf"];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Please give some input" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        
        return YES;
    }
    
    [textField resignFirstResponder];
    [self searchClicked:_searchButton];
    return YES;
}



@end
