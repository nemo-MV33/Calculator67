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
