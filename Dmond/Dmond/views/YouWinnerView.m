//
//  YouWinnerView.m
//  Dmond
//
//  Created by M on 10/30/26.
//

#import "YouWinnerView.h"
@interface YouWinnerView()

@property (strong, nonatomic) UILabel *youLabel;
@property (strong, nonatomic) UILabel *winnerLabel;

@end

@implementation YouWinnerView

-(instancetype)init {
    self = [super initWithFrame:CGRectZero];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self configureSubviews];
    return self;
}

+(UILabel *)winnerLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:30];
    return label;
}

- (void)rewardUserGoodJob {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.youLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5
                              delay:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            weakSelf.winnerLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [weakSelf performHappinessSplosion];
        }];
    }];
}

- (void)configureSubviews {
    
    self.youLabel = [YouWinnerView winnerLabel:@"You.."];
    self.winnerLabel = [YouWinnerView winnerLabel:@"Winner!"];
    
    UIStackView *labelsContainer = [[UIStackView alloc] initWithArrangedSubviews:@[self.youLabel, self.winnerLabel]];
    
    labelsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.youLabel.alpha = 0;
    self.winnerLabel.alpha = 0;
    
    [self addSubview:labelsContainer];
    [[labelsContainer.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[labelsContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
}


- (void)performHappinessSplosion {
    
    NSArray *slots = @[@"slot-bell",
                       @"slot-diamond",
                       @"slot-cherries",
                       @"slot-lemon",
                       @"slot-star"];
    
    NSUInteger slotsCount = slots.count;
    
    __weak typeof(self) weakSelf = self;

    [slots enumerateObjectsUsingBlock:^(NSString   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC * idx)), dispatch_get_main_queue(), ^{
            
            [weakSelf addLayerForImage:obj percentileOfScreen:((CGFloat)idx/(CGFloat)slotsCount)];
        });
    }];
}

- (void)addLayerForImage:(NSString *)imageName percentileOfScreen:(CGFloat)percentile {
    CAEmitterLayer *emitterLayer = [[CAEmitterLayer alloc] init];
    emitterLayer.frame = CGRectMake(self.frame.size.width*percentile, 0, 0, 0);
    emitterLayer.emitterCells = @[[YouWinnerView makeEmitterCellNamed: imageName]];
    [self.layer addSublayer:emitterLayer];
}


+ (CAEmitterCell *)makeEmitterCellNamed:(NSString *)named {
    
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.birthRate = 8;
    cell.lifetime = 10;
    cell.velocity = 200;
    cell.scale = 0.08;
    cell.spin = 1;
    cell.spinRange = 1;
    cell.scaleRange = 0.08;
    cell.emissionRange = M_PI*2;
    
    cell.contents = CFBridgingRelease([UIImage imageNamed:named].CGImage);
    return cell;
}

@end
