//
//  WorldSeederSpec.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND
#define HC_SHORTHAND
#define MOCKITO_SHORTHAND
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GOLWorld.h"
#import "GOLWorldSeeder.h"
#import "GOLCell.h"


SpecBegin(GOLWorldSeeder)
describe(@"World Seeder", ^{
    __block GOLWorldSeeder *seeder;
    __block CGSize size;
    beforeEach(^{
        size = CGSizeMake(10, 10);
        seeder = [[GOLWorldSeeder alloc] initWithSize:size];
    });
    
    it(@"generates a pattern with the correct dimensions", ^{
        NSString *pattern = [seeder generatePattern];
        NSArray *lines = [pattern componentsSeparatedByString:@"\n"];
        expect(lines).to.haveCountOf(size.height);
        for(NSString *line in lines) {
            expect(line.length).to.equal(size.width);
        }
    });
    
    it(@"generates only live cell if probability is 1", ^{
        seeder.lifeProbability = 1;
        NSString *pattern = [seeder generatePattern];
        NSArray *lines = [pattern componentsSeparatedByString:@"\n"];
        expect(lines).to.haveCountOf(size.height);
        for(NSString *line in lines) {
            for (int i = 0; i < line.length; i++) {
                expect([line characterAtIndex:i]).to.equal('*');
            }
        }
    });
    
    it(@"generates only dead cell if probability is 0", ^{
        seeder.lifeProbability = 0;
        NSString *pattern = [seeder generatePattern];
        NSArray *lines = [pattern componentsSeparatedByString:@"\n"];
        expect(lines).to.haveCountOf(size.height);
        for(NSString *line in lines) {
            for (int i = 0; i < line.length; i++) {
                expect([line characterAtIndex:i]).to.equal('.');
            }
        }
    });
    
});
SpecEnd
