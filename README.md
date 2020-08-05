# nbasic

This repository is of Bob Rost's nbasic compiler, from his [NES game development course](http://bobrost.com/nes/).

See also: [nesasm](https://github.com/Fordi/nesasm).

To build:

You'll need g++ or another C++ compiler (assigned to the environment variable `CXX`).

```bash
make
```

To install:

```bash
sudo make install
```

## nbasic Language Reference Manual

#### _Updated March 15, 2004_

#### Originally from http://bobrost.com/nes/files/nbasic_manual.html

### Contents

* [About nbasic](#about)
* [Code Comments](#comments)
* [Inline Assembly](#asm)
* [Numbers](#numbers)
* [Variables](#vars)
* [Setting Variables](#set)
* [Push and Pop](#push)
* [Array Declaration](#arrays)
* [Array Usage](#arrays2)
* [Static Data](#data)
* [Labels](#labels)
* [Jumps](#jumps)
* [Arithmetic Expressions](#arithmetic)
* [Conditional Expressions](#conditionals)
* [Loops](#loops)
* [List of nbasic Keywords](#keywords)

<a name="about" />

### About nbasic

`nbasic` is a high-level programming language designed for the 6502 processor, the main CPU of the Nintendo Entertainment System. It has BASIC-like program flow, relying on `goto`, `gosub`, and `return` for most execution flow. It also has no dynamic memory allocation and no actual function parameter passing; rather, globally scoped variables and arrays take the place of these. This kind of language design allows for a very efficient implementation on a low-powered 8-bit CPU such as the NES's 6502.

The language was originally created by Bob Rost for development of the homebrew original NES game</a> [Sack of Flour, Heart of Gold](http://bobrost.com/sof), and its development continues as the language is used in Bob's class at Carnegie Mellon, [Game Development for the 8-bit NES](http://bobrost.com/nes). While this document can be a useful guide when dealing with the language, the best way to learn is to play with some of the example nbasic programs on the course website.<a name="comments"></a>

<a name="comments"></a>

### Code Comments

Comments are created by using any of several common comment conventions. Comments begin with a double forward slash, a hash mark, or a semicolon. A comment may begin at any location in a line, and the rest of the line is ignored by the compiler.

```
   // this is a C++-style comment  
   # this is a shell-style comment  
   ; this is a nesasm-style comment (for inline assembly)  
   ;// this nesasm-style comment shows up colored in my C++ editor  
```

<a name="asm"></a>

### Inline Assembly

You may sometimes wish to use inline assembly, such as when a particular advanced feature is not provided natively by the `nbasic` compiler, or when you must feed directives to the assembler. Assembly blocks begin with the `asm` keyword, and they are ended by the `endasm` keyword. The lines of text in between are fed as-is to the assembler. Note that, if you are using nesasm as your assembler, you will be required to start most lines with a space or tab.

```
asm  
  lda #0 ;nesasm comments start with a semicolon  
  sta $2000  
  sta $2000  
endasm
```

In addition to a large block of assembly code, you can also create a single line of inline assembly. This is useful for using a single instruction without interrupting the flow of your code. The `asmline` keyword takes the remainder of its line and puts it into your file as assembly.

`asmline lda [pointer],y`

<a name="numbers"></a>

### Numbers

For your convenience, `nbasic` supports binary (base 2), decimal (base 10), and hexadecimal (base 16) numbers. All numbers are treated as unsigned, usually in the range 0 to 255, though sometimes in the 16-bit range for memory locations. Binary numbers begin with a `%` character, decimal numbers are a string of digits, and hexadecimal numbers begin with a `$` character. The hexadecimal letters may be either capital or lowercase. These are examples of the same number written in all three methods:

`%11111111`  
`255`  
`$ff`  

<a name="vars"></a>

### Variables

The first important rule of `nbasic` variables is that you should not use the names `A`, `X`, or `Y` as variable names. These are special registers of the 6502 processor. You are allowed to use them in many cases as you would a variable, but you should first be familiar with the 6502 and what you are doing in each particular use. As a general rule, array accesses will alter the `X` register, and any sort of arithmetic expression will alter the `A` register. `Y` is not touched in many cases.

General variables in `nbasic` are single unsigned bytes of memory. They have global scope throughout your program, and you have the option of initializing them manually or automatically. Automatic initialization is done the first time a variable's value is set, and a single byte of convenient memory is allocated. Manual memory allocation is described below in the</a> [Arrays](#arrays) section.

<a name="set"></a>

### Setting Variables

The `set` statement is used to assign a value to a variable, array element, or a specific location in memory. The general syntax is `set _location value_`. The value is always an unsigned byte. These examples demonstrate setting a value to a variable, an array element, and a specific memory location.

```
set my_var 5
set [my_array 3] 1
set $4016 0
```

It is important to note that the compiler automatically allocates 1 byte of memory for any variable which is assigned a value and not otherwise declared elsewhere in the program.

<a name="push"></a>

### Push and Pop

There are times when you may wish to store data on the processor stack. For instance, saving and restoring the values of registers during an interrupt. For important cases like this, you can use the `push` and `pop` keywords to store or retrieve data on the stack. The nbasic implementation will only let you directly push or pop the values of registers. Note that, because `gosub` and `return` also manipulate the stack, you should always be certain to `pop` within the same function as a corresponding `push`. Due to the nature of stacks, if you push several registers, you should pop them in the reverse order. Here is an example of proper stack usage during an interrupt.

```
IRQ:
  push a
  push x
  push y
  gosub irq_handler
  pop y
  pop x
  pop a
  resume
```

<a name="arrays"></a>

### Array Declaration

Arrays and variables are essentially the same in `nbasic`, and they differ primarily in their usage.

Arrays may be declared with several methods. Simple declaration assigns a specified number of bytes to a variable name, using the first conveniently available memory that the compiler finds. This example allocates 8 bytes for the variable `my_array`.

```
array my_array 8
```

Arrays may also be declared in the zero page of memory, which guarantees that they are entirely within the first 256 bytes of system memory, which allows faster access time for frequently used data.

```
array zeropage my_array 8
```

You may also wish for your array to exist at a particular location in memory. For this, you use an absolute array declaration, providing the location in memory, the variable name, and the array size. This is very helpful for allocating sprite memory to allow DMA.

```
array absolute $c000 my_array 8
array absolute $200 sprite_mem 256
```

If you wish to allocate a particular general variable in the zero page or at an absolute memory location, you may declare an array of size 1 using the above syntax. It is also sometimes helpful to declare an absolute array of size 0\. This will allow you to reference a particular memory region by a simple variable name. This can be useful for NES system ports, or for quickly accessing certain parts of an array.

```
array absolute $4016 joystick1port 0
array absolute $c000 hero_data 8
array absolute $c001 hero_lives 0
```

It is important to note that `nbasic` automatically allocates the memory region from $100 to $1FF for the variable `nbasic_stack`. This is the memory region of the 6502's call stack, which is very bad for you to accidentally overwrite. If you absolutely must manipulate this region manually, then you may use the `nbasic_stack` variable; otherwise, don't touch it.</a><a name="arrays2"></a>

<a name="arrays2"></a>

### Array Usage

As mentioned above, arrays and variables in `nbasic` are essentially the same, and they differ primarily in usage. An array is a contiguous region of memory assigned to a variable name. Elements in the array may be referenced by the general syntax `[`*`array_name`* *`index`*`]`. Additionally, the first element of the array may be referenced simply by its name. Array elements, like other variables, are unsigned bytes, and they may be used in arithmetic expressions or set like other variables. The index of an array element may be a constant number, a variable, or an arithmetic expression.

```
[my_array 0] // the first element
my_array // equivalent to the above line
set [my_array my_var] 5
[my_array [my_var 2]]
[my_array x]
```

Notice in the last example that the index variable is the `X` register. In general, array accesses destroy the current value of the `X` register. However, you may manually set the value of either the `X` or `Y` registers and use one of them as your array index. This will preserve the value of the register, and the array access itself will be faster. This can be useful when using the same index multiple times, or in multiple arrays.

```
set y 5
set [my_array y] 3
set [your_array y] 4
set [his_array y] [my_array 2]
```

<a name="data"></a>

### Static Data

The `data` keyword allows specifying a string of raw data to be included in the ROM. This is often used for text, palettes, and similar small and unchanging pieces of data. Data may consist of unsigned 8-bit numbers and ASCII strings, each separated by commas. ASCII strings must be enclosed in double quotes, and each character is individually converted to the corresponding ASCII value. Generally, a `data` statement will appear after a label, so that it may be referenced easily.

```
my_data:
data 1,3,"A string",0,$10,%10101
```

<a name="labels"></a>

### Labels

A label in `nbasic` is similar to a line number or label in many other programming languages. Your program may jump to a label to continue execution from that point on. In `nbasic`, labels may also be used as a variable, to allow you to reference static data at that point in the ROM. Labels are written as a name, followed by a colon. These examples demonstrate jumping to a label, and using a label as an array reference.

```
my_label:
  set my_var [my_data 2]
  goto my_label
my_data:
  data 0,1,2,3,4
```

<a name="jumps"></a>

### Jumps

Program flow is controlled by jumps, which allow your program to move the execution point to a label. The two types of jumps are `goto`, and `gosub`. A goto will simply move the current execution point, as it does in BASIC. A `gosub` is also just like in BASIC; it moves the current execution point, but it also saves the previous execution point on the stack. The `return` statement will return execution to just after the point from which the jump was made. Note that if you call `gosub` rampantly and do not have a `return` for each one, your program will overflow the 256 byte stack, which will crash the game.

```
my_label:
  gosub my_function
  goto my_label
my_function:
  return
```

In BASIC, the `goto` statement is notorious for creating "spaghetti" code, and it is frowned upon in other languages. For this reason, I have two primary guidelines for proper usage of jumps, in order to help avoid some of the common problems.

* Use `goto` for loops, or for downward jumps within a single function.
* Use `gosub` and `return` for all other jumps.

Notice that I reference the concept of a function, even though `nbasic` does not actually support functions as in other languages. In general, a function is a block of code under a label, which is written to do one particular thing. With proper code design, the boundaries between one conceptual function and another will be obvious in almost all cases.

Another related keyword is `resume`. It is similar to `return`, but it is used to return execution after an interrupt is called, such as the NMI at the blanking interval.

Yet another related keyword is `branchto`. See the section on conditionals for information on that.

<a name="arithmetic"></a>

### Arithmetic Expressions

Arithmetic expressions in nbasic are written in prefix notation. This creates non-ambiguous expressions that are easy for the compiler to parse. Valid operators are addition (`+`), subtraction (`-`), shift left (`<<`), shift right (`>>`), bitwise and (`&`), bitwise or (`|`), bitwise xor (`^`). Each of these operators should be followed by two numbers, variables, array lookups, or arithmetic expressions in order to create a valid expression. Note that bit shifting may only be done by a constant amount.

```
set a + one two
set four << one 1
set value - & bitmask %10101011 + 3 two
```

<a name="conditionals"></a>

### Conditional Expressions

The nbasic language supports two types of conditional statements. The first is `if` *`condition`* *`result`*. This will execute a single nbasic statement if the provided condition is true.

The second type is an `if` *`condition`* `then` `...` `endif` construct. In this type, when the provided condition is true, it will execute multiple nbasic statements listed between the `then` and `endif` keywords. Note that, due to limitations of the hardware, the assembler will fail if the statement block compiles to more than 127 bytes of code.

```
if one <= 2 then
  set result1 one
  set result2 two
  gosub do_more_stuff
  return
endif

if x <> 0 branchto my_label
```

You may notice the use of the `branchto` keyword. This is a special case goto, designed for fast loop execution. You may use a `branchto` as the action of a simple comparison, and it will jump to the designated label. However, the jump may not cross more than 127 compiled bytes of code.

<a name="#keywords"></a>

### List of `nbasic` Keywords

`absolute`  
`array`  
`asm`  
`asmline`  
`branchto`  
`data`  
`endasm`  
`endif`  
`gosub`  
`goto`  
`if`  
`pop`  
`push`  
`resume`  
`return`  
`set`  
`then`  
`x`  
`y`  
`zeropage`  
