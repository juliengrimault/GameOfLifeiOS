//
//  WorldSpec.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "GOLWorld.h"
#import "GOLCell.h"

SpecBegin(GOLWorld)

describe(@"World", ^{
    __block GOLWorld *world;
    __block CGSize size;
    beforeEach(^{
        size = CGSizeMake(7, 6);
        world = [[GOLWorld alloc] initWithSize:size];
    });
    
    it(@"has a size", ^{
        expect(world.rows).to.equal(size.height);
        expect(world.columns).to.equal(size.width);
    });
    
    it(@"can access a cell", ^{
        GOLCell *cell = [world cellAtRow:0 col:0];
        expect(cell).notTo.beNil;
        
        cell = [world cellAtRow:size.height - 1 col:size.width - 1];
        expect(cell).notTo.beNil;
    });
    
    it(@"initialzes all the cell to dead", ^{
        for (int i = 0; i < size.height; i++) {
            for (int j = 0; j < size.width; j++) {
                id cell = [world cellAtRow:i col:j];
                expect(cell).to.beKindOf([GOLCell class]);
            }
        }
    });
    
    NSString *pattern =
    @"*......\n"
    @".*.....\n"
    @"..*....\n"
    @"...*...\n"
    @"....*..\n"
    @".....*.";
    describe(@"ascii", ^{
        beforeEach(^{
            [world seed:pattern];
        });
        
        it(@"can be seeded", ^{
 
            for (int i = 0; i < size.height; i++) {
                for (int j = 0; j < size.width; j++) {
                    GOLCell *c = [world cellAtRow:i col:j];
                    if (i == j) {
                        expect(c.alive).to.equal(YES);
                    } else {
                        expect(c.alive).to.equal(NO);
                    }
                }
            }
            
        });
        
        it(@"can print an ascii description", ^{
            expect([world asciiDescription]).to.equal(pattern);
        });
    });
    
    it(@"can reset itself to its last seeded value", ^{
        [world seed:pattern];
        [world tick];
        [world reset];
        expect(world.generationCount).to.equal(0);
        expect([world asciiDescription]).to.equal(pattern);
        
    });
    
    it (@"increases generation count by one when ticking", ^{
        [world tick];
        expect(world.generationCount).to.equal(1);
    });
    
    it(@"reset generation count when seeding", ^{
        [world tick];
        [world seed:pattern];
        expect(world.generationCount).to.equal(0);
    });
         
    describe(@"Patterns", ^{
        describe(@"Still patterns", ^{
            NSArray *stillPatterns = @[
              @".......\n"
              @"..**...\n"
              @"..**...\n"
              @".......\n"
              @".......\n"
              @".......",
              
              @".......\n"
              @"..**...\n"
              @".*..*..\n"
              @"..**...\n"
              @".......\n",
              @".......",
              
              @".......\n"
              @"..**...\n"
              @".*..*..\n"
              @"..*.*..\n"
              @"...*...\n",
              @".......",
              
              @".......\n"
              @".**....\n"
              @".*.*...\n"
              @"..*....\n"
              @".......\n",
              @"......."];
            
            for(NSString *p in stillPatterns) {
                [world seed:p];
                [world tick];
                expect([world asciiDescription]).to.equal(p);
            }
        });
        
        describe(@"Cyclic patterns", ^{
            NSArray *blinker = @[
                                 @".......\n"
                                 @".......\n"
                                 @".***...\n"
                                 @".......\n"
                                 @".......\n"
                                 @".......",
                                 
                                 @".......\n"
                                 @"..*....\n"
                                 @"..*....\n"
                                 @"..*....\n"
                                 @".......\n"
                                 @"......."
                                 ];
            
            NSArray *toad = @[
                                  @".......\n"
                                  @".......\n"
                                  @"..***..\n"
                                  @".***...\n"
                                  @".......\n"
                                  @".......",
                              
                                 @".......\n"
                                 @"...*...\n"
                                 @".*..*..\n"
                                 @".*..*..\n"
                                 @"..*....\n"
                                 @"......."
                                 ];
            
            NSArray *beacon = @[
                              @".......\n"
                              @".**....\n"
                              @".**....\n"
                              @"...**..\n"
                              @"...**..\n"
                              @".......",
                              
                              @".......\n"
                              @".**....\n"
                              @".*.....\n"
                              @"....*..\n"
                              @"...**..\n"
                              @"......."];
            
            NSArray *cyclicPatterns = @[blinker, toad, beacon];
            
            it(@"follows the cyclic patterns", ^{
                for(NSArray *cycle in cyclicPatterns) {
                    [world seed:cycle[0]];
                    [world tick];
                    expect([world asciiDescription]).to.equal(cycle[1]);
                }
            });
        });

    });
    
});

SpecEnd
