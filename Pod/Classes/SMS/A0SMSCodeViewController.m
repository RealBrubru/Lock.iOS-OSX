// A0SMSCodeViewController.m
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

#import "A0SMSCodeViewController.h"
#import "A0CredentialFieldView.h"
#import "A0ProgressButton.h"
#import "A0Theme.h"
#import "A0UIUtilities.h"
#import "A0APIClient.h"
#import "A0Errors.h"

#import <libextobjc/EXTScope.h>

@interface A0SMSCodeViewController ()

@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *codeFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)login:(id)sender;

@end

@implementation A0SMSCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = A0LocalizedString(@"Enter SMS code");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureTextField:self.codeFieldView.textField];
    [theme configurePrimaryButton:self.loginButton];
    [theme configureLabel:self.messageLabel];
    [self.loginButton setTitle:A0LocalizedString(@"LOGIN") forState:UIControlStateNormal];
    NSString *message = [NSString stringWithFormat:A0LocalizedString(@"Please check your phone %@.\nYou’ve received a message from us with your passcode"), self.phoneNumber];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:message];
    if (self.phoneNumber) {
        NSRange phoneRange = [message rangeOfString:self.phoneNumber];
        [attrString setAttributes:@{
                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:self.messageLabel.font.pointSize],
                                    }
                            range:phoneRange];
    }
    self.messageLabel.attributedText = attrString;
    self.codeFieldView.textField.placeholder = A0LocalizedString(@"SMS Code");
}

- (void)login:(id)sender {
    Auth0LogVerbose(@"About to login with phone number %@", self.phoneNumber);
    [self.codeFieldView.textField resignFirstResponder];
    NSString *passcode = [self.codeFieldView.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = passcode.length > 0;
    [self.codeFieldView setInvalid:!valid];
    if (passcode.length > 0) {
        @weakify(self);
        void(^failureBlock)(NSError *) = ^(NSError *error) {
            @strongify(self);
            [self.loginButton setInProgress:NO];
            NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
            NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForSMSLoginError:error];
            A0ShowAlertErrorView(title, message);
        };
        [self.loginButton setInProgress:YES];
        [[A0APIClient sharedClient] loginWithPhoneNumber:self.phoneNumber
                                                passcode:passcode
                                              parameters:self.parameters
                                                 success:self.onAuthenticationBlock
                                                 failure:failureBlock];
    } else {
        Auth0LogError(@"Must provide a non-empty passcode.");
        A0ShowAlertErrorView(A0LocalizedString(@"There was an error logging in"), A0LocalizedString(@"You must enter a valid SMS code"));
    }
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.loginButton.frame fromView:self.loginButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.codeFieldView.textField resignFirstResponder];
}
@end
