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
#include <string>
#include <stdexcept>
#include <cmath>

using namespace std;  // чтобы писать string вместо std::string и т.д.

/*
Разбор выражения "рекурсивным спуском": на каждый приоритет операций — своя функция, и они
вызывают друг друга по цепочке от низшего приоритета к высшему: parseExpr (+ -) -> parseTerm (* /) ->
 parseUnary (минус, корень) -> parsePower (^) -> parsePrimary (число или скобки).
 Благодаря этому 5+2*2 само считается как 5+(2*2)=9, без лишних усилий.
*/

class Parser {
public:
    Parser(string text) {
        this->text = text;  // выражение, которое разбираем
        pos = 0;            // позиция текущего символа в строке
    }

    double evaluate() {
        double value = parseExpr();
        // если после разбора остались символы — значит во вводе ошибка
        if (pos != (int)text.size())
            throw runtime_error("Лишний символ в выражении");
        return value;
    }

private:
    string text;  // разбираемое выражение
    int pos;      // на каком символе мы сейчас стоим

    // посмотреть текущий символ, НЕ сдвигаясь дальше (0 — строка кончилась)
    char currentChar() {
        if (pos < (int)text.size())
            return text[pos];
        return 0;
    }

    // взять текущий символ и перейти к следующему
    char readChar() {
        char c = currentChar();
        if (c != 0) pos++;
        return c;
    }

    // Обычные символы (+, -, цифры) — это один байт, а √ в кодировке UTF-8
    // занимает три байта: E2 88 9A. Поэтому отдельно проверяем эти три байта,
    // и если совпало — пропускаем их все три (pos += 3).
    bool matchRoot() {
        if (pos + 2 < (int)text.size() &&
            (unsigned char)text[pos]     == 0xE2 &&
            (unsigned char)text[pos + 1] == 0x88 &&
            (unsigned char)text[pos + 2] == 0x9A) {
            pos += 3;
            return true;
        }
        return false;
    }

    // сложение и вычитание (самый низкий приоритет — выполняется последним)
    double parseExpr() {
        double value = parseTerm();
        // пока идут + или -, берём следующее слагаемое и накапливаем результат
        while (currentChar() == '+' || currentChar() == '-') {
            char op = readChar();
            double right = parseTerm();
            if (op == '+') value = value + right;
            else           value = value - right;
        }
        return value;
    }

    // умножение и деление (приоритет выше, чем + и -)
    double parseTerm() {
        double value = parseUnary();
        while (currentChar() == '*' || currentChar() == '/') {
            char op = readChar();
            double right = parseUnary();
            if (op == '*') {
                value = value * right;
            } else {
                // на ноль делить нельзя — сообщаем об ошибке
                if (right == 0) throw runtime_error("Деление на ноль");
                value = value / right;
            }
        }
        return value;
    }

    // унарный минус (-5) и корень (√9): применяются к тому, что идёт следом
    double parseUnary() {
        if (currentChar() == '-') {
            readChar();
            return -parseUnary();
        }
        if (matchRoot())
            return sqrt(parseUnary());
        return parsePower();
    }

    // возведение в степень. pow — функция из <cmath>
    double parsePower() {
        double base = parsePrimary();
        if (currentChar() == '^') {
            readChar();
            return pow(base, parseUnary());
        }
        return base;
    }

    // самый высокий приоритет: либо число, либо выражение в скобках.
    // скобки обрабатываются рекурсией — внутри снова вызываем parseExpr
    double parsePrimary() {
        if (currentChar() == '(') {
            readChar();
            double value = parseExpr();
            if (readChar() != ')')
                throw runtime_error("Нет закрывающей скобки");
            return value;
        }
        return parseNumber();
    }

    // собираем подряд идущие цифры и точку в строку, потом переводим в число
    double parseNumber() {
        string number = "";
        while (pos < text.size() && (isdigit(text[pos]) || text[pos] == '.')) {
            number += text[pos];
            pos++;
        }
        if (number == "")
            throw runtime_error("Ожидалось число");
        return stod(number);  // stod = string to double, переводит "3.14" в 3.14
    }
};

// реагирует на нажатия кнопок и считает выражение
@interface Calculator : NSObject
@property (strong) NSTextField *display;  // текстовое поле сверху (что показываем)
@property (strong) NSImageView *gif;      // картинка-гифка рядом с числом
@property (assign) BOOL hasResult;        // true, если на экране уже готовый ответ
@end

@implementation Calculator

// записать новый текст на экран
- (void)setText:(NSString *)value {
    self.display.stringValue = value;
    self.gif.hidden = YES;  // гифка прячется при любом изменении строки
}

// прочитать, что сейчас на экране
- (NSString *)currentText {
    return self.display.stringValue;
}

