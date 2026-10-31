//
//  ReelView.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "ReelView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ReelView()

// Ideally I would use a collection view to implement an infinite scroll.
@property (strong, nonatomic) UIStackView *stackOne;
@property (strong, nonatomic) UIStackView *stackTwo;
@property (strong, nonatomic) NSLayoutConstraint *stackOneOffset;
@property (strong, nonatomic) NSLayoutConstraint *stackTwoOffset;
@property (assign, nonatomic) NSTimeInterval randomSpinDuration;
@property (strong, nonatomic) NSArray <NSString *>*imageNames;
@property (assign, nonatomic) CGFloat reelHeight;
@property (assign, nonatomic) CGFloat totalHeight;
@end

@implementation ReelView

// This is more of a component so if it had a model it would be more of a domain model according to data displayed, than a view model managing state.
-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectZero];
    self.translatesAutoresizingMaskIntoConstraints = false;
    self.imageNames = @[@"slot-bell",
                        @"slot-diamond",
                        @"slot-cherries",
                        @"slot-lemon",
                        @"slot-star",
                        @"slot-seven",
                        @"slot-bell",
                        @"slot-diamond",
                        @"slot-cherries"];
    
    self.reelHeight = 120.0;
    self.totalHeight = 240.0;
    [self configureSubviews];

    return self;
}

- (void)resetDisplay {
    
    __weak typeof(self) weakSelf = self;
    CGFloat restingStacksOffset =  -self.reelHeight - [self centeredOffset];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.stackOne.alpha = 0;
        weakSelf.stackTwo.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.stackOneOffset.constant = restingStacksOffset;
        weakSelf.stackTwoOffset.constant = restingStacksOffset;
        [weakSelf layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.stackOne.alpha = 1;
            weakSelf.stackTwo.alpha = 1;
        }];
    }];
}

- (void)spinNowtoIndex:(NSUInteger)index completion:(void(^)(void))completion {
    _randomSpinDuration = (((100.0 - (arc4random_uniform(10))))/100)*1.0;
    
    NSUInteger numberOfSpins = arc4random_uniform(5) + 5;
    
    __weak typeof(self) weakSelf = self;
    
    weakSelf.stackTwo.hidden = YES;
    weakSelf.stackOne.hidden = NO;

    NSUInteger imagesCount = self.imageNames.count;
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.stackOneOffset.constant = -self.reelHeight*(imagesCount-2) - [self centeredOffset];
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        weakSelf.stackOne.hidden = YES;
        weakSelf.stackTwo.hidden = NO;
        weakSelf.stackOneOffset.constant = 0;
        [weakSelf spinMoreIsTop:NO
                        toIndex: index
                  numberOfSpins:numberOfSpins
                     completion: completion];
    }];
}

- (CGFloat)destinationOffsetForAnimatedReel:(NSUInteger)index
                                      spins:(NSUInteger)spins {
    CGFloat constantTo;
    if (spins == 0) {
        if (index == 0) { // bell
            constantTo = -self.reelHeight*(self.imageNames.count-4);
        } else if (index == 1) { // diamond
            constantTo = -self.reelHeight*(self.imageNames.count-3);
        } else  {
            constantTo = -self.reelHeight*(index-1);
        }
        
    } else {
        constantTo = -self.reelHeight*(self.imageNames.count-2);
    }
    
    constantTo -= - [self centeredOffset];
    return constantTo;
}

- (void)spinMoreIsTop:(BOOL)isTop
              toIndex:(NSUInteger)index
        numberOfSpins:(NSUInteger)spins
           completion:(void(^)(void))completionBlock {
    
    CGFloat destinationOffset = [self destinationOffsetForAnimatedReel:index
                                                                 spins: spins];

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_randomSpinDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
       
        if (isTop) {
            weakSelf.stackOneOffset.constant = destinationOffset;
        } else {
            weakSelf.stackTwoOffset.constant = destinationOffset;
        }
        
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {

        if (spins > 0) {
            
            weakSelf.stackTwo.hidden = !isTop;
            weakSelf.stackOne.hidden = isTop;
            weakSelf.stackOneOffset.constant = 0;
            weakSelf.stackTwoOffset.constant = 0;
        
            [weakSelf setNeedsLayout];
            
            [weakSelf spinMoreIsTop:!isTop
                            toIndex:index
                      numberOfSpins:spins-1
                         completion:completionBlock];
            return;
        }
        
        AudioServicesPlaySystemSound(1103);
        completionBlock();
    }];
}

- (UIView *)slotImageView:(NSString *) image {
    UIImageView *imageView = [UIImageView new];

    imageView.translatesAutoresizingMaskIntoConstraints = false;
    imageView.image = [UIImage imageNamed:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeHeight
                              multiplier:1 constant:self.reelHeight]];
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeWidth
                              multiplier:1 constant:self.reelHeight]];
    return imageView;
}

- (CGFloat) centeredOffset {
    return (self.totalHeight - self.reelHeight*3)/2;
}

- (void) configureSubviews {
    
    UIStackView *topScrollStack = [UIStackView new];
    topScrollStack.translatesAutoresizingMaskIntoConstraints = false;
    topScrollStack.axis = UILayoutConstraintAxisVertical;
    
    UIStackView *bottomScrollStack = [UIStackView new];
    bottomScrollStack.translatesAutoresizingMaskIntoConstraints = false;
    bottomScrollStack.axis = UILayoutConstraintAxisVertical;

    [self.imageNames enumerateObjectsUsingBlock:^(NSString * _Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        [topScrollStack addArrangedSubview:[self slotImageView:imageName]];
        [bottomScrollStack addArrangedSubview:[self slotImageView:imageName]];
    }];
    
    [self addSubview:bottomScrollStack];
    [self addSubview:topScrollStack];
    
    CGFloat centeredOffset = [self centeredOffset];

    NSLayoutConstraint *constraintTop = [topScrollStack.topAnchor constraintEqualToAnchor:self.topAnchor constant: centeredOffset];
    NSLayoutConstraint *constraintBottomStackTop = [bottomScrollStack.topAnchor constraintEqualToAnchor:self.topAnchor constant: centeredOffset];
    
    [NSLayoutConstraint activateConstraints:@[constraintBottomStackTop,
                                              constraintTop,
                                              [topScrollStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                              [bottomScrollStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                              [self.heightAnchor constraintEqualToConstant:self.totalHeight],
                                              [self.widthAnchor constraintEqualToConstant:self.reelHeight] ]];
    
    self.stackOne = topScrollStack;
    self.stackOneOffset = constraintTop;
    self.stackTwo = bottomScrollStack;
    self.stackTwoOffset = constraintBottomStackTop;
    self.clipsToBounds = true;
}

@end
