#!/bin/zsh
# компиляция и запуск тестов
cd "$(dirname "$0")"
clang++ -std=c++17 tests.cpp \
    -I/opt/homebrew/include \
    -L/opt/homebrew/lib \
    -lgtest -lgtest_main \
    -o tests_runner && ./tests_runner