// для некоторых результатов показываем гифку рядом с числом
- (void)showGifFor:(NSString *)result {
    // словарь "результат -> файл гифки", сюда можно дописывать новые пары
    NSDictionary *gifs = @{ @"67": @"assets/tenor.gif",
                            @"42": @"assets/42.gif",
                            @"52": @"assets/52.gif" };
    NSString *file = gifs[result];
    if (file == nil) return;                                       // для этого числа гифки нет
    self.gif.image = [[NSImage alloc] initWithContentsOfFile:file]; // загружаем из файла
    self.gif.hidden = NO;                                          // показываем
}

// добавляем символ нажатой кнопки в строку
- (void)append:(NSButton *)sender {
    NSString *token = sender.title;          // надпись на кнопке: "7", "+", "√"...
    NSString *current = [self currentText];   // что уже набрано

    // если на экране готовый ответ и нажали оператор (например 7, потом *) —
    // продолжаем считать от него; если нажали цифру — начинаем новое число
    if (self.hasResult) {
        BOOL isOperator = [@"+-*/^" containsString:token];
        current = isOperator ? current : @"";
        self.hasResult = NO;
    }
    [self setText:[current stringByAppendingString:token]];
}

// кнопка C — полностью очищаем экран
- (void)clear:(NSButton *)sender {
    self.hasResult = NO;
    [self setText:@""];
}

// кнопка ⌫ — удаляем последний символ
- (void)backspace:(NSButton *)sender {
    NSString *value = [self currentText];
    if (self.hasResult) { [self clear:sender]; return; }  // после ответа стираем всё сразу
    if (value.length == 0) return;                         // стирать нечего

    // берём диапазон последнего символа целиком — чтобы √ (3 байта) удалялся за раз
    NSRange last = [value rangeOfComposedCharacterSequenceAtIndex:value.length - 1];
    [self setText:[value substringToIndex:last.location]];
}

// считаем выражение и показываем результат
- (void)evaluate:(NSButton *)sender {
    // берём текст с экрана и переводим из NSString в обычную C++ строку.
    // ?: "" — если UTF8String вдруг вернёт nullptr, подставляем пустую строку
    string expr([self currentText].UTF8String ?: "");
    if (expr.empty()) return;

    // try/catch: если в выражении ошибка, Parser кидает исключение,
    // и мы ловим его здесь, показывая текст ошибки вместо вылета программы
    try {
        Parser parser(expr);
        double result = parser.evaluate();
        // %g печатает число без лишних нулей: 9, а не 9.000000
        NSString *out = [NSString stringWithFormat:@"%g", result];
        [self setText:out];
        self.hasResult = YES;
        [self showGifFor:out];  // покажем гифку, если результат особенный
    } catch (const exception &e) {
        [self setText:[NSString stringWithFormat:@"Ошибка: %s", e.what()]];
        self.hasResult = YES;
    }
}

@end

