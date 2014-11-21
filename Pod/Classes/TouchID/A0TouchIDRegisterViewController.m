// A0TouchIDRegisterViewController.m
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

#import "A0TouchIDRegisterViewController.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0ProgressButton.h"
#import "A0KeyboardHandler.h"
#import "A0TouchIDSignUpViewController.h"
#import "A0DatabaseLoginViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <libextobjc/EXTScope.h>
#import "A0ChangePasswordViewController.h"
#import "A0AuthParameters.h"
#import "A0NavigationView.h"

@interface A0TouchIDRegisterViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;

@end

@implementation A0TouchIDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayController:[self buildSignUp]];
    A0Theme *theme = [A0Theme sharedInstance];
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor];
    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName];
}

- (UIViewController<A0KeyboardEnabledView> *)buildSignUp {
    @weakify(self);
    A0TouchIDSignUpViewController *signUpController = [[A0TouchIDSignUpViewController alloc] init];
    signUpController.onRegisterBlock = self.onRegisterBlock;
    signUpController.authenticationParameters = self.authenticationParameters;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:self.onCancelBlock];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE AN ACCOUNT?") actionBlock:^{
        @strongify(self);
        A0DatabaseLoginViewController *controller = [self buildLogin];
        controller.defaultUsername = signUpController.emailField.textField.text;
        [self displayController:controller];
    }];
    return signUpController;
}

- (A0DatabaseLoginViewController *)buildLogin {
    @weakify(self);
    A0DatabaseLoginViewController *controller = [[A0DatabaseLoginViewController alloc] init];
    controller.showSignUp = YES;
    controller.showResetPassword = YES;
    controller.parameters = self.authenticationParameters;
    controller.onLoginBlock = self.onRegisterBlock;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        @strongify(self);
        [self displayController:[self buildSignUp]];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        @strongify(self);
        A0ChangePasswordViewController *resetController = [self buildChangePassword];
        resetController.defaultEmail = controller.userField.textField.text;
        [self displayController:resetController];
    }];
    return controller;
}

- (A0ChangePasswordViewController *)buildChangePassword {
    @weakify(self);
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.parameters = self.authenticationParameters;
    controller.onChangePasswordBlock = ^{
        @strongify(self);
        [self displayController:[self buildLogin]];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        @strongify(self);
        A0DatabaseLoginViewController *loginController = [self buildLogin];
        loginController.defaultUsername = controller.userField.textField.text;
        [self displayController:loginController];
    }];
    return controller;
}
@end
