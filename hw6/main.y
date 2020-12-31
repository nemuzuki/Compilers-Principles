%{  //注意%left的地方越靠后定义的运算优先级越高！
    #include"common.h"
    extern TreeNode * root;
    int yylex();
    int yyerror( char const * );
    extern action_zone zone[20];
%}
%defines

%start program

%token ID INT_VAL STRING_VAL CHAR_VAL FLOAT_VAL
%token IF ELSE WHILE FOR RETURN
%token INT VOID CHAR FLOAT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA QUOTA 
%token GET_ADDR
%token TRUE FALSE
%token NOT
%token ADD_ONE SUB_ONE
%token ADD_SELF SUB_SELF
%token MUL DIV MOD
%token ADD SUB
%token LARGER SMALLER LARGER_EQUAL SMALLER_EQUAL NOT_EQUAL
%token EQUAL
%token AND OR
%token ASSIGN
%token PRINTF SCANF

%right NOT
%right ADD_ONE SUB_ONE
%right ADD_SELF SUB_SELF
%left ADD SUB
%left MUL DIV MOD
%left LARGER SMALLER LARGER_EQUAL SMALLER_EQUAL NOT_EQUAL
%left EQUAL
%right ASSIGN
%left OR 
%left AND
%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE 
%nonassoc UMINUS
%%
program
    : statements {
        root=new TreeNode(NODE_PROG);
        root->addChild($1);
    }
    ;
statements
    : statement {$$=$1;}
    | statements statement{$$=$1;$$->addSibling($2);}
    ;
statement
    : LBRACE statements RBRACE {//花括号，这一条至关重要，决定了作用域
        TreeNode *node=new TreeNode(NODE_STMTS);
        node->addChild($2);
        $$=node;
    }
    | function {$$=$1;}
    | type instruction SEMICOLON{//int a=2;
        $$=$2;
    }
    | instruction SEMICOLON{//a=2;
        $$=$1;
    }
    | scanf_statement {$$=$1;}
    | printf_statement {$$=$1;}
    | if_else_statement {$$=$1;}
    | while_statement {$$=$1;}
    | for_statement {$$=$1;}
    | return_statement {$$=$1;}
    | self_add SEMICOLON {$$=$1;}
    ;

instruction
    : instruction_element{
        $$=$1;  
    }
    | instruction COMMA instruction_element{
        $$=$1;
        $$->addSibling($3);
    }
    ;
instruction_element
    : ID {//a=2;
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->addChild($1);
        $$=node; 
    }
    | ID ASSIGN expr {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->addChild($1);
        node->addChild($3);
        $$=node;  
    }
    ;

if_else_statement
    : IF LPAREN bool_expr RPAREN statement %prec LOWER_THEN_ELSE {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    | IF LPAREN bool_expr RPAREN statement ELSE statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($3);
        node->addChild($5);
        node->addChild($7);
        $$=node;
    }
    ;

