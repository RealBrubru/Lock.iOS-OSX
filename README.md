# Lock

[![CI Status](http://img.shields.io/travis/auth0/Lock.iOS-OSX.svg?style=flat)](https://travis-ci.org/auth0/Lock.iOS-OSX)
[![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![License](https://img.shields.io/cocoapods/l/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![Platform](https://img.shields.io/cocoapods/p/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

## Key features

* **Integrates** your iOS app with **Auth0**
* Provides a **beautiful native UI** to log your users in
* Provides support for **Social Providers** (Facebook, Twitter, etc.), **Enterprise Providers** (AD, LDAP, etc.) and **Username & Password**
* Provides the ability to do **SSO** with 2 or more mobile apps similar to Facebook and Messenger apps.

![iOS Gif](https://cloudup.com/cnccuUlFiYI+)

## Requierements

iOS 7+. If you need to use our SDK in an earlier version please use our previous SDK pod `Auth0Client` or check the branch [old-sdk](https://github.com/auth0/Lock.iOS-OSX/tree/old-sdk) of this repo.

## Install

The Lock pod is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock", "~> 1.5"
```

Then in your project's `Info.plist` file add the following entries:

* __Auth0ClientId__: The client ID of your application in _Auth0_. You can find this value in your app's settings in [Auth0 dashboard](https://app.auth0.com/#/applications).
* __Auth0Tenant__: The name of your account, if your account's domain in Auth0 is `myaccount.auth0.com`, your tenant name is `myaccount`.  

For example:

[![Auth0 plist](https://cloudup.com/cdHr2oMAN7d+)](http://auth0.com)

Also you need to register a Custom URL type, it must have a custom scheme with the following format `a0<Your Client ID>`. For example if your Client ID is `Exe6ccNagokLH7mBmzFejP` then the custom scheme should be `a0Exe6ccNagokLH7mBmzFejP`.

Then you'll need to handle that custom scheme, so first import __Lock__ header in your `AppDelegate.m` if you are coding in __Objective-C__ or in your _Objective-C Bridging Header_ if you are coding in __Swift__.

```objc
#import <Lock/Lock.h>
```

> If you need help creating the Objective-C Bridging Header, please check the [wiki](https://github.com/auth0/Lock.iOS-OSX/wiki/Lock-&-Swift#create-objective-c-bridging-header)

And override `-application:openURL:sourceApplication:annotation:` method, if you haven't done it before, and add the following implementation:

```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0IdentityProviderAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```
```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    return A0IdentityProviderAuthenticator.sharedInstance().handleURL(url, sourceApplication: sourceApplication)
}
```

> This is required to be able to return back to your application when authenticating with Safari (or native integration with FB or Twitter). This call checks the URL and handles them if their scheme matches the custom scheme defined earlier.

## Usage

If you are working in Objective-C, first import __Lock__ header

```objc
#import <Lock/Lock.h>
```

### Email/Password, Enterprise & Social authentication

`A0LockViewController` will handle Email/Password, Enterprise & Social authentication based on your Application's connections enabled in your Auth0's Dashboard.

To get started, instantiate `A0LockViewController` and register the authentication callback that will receive the authenticated user's credentials. Finally present it as a modal view controller:

```objc
A0LockViewController *controller = [[A0LockViewController alloc] init];
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```
```swift
let lock = A0LockViewController()
lock.onAuthenticationBlock = {(profile: A0UserProfile!, token: A0Token!) -> () in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
self.presentViewController(lock, animated: true, completion: nil)
```
And you'll see our native login screen

[![Lock.png](http://blog.auth0.com.s3.amazonaws.com/Lock-Widget-Screenshot.png)](https://auth0.com)

> By default all social authentication will be done using Safari, if you want native integration please check this [wiki page](https://github.com/auth0/Lock.iOS-OSX/wiki/Native-Social-Authentication).

Also you can check our [Swift](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample-swift) and [Objective-C](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample) example apps. For more information on how to use **Lock** with Swift please check [this guide](https://github.com/auth0/Lock.iOS-OSX/wiki/Lock-&-Swift)

### TouchID

`A0TouchIDLockViewController` authenticates without using a password with TouchID. In order to be able to authenticate the user, your application must have a Database connection enabled.

First instantiate `A0TouchIDLockViewController` and register the authentication callback that will receive the authenticated user's credentials. Finally present it as a modal view controller:
```objc
A0TouchIDLockViewController *controller = [[A0LockViewController alloc] init];
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```
```swift
let lock = A0TouchIDLockViewController()
lock.onAuthenticationBlock = {(profile: A0UserProfile!, token: A0Token!) -> () in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
self.presentViewController(lock, animated: true, completion: nil)
```
And you'll see TouchID login screen

[![Lock.png](http://blog.auth0.com.s3.amazonaws.com/Lock-TouchID-Screenshot.png)](https://auth0.com)

> Because it uses a Database connection, the user can change it's password and authenticate using email/password whenever needed. For example when you change your device.

## SSO

A very cool thing you can do with Lock is use SSO. Imagine you want to create 2 apps. However, you want that if the user is logged in in app A, he will be already logged in in app B as well. Something similar to what happens with Messenger and Facebook as well as Foursquare and Swarm.

Read [this guide](https://github.com/auth0/Lock.iOS-OSX/wiki/SSO-on-Mobile-Apps) to learn how to accomplish this with this library.

##API

###A0LockViewController

####A0LockViewController#init
```objc
- (instancetype)init;
```
Initialise 'A0LockViewController' using `Auth0ClientId` & `Auth0Tenant` from info plist file.
```objc
A0LockViewController *controller = [[A0LockViewController alloc] init];
```

####A0LockViewController#onAuthenticationBlock
```objc
@property (copy, nonatomic) void(^onAuthenticationBlock)(A0UserProfile *profile, A0Token *token);
```
Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
```objc
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Auth successful: profile %@, token %@", profile, token);
};
```

####A0LockViewController#onUserDismissBlock
```objc
@property (copy, nonatomic) void(^onUserDismissBlock)();
```
Block that is called on when the user dismisses the Login screen. Only when `closable` property is `YES`.
```objc
controller.onUserDismissBlock = ^() {
  NSLog(@"User dismissed login screen.");
};
```

####A0LockViewController#usesEmail
```objc
@property (assign, nonatomic) BOOL usesEmail;
```
Enable the username to be treated as an email (and validated as one too) in all Auth0 screens. Default is `YES`
```objc
controller.usesEmail = NO;
```

####A0LockViewController#closable
```objc
@property (assign, nonatomic) BOOL closable;
```
Allows the `A0LockViewController` to be dismissed by adding a button. Default is `NO`
```objc
controller.closable = YES;
```

####A0LockViewController#loginAfterSignup
```objc
@property (assign, nonatomic) BOOL loginAfterSignUp;
```
After a successful Signup, `A0LockViewController` will attempt to login the user if this property is `YES` otherwise will call `onAuthenticationBlock` with both parameters nil. Default value is `YES`
```objc
controller.loginAfterSignup = NO;
```

####A0LockViewController#authenticationParameters
```objc
@property (assign, nonatomic) A0AuthParameters *authenticationParameters;
```
List of optional parameters that will be used for every authentication request with Auth0 API. By default it only has  'openid' and 'offline_access' scope values. For more information check out our [Wiki](https://github.com/auth0/Lock.iOS-OSX/wiki/Sending-authentication-parameters)
```objc
controller.authenticationParameters.scopes = @[A0ScopeOfflineAccess, A0ScopeProfile];
```

###A0LockViewController#signupDisclaimerView
```objc
@property (strong, nonatomic) UIView *signUpDisclaimerView;
```
View that will appear in the bottom of Signup screen. It should be used to show Terms & Conditions of your app.
```objc
UIView *view = //..
controller.signupDisclaimerView = view;
```
####A0LockViewController#useWebView
```objc
@property (assign, nonatomic) BOOL useWebView;
```
When the authentication requires to open a web login, for example Linkedin, it will use an embedded UIWebView instead of Safari if it's `YES`. We recommend using Safari for Authentication since it will always save the User session. This means that if he's already signed in, for example in Linkedin, and he clicks in the Linkedin button, it will just work. Default values is `NO`
```objc
controller.useWebView = YES
```

> For more information please check Lock's documentation in [CocoaDocs](http://cocoadocs.org/docsets/Lock).

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amont others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free account in Auth0

1. Go to [Auth0](https://auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.

## Author

Auth0

## License

Lock is available under the MIT license. See the [LICENSE file](LICENSE) for more info.
