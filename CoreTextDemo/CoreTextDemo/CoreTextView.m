//
//  CoreTextView.m
//  CoreTextDemo
//
//  Created by apple on 2017/5/21.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "CoreTextView.h"
#import <CoreText/CoreText.h>

@implementation CoreTextView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //1.获取当前绘制画布的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2.翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角是(0,0),而UIView是以左上角为原点）
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //3.创建绘制区域
    CGMutablePathRef path  = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.bounds);
//    CGPathAddRect(path, NULL, CGRectMake(10, 20, self.bounds.size.width - 20, self.bounds.size.height - 40));//CGPathAddEllipseInRect（呈梯状排布） - CGPathAddRect（矩形排布）-两种绘制区域
    
    //4.创建需要绘制文字与计算需要绘制区域
    // 步骤4：创建需要绘制的文字与计算需要绘制的区域
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"如果你正在创建一个iPad上的杂志或书籍的应用程序，使用CoreText非常方便。这个CoreText教程将带你如何使用CoreText创建一个杂志应用你将学习如何： 奠定格式化的上下文本在屏幕上 微调文本的外观 向文本内容中添加图片 最后创建一个杂志的应用程序，它加载文本标记来轻松地控制渲染文本的格式* 最后吃掉你的脑子，如果你正在创建一个iPad上的杂志或书籍的应用程序，使用CoreText非常方便。这个CoreText教程将带你如何使用CoreText创建一个杂志应用你将学习如何： 奠定格式化的上下文本在屏幕上 微调文本的外观 向文本内容中添加图片 最后创建一个杂志的应用程序，它加载文本标记来轻松地控制渲染文本的格式* 最后吃掉你的脑，如果你正在创建一个iPad上的杂志或书籍的应用程序，使用CoreText非常方便。这个CoreText教程将带你如何使用CoreText创建一个杂志应用你将学习如何： 奠定格式化的上下文本在屏幕上 微调文本的外观 向文本内容中添加图片 最后创建一个杂志的应用程序，它加载文本标记来轻松地控制渲染文本的格式* 最后吃掉你的脑"];
    
    
    // 步骤8：设置部分文字颜色
    [attrString addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10, 10)];
    
    // 设置部分文字字体
    CGFloat fontSize = 20;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attrString addAttribute:(id)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(15, 10)];
    CFRelease(fontRef);
    
    // 设置行间距
    CGFloat lineSpacing = 10;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    [attrString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attrString.length)];
    CFRelease(theParagraphRef);
    
    
    /*
     * 步骤9：图文混排部分
     * 设置一个回调结构体，告诉代理该回调那些方法
     */
    CTRunDelegateCallbacks callbacks;//创建一个回调结构体，设置相关参数
    memset(&callbacks,0,sizeof(CTRunDelegateCallbacks));//memset将已开辟内存空间 callbacks 的首 n 个字节的值设为值 0, 相当于对CTRunDelegateCallbacks内存空间初始化
    callbacks.version = kCTRunDelegateVersion1;//设置回调版本，默认这个
    callbacks.getAscent = ascentCallback;//设置图片顶部距离基线的距离
    callbacks.getDescent = descentCallback;//设置图片底部距离基线的距离
    callbacks.getWidth = widthCallback;//设置图片宽度
    
    
    // 图片信息字典
    NSDictionary *imgInfoDic = @{@"width":@160,@"height":@60};
    
    // 设置CTRun的代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)imgInfoDic);
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;//创建空白字符
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];//已空白字符生成字符串
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];//用字符串初始化占位符的富文本
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);//给字符串中的范围中字符串设置代理
    CFRelease(delegate);//释放（__bridge进行C与OC数据类型的转换，C为非ARC，需要手动管理）
    
    // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [attrString insertAttributedString:space atIndex:60];//将占位符插入原富文本
    
    
    // 步骤5：根据AttributedString生成CTFramesetterRef
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);//一个frame的工厂，负责生成frame
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attrString length]), path, NULL);//工厂根据绘制区域及富文本（可选范围，多次设置）设置frame
    
    
    // 步骤6：进行绘制
    CTFrameDraw(frame, context);//根据frame绘制文字
    
    // 步骤10：绘制图片
    UIImage *image = [UIImage imageNamed:@"coretext.png"];
    CGContextDrawImage(context, [self calculateImagePositionInCTFrame:frame], image.CGImage);//绘制图片
    
    
    // 步骤7.内存管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}


#pragma mark - CTRun delegate 回调方法
static CGFloat ascentCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}


/**
 *  根据CTFrameRef获得绘制图片的区域
 *
 *  @param ctFrame CTFrameRef对象
 *
 *  @return 绘制图片的区域
 */
- (CGRect)calculateImagePositionInCTFrame:(CTFrameRef)ctFrame {
    // 获得CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);//根据frame获取需要绘制的线的数组
    NSInteger lineCount = [lines count];//获取线的数量
    CGPoint lineOrigins[lineCount];//建立起点的数组（cgpoint类型为结构体，故用C语言的数组）
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);//获取起点
    
    // 遍历每个CTLine
    for (NSInteger i = 0 ; i < lineCount; i++) {
        
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);//获取GlyphRun数组（GlyphRun：高效的字符绘制方案）
        // 遍历每个CTLine中的CTRun
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;//获取CTRun
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);//获取CTRun的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];//获取代理
            if (delegate == nil) {//非空
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);//判断代理字典
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;//创建一个frame
            CGFloat ascent;//获取上距
            CGFloat descent;//获取下距
            
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;//取得高
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);//获取x偏移量
            runBounds.origin.x = lineOrigins[i].x + xOffset;//point是行起点位置，加上每个字的偏移量得到每个字的x
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;//计算原点
            
            CGPathRef pathRef = CTFrameGetPath(ctFrame);//获取绘制区域
            CGRect colRect = CGPathGetBoundingBox(pathRef);//获取剪裁区域边框
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            return delegateBounds;
        }
    }
    return CGRectZero;
}














@end
