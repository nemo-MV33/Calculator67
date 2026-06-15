#import <Cocoa/Cocoa.h>

// реагирует на нажатия кнопок и считает выражение
@interface CalcController : NSObject
@property (strong) NSTextField *display;
@property (assign) BOOL hasResult;

- (void)append:(NSButton *)sender;
- (void)clear:(NSButton *)sender;
- (void)backspace:(NSButton *)sender;
- (void)evaluate:(NSButton *)sender;
@end
