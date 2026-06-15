#include "Parser.hpp"
#include <stdexcept>
#include <cctype>

Parser::Parser(const std::string &text) : text(text), pos(0) {}

double Parser::evaluate() {
    double value = parseExpr();
    skipSpaces();
    if (pos != text.size())
        throw std::runtime_error("Лишний символ в выражении");
    return value;
}

void Parser::skipSpaces() {
    while (pos < text.size() && std::isspace((unsigned char)text[pos]))
        ++pos;
}

char Parser::peek() {
    skipSpaces();
    return pos < text.size() ? text[pos] : '\0';
}

char Parser::get() {
    char c = peek();
    if (c != '\0') ++pos;
    return c;
}

// сложение и вычитание — самый низкий приоритет
double Parser::parseExpr() {
    double value = parseTerm();
    for (;;) {
        char op = peek();
        if (op == '+' || op == '-') {
            get();
            double rhs = parseTerm();
            value = (op == '+') ? value + rhs : value - rhs;
        } else {
            return value;
        }
    }
}

// умножение и деление
double Parser::parseTerm() {
    double value = parseNumber();
    for (;;) {
        char op = peek();
        if (op == '*' || op == '/') {
            get();
            double rhs = parseNumber();
            if (op == '/') {
                if (rhs == 0.0) throw std::runtime_error("Деление на ноль");
                value /= rhs;
            } else {
                value *= rhs;
            }
        } else {
            return value;
        }
    }
}

double Parser::parseNumber() {
    skipSpaces();
    size_t start = pos;
    while (pos < text.size() &&
           (std::isdigit((unsigned char)text[pos]) || text[pos] == '.'))
        ++pos;
    if (pos == start)
        throw std::runtime_error("Ожидалось число");
    return std::stod(text.substr(start, pos - start));
}
