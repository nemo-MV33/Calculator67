#!/bin/zsh
# сборка и запуск калькулятора
cd "$(dirname "$0")"
clang++ -std=c++17 -fobjc-arc -framework Cocoa main.mm -o Calculator && ./Calculator
