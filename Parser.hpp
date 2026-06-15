#pragma once
#include <string>

// разбор арифметического выражения рекурсивным спуском
class Parser {
public:
    explicit Parser(const std::string &text);
    double evaluate();

private:
    const std::string text;
    size_t pos;

    void skipSpaces();
    char peek();
    char get();

    double parseExpr();    // сложение и вычитание
    double parseTerm();    // умножение и деление
    double parseNumber();
};
