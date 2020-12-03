作业只需完成语法树的构建，不用计算！

一、文件结构
main.l（词法分析）：每种终结符对应哪种标识符，遇到终结符该怎么办
main.y（语法分析）：定义各种标识符，各种产生式（非终结符）及动作【补充产生式】
common.h：中间为了方便安排的头文件
main.cpp：主函数
tree.h：定义树节点的结构
tree.cpp：实现treenode的成员函数
main.out:最后编译得到的可执行文件



二、要求
1. 数据类型：int，char, 常量字符串。
2. 变量声明，注意正确区分不同作用域的同名变量。
3. 语句：赋值（=）、表达式语句、语句块、if、while、for、return.
4. 表达式：算术运算（+、-、*、/、%，其中 +、-都可以是单目运算符）、关系运算（==，>，<，
>=，<=，!=）和逻辑运算（（与）、||（或）、!（非））
5. 注释.
6. 简单的输入输出（依 SysY 运行时库或自行定义词法、语法、语义均可，最好可以支持有“格式控制符”的 printf, scanf）。



三、执行方法：
make run：整个编译一遍
make out：键盘输入
make test：运行测试用例



四、产生式结构
1.最抽象的部分
program：整个程序
statements：语句块
statement
    : LBRACE statements RBRACE {//花括号，这一条至关重要，决定了作用域
        $$=$2;
    }
    | function {$$=$1;}
    | instruction {$$=$1;}
    | scanf_statement {$$=$1;}
    | printf_statement {$$=$1;}
    | if_else_statement {$$=$1;}
    | while_statement {$$=$1;}
    | for_statement {$$=$1;}
    | return_statement {$$=$1;}
    | equation SEMICOLON {$$=$1;}
    | declare_list SEMICOLON {$$=$1;}
    ;


2.变量声明
instruction：
设计了一个declare_list结构，因为变量声明可以是int a,b=2这样的组合，以分号结尾

3.for_statement：
两种for(i=1;i<0;++i)、for(int i=1;i<0;++i)


4.scanf_statement
printf_statement


5.布尔表达式
注意区分布尔表达式和普通表达式：
bool_expr：布尔表达式 a==b
    bigger
    smaller
    bigger_equal
    smaller_equal
    not_equal
    包括 and or 的组合


6.普通表达式expr：算术运算（+、-、*、/、%，其中 +、-都可以是单目运算符）、关系运算（==，>，<，>=，<=，!=）
和逻辑运算（（与）、||（或）、!（非））
expr：普通表达式，可以被当成一个变量，包括运算+ - * / %
    add
    sub
    mul
    div
    mod
7.equation等式
a++这里不算表达式，算一个陈述句，赋值表达式
a+=1也是一个陈述句
于是把它们归到equation等式里面，而equation加上分号可以作为陈述句
add_self:a+=b、a-=b
add_one:a++、a--


8.type数据类型:
int char void string

9.函数function
parameter_list参数表
parameter参数

10.词法分析中的关键点
注释：
作用域：左右括号！！
词法分析中判断作用域，特例是for语句，出现for就将当前作用域+1，后面的花括号就不影响作用域了
for_statement的int作用域属于下面的stats
例如：for(int i=0;i<n;++i){//假设现在i的作用域为9
    i=9;//现在i的作用域仍为9，不受前面花括号的影响！
    //必须在花括号的词法分析部分加上这种情况
}

11.树的结构
father
|(child)
son1-(sibling)-son2-(sibling)-son3


