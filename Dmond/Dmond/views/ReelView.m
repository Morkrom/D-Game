//
//  ReelView.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "ReelView.h"

@interface ReelView()

// Ideally I would use a collection view to implement an infinite scroll.
@property (strong, nonatomic) UIStackView *stackOne;
@property (strong, nonatomic) UIStackView *stackTwo;
@property (strong, nonatomic) NSLayoutConstraint *stackOneOffset;
@property (strong, nonatomic) NSLayoutConstraint *stackTwoOffset;

@end

@implementation ReelView

- (void)resetDisplay {
    
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.stackOne.alpha = 0;
        weakSelf.stackTwo.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.stackOneOffset.constant = 0;
        weakSelf.stackTwoOffset.constant = 0;
        [weakSelf layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{}];
    }];
}

- (void)spinNowtoIndex:(NSUInteger)index completion:(void(^)(void))completion {
    
    NSUInteger numberOfSpins = arc4random_uniform(10) + 5;
    
    __weak typeof(self) weakSelf = self;
    
//    self.stackTwo.hidden = YES;
//    self.stackOne.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.stackOneOffset.constant = -120*6;
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

- (void)spinMoreIsTop:(BOOL)isTop toIndex:(NSUInteger) index numberOfSpins:(NSUInteger)spins completion:(void(^)(void))completionBlock {
    __weak typeof(self) weakSelf = self;

    CGFloat constantTo = spins == 0 ? -120*index : -120*6;
    
    NSLayoutConstraint *determinedStack = isTop ? self.stackOneOffset : self.stackTwoOffset;
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        determinedStack.constant = constantTo;
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (spins > 0) {
            weakSelf.stackOne.hidden = isTop;
            weakSelf.stackTwo.hidden = !isTop;
            determinedStack.constant = 0;
            [weakSelf spinMoreIsTop:!isTop toIndex:index numberOfSpins:spins-1 completion:completionBlock];
            return;
        }
        completionBlock();
    }];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    self.translatesAutoresizingMaskIntoConstraints = false;
    [self configureDimension];
    self.backgroundColor = [UIColor blueColor];
    return self;
}

- (UIView *)slotImageView:(NSString *) image {
    UIImageView *imageView = [UIImageView new];
    imageView.translatesAutoresizingMaskIntoConstraints = false;
    imageView.image = [UIImage imageNamed:image];
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeHeight
                              multiplier:1 constant:120]];
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeWidth
                              multiplier:1 constant:120]];
    return imageView;
}

- (void) configureDimension {
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeHeight
                                                     multiplier:1
                                                       constant:120]];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeWidth
                                                     multiplier:1
                                                       constant:120]];
    
    NSArray <NSString *>*imageNames = @[@"slot-bell",
                            @"slot-diamond",
                            @"slot-cherries",
                            @"slot-lemon",
                            @"slot-star",
                            @"slot-seven",
                                        @"slot-bell"];
    
    UIStackView *topScrollStack = [UIStackView new];
    topScrollStack.translatesAutoresizingMaskIntoConstraints = false;
    topScrollStack.axis = UILayoutConstraintAxisVertical;
    
    [imageNames enumerateObjectsUsingBlock:^(NSString * _Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        [topScrollStack addArrangedSubview:[self slotImageView:imageName]];
    }];
    
    [self addSubview:topScrollStack];
    
    NSLayoutConstraint *constraintTop = [topScrollStack.topAnchor constraintEqualToAnchor:self.topAnchor];
    NSLayoutConstraint *centerX = [topScrollStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
    
    self.stackOne = topScrollStack;
    self.stackOneOffset = constraintTop;
    
    UIStackView *bottomScrollStack = [UIStackView new];
    bottomScrollStack.translatesAutoresizingMaskIntoConstraints = false;
    bottomScrollStack.axis = UILayoutConstraintAxisVertical;
    
    [imageNames enumerateObjectsUsingBlock:^(NSString * _Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        [bottomScrollStack addArrangedSubview:[self slotImageView:imageName]];
    }];
    
    [self addSubview:bottomScrollStack];
    
    NSLayoutConstraint *constraintBottomStackTop = [bottomScrollStack.topAnchor constraintEqualToAnchor:self.topAnchor];
    NSLayoutConstraint *bottomStackCenterX = [bottomScrollStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor];
    
    [NSLayoutConstraint activateConstraints:@[constraintBottomStackTop, bottomStackCenterX, constraintTop, centerX]];
    self.stackTwo = topScrollStack;
    self.stackTwoOffset = constraintBottomStackTop;
    
    self.clipsToBounds = true;
}

@end
