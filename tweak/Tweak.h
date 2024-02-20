@interface CSGraphicComplicationLayoutProvider : NSObject
+ (double)complicationEdgeInset;
@end

@interface CSComplicationLayoutElement : NSObject <NSCopying>
@property(nonatomic, readonly) long long gridWidth;
@end

@interface NSValue (WhyArentTheseDefinedAlready)
+ (NSValue *)valueWithCGRect:(CGRect)rect;
- (CGRect)CGRectValue;
@end

typedef CGRect NSRect;
