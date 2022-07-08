//
//  QJFormatTextField.m
//  QJComponentsDome
//
//  Created by 杰 on 2022/7/8.
//

#import "QJFormatTextField.h"
@interface QJFormatTextField()<UITextFieldDelegate>

@property (nonatomic, copy) NSString *  replacementString ; //
@property (nonatomic, assign) NSRange replacementRange;
@property (nonatomic, assign) NSInteger cursorLocation;

@property (nonatomic,copy) NSString * contentValue;

@end

@implementation QJFormatTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initConfigure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfigure];
    }
    return self;
}

- (void)initConfigure
{
    self.delegate = self;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTarget:self action:@selector(ppTextFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}
-(void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - Overwriter
/*!
 *  @method
 *  @abstract TextField里面的方法
 *  @discussion
 */
//- (CGRect)textRectForBounds:(CGRect)bounds {
//    bounds.origin.y += VMargin10;
//    return bounds;
//}
//
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//    bounds.origin.y += VMargin10;
//    return bounds;
//}

#pragma mark - Outter

- (void)setText:(NSString *)text {
    self.contentValue = text;
    // 转换格式
    text = [self.class transformationText:text toFormat:self.format];
    self.replacementRange = NSMakeRange(text.length, 0);

    [super setText:text];
    
    // 解决对齐问题
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text?:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    self.attributedText = attributedString;
}
-(NSString *)text {
    return [self.class transformationText:[super text] fromFormat:self.format];
}

/// 将 text 转成 format 格式的字符串
+(NSString *)transformationText:(NSString *)text toFormat:(NSString *)format {
    if (format.length==0 || text.length==0) {
        return text?:@"";
    }
    
    NSMutableString * mutText = [NSMutableString string];
    int t = 0 ;
    for (int f = 0 ; f < format.length && t < text.length; f++) {
        NSString * subFormat = [format substringWithRange:NSMakeRange(f, 1)];

        if ([subFormat isEqualToString:@"X"] || [subFormat isEqualToString:@"x"]) {
            NSString * subText = [text substringWithRange:NSMakeRange(t, 1)];
            [mutText appendString:subText];
            t++;
        }else {
            // 拼接符
            [mutText appendString:subFormat];
        }
    }
    
    if (t < text.length) {
        // 拼接剩于的字符
        [mutText appendString:[text substringFromIndex:t]];
    }
    
    return mutText.copy;
}

/// 将 text 根据 format 格式还原字符串
+(NSString *)transformationText:(NSString *)text fromFormat:(NSString *)format {
    if (format.length==0 || text.length==0) {
        return text?:@"";
    }
    
    NSMutableString * mutText = [NSMutableString string];
    int t = 0 ;
    for (int f = 0 ; f < format.length && t < text.length; f++,t++) {
        NSString * subFormat = [format substringWithRange:NSMakeRange(f, 1)];
        NSString * subText = [text substringWithRange:NSMakeRange(t, 1)];

        if ([subFormat isEqualToString:@"X"] || [subFormat isEqualToString:@"x"]) {
            [mutText appendString:subText];
        }else if(![subFormat isEqualToString:subText]){
            // 不符合拼接符格式的直接返回原字符串
            return text;
        }
    }
    
    if (t < text.length) {
        // 拼接剩于的字符
        [mutText appendString:[text substringFromIndex:t]];
    }
    
    return mutText.copy;
}

- (void)paste:(id)sender
{
    [super paste:sender];
    [self ppTextFieldValueChanged:self];
}

-(NSString *)doReplaceOldText:(NSString *)oldText inRange:(NSRange)range replacementString:(NSString *)string {
    NSString * format = self.format?:@"";
    // 真实的text
    NSString * trueText = [self.class transformationText:oldText fromFormat:format];
    NSInteger location = range.location ;
    NSInteger length = range.length ;
    
    if (format.length) {
        // 将 range 转成 trueText 所在的位置
        for (int f = 0 ; f < format.length ; f++) {
            NSString * subFormat = [format substringWithRange:NSMakeRange(f, 1)];

            if (![subFormat isEqualToString:@"X"] && ![subFormat isEqualToString:@"x"]) {
                // 在range 范围内有多少个拼接符 就减多少个
                if (f < range.location) {
                    location--;
                }
                if (range.location <= f && f < range.location+range.length) {
                    // 范围内长度-1
                    length--;
                }
            }
        }
    }
    
    range = NSMakeRange(location, length);
    self.cursorLocation = location + string.length;
    
    if (range.location >= trueText.length) {
        return [trueText stringByAppendingString:string?:@""];
    }
    
    if (range.location >= 0 && range.location+range.length <= trueText.length) {
        return [trueText stringByReplacingCharactersInRange:range withString:string?:@""];
    }
    
    // range算的对，这里一般是执行不到的，防错
    return trueText;
}

#pragma mark - Event

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    self.replacementString = string;
    self.replacementRange = range;
    return YES;
}

- (void)ppTextFieldValueChanged:(UITextField*)textField
{
    // 解决无法连续输入中文的问题
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position || !selectedRange) {
        
        if (textField.text.length) {
            //记录旧光标位置
            UITextRange * selectedTextRange = textField.selectedTextRange;
            //需要转换成的格式
            NSString * textFormat = self.format?:@"";
            
            // 真实text内容，没有格式的 , 并记录光标位置 cursorLocation
            NSString * trueText = [self doReplaceOldText:[self.class transformationText:self.contentValue toFormat:textFormat] inRange:self.replacementRange replacementString:self.replacementString];
            
            /// 样式展示 以及 阿语对齐问题
            textField.text = trueText;
            
            // 设置光标位置
            if (self.replacementString.length) {
                // 将光标位置 cursorLocation 转成 格式化后 所在的光标位置
                NSInteger xCount = 0;
                NSInteger cursorLocation = self.cursorLocation;
                for (int f = 0 ; f < textFormat.length ; f++) {
                    NSString * subFormat = [textFormat substringWithRange:NSMakeRange(f, 1)];
                    if ([subFormat isEqualToString:@"X"] || [subFormat isEqualToString:@"x"]) {
                        xCount++;
                    }else{
                        // 连接字符
                        if (xCount < cursorLocation) {
                            self.cursorLocation++;
                        }
                    }
                }
                
                // 设置光标位置
                UITextPosition * endPostion = [textField positionFromPosition:textField.beginningOfDocument offset:self.cursorLocation];
//                [textField positionFromPosition:selectedTextRange.end offset:self.replacementString.length-1]?:selectedTextRange.end;
                textField.selectedTextRange = [textField textRangeFromPosition:endPostion toPosition:endPostion];
            }else{
                UITextPosition * startPostion = selectedTextRange.start;
                textField.selectedTextRange = [textField textRangeFromPosition:startPostion toPosition:startPostion];
            }
        }else{
            // 防止最开始的位置有格式符显示
            textField.text = @"";
        }
        
        // 清除数据
        self.replacementString = @"";
        self.replacementRange = NSMakeRange(textField.text.length, 0);
        
//        textField.text = textField.text;

        self.contentValue = textField.text;
    }
}

@end
