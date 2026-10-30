//
//  ViewController.m
//  Dmond
//
//  Created by M on 10/29/26.
//

#import "ViewController.h"
#import "ReelView.h"
#import "GameViewModel.h"
#import "WinnerView.h"

@interface ViewController ()


@property (strong, nonatomic) NSArray <ReelView *> *reels;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UILabel *creditsLabel;
@property (strong, nonatomic) GameViewModel *viewModel;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) WinnerView *winnerView;
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
    
    self.view.backgroundColor = [UIColor blackColor];
    __weak typeof(self) weakSelf = self;
    
    self.reelsBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reels-background-only"]];
    self.reelsBackgroundView.layer.cornerRadius = 15.0;
    
    self.reelsBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    self.segmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero actions:creditsSelection];
    self.segmentControl.selectedSegmentIndex = 0;
    self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.reels = @[[ReelView new],
                   [ReelView new],
                   [ReelView new]];
    self.playButton = [UIButton buttonWithType: UIButtonTypeCustom];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.creditsLabel = [UILabel new];
    self.creditsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    // Do any additional setup after loading the view.
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:self.reels];
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    stackView.spacing = 15;
    self.reelsBackgroundView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview: self.reelsBackgroundView];
    [self.view addSubview:stackView];
    [self.view addSubview: self.playButton];
    [self.view addSubview:self.creditsLabel];
    [self.view addSubview:self.winnerView];
    [self.view addSubview:self.segmentControl];
    
    [[self.reelsBackgroundView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive: YES];
    [[self.reelsBackgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive: YES];
    [[self.reelsBackgroundView.widthAnchor constraintEqualToConstant:500] setActive: YES];
    
    [[self.winnerView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive: YES];
    [[self.winnerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive: YES];
    [[self.winnerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive: YES];
    [[self.winnerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive: YES];
    
    [self.playButton setImage:[UIImage imageNamed: @"play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];

    [[self.playButton.heightAnchor constraintEqualToConstant:150/1.8] setActive:YES];
    [[self.playButton.widthAnchor constraintEqualToConstant:150] setActive:YES];
    [[self.playButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-50] setActive: YES];
    [[self.playButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive: YES];
    
    [[self.creditsLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50] setActive:YES];
    [[self.creditsLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0] setActive:YES];
    [[self.segmentControl.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:150] setActive: YES];
    [[self.segmentControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive: YES];

    self.creditsLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle2] size:25];
    self.creditsLabel.textColor = [UIColor whiteColor];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self bindViewModel];
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
        [weakSelf.winnerView spinWinner];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.winnerView stopWinner];
        });
    }];
    
    [self.viewModel refreshForDisplay];
}

-(void)resetReels {
    
    [self.reels enumerateObjectsUsingBlock:^(ReelView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj resetDisplay];
    }];
    
}

-(void)playAction:(id)sender {
   
    [self.viewModel deductCreditsForReelRoll];

    self.playButton.enabled = NO;
    self.segmentControl.hidden = YES;
    NSArray<NSNumber *> *reelResults = [self.viewModel generateReelResults];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    
    [self.reels enumerateObjectsUsingBlock:^(ReelView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        dispatch_group_enter(dispatchGroup);

        [obj spinNowtoIndex:reelResults[idx].unsignedIntValue completion:^{
                //
            
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

@end
