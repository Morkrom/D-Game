//
//  GameViewModel.h
//  Dmond
//
//  Created by M on 10/29/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

 
@interface GameViewModel : NSObject

@property (strong, nonatomic, readonly) NSNumber *userCredits;
@property (strong, nonatomic, readonly) NSNumber *bettingAmount;

- (void)bettingCreditsAmount:(NSNumber *)creditsAmount;
- (void)observeDisplayChange:(void(^)(void))doUpdate;
- (void)observeForShowWinningScreen:(void(^)(void))doUpdate;
- (BOOL)needsCredits;

- (NSArray <NSNumber *>*) generateReelResults;
- (void)logReelResults: (NSArray <NSNumber *> *)reelsResults;

@end



NS_ASSUME_NONNULL_END
