//
//  ViewController.m
//  CoreTextDemo
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CoreTextView *textView = [[CoreTextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