// создаём цветную кнопку с белой подписью.
// calc + action — кому и какой метод вызвать при нажатии (механизм target-action)
static NSButton *makeButton(NSString *title, NSColor *color, Calculator *calc, SEL action) {
    NSButton *button = [[NSButton alloc] init];
    button.bordered = NO;
    button.wantsLayer = YES;                      // включаем слой, чтобы задать фон и скругление
    button.layer.backgroundColor = color.CGColor; // цвет фона кнопки
    button.layer.cornerRadius = 10;               // скруглённые углы
    // своя подпись: белый текст нужного размера (обычный title красить нельзя)
    button.attributedTitle = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{ NSForegroundColorAttributeName: NSColor.whiteColor,
                          NSFontAttributeName: [NSFont systemFontOfSize:22
                                                 weight:NSFontWeightMedium] }];
    button.target = calc;     // объект, у которого вызовем метод
    button.action = action;   // сам метод (append:, evaluate: и т.д.)
    return button;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {  // автоматически освобождает память объектов Cocoa
        // создаём само приложение и говорим показывать его как обычное окно
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];

        // создаём окно: размер, заголовок, кнопки закрыть/свернуть, тёмный фон
        CGFloat width = 360, height = 520;
        NSWindow *window = [[NSWindow alloc]
            initWithContentRect:NSMakeRect(0, 0, width, height)
                      styleMask:(NSWindowStyleMaskTitled |          // полоса заголовка
                                 NSWindowStyleMaskClosable |        // кнопка закрыть
                                 NSWindowStyleMaskMiniaturizable)   // кнопка свернуть
                        backing:NSBackingStoreBuffered
                          defer:NO];
        window.title = @"Калькулятор";
        window.backgroundColor = [NSColor colorWithWhite:0.12 alpha:1.0];  // почти чёрный
        [window center];  // разместить окно по центру экрана

        Calculator *calc = [[Calculator alloc] init];  // объект с логикой кнопок

        // поле вывода выражения и результата (сверху окна)
        CGFloat margin = 16;  // отступ от краёв
        NSTextField *display = [[NSTextField alloc] initWithFrame:
            NSMakeRect(margin, height - 100, width - 2 * margin, 70)];
        display.editable = NO;                          // нельзя печатать вручную
        display.selectable = NO;                        // нельзя выделять
        display.bordered = NO;                          // без рамки
        display.drawsBackground = NO;                   // прозрачный фон
        display.textColor = NSColor.whiteColor;         // белый текст
        display.alignment = NSTextAlignmentRight;       // число прижато вправо
        display.font = [NSFont monospacedDigitSystemFontOfSize:34
                                                        weight:NSFontWeightLight];
        display.cell.lineBreakMode = NSLineBreakByTruncatingHead;  // длинное число режем слева
        calc.display = display;
        [window.contentView addSubview:display];        // кладём поле в окно

        // гифка рядом с числом, чуть крупнее шрифта
        CGFloat gifSize = 75;
        NSImageView *gif = [[NSImageView alloc] initWithFrame:
            NSMakeRect(margin, NSMidY(display.frame) - gifSize / 2, gifSize, gifSize)];  // по центру поля
        gif.animates = YES;                                   // проигрывать анимацию гифки
        gif.imageScaling = NSImageScaleProportionallyUpOrDown; // вписывать с сохранением пропорций
        gif.hidden = YES;                                     // по умолчанию скрыта
        calc.gif = gif;
        [window.contentView addSubview:gif];

        // цвета: цифры серые, операторы оранжевые, спец тёмные, равно зелёное
        NSColor *grey   = [NSColor colorWithWhite:0.25 alpha:1.0];
        NSColor *dark   = [NSColor colorWithWhite:0.18 alpha:1.0];
        NSColor *orange = [NSColor colorWithCalibratedRed:0.95 green:0.55 blue:0.10 alpha:1.0];
        NSColor *green  = [NSColor colorWithCalibratedRed:0.20 green:0.65 blue:0.35 alpha:1.0];

        // одна клетка таблицы кнопок: что написано, какого цвета, какой метод вызывает
        struct Button { NSString *title; NSColor *color; SEL action; };
        // сама раскладка кнопок — как они расположены на калькуляторе
        Button layout[5][5] = {
            {{@"C", dark,   @selector(clear:)},     {@"⌫", dark,   @selector(backspace:)},
             {@"(", dark,   @selector(append:)},    {@")", dark,   @selector(append:)},
             {@"√", orange, @selector(append:)}},

            {{@"7", grey,   @selector(append:)},     {@"8", grey,   @selector(append:)},
             {@"9", grey,   @selector(append:)},     {@"/", orange, @selector(append:)},
             {@"^", orange, @selector(append:)}},

            {{@"4", grey,   @selector(append:)},     {@"5", grey,   @selector(append:)},
             {@"6", grey,   @selector(append:)},     {@"*", orange, @selector(append:)},
             {@"-", orange, @selector(append:)}},

            {{@"1", grey,   @selector(append:)},     {@"2", grey,   @selector(append:)},
             {@"3", grey,   @selector(append:)},     {@"+", orange, @selector(append:)},
             {@"=", green,  @selector(evaluate:)}},

            {{@"0", grey,   @selector(append:)},     {nil, nil, nil},
             {@".", grey,   @selector(append:)},      {nil, nil, nil}, {nil, nil, nil}},
        };

        // раскладываем кнопки сеткой 5 на 5.
        // ширину/высоту кнопки считаем из размеров окна, чтобы всё ровно влезало
        CGFloat gap = 12;                                                 // зазор между кнопками
        CGFloat top = height - 120;                                       // ниже поля вывода
        CGFloat buttonWidth = (width - 2 * margin - 4 * gap) / 5;
        CGFloat buttonHeight = (top - margin - 4 * gap) / 5;

        for (int row = 0; row < 5; ++row) {
            for (int col = 0; col < 5; ++col) {
                Button item = layout[row][col];
                if (item.title == nil) continue;  // пустые клетки пропускаем

                // в Cocoa точка отсчёта (0,0) — это левый НИЖНИЙ угол,
                // поэтому y отсчитываем сверху вниз через top минус строка
                CGFloat x = margin + col * (buttonWidth + gap);
                CGFloat y = top - buttonHeight - row * (buttonHeight + gap);
                CGFloat w = buttonWidth;
                if (row == 4 && col == 0) w = buttonWidth * 2 + gap;  // ноль на две клетки

                NSButton *button = makeButton(item.title, item.color, calc, item.action);
                button.frame = NSMakeRect(x, y, w, buttonHeight);
                [window.contentView addSubview:button];

                if (row == 4 && col == 0) col++;  // следующую клетку занял широкий ноль
            }
        }

        [window makeKeyAndOrderFront:nil];      // показать окно
        [app activateIgnoringOtherApps:YES];    // вывести его на передний план
        [app run];                              // запустить цикл обработки нажатий
    }
    return 0;
}
