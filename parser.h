#pragma once
#include <string>
#include <stdexcept>
#include <cmath>

using namespace std;

class Parser {
public:
    Parser(string text) {
        this->text = text;
        pos = 0;
    }

    double evaluate() {
        double value = parseExpr();
        if (pos != (int)text.size()) {
            throw runtime_error("Лишний символ в выражении");
        }
        return value;
    }

private:
    string text;
    int pos;

    char currentChar() {
        if (pos < (int)text.size()) {
            return text[pos];
        }
        return 0;
    }

    char readChar() {
        char c = currentChar();
        if (c != 0) {
            pos++;
        }
        return c;
    }

    // √ в UTF-8 занимает три байта: E2 88 9A
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

    double parseExpr() {
        double value = parseTerm();
        while (currentChar() == '+' || currentChar() == '-') {
            char op = readChar();
            double right = parseTerm();
            if (op == '+') {
                value = value + right;
            } else {
                value = value - right;
            }
        }
        return value;
    }

    double parseTerm() {
        double value = parseUnary();
        while (currentChar() == '*' || currentChar() == '/') {
            char op = readChar();
            double right = parseUnary();
            if (op == '*') {
                value = value * right;
            } else {
                if (right == 0) {
                    throw runtime_error("Деление на ноль");
                }
                value = value / right;
            }
        }
        return value;
    }

    double parseUnary() {
        if (currentChar() == '-') {
            readChar();
            return -parseUnary();
        }
        if (matchRoot()) {
            return sqrt(parseUnary());
        }
        return parsePower();
    }

    double parsePower() {
        double base = parsePrimary();
        if (currentChar() == '^') {
            readChar();
            return pow(base, parseUnary());
        }
        return base;
    }

    double parsePrimary() {
        if (currentChar() == '(') {
            readChar();
            double value = parseExpr();
            if (readChar() != ')') {
                throw runtime_error("Нет закрывающей скобки");
            }
            return value;
        }
        return parseNumber();
    }

    double parseNumber() {
        string number = "";
        while (pos < (int)text.size() && (isdigit(text[pos]) || text[pos] == '.')) {
            number += text[pos];
            pos++;
        }
        if (number == "") {
            throw runtime_error("Ожидалось число");
        }
        return stod(number);
    }
};
