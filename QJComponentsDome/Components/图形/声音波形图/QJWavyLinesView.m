//
//  QJWavyLinesView.m
//
//  Created by 杰 on 2020/9/15.
//  Copyright © 2020 . All rights reserved.
//

#import "QJWavyLinesView.h"

@interface QJWavyLinesView ()

//相位变化,用来移动曲线
@property (nonatomic, assign) CGFloat offX;
//存放线的数组
@property (nonatomic, strong) NSMutableArray * linesArr;
//高度
@property (nonatomic, assign) CGFloat maxHeight;
//宽度
@property (nonatomic, assign) CGFloat maxWidth;
//最大振幅
@property (nonatomic, assign) CGFloat maxAmplitude;
//振幅系数
@property (nonatomic, assign) CGFloat amplitudeLevel;

@end
@implementation QJWavyLinesView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _lineCount = 5 ;
        _maxLineWidth = 2 ;
        _minLineWidth = 1 ;
        _lineColor = [[UIColor alloc] initWithRed:123/255.0 green:177/255.0 blue:235/255.0 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (CAShapeLayer * layer in self.linesArr) {
        [layer removeFromSuperlayer];
    }
    self.linesArr = [[NSMutableArray alloc]init];
    self.maxHeight = CGRectGetHeight(self.bounds);
    self.maxWidth = CGRectGetWidth(self.bounds) ;
    self.maxAmplitude = self.maxHeight - self.maxLineWidth;
    self.amplitudeLevel = 0;
    
    for(int i=0; i < self.lineCount; i++){
        CAShapeLayer *line = [CAShapeLayer layer];
        line.fillColor = [[UIColor clearColor] CGColor];
        line.lineCap = kCALineCapSquare;
        line.lineJoin = kCALineJoinRound;
        CGFloat progress = 1.0f - (CGFloat)i / self.lineCount;
        line.lineWidth = self.maxLineWidth * progress;
        if(line.lineWidth < self.minLineWidth) line.lineWidth = self.minLineWidth ;
        
        UIColor *color = [self.lineColor colorWithAlphaComponent:progress];
        line.strokeColor = color.CGColor;
        [self.layer addSublayer:line];
        [self.linesArr addObject:line];
    }
}

- (void)setLevel:(CGFloat)level
{
    _level = level;
    self.offX -= 0.25f;
    self.amplitudeLevel = fmax(level, 0.01f);
    [self refreshLines];
}

- (void)refreshLines
{
    UIGraphicsBeginImageContext(self.frame.size);
    
    for(int i=0; i < self.lineCount; i++) {
        
        UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
        CGFloat progress = 1.0f - (CGFloat)i / self.lineCount;
        CGFloat nowAmplitudeLevel = (1.5f * progress - 0.25f) * self.amplitudeLevel;
        
        for(CGFloat x = 0; x < self.maxWidth; x++) {
            
            CGFloat midScale = 1 - pow(x / (self.maxWidth / 2)  - 1, 2);
            
            CGFloat y = midScale * self.maxAmplitude * nowAmplitudeLevel * sinf(2* M_PI *(x / self.maxWidth) * 1 + self.offX) + (self.maxHeight * 0.5);
            
            if (x==0) {
                [wavelinePath moveToPoint:CGPointMake(x, y)];
            }
            else {
                [wavelinePath addLineToPoint:CGPointMake(x, y)];
            }
        }
        
        CAShapeLayer *waveline = [self.linesArr objectAtIndex:i];
        waveline.path = [wavelinePath CGPath];
    }
    
    UIGraphicsEndImageContext();
}
-(void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor ;
    [self setNeedsLayout];
}
-(void)setLineCount:(NSInteger)lineCount {
    _lineCount = lineCount ;
    [self setNeedsLayout];
}
-(void)setMaxLineWidth:(CGFloat)maxLineWidth {
    _maxLineWidth = maxLineWidth ;
    [self setNeedsLayout];
}
-(void)setMinLineWidth:(CGFloat)minLineWidth {
    _minLineWidth = minLineWidth ;
    [self setNeedsLayout];
}
@end
