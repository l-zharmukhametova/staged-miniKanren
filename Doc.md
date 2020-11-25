# Staged miniKanren

Staged miniKanren is an extension of miniKanren that supports staging. Staged programming is manual partial evaluation, where offline manual binding time analysis is used to select unifications for lifting. 

Given a program and only partially known input data, one can eliminate or simplify certain parts of the code, by performing computations that only involve available data. Depending on the known input, we might also be able to make observations such as whether a loop is degenerate for most iterations and restructure the code accordingly. As a result, we can have a new program that is specialized to the available input. 

In order to perform as much computation as possible, it is important to correctly annotate arguments according to their availability. This is done via *binding time analysis*. 

The power of staging is manual control of binding time analysis, where one can manually decide which unifications are to be lifted.

## Deferring unifications in miniKanren
In staged miniKanren, some unifications are done in the first stage, while others are quoted out and get deferred to the second stage. The second stage represents code that is "kept for later", while the first stage is for executing now. Deferring a unification is similar to deferring a command in functional programming. 

## Dynamic variables

We have tried an alternative approach to manual lifting of unifications by introducing dynamic variables, where we annotate some variables by hand, and the lifting automatically follows. To decide whether the unification needs to be deferred we could examine the terms being unified to see whether they contain a dynamic variable. This approach did not work as it was unclear how dynamic variables should interact with non-dynamic variables and the rest of the code. For example, if we just say that a term containing a dynamic variable is dynamic, then an expression like `(cdr (cons 5 y))` where only `y` is dynamic will be treated as dynamic, which is not ideal.