while_statement
    : WHILE LPAREN bool_expr RPAREN statement {  //while(a>b)
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_WHILE;
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    ;

for_statement
    : FOR LPAREN instruction SEMICOLON bool_expr SEMICOLON instruction RPAREN statement {
        //for(i=0; i<b; i++)
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($3);
        node->addChild($5);
        node->addChild($7);
        node->addChild($9);
        $$=node;
    }
    | FOR LPAREN type instruction SEMICOLON bool_expr SEMICOLON instruction RPAREN statement {
        //for(int i=0; i<b; i++)
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($4);
        node->addChild($6);
        node->addChild($8);
        node->addChild($10);
        $$=node;
    }
    ;

return_statement
    : RETURN expr SEMICOLON{
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_RETURN;
        node->addChild($2);
        $$=node;
    }
    ;


scanf_statement
    : SCANF LPAREN STRING_VAL COMMA GET_ADDR ID RPAREN SEMICOLON {//scanf("%c", &ch);
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_SCANF;
        node->addChild($3);
        node->addChild($6);
        $$=node;    
    }
    ;

printf_statement
    : PRINTF LPAREN STRING_VAL COMMA ID RPAREN SEMICOLON {//printf("hello, %d\n", i);
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        node->addChild($5);
        $$=node;   
    } 
    | PRINTF LPAREN STRING_VAL RPAREN SEMICOLON {//printf("hello, %d\n");
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        $$=node;   
    } 
    ;
bool_expr
    : TRUE {
        $$=$1;//true和false节点的信息在lex程序里面定义了
    }
    | FALSE {$$=$1;}
    | expr {//单独一个表达式也可以，和0比较
        $$=$1;
    }
    | LPAREN bool_expr RPAREN {//这里可能会warning: 1 shift/reduce conflict
        $$=$2;
    }
    | expr EQUAL expr { //a+b==c，整个表达式的类型应该是布尔
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_EQUAL;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;//得到expr的行号
        $$=node;
    }
    | expr LARGER expr { //a+b>c
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_LARGER;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;
    }
    | expr SMALLER expr { //a+b<c
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_SMALLER;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;
    }
    | expr LARGER_EQUAL expr { //a+b>=c
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_LARGER_EQUAL;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;
    }
    | expr SMALLER_EQUAL expr { //a+b<=c
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_SMALLER_EQUAL;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;
    }
    | expr NOT_EQUAL expr { //a+b!=c
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_NOT_EQUAL;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;
    }
    | bool_expr AND bool_expr{  //a>0 && a<=10 
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_AND;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
    | bool_expr OR bool_expr{   //a<=10 || a%100==10 
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_OR;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
    | NOT bool_expr{    //!a==0
        TreeNode *node=new TreeNode(NODE_BOOL);
        node->opType=OP_NOT;
        node->addChild($2);
        node->lineno=$2->lineno;
        $$=node;  
    }

    ;
expr
    : ID {$$=$1;}
    | INT_VAL {$$=$1;}
    | FLOAT_VAL {$$=$1;}
    | CHAR_VAL {$$=$1;}
    | STRING_VAL {$$=$1;}
    | LPAREN expr RPAREN {//这里可能会warning: 1 shift/reduce conflict
        $$=$2;
    }
    | expr ADD expr {
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_ADD;
        node->varType=Notype;//现在还不知道类型，在类型检查时赋予
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;//整个expr节点的行号由子表达式的行号决定
        $$=node;   
    }
    | expr SUB expr {
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_SUB;
        node->varType=Notype;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
    | expr MUL expr {
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_MUL;
        node->varType=Notype;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
    | expr DIV expr {
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_DIV;
        node->varType=Notype;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
    | expr MOD expr {
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_MOD;
        node->varType=Notype;
        node->addChild($1);
        node->addChild($3);
        node->lineno=$1->lineno;
        $$=node;   
    }
   
    | SUB expr %prec UMINUS {//前面是负号的情况
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_SUB;
        node->varType=Notype;
        node->addChild($2);
        node->lineno=$2->lineno;
        $$=node;  
    }
    | ADD expr %prec UMINUS {//前面是正号的情况
        TreeNode *node=new TreeNode(NODE_EXPR);
        node->opType=OP_ADD;
        node->varType=Notype;
        node->addChild($2);
        node->lineno=$2->lineno;
        $$=node;  
    }
    ;

self_add
    : ID ADD_SELF expr { //a+=b，是一种stmt！
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->opType=OP_ADD_SELF;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | ID SUB_SELF expr{ //a-=b
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->opType=OP_SUB_SELF;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | ID ADD_ONE {//a++
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->opType=OP_ADD_ONE;
        node->addChild($1);
        $$=node;  
    }
    | ID SUB_ONE {//a--
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->opType=OP_SUB_ONE;
        node->addChild($1);
        $$=node;  
    }
type
    : INT {//这代表"int"这三个字母
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_INTEGER;
        $$=node; 
    }
    | VOID {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_VOID;
        $$=node;         
    }
    | CHAR {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_CHAR;
        $$=node;    
    }
    | FLOAT {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_FLOAT;
        $$=node;    
    }
    ;

parameter_list
    : parameter {$$=$1;}
    | parameter_list COMMA parameter {  //int a,char b
        $$=$1;
        $$->addSibling($3);
    }
    ;
parameter
    : type ID { //int a
        TreeNode *node=new TreeNode(NODE_PARA);//参数类型
        node->varType=$1->varType;
        node->addChild($1);
        node->addChild($2);
        $$=node;
    }
    ;
function
    : type ID LPAREN parameter_list RPAREN statement{        //int f(int a,int b){}
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FUNC;//函数类型
        node->varType=$1->varType;
        node->addChild($2);
        node->addChild($4);
        node->addChild($6);
        $$=node;
    }
    | type ID LPAREN RPAREN statement{   //int f()，不让paralist->空，避免使用epsilon
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FUNC;//函数类型
        node->varType=$1->varType;
        node->addChild($2);
        node->addChild($5);
        $$=node;
    }
    
    ;

%%
