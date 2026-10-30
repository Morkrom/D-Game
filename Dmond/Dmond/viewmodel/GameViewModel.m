//
//  GameViewModel.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "GameViewModel.h"

@interface GameViewModel()

typedef NS_ENUM(NSUInteger, ReelSymbol) {
    ReelSymbolBell,
    ReelSymbolDiamond,
    ReelSymbolCherries,
    ReelSymbolLemon,
    ReelSymbolStar,
    ReelSymbolSeven
};

@property (nonatomic, copy) void (^doUpdate) (void);
@property (nonatomic, copy) void (^doShowWinnerScreen) (void);

@end

@implementation GameViewModel


- (id)init {
    self = [super init];
    self.userCredits = @(100);
    self.bettingAmount =@(1);
    return self;
}

- (void)updateInterface {
    if (self.doUpdate == nil) {
        return;
    }
    self.doUpdate();
}

- (BOOL)needsCredits {
    return self.userCredits.unsignedIntValue < self.bettingAmount.unsignedIntValue;
}

- (void)observeForShowWinningScreen:(void(^)(void))doUpdate {
    self.doShowWinnerScreen = doUpdate;
}

- (void)observeDisplayChange:(void(^)(void))doUpdate {
    self.doUpdate = doUpdate;
}

- (void)bettingCreditsAmount:(NSNumber *)creditsAmount {
    self.bettingAmount = creditsAmount;
}

- (void)deductCredit {
    [self setUserCredits:@(self.userCredits.unsignedIntValue - self.bettingAmount.unsignedIntValue)];
    [self updateInterface];
}

- (NSArray <NSNumber *>*) generateReelResults {
    return @[@(arc4random_uniform(6)),
             @(arc4random_uniform(6)),
             @(arc4random_uniform(6))];
}

- (void)refreshForDisplay {
    self.doUpdate();
}

- (void)deductCreditsForReelRoll {
    self.userCredits = @(self.userCredits.unsignedIntValue - self.bettingAmount.unsignedIntValue);
    self.doUpdate();
}

- (void)logReelResults: (NSArray <NSNumber *> *)reelsResults {
    NSNumber *firstItem = [reelsResults firstObject];
    BOOL isWinner = YES;
    
    for (NSNumber *item in reelsResults) {
        if (item.unsignedIntValue != firstItem.unsignedIntValue) {
            isWinner = NO;
            break;
        }
    }
    
    if (isWinner) {
        self.doShowWinnerScreen();
        ReelSymbol symbol = firstItem.unsignedIntValue;
        NSUInteger scoreUp = 0;
        switch (symbol) {
            case ReelSymbolBell:
                scoreUp = 10*self.bettingAmount.unsignedIntValue;
                break;
            case ReelSymbolDiamond:
                scoreUp = 25*self.bettingAmount.unsignedIntValue;
                break;
            case ReelSymbolCherries:
                scoreUp = 2*self.bettingAmount.unsignedIntValue;
                break;
            case ReelSymbolLemon:
                scoreUp = 3*self.bettingAmount.unsignedIntValue;
                break;
            case ReelSymbolStar:
                scoreUp = 15*self.bettingAmount.unsignedIntValue;
                break;
            case ReelSymbolSeven:
                scoreUp = 5*self.bettingAmount.unsignedIntValue;
                break;
        }
        self.userCredits = @(self.userCredits.unsignedIntValue + scoreUp);
    }
    self.doUpdate();
}

@end
