# C Compiler Front End Using Flex and Bison

## Overview

This project implements a simple C compiler front end that converts a supported subset of C programs into **Three-Address Code (TAC)** using Flex and Bison.

It performs lexical analysis, syntax analysis, basic symbol-table management, type handling, and intermediate code generation.

## Features

- Supports `int` and `float` data types.
- Handles variable declarations and assignments.
- Generates TAC for arithmetic expressions.
- Supports implicit type promotion and conversion for supported expressions.
- Handles nested `if-else` statements and `while` loops.
- Supports relational and equality operators.
- Uses temporary variables and labels for intermediate code generation.
- Detects certain errors, including undeclared and duplicate variables.

## Technologies Used

- C
- Flex (Lexical Analysis)
- Bison (Syntax Analysis)
- GCC (Compilation)

## Project Structure

```text
Compiler_Frontend/
├── front.l
├── front.y
├── sample.c
├── README.md
└── output.txt
```

- `front.l` — Defines lexical rules for recognizing tokens.
- `front.y` — Defines grammar rules, type handling, and TAC generation.
- `sample.c` — Sample C program used as input.
- `output.txt` — Generated Three-Address Code (optional).

## Installation

Install [MSYS2](https://www.msys2.org/) and open the **MSYS2 UCRT64** terminal.

Install the required tools:

```bash
pacman -S --needed flex bison gcc
```

## Build and Run

Navigate to the project directory:

```bash
cd /d/Compiler_Frontend
```

Generate the parser:

```bash
bison -d -o front.tab.c front.y
```

Generate the lexer:

```bash
flex -o lex.yy.c front.l
```

Compile the generated files:

```bash
gcc -o compiler.exe front.tab.c lex.yy.c
```

Run the compiler with the sample input and save the output:

```bash
./compiler.exe < sample.c > output.txt
```

View the generated TAC:

```bash
cat output.txt
```

## Example

### Input

```c
int a, b, c;
float x;

a = 2;
b = 5;
x = 2.5;

while (a < b) {
    if (x > 1.0) {
        if (a != 3)
            c = a + b;
        else
            c = a - b;
    } else {
        c = a * b;
    }
    a = a + 1;
}
```

### Generated Three-Address Code

```text
a = 2
b = 5
x = 2.5
L0:
t0 = a < b
if !t0 goto L1
t1 = x > 1.0
if !t1 goto L2
t2 = a != 3
if !t2 goto L3
t3 = a + b
c = t3
goto L4
L3:
t4 = a - b
c = t4
L4:
goto L5
L2:
t5 = a * b
c = t5
L5:
t6 = a + 1
a = t6
goto L0
L1:
```

*Note: Temporary variable and label names depend on the input program.*

## How It Works

1. **Lexical Analysis:** Flex identifies keywords, identifiers, literals, and operators.
2. **Syntax Analysis:** Bison validates the program according to the defined grammar.
3. **Symbol Table:** Tracks declared variables and their data types.
4. **Type Handling:** Applies supported type-promotion and conversion rules.
5. **Intermediate Code Generation:** Converts expressions and control-flow statements into TAC using temporary variables and labels.

## Limitations

This project supports an educational subset of C rather than the complete language. Unsupported features such as pointers, arrays, and function definitions are not implemented. Refer to the grammar in `front.y` for the exact supported syntax.

## License

This project is intended for educational purposes.