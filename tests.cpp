#include <gtest/gtest.h>
#include "parser.h"

// Вспомогательная функция: вычислить строку и вернуть результат
static double calc(const string &expr) {
    return Parser(expr).evaluate();
}
//dark box
TEST(BlackBox, Plus) {
    EXPECT_DOUBLE_EQ(calc("2+3"), 5.0);
}
TEST(BlackBox,Minus){
    EXPECT_DOUBLE_EQ(calc("5-1"),4.0);
}
TEST(BlackBox,Ymn){
    EXPECT_DOUBLE_EQ(calc("5*5"),25.0);
}
TEST(BlackBox,Del){
    EXPECT_DOUBLE_EQ(calc("5/5"),1.0);
}

TEST(BlackBox, Priority) {
    EXPECT_DOUBLE_EQ(calc("5+2*2"), 9.0);
}

TEST(BlackBox, Parentheses) {
    EXPECT_DOUBLE_EQ(calc("(5+2)*2"), 14.0);
}

TEST(BlackBox, DivisionByZero) {
    EXPECT_THROW(calc("5/0"), runtime_error);
}

TEST(BlackBox, MissingBracket) {
    EXPECT_THROW(calc("(5+2"), runtime_error);
}
//white box

TEST(WhiteBox, Plus) {
    EXPECT_DOUBLE_EQ(calc("2+3"), 5.0);
}
TEST(WhiteBox,Minus){
    EXPECT_DOUBLE_EQ(calc("5-1"),4.0);
}
TEST(WhiteBox,Ymn){
    EXPECT_DOUBLE_EQ(calc("5*5"),25.0);
}
TEST(WhiteBox,Del){
    EXPECT_DOUBLE_EQ(calc("5/5"),1.0);
}
TEST(WhiteBox, Del_NaNul) {
    EXPECT_THROW(calc("5/0"), runtime_error);
}
TEST(WhiteBox, Root) {
    EXPECT_DOUBLE_EQ(calc("√9"), 3.0);
}

TEST(WhiteBox, Power) {
    EXPECT_DOUBLE_EQ(calc("2^3"), 8.0);
}

TEST(WhiteBox, Skb) {
    EXPECT_THROW(calc("(6-5"), runtime_error);
}
TEST(WhiteBox,Nothing){
    EXPECT_THROW(calc("++"),runtime_error);
}

TEST(BlackBox, UnaryMinus) {
    EXPECT_DOUBLE_EQ(calc("-5+3"), -2.0);
}
TEST(BlackBox, Float) {
    EXPECT_DOUBLE_EQ(calc("3.5*2"), 7.0);
}
TEST(BlackBox, NestedParentheses) {
    EXPECT_DOUBLE_EQ(calc("((2+3))*2"), 10.0);
}
TEST(BlackBox, RootAndPower) {
    EXPECT_DOUBLE_EQ(calc("√9+2^3"), 11.0);
}
TEST(BlackBox, EmptyExpression) {
    EXPECT_THROW(calc(""), runtime_error);
}

TEST(WhiteBox, DoubleUnaryMinus) {
    EXPECT_DOUBLE_EQ(calc("--5"), 5.0);
}
TEST(WhiteBox, LongChain) {
    EXPECT_DOUBLE_EQ(calc("1+2+3+4"), 10.0);
}

//new tests
TEST(BlackBox, LargeNumbers) {
    EXPECT_DOUBLE_EQ(calc("2000000000*2000000000"), 4000000000000000000.0);
}

TEST(BlackBox, DotWithoutDigitAfter) {
    EXPECT_DOUBLE_EQ(calc("2.*4"), 8.0);
}

TEST(BlackBox, LeadingDot) {
    EXPECT_DOUBLE_EQ(calc(".5+.5"), 1.0);
}


TEST(BlackBox, ZeroResult) {
    EXPECT_DOUBLE_EQ(calc("0*1000"), 0.0);
}

TEST(BlackBox, NegativePower) {
    EXPECT_DOUBLE_EQ(calc("2^-1"), 0.5);
}

TEST(BlackBox, ZeroPowerZero) {
    EXPECT_DOUBLE_EQ(calc("0^0"), 1.0);
}

TEST(BlackBox, RootOfZero) {
    EXPECT_DOUBLE_EQ(calc("√0"), 0.0);
}

TEST(BlackBox, ManyNestedParentheses) {
    EXPECT_DOUBLE_EQ(calc("((((5))))"), 5.0);
}

TEST(BlackBox, EmptyParentheses) {
    EXPECT_THROW(calc("()"), runtime_error);
}

TEST(BlackBox, OnlyOperator) {
    EXPECT_THROW(calc("*"), runtime_error);
}

TEST(WhiteBox, Fraction) {
    EXPECT_NEAR(calc("1/3"), 0.333333, 1e-5);
}
TEST(WhiteBox,SigedBeforSkobka) {
    EXPECT_THROW(calc("5("), runtime_error);
}

TEST(WhiteBox, ComboSym) {
    EXPECT_THROW(calc("5√9"), runtime_error);
}

TEST(WhiteBox, TestFormata) {
    EXPECT_THROW(calc("(√)"), runtime_error);
}

TEST(BlackBox, Overflow) {
    EXPECT_TRUE(isinf(calc("10000000000^10000000000")));
}

TEST(BlackBox, RootOfRoot) {
    EXPECT_DOUBLE_EQ(calc("√(√16)"), 2.0);
}

TEST(BlackBox, NegativeRoot) {
    
    EXPECT_DOUBLE_EQ(calc("-√9"), -3.0);
}

TEST(BlackBox, ZeroDividedByNumber) {
    EXPECT_DOUBLE_EQ(calc("0/5"), 0.0);
}

TEST(BlackBox, SmallNumbers) {
    EXPECT_NEAR(calc("0.000001*1000000"), 1.0, 1e-9);
}

TEST(BlackBox, OneToAnyPower) {
    EXPECT_DOUBLE_EQ(calc("1^99999"), 1.0);
}

TEST(BlackBox, NegativeZero) {
    EXPECT_DOUBLE_EQ(calc("-0"), 0.0);
}

TEST(BlackBox, RootWithoutNumber) {
    EXPECT_THROW(calc("√"), runtime_error);
}

TEST(BlackBox, PowerWithoutExponent) {
    EXPECT_THROW(calc("5^"), runtime_error);
}

TEST(BlackBox, PowerWithoutBase) {
    EXPECT_THROW(calc("^5"), runtime_error);
}

TEST(BlackBox, DoubleOperator) {
    EXPECT_THROW(calc("5++3"), runtime_error);
}
TEST(WhiteBox, NegativeRoot) {
    EXPECT_TRUE(isnan(calc("√-4")));
}
