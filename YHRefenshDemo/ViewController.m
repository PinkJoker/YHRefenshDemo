//
//  ViewController.m
//  YHRefenshDemo
//
//  Created by 我叫MT on 17/5/18.
//  Copyright © 2017年 Pinksnow. All rights reserved.
//

#import "ViewController.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic, copy)NSMutableArray *dataArray;
@property(nonatomic, assign)BOOL isAnimating;
@property(nonatomic, assign)NSInteger currentColorIndex;
@property(nonatomic, assign)NSInteger currentLabelIndex;
@property(nonatomic, strong)NSTimer *timer;
//@property(n)
@property(nonatomic, strong)UIView *refreshView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kWidth, kWidth) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor clearColor];
    self.tableView.refreshControl = self.refreshControl;
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI *1.5);
    
    self.refreshView = [UIView new];
    for (int i = 0; i < 10; i++) {
            UILabel *subView = [[UILabel alloc]init];
            subView.frame = CGRectMake(i * 10 +kWidth *0.1 *i, 0, kWidth *0.1, self.refreshControl.bounds.size.height);
            subView.text = [NSString stringWithFormat:@"%d",i];
            subView.textColor = [UIColor greenColor];
        subView.font = [UIFont systemFontOfSize:24 weight:1];
            [self.refreshView addSubview:subView];
         [self.dataArray addObject:subView];

    }

    self.refreshView.frame = self.refreshControl.bounds;
    [self.refreshControl addSubview:self.refreshView];
    self.isAnimating = NO;

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.transform = CGAffineTransformMakeRotation(-M_PI *1.5);
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%@",self.dataArray);
    return self.dataArray.count;
}

-(void)animateRefreshStep
{
    self.isAnimating = true;
     UILabel *label = self.dataArray[self.currentLabelIndex];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
       
        label.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.5, 0.5), 0);
        label.textColor = [self jk_randomColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            label.transform = CGAffineTransformIdentity;
            label.textColor = [UIColor blackColor];
            
        } completion:^(BOOL finished) {
            self.currentLabelIndex += 1;
            if (self.currentLabelIndex < self.dataArray.count) {
                [self animateRefreshStep];
            }else{
                
                [self animationStepSecond];
                
            }
            
        }];
        
        
        
        
    }];
}

-(void)animationStepSecond{
    [UIView animateWithDuration:1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        for (UILabel *obj in self.dataArray) {
            obj.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            for (UILabel *label in self.dataArray) {
                label.transform = CGAffineTransformIdentity;
            }
        } completion:^(BOOL finished) {
            if (self.refreshControl.isRefreshing) {
                self.currentLabelIndex = 0 ;
                [self animateRefreshStep];
                [self endRefresh];
            }else{
                self.isAnimating = NO;
                self.currentLabelIndex = 0;
                for (int i = 0; i<self.dataArray.count; i++) {
                    ((UILabel *)self.dataArray[i]).textColor = [UIColor blackColor];
                    ((UILabel *)self.dataArray[i]).transform = CGAffineTransformIdentity;
                    [self endRefresh];
                }
            }
        }];
        
    
        
        
        
    }];
}

-(UIColor *)jk_randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.refreshControl.isRefreshing) {
        if (!self.isAnimating) {
            [self addTime];
            [self animateRefreshStep];
        }
    }
}

-(void)addTime
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(endRefresh) userInfo:nil repeats:YES];
}

-(void)endRefresh
{
    [self.refreshControl endRefreshing];
    [self.timer  invalidate];
    self.timer = nil;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
