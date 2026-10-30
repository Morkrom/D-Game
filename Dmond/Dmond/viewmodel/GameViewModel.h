//
//  GameViewModel.h
//  Dmond
//
//  Created by M on 10/29/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

 
@interface GameViewModel : NSObject

@property (strong, nonatomic) NSNumber *userCredits;
@property (strong, nonatomic) NSNumber *bettingAmount;

- (void)bettingCreditsAmount:(NSNumber *)creditsAmount;
- (void)observeDisplayChange:(void(^)(void))doUpdate;
- (void)observeForShowWinningScreen:(void(^)(void))doUpdate;
- (BOOL)needsCredits;

- (NSArray <NSNumber *>*) generateReelResults;
- (void)logReelResults: (NSArray <NSNumber *> *)reelsResults;
- (void)refreshForDisplay;
- (void)deductCreditsForReelRoll;

@end



NS_ASSUME_NONNULL_END
