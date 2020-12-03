%{
    #include"common.h"
    extern TreeNode * root;
    VarType now_type=VAR_VOID;
    struct id{
        string name;
        VarType type;
        id(){
            name="";
            type=VAR_VOID;
        }
        id(string n,VarType t){
            name=n;
            type=t;
        }
    };
    vector<id>v; 
    int yylex();
    int yyerror( char const * );
%}
%defines

%start program

%token ID INTEGER STRING
%token IF ELSE WHILE FOR RETURN
%token INT VOID CHAR
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
%left MUL DIV MOD
%left ADD SUB
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

instruction
    : type declare_list SEMICOLON {     //int a,b; int a=2,b; int a,b=2;
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_DECL;
        node->addChild($1);
        node->addChild($2);
        $2->varType=$1->varType;
        $$=node;  
    }
    ;
declare_list
    : declare{
        $$=$1;
    }
    | declare_list COMMA declare{
        $$=$1;
        $$->addSibling($3);
    }
    ;
declare
    : ID {//b
        TreeNode *node=new TreeNode(NODE_DECL);
        node->addChild($1);
        $$=node; 
    }    
    | ID ASSIGN expr {//a=1
        TreeNode *node=new TreeNode(NODE_DECL);
        node->addChild($1);
        node->addChild($3);
        $$=node; 
    }
    ;
if_else_statement
    : IF bool_statement statement %prec LOWER_THEN_ELSE {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($2);
        node->addChild($3);
        $$=node;
    }
    | IF bool_statement statement ELSE statement {
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_IF;
        node->addChild($2);
        node->addChild($3);
        node->addChild($5);
        $$=node;
    }
    ;

while_statement
    : WHILE bool_statement statement {  //while(a>b){....}
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_WHILE;
        node->addChild($2);
        node->addChild($3);
        $$=node;
    }
    ;

bool_statement
    : LPAREN bool_expr RPAREN {$$=$2;}
    ;


for_statement
    : FOR LPAREN declare_list SEMICOLON bool_expr SEMICOLON equation RPAREN statement {
        //for(i=0; i<b; i++)
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($3);
        node->addChild($5);
        node->addChild($7);
        node->addChild($9);
        $$=node;
    }
    | FOR LPAREN instruction bool_expr SEMICOLON equation RPAREN statement {
        //for(int i=0; i<b; i++)
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_FOR;
        node->addChild($3);
        node->addChild($4);
        node->addChild($6);
        node->addChild($8);
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


printf_statement
    : PRINTF LPAREN STRING COMMA ID RPAREN SEMICOLON {//printf("hello, %d\n", i);
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_PRINTF;
        node->addChild($3);
        node->addChild($5);
        $$=node;   
    } 
    ;
scanf_statement
    : SCANF LPAREN STRING COMMA GET_ADDR ID RPAREN SEMICOLON {//scanf("\%d", &ch);
        TreeNode *node=new TreeNode(NODE_STMT);
        node->stmtType=STMT_SCANF;
        node->addChild($3);
        node->addChild($6);
        $$=node;    
    }
    ;

bool_expr
    : TRUE {$$=$1;}
    | FALSE {$$=$1;}
    | expr EQUAL expr { //a+b==c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_EQUAL;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr LARGER expr { //a+b>c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LARGER;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr SMALLER expr { //a+b<c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SMALLER;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr LARGER_EQUAL expr { //a+b>=c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_LARGER_EQUAL;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr SMALLER_EQUAL expr { //a+b<=c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SMALLER_EQUAL;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | expr NOT_EQUAL expr { //a+b!=c
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NOT_EQUAL;
        node->addChild($1);
        node->addChild($3);
        $$=node;
    }
    | bool_expr AND bool_expr{  //a>0 && a<=10 
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_AND;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | bool_expr OR bool_expr{   //a<=10 || a%100==10 
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_OR;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | NOT bool_expr{    //!a==0
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_NOT;
        node->addChild($2);
        $$=node;  
    }
    ;
expr
    : ID {$$=$1;}
    | INTEGER {$$=$1;}
    | expr ADD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_ADD;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr SUB expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SUB;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr MUL expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MUL;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr DIV expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_DIV;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | expr MOD expr {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_MOD;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
   
    | SUB expr %prec UMINUS {
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SUB;
        node->addChild($2);
        $$=node;  
    }

    ;

equation
    : ID ADD_SELF expr { //a+=b
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_ADD_SELF;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | ID SUB_SELF expr{//a-=b
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SUB_SELF;
        node->addChild($1);
        node->addChild($3);
        $$=node;   
    }
    | ID ADD_ONE {//a++
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_ADD_ONE;
        node->addChild($1);
        $$=node;  
    }
    | ID SUB_ONE {//a--
        TreeNode *node=new TreeNode(NODE_OP);
        node->opType=OP_SUB_ONE;
        node->addChild($1);
        $$=node;  
    }
type
    : INT {
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
    | STRING {
        TreeNode *node=new TreeNode(NODE_TYPE);
        node->varType=VAR_STRING;
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
        TreeNode *node=new TreeNode(NODE_FUNC);//函数类型
        node->varType=$1->varType;
        node->addChild($1);
        node->addChild($2);
        node->addChild($4);
        node->addChild($6);
        $$=node;
    }
    | type ID LPAREN RPAREN statement{   //int f()，不让paralist->空，避免使用epsilon
        TreeNode *node=new TreeNode(NODE_FUNC);//函数类型
        node->varType=$1->varType;
        node->addChild($1);
        node->addChild($2);
        node->addChild($5);
        $$=node;
    }
    
    ;

%%