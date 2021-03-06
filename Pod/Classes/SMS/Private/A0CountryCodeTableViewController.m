// A0CountryCodeTableViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0CountryCodeTableViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

static NSString *CellIdentifier = @"CountryCell";
static NSString *CountryCode = @"Code";
static NSString *CountryDialCode = @"DialCode";
static NSString *CountryName = @"Name";

@interface A0CountryCodeTableViewController () <UISearchDisplayDelegate>
@property (strong, nonatomic) NSArray *countryCodes;
@property (strong, nonatomic) NSArray *filteredCountryCodes;
@end

@implementation A0CountryCodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.countryCodes = [A0CountryCodeTableViewController loadCountryCodes];
    self.countryCodes = [self.countryCodes sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *left, NSDictionary *right) {
        NSComparisonResult order = NSOrderedAscending;
        if ([self.defaultCountry isEqualToString:right[CountryCode]]) {
            order = NSOrderedDescending;
        }
        return order;
    }];
    NSLocale *locale = [NSLocale currentLocale];
    self.countryCodes = [self.countryCodes map:^id(NSDictionary *country) {
        NSMutableDictionary *countryWithName = [country mutableCopy];
        NSString *name = [locale displayNameForKey:NSLocaleCountryCode value:country[CountryCode]];
        if(name) {
            countryWithName[CountryName] = name;
        } else {
            countryWithName[CountryName] = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:country[CountryCode]];
        }

        return countryWithName;
    }];

    UINib *cellNib = [UINib nibWithNibName:@"A0CountryCodeTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.searchDisplayController.searchBar.placeholder = NSLocalizedStringFromTable(@"Search", @"Auth0.SMS", @"Search Country Placeholder");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.searchDisplayController.navigationItem.hidesBackButton = YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

+ (NSString *)dialCodeForCountryWithCode:(NSString *)code {
    NSArray *codes = [self loadCountryCodes];
    NSDictionary *country = [codes find:^BOOL(NSDictionary *country) {
        return [country[CountryCode] isEqualToString:code];
    }];
    return [self dialCodeForCountry:country];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.filteredCountryCodes = [self.countryCodes select:^BOOL(NSDictionary *country) {
        NSRange nameRange = [country[CountryName] rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
        NSRange codeRange = [country[CountryCode] rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
        return nameRange.location != NSNotFound || codeRange.location != NSNotFound;
    }];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self countryCodesSourceForTableView:tableView] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *countries = [self countryCodesSourceForTableView:tableView];
    NSDictionary *country = countries[indexPath.row];
    cell.textLabel.text = country[CountryName];
    cell.detailTextLabel.text = country[CountryDialCode];
    if ([self.defaultCountry isEqualToString:country[CountryCode]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
    NSArray *countries = [self countryCodesSourceForTableView:tableView];
    NSDictionary *country = countries[indexPath.row];
    if (self.onCountrySelect) {
        self.onCountrySelect(country[CountryCode], [A0CountryCodeTableViewController dialCodeForCountry:country]);
    }
}

#pragma mark - Utility methods

+ (NSString *)dialCodeForCountry:(NSDictionary *)country {
    if ([country[CountryCode] isEqualToString:@"AR"]) {
        return [country[CountryDialCode] stringByAppendingString:@" 9 "];
    } else {
        return country[CountryDialCode];
    }
}

- (NSArray *)countryCodesSourceForTableView:(UITableView *)tableView {
    NSArray *countries = self.tableView == tableView ? self.countryCodes : self.filteredCountryCodes;
    return countries;
}

+ (NSArray *)loadCountryCodes {
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Auth0.SMS" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"CountryCodes" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:plistPath];
}

@end
