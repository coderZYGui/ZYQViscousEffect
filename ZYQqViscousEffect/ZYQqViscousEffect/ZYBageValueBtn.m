//
//  ZYBageValueBtn.m
//  ZYQqViscousEffect
//
//  Created by 朝阳 on 2017/10/21.
//  Copyright © 2017年 sunny. All rights reserved.
//

#import "ZYBageValueBtn.h"
#define maxDistance 80

@interface ZYBageValueBtn()

/** 小圆 */
@property (nonatomic, weak) UIView *smallCircle;

/** 形状图层 */
@property (nonatomic, weak) CAShapeLayer *shapeL;

@end

@implementation ZYBageValueBtn

/**
 求出路径后,要把路径填充起来.但是不能够直接给填充到当前的按钮之上.按钮是可以拖动的.
 绘制东西,当超出它的范围以外就不会再绘制.
 所以要把路径添加到按钮的父控件当中, 但是当前是一个路径,是不能够直接添加到父控件当中的.
 可能过形状图层添加.
 形状图层会根据一个路径生成一个形状.把这个形状添加到当前控件的图片父层就可以了.
 添加时需要注意:
 形状图层之有一个,所以不能够在手指拖动方法当中添加.由于当手指拖动的距离超过某个范围后,形状图片会被移除.
 下一次再去移动时, 还会有填充的路径.所以把创建形状图层搞成一个懒加载的形式,
 如果发现下一次被删除时,再重新创建.
 */

// 懒加载
- (CAShapeLayer *)shapeL
{
    if (_shapeL == nil) {
        CAShapeLayer *shapeL = [CAShapeLayer layer];
        // 把形状图层添加到self的父视图的最下面
        [self.superview.layer insertSublayer:shapeL atIndex:0];
        shapeL.fillColor = [UIColor redColor].CGColor;
        _shapeL = shapeL;
    }
    return _shapeL;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

// 初始化
- (void)setUp
{
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // 添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    // 添加一个小圆在大圆的底部
    UIView *smallCircle = [[UIView alloc] init];
    smallCircle.frame = self.frame;
    smallCircle.backgroundColor = self.backgroundColor;
    smallCircle.layer.cornerRadius = self.layer.cornerRadius;
    self.smallCircle = smallCircle;
    // 把小圆添加到大圆的父控件上
    [self.superview addSubview:smallCircle];
    // 放在大圆的下面
    [self.superview insertSubview:smallCircle belowSubview:self];
}

#pragma -mark 手势方法
- (void)pan:(UIPanGestureRecognizer *)pan
{
    // 获取当前偏移量
    CGPoint transP = [pan translationInView:self];
    // 注意: 当使用transform的时候,修改的是self的frame值,不会修改center
    //    self.transform = CGAffineTransformTranslate(self.transform, transP.x, transP.y);
    
    CGPoint center = self.center;
    center.x += transP.x;
    center.y += transP.y;
    self.center = center;
    // NSLog(@"%@",NSStringFromCGPoint(self.center));
    // 复位(相对于上一次)
    [pan setTranslation:CGPointZero inView:self];
    
    // 当拖动的时候计算距离
    CGFloat distance = [self distanceWithSmallCircle:self.smallCircle bigCircle:self];
    // 取出小圆的半径
    CGFloat smallRadius = self.bounds.size.width * 0.5;
    // 当距离增大,小圆半径每次都减少一个比例
    smallRadius -= distance / 10.0;
    // 每次移动重新设置小圆的尺寸
    self.smallCircle.bounds = CGRectMake(0, 0, smallRadius * 2, smallRadius * 2);
    self.smallCircle.layer.cornerRadius = smallRadius;
    
    // 业务逻辑处理
    UIBezierPath *path = [self pathWithSmallCircle:self.smallCircle bigCircle:self];
    
    // 只有当小圆不隐藏的时候,才填充路径
    if (self.smallCircle.hidden == NO) {
        self.shapeL.path = path.CGPath;
    }
    
    // 当两圆之间的距离超过一个最大值的时候.把小圆隐藏,清除路径
    if (distance > maxDistance) {
        self.smallCircle.hidden = YES;
        // 移除填充路径
        [self.shapeL removeFromSuperlayer];
    }
    
    // 当手指停止拖动时
    /*
     移动后手指松开时判断: 如果两个圆之间的距离不超过最大距离,则让大圆复位,小圆显示
     若超过最大距离,让大圆播放一个动画消失
     */
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 距离小于最大距离
        if (distance < maxDistance) {
            // 添加一个弹簧动画
            [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                // 将绘制的图形清空
                [self.shapeL removeFromSuperlayer];
                // 和小圆重合
                self.center = self.smallCircle.center;
                self.smallCircle.hidden = NO;
                
            } completion:nil];
            
        }else{
            
            //播放一个动画消失
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.bounds];
            
            NSMutableArray *imageArray = [NSMutableArray array];
            for (int i = 0 ; i < 8; i++) {
                UIImage *image =  [UIImage imageNamed:[NSString stringWithFormat:@"%d",i +1]];
                [imageArray addObject:image];
            }
            
            imageV.animationImages = imageArray;
            imageV.animationDuration = 1;
            [imageV startAnimating];
            
            [self addSubview:imageV];
            
            // 延迟1s后执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 将自己从父控件中移除
                [self removeFromSuperview];
                
            });
        }
    }
    
}


/**
 给定两个圆描述一个不规则路径,然后填充这条路径,就是粘性效果
 
 @param smallCircle 小圆
 @param bigCircle 大圆
 @return 路径
 */
- (UIBezierPath *)pathWithSmallCircle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle
{
    // 获得小圆中心点
    CGFloat x1 = smallCircle.center.x;
    CGFloat y1 = smallCircle.center.y;
    // 获得大圆中心点
    CGFloat x2 = bigCircle.center.x;
    CGFloat y2 = bigCircle.center.y;
    
    // 两圆之间的距离
    CGFloat d = [self distanceWithSmallCircle:smallCircle bigCircle:bigCircle];
    
    // 如果没有移动,则返回nil
    if (d <= 0) {
        return nil;
    }
    
    // X轴偏移量 / d
    CGFloat sinθ = (x2 - x1) / d;
    // Y轴偏移量 / d
    CGFloat cosθ = (y2 - y1) / d;
    
    /**
     已知一个角,一个斜边
     角的邻边 = 斜边 * cosθ
     角的对边 = 斜边 * sinθ
     */
    
    CGFloat r1 = smallCircle.bounds.size.width * 0.5;
    CGFloat r2 = bigCircle.bounds.size.width * 0.5;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinθ, pointA.y + d * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinθ, pointB.y + d * 0.5 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //AB
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    //BC(曲线)
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    //CD
    [path addLineToPoint:pointD];
    //DA(曲线)
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
    
}

//当手指拖动大圆时,小圆的半径会根据拖动的距离进行减小.所以要计算出两个圆之间的距离.
//计算完毕后.让小圆的原始半径每次都减去一个距离比例.重新设置尺寸大小.和小圆的半径.
/**
 计算小圆中心到大圆中心的距离
 
 @param smallCircle 小圆
 @param bigCircle 大圆
 */
- (CGFloat)distanceWithSmallCircle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle
{
    // 根据勾股定理求
    // X轴上的偏移量
    CGFloat offsetX = bigCircle.center.x - smallCircle.center.x;
    // Y轴上的偏移量
    CGFloat offsetY = bigCircle.center.y - smallCircle.center.y;
    
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}

/**
 取消按钮的高亮状态
 
 */
- (void)setHighlighted:(BOOL)highlighted
{
    
}

@end
