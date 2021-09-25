//
//  ViewController.m
//  OrzInjection
//
//  Created by wangzhizhou on 2021/9/12.
//

#import "ViewController.h"

extern BOOL isStopRecordSymbols;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    isStopRecordSymbols = YES;
    [super viewDidLoad];
}

@end
