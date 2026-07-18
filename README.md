# RISC-V Arithmetic Expression Evaluator

A robust **RISC-V Assembly (RV32I)** program designed to parse, validate, and evaluate complex arithmetic expressions provided as ASCII strings. The program supports standard operations (`+`, `-`, `*`, `/`), nested parentheses, multi-digit integer conversions, and complete low-level arithmetic routines implemented from scratch.



## 🌟 Key Features

* **Expression Parsing & Stack-Based Evaluation**:
  * Processes string input character-by-character.
  * Dynamically manages operator precedence and nested parentheses using the execution stack (`sp`).
* **Custom Integer Arithmetic Algorithms**:
  * **Shift-and-Add Multiplication (`mul`)**: Custom implementation of binary multiplication without relying on hardware multiplication instructions, featuring sign resolution and overflow checks.
  * **Bitwise Restoring Division (`div`)**: Custom 32-bit division routine based on bit shifts and restoring subtraction, including division-by-zero protection.
  * **String to Integer Converter (`string_2_int`)**: Converts ASCII numerical substrings into 32-bit signed integers.
* **Comprehensive Error & Overflow Management**:
  * Detects division by zero (`stai cercando di dividere per 0`).
  * Handles arithmetic overflow for Addition, Subtraction, Multiplication, and Division.
  * Validates parenthesis matching (`una o più parentesi non sono chiuse o non sono state aperte`).
  * Catches invalid characters and malformed expression syntax.



## 🧪 Testing Custom Expressions

In [`main.s`], multiple pre-defined expressions are stored in the `.data` section:

```assembly
menoTrecentoVentiQuattro: .string "((1+2)*(3*2))-(1+(1024/3))"
sette:                    .string "1+(1+(1+(1+(1+(1+(1+0))))))"
menoDuemilaQuarantotto:   .string "((00000-2)*(1024+1024)) / 2"
ofMul:                    .string "2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(1024*1024)))))))))))"
due:                      .string "2147483647+0"
ofSum:                    .string "2147483647+1"
dueSub:                   .string "(0-2147483647)-1"
ofSub:                    .string "(0-2147483647)-2"
erroreParentesi:          .string "32+(7-(2+3)"
```

To test a specific expression (or your own custom string), update line 35 in [`main.s`]:

```assembly
la a1 <string_name>   # e.g., la a1 menoTrecentoVentiQuattro
```


## ⚙️ Technical Architecture & Register Allocation

### Register Usage

| Register | Usage / ASCII Constant |
| :--- | :--- |
| `s0` | Constant `1` |
| `s1` | Constant `2` |
| `s2` | ASCII `'0'` (48) |
| `s3` | ASCII character after `'9'` (58) |
| `s4` | ASCII space `' '` (32) |
| `s5` | ASCII `'('` (40) |
| `s6` | ASCII `')'` (41) |
| `s7` | ASCII `'*'` (42) |
| `s8` | ASCII `'+'` (43) |
| `s9` | ASCII `'-'` (45) |
| `s10` | ASCII `'/'` (47) |
| `a6` | Parenthesis balance counter |
| `sp` | Stack pointer for subexpressions & nested evaluations |



## 👨‍💻 Author

**Pietro Palandrani**  
Computer Science Project for the course Computer Architecture at University of Florence
