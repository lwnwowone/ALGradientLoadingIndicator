//
//  ViewController.m
//  ALGradientLoadingIndicator
//
//  Created by Alanc on 6/2/17.
//  Copyright © 2017 Alanc. All rights reserved.
//

#import "ViewController.h"
#import "ALGradientLoadingIndicator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Sample
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    backgroundView.frame = self.view.bounds;
    [self.view addSubview:backgroundView];
    
    [[ALGradientLoadingIndicator instance] showInView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
