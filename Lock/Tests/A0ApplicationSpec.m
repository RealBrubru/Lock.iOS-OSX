//  A0ApplicationSpec.m
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

#import "Specta.h"
#import "A0Application.h"
#import "A0Strategy.h"

#define kAppDataKey @"app"
#define kAppIdentifier @"A VALID IDENTIFIER"
#define kTenant @"TENANT"
#define kAuthorizeURL @"https://somewherefarneyond.com"
#define kCallbackURL @"https://callback.to"

SpecBegin(A0Application)

describe(@"A0Application", ^{

    __block A0Application *application;

    NSDictionary *jsonDict = @{
                               @"id": kAppIdentifier,
                               @"tenant": kTenant,
                               @"authorize": kAuthorizeURL,
                               @"callback": kCallbackURL,
                               @"strategies": @[
                                       @{@"name": @"facebook"},
                                       @{@"name": @"twitter"},
                                       @{@"name": @"yahoo"},
                                       ],
                               };

    sharedExamplesFor(@"valid application object", ^(NSDictionary *data) {

        beforeEach(^{
            application = data[kAppDataKey];
        });

        specify(@"valid id", ^{
            expect(application.identifier).to.equal(kAppIdentifier);
        });

        specify(@"valid tenant", ^{
            expect(application.tenant).to.equal(kTenant);
        });

        specify(@"valid authorize URL", ^{
            expect(application.authorizeURL).to.equal([NSURL URLWithString:kAuthorizeURL]);
        });

        specify(@"valid strategies", ^{
            expect(application.strategies).to.haveCountOf(3);
        });
    });

    context(@"object creation from JSON", ^{

        NSString *JSONDictKey = @"JSONDict";

        sharedExamplesFor(@"invalid JSON dictionary", ^(NSDictionary *data) {
            it(@"should fail on init method", ^{
                expect(^{
                    A0Application *app = [[A0Application alloc] initWithJSONDictionary:data[JSONDictKey]];
                    expect(app).to.beNil();
                }).to.raiseAny();
            });
        });

        itBehavesLike(@"valid application object", ^{
            return @{
                     kAppDataKey: [[A0Application alloc] initWithJSONDictionary:jsonDict],
                     };
        });

        itBehavesLike(@"invalid JSON dictionary", @{});

        itBehavesLike(@"invalid JSON dictionary", @{JSONDictKey: @{}});

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"id"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"tenant"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"authorize"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"callback"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"strategies"];
            return dict;
        });

    });

    describe(@"Database Connection strategy handling", ^{

        context(@"when it has auth0 strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                      @{@"name": @"auth0"},
                                      @{@"name": @"twitter"},
                                      ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should indicate that it has a Database Connection", ^{
                expect(application.databaseStrategy).toNot.beNil();
            });

            it(@"should return database connection", ^{
                expect([application.databaseStrategy name]).to.equal(@"auth0");
            });
        });

        context(@"when it has not auth0 strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[ @{ @"name": @"twitter" } ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should indicate that it has no Database Connection", ^{
                expect(application.databaseStrategy).to.beNil();
            });
            
        });

    });

    describe(@"Social strategy handling", ^{

        context(@"when it has a social strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                        @{@"name": A0StrategyNameAuth0},
                                        @{@"name": A0StrategyNameTwitter},
                                      ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should return social strategies", ^{
                expect(application.socialStrategies).to.haveCountOf(1);
            });

            it(@"should have only twitter", ^{
                expect([application.socialStrategies.firstObject name]).to.equal(@"twitter");
            });
        });

        context(@"when it has no social strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                        @{ @"name": A0StrategyNameAuth0 }
                                        ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should return no social strategies", ^{
                expect(application.socialStrategies).to.beEmpty();
            });
        });
        
    });

    describe(@"Enterprise strategy handling", ^{

        context(@"when it has an enterprise strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                        @{@"name": A0StrategyNameAuth0},
                                        @{@"name": A0StrategyNameTwitter},
                                        @{@"name": A0StrategyNameActiveDirectory},
                                        ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should return enterprise strategies", ^{
                expect(application.enterpriseStrategies).to.haveCountOf(1);
            });

            it(@"should have only have ad", ^{
                expect([application.enterpriseStrategies.firstObject name]).to.equal(@"ad");
            });
        });

        context(@"when it has no enterprise strategy", ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                        @{@"name": A0StrategyNameAuth0},
                                        @{@"name": A0StrategyNameTwitter},
                                        ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should return no enterprise strategies", ^{
                expect(application.enterpriseStrategies).to.beEmpty();
            });
        });

        describe(NSStringFromSelector(@selector(enterpriseStrategyWithConnection:)), ^{

            beforeEach(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"strategies"] = @[
                                        @{
                                            @"name": A0StrategyNameActiveDirectory,
                                            @"connections": @[@{@"name": @"myAD"}],
                                        },
                                        @{
                                            @"name": A0StrategyNameADFS,
                                            @"connections": @[@{@"name": @"myADFS"}],
                                        },
                                    ];
                application = [[A0Application alloc] initWithJSONDictionary:dict];
            });

            it(@"should return a strategy", ^{
                expect([application enterpriseStrategyWithConnection:@"myADFS"]).toNot.beNil();
            });

            it(@"should return ADFS strategy", ^{
                A0Strategy *strategy = [application enterpriseStrategyWithConnection:@"myADFS"];
                expect(strategy.name).to.equal(A0StrategyNameADFS);
            });

            it(@"should return nil with unkown connection name", ^{
                expect([application enterpriseStrategyWithConnection:@"otherADFS"]).to.beNil();
            });

        });
    });

});

SpecEnd
