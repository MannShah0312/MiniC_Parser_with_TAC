# Mini C Parser with TAC Generation

This project implements a **parser for a subset of the C language (Mini C)** using **Flex** and **Bison**.  
The parser translates Mini C programs into **Three Address Code (TAC)**, which is a common intermediate representation in compilers.

---

## ✨ Features
- Lexical analysis using **Flex**
- Syntax analysis and parsing using **Bison**
- **Three Address Code (TAC)** generation for Mini C programs
- Supports basic variable declarations, assignments, and arithmetic expressions

---

## ⚙️ Requirements
Make sure you have the following installed:
- **Flex**
- **Bison**
- **GCC**

On Ubuntu/Debian-based systems, you can install them via:
```bash
sudo apt-get install flex bison gcc
```

---

## 🚀 Build Instructions

bison -d parser.y -o parser.tab.c
flex -o lex.yy.c lexer.l
gcc parser.tab.c lex.yy.c -o parser -lfl

