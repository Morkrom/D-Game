//
//  ViewController.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "ViewController.h"
#import "ReelView.h"
#import "GameViewModel.h"
#import "YouWinnerView.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray <ReelView *> *reels;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UILabel *creditsLabel;
@property (strong, nonatomic) GameViewModel *viewModel;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) UIImageView *reelsBackgroundView;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //TODO: Because this viewcontroller is instantiated from a xib the viewmodel is created here, however it would be best if there was a single source for all dependencies for instance a dependency manager in the application delegate. For this example it is suffice that this viewcontroller is the application root.
        
        self.viewModel = [GameViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAndAddSubviews];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self bindViewModel];
        
}

- (void)displayWinnerScreen {
    YouWinnerView *winnerView = [[YouWinnerView alloc] init];
    winnerView.alpha = 0;
    [self.view addSubview:winnerView];
    
    [[winnerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[winnerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];

    [[winnerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor] setActive:YES];
    [[winnerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor] setActive:YES];

    [UIView animateWithDuration:0.4 animations:^{
        winnerView.alpha = 1;
    } completion:^(BOOL finished) {
        [winnerView rewardUserGoodJob];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [winnerView removeFromSuperview];
        });
    }];
}

-(void)bindViewModel {
    __weak typeof(self) weakSelf = self;
    [self.viewModel observeDisplayChange:^{
        NSString *creditsLabelText = ![weakSelf.viewModel needsCredits] ? [NSString stringWithFormat: @"Credits: %@", weakSelf.viewModel.userCredits] : @"Need more credits!";
        weakSelf.creditsLabel.text = creditsLabelText;
        
        weakSelf.playButton.enabled = ![weakSelf.viewModel needsCredits];
        weakSelf.segmentControl.hidden = NO;
    }];
    
    [self.viewModel observeForShowWinningScreen:^{
        [weakSelf displayWinnerScreen];
    }];
    
    [self.viewModel refreshForDisplay];
}

-(void)resetReels {
    
    [self.reels enumerateObjectsUsingBlock:^(ReelView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj resetDisplay];
    }];
    
}

-(void)playAction:(id)sender {
   
    [self.viewModel playStartGameSound];
    [self.viewModel deductCreditsForReelRoll];

    self.playButton.enabled = NO;
    self.segmentControl.hidden = YES;
    NSArray<NSNumber *> *reelResults = [self.viewModel generateReelResults];

    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    [self.reels enumerateObjectsUsingBlock:^(ReelView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        dispatch_group_enter(dispatchGroup);

        [obj spinNowtoIndex:reelResults[idx].unsignedIntValue completion:^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_group_leave(dispatchGroup);
            });
        }];
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        [weakSelf.viewModel logReelResults:reelResults];
        [weakSelf resetReels];
    });
}

- (NSArray *)makeCreditSelectionActions {
    __weak typeof(self) weakSelf = self;
    NSArray *creditsSelection = @[[UIAction actionWithTitle:@"Bet 1 credit"
                                                      image:nil
                                                 identifier:nil
                                                    handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf.viewModel bettingCreditsAmount: @(1)];
    }],
                                  [UIAction actionWithTitle:@"Bet 5 credits"
                                                      image:nil
                                                 identifier:nil
                                                    handler:^(__kindof UIAction * _Nonnull action) {
                                      [weakSelf.viewModel bettingCreditsAmount: @(5)];
      }],
                                  [UIAction actionWithTitle:@"Bet 10 credits"
                                                      image:nil
                                                 identifier:nil
                                                    handler:^(__kindof UIAction * _Nonnull action) {
                                      [weakSelf.viewModel bettingCreditsAmount: @(10)];
      }]];
    return creditsSelection;
}

- (void) createAndAddSubviews {
    
    self.reelsBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reels-background-only"]];
    self.reelsBackgroundView.layer.cornerRadius = 15.0;
    self.reelsBackgroundView.clipsToBounds = YES;
    self.reelsBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.reelsBackgroundView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.segmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero actions:[self makeCreditSelectionActions]];
    self.segmentControl.selectedSegmentIndex = 0;
    self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.reels = @[[ReelView new],
                   [ReelView new],
                   [ReelView new]];
    self.playButton = [UIButton buttonWithType: UIButtonTypeCustom];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playButton setImage:[UIImage imageNamed: @"play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];

    self.creditsLabel = [UILabel new];
    self.creditsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.creditsLabel.font = [UIFont boldSystemFontOfSize:30];
    self.creditsLabel.textColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:self.reels];
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    stackView.spacing = 15;
    
    [self.view addSubview: self.reelsBackgroundView];
    [self.view addSubview:stackView];
    [self.view addSubview: self.playButton];
    [self.view addSubview:self.creditsLabel];
    [self.view addSubview:self.segmentControl];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.reelsBackgroundView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.reelsBackgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.reelsBackgroundView.widthAnchor constraintEqualToConstant:520],
        [self.playButton.heightAnchor constraintEqualToConstant:150/1.8],
        [self.playButton.widthAnchor constraintEqualToConstant:150],
        [self.playButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-50],
        [self.playButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.creditsLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50],
        [self.creditsLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0],
        [self.segmentControl.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:150],
        [self.segmentControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]]
    ];
}

@end
