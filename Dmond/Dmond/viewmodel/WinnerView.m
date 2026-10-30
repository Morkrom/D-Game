//
//  WinnerView.m
//  Dmond
//
//  Created by M on 10/30/26.
//

#import "WinnerView.h"

@interface WinnerView()
    @property UILabel *spunLabel;
@end

@implementation WinnerView

- (UILabel *)spunLabel {
    if (!_spunLabel) {
        UILabel *label = [UILabel new];
        [label setFont: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]];
        label.textColor = [UIColor whiteColor];
        label.translatesAutoresizingMaskIntoConstraints = false;
        _spunLabel = label;
    }
    
    return _spunLabel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    [self addSubview:self.spunLabel];
    [self.spunLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.spunLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    self.alpha = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)spinWinner {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
    
    [UIView animateWithSpringDuration:2
                               bounce:1
                initialSpringVelocity:1
                                delay:0
                              options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        self.spunLabel.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 15);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)stopWinner {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
    
}

@end
