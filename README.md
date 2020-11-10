calc.y：支持赋值语句的计算器

运行方法：
```
bison -d calc.y
gcc calc.tab.c -o calc
./calc
```
sysycc.l：

一个支持作用域的lex语法分析程序
运行方法：
```
flex -+ sysycc.l
g++ lex.yy.cc -o lcc.out
./lcc.out
```
