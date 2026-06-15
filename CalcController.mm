#import "CalcController.h"
#include "Parser.hpp"
#include <string>
#include <cmath>
#include <algorithm>

@implementation CalcController

- (void)setText:(NSString *)value {
    self.display.stringValue = value;
}

- (NSString *)currentText {
    return self.display.stringValue;
}

// добавляем символ кнопки в строку
- (void)append:(NSButton *)sender {
    NSString *token = sender.title;
    NSString *current = [self currentText];

    // после результата оператор продолжает вычисление, цифра начинает новое
    if (self.hasResult) {
        BOOL isOperator = [@"+-*/" containsString:token];
        current = isOperator ? current : @"";
        self.hasResult = NO;
    }
    [self setText:[current stringByAppendingString:token]];
}

- (void)clear:(NSButton *)sender {
    self.hasResult = NO;
    [self setText:@""];
}

// удаляем последний символ
- (void)backspace:(NSButton *)sender {
    NSString *value = [self currentText];
    if (self.hasResult) { [self clear:sender]; return; }
    if (value.length == 0) return;
    [self setText:[value substringToIndex:value.length - 1]];
}

// считаем выражение и показываем результат
- (void)evaluate:(NSButton *)sender {
    std::string expr([self currentText].UTF8String ?: "");
    if (expr.empty()) return;
    std::replace(expr.begin(), expr.end(), ',', '.');  // запятая как десятичный разделитель

    try {
        Parser parser(expr);
        double result = parser.evaluate();

        // целое выводим без дробной части, иначе компактно
        NSString *out;
        if (std::isfinite(result) && result == std::floor(result) &&
            std::fabs(result) < 1e15) {
            out = [NSString stringWithFormat:@"%lld", (long long)result];
        } else {
            out = [NSString stringWithFormat:@"%.10g", result];
        }
        [self setText:out];
        self.hasResult = YES;
    } catch (const std::exception &e) {
        [self setText:[NSString stringWithFormat:@"Ошибка: %s", e.what()]];
        self.hasResult = YES;
    }
}

@end
