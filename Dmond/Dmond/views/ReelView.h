//
//  ReelView.h
//  Dmond
//
//  Created by M on 10/29/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReelView : UIView

- (void)spinNowtoIndex:(NSUInteger)index completion: (void(^)(void))completion;
- (void)resetDisplay;

@end

NS_ASSUME_NONNULL_END
