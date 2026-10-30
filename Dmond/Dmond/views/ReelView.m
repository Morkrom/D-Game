//
//  ReelView.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "ReelView.h"

@interface ReelView()

@property (strong, nonatomic) UIStackView *stackOne;
@property (strong, nonatomic) NSLayoutConstraint *stackOneOffset;
@property (strong, nonatomic) NSLayoutConstraint *stackTwoOffset;

//maybe need we'll see
//@property (strong, nonatomic) UIStackView *stackTwo;

@end

@implementation ReelView

/*
 a pair of views with both lists of items:
 - You start one list, it scrolls to the end of the items,
 - On animation end, one list hides and resets scorll position and the next one begins.
*/

- (void)spinNow:(NSTimeInterval) delay {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.0 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.stackOneOffset.constant = -120*6;
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakSelf.stackOneOffset.constant = 0;
        [weakSelf spinMore];
    }];
}

- (void)spinMore {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.stackOneOffset.constant = -120*6;
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakSelf.stackOneOffset.constant = 0;
        [weakSelf layoutIfNeeded];
        [weakSelf spinMore];
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
    
    [NSLayoutConstraint activateConstraints:@[constraintTop, centerX]];
    self.stackOne = topScrollStack;
    self.stackOneOffset = constraintTop;
    self.clipsToBounds = true;
}

@end
