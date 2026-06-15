/*
 5. Калькулятор
 Пользователь вводит с клавиатуры некоторое арифметическое выражение. Выражение может
 содержать: Начальный уровень: режим игры «Человек», вывод статистики по игре в файл в формате
 txt (количество перестановок и время на сбор пятнашек).
   - Начальный уровень: +, -, *, /. Например, если пользователь ввел: 5+2*2. Результат: 9.
   - (), +, -, *, /. Приложение рассчитывает результат выражения с учетом скобок, приоритетов
     операторов.
   - Сложный уровень (в дополнение к среднему):
     (), +, -, *, /, возведение в степень, вычисление корня.
*/

#import <Cocoa/Cocoa.h>

// создаём цветную кнопку с белой подписью
static NSButton *makeButton(NSString *title, NSColor *color) {
    NSButton *button = [[NSButton alloc] init];
    button.bordered = NO;
    button.wantsLayer = YES;
    button.layer.backgroundColor = color.CGColor;
    button.layer.cornerRadius = 10;
    button.attributedTitle = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{ NSForegroundColorAttributeName: NSColor.whiteColor,
                          NSFontAttributeName: [NSFont systemFontOfSize:22
                                                 weight:NSFontWeightMedium] }];
    return button;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];

        // окно
        CGFloat width = 360, height = 520;
        NSWindow *window = [[NSWindow alloc]
            initWithContentRect:NSMakeRect(0, 0, width, height)
                      styleMask:(NSWindowStyleMaskTitled |
                                 NSWindowStyleMaskClosable |
                                 NSWindowStyleMaskMiniaturizable)
                        backing:NSBackingStoreBuffered
                          defer:NO];
        window.title = @"Калькулятор";
        window.backgroundColor = [NSColor colorWithWhite:0.12 alpha:1.0];
        [window center];

        // поле вывода выражения и результата
        CGFloat margin = 16;
        NSTextField *display = [[NSTextField alloc] initWithFrame:
            NSMakeRect(margin, height - 100, width - 2 * margin, 70)];
        display.editable = NO;
        display.selectable = NO;
        display.bordered = NO;
        display.drawsBackground = NO;
        display.textColor = NSColor.whiteColor;
        display.alignment = NSTextAlignmentRight;
        display.font = [NSFont monospacedDigitSystemFontOfSize:34
                                                        weight:NSFontWeightLight];
        display.cell.lineBreakMode = NSLineBreakByTruncatingHead;
        [window.contentView addSubview:display];

        // цвета: цифры серые, операторы оранжевые, спец тёмные, равно зелёное
        NSColor *grey   = [NSColor colorWithWhite:0.25 alpha:1.0];
        NSColor *dark   = [NSColor colorWithWhite:0.18 alpha:1.0];
        NSColor *orange = [NSColor colorWithCalibratedRed:0.95 green:0.55 blue:0.10 alpha:1.0];
        NSColor *green  = [NSColor colorWithCalibratedRed:0.20 green:0.65 blue:0.35 alpha:1.0];

        struct Button { NSString *title; NSColor *color; };
        Button layout[5][5] = {
            {{@"C", dark}, {@"⌫", dark}, {@"(", dark}, {@")", dark}, {@"√", orange}},
            {{@"7", grey}, {@"8", grey}, {@"9", grey}, {@"/", orange}, {@"^", orange}},
            {{@"4", grey}, {@"5", grey}, {@"6", grey}, {@"*", orange}, {@"-", orange}},
            {{@"1", grey}, {@"2", grey}, {@"3", grey}, {@"+", orange}, {@"=", green}},
            {{@"0", grey}, {@".", grey}, {@",", grey}, {nil, nil}, {nil, nil}},
        };

        // раскладываем кнопки сеткой 5 на 5
        CGFloat gap = 12;
        CGFloat top = height - 120;
        CGFloat buttonWidth = (width - 2 * margin - 4 * gap) / 5;
        CGFloat buttonHeight = (top - margin - 4 * gap) / 5;

        for (int row = 0; row < 5; ++row) {
            for (int col = 0; col < 5; ++col) {
                Button item = layout[row][col];
                if (item.title == nil) continue;

                CGFloat x = margin + col * (buttonWidth + gap);
                CGFloat y = top - buttonHeight - row * (buttonHeight + gap);
                CGFloat w = buttonWidth;
                if (row == 4 && col == 0) w = buttonWidth * 2 + gap;  // ноль на две клетки

                NSButton *button = makeButton(item.title, item.color);
                button.frame = NSMakeRect(x, y, w, buttonHeight);
                [window.contentView addSubview:button];

                if (row == 4 && col == 0) col++;
            }
        }

        [window makeKeyAndOrderFront:nil];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}
