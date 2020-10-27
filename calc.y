%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex ();
extern int yyparse();
FILE* yyin ;
void yyerror(const char* s );
char idStr [50];
//符号表：词素->对应的hash值，这里就取每位的asc码相加
double idlist[100];
//值表：符号存的值
double valuelist[100];
//计算单词对应哈希值
int hash(char *a){
    int h=0;
    int n=strlen(a);
    for(int i=0;i<n;++i){
        h=10*h+(int)a[i];
    }
    return h;
}
//id个数的计数器
int cnt=0;
%}

//按从弱到强顺序定义优先级
%token NUMBER
%token ID
%token ADD SUB MUL DIV LEFT RIGHT
%left EQUAL
%left ADD SUB
%left MUL DIV
%right UMINUS
%%

lines:
    lines expr ';' { printf("%f\n", $2); }
    | lines assign_stat ';'
    | lines ';'
    |
    ;

expr: 
    expr ADD expr { $$ = $1 + $3; }
    | expr SUB expr { $$ = $1 - $3; }
    | expr MUL expr { $$ = $1 * $3; }
    | expr DIV expr { $$ = $1 / $3; }
    | LEFT expr RIGHT { $$ = $2; }
    | SUB expr %prec UMINUS { $$ =-$2; }
    | NUMBER 
    | ID {
        int i;
        for(i=0;i<cnt;++i){
            if(idlist[i]==$1){
                break;
            }
        }
        $$=valuelist[i];
    }
    ;
//赋值语句，先找到符号表idlist中id的位置i，再去将值放到valuelist[i]
assign_stat:
    ID EQUAL expr{
        for(int i=0;i<cnt;++i){
            if(idlist[i]==$1){
                valuelist[i]=$3;
            }
        }
        // for(int i=0;i<cnt;++i){
        //     printf("%f %f\n",idlist[i],valuelist[i]);
        // }
    }
    ;
%%
//词法分析函数
int yylex(){
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n');
        else if(t=='+')return ADD;
        else if(t=='-')return SUB;
        else if(t=='*')return MUL;
        else if(t=='/')return DIV;
        else if(t=='(')return LEFT;
        else if(t==')')return RIGHT;
        else if(t=='=')return EQUAL;

        else if(t>='0'&&t<='9'){
            yylval=0;
            while(t>='0'&&t<='9'){
                yylval=10*yylval+(t-'0');
                t=getchar();
            }
            ungetc(t , stdin);
            return NUMBER;
        }
        //识别标识符id
        else if((t>='a'&&t<='z')||(t>='A'&&t<='Z')||t=='_'){
            int ti=0;
            while((t>='a'&&t<='z')||(t>='A'&&t<='Z')||t=='_'||(t>='0'&&t<='9')){
                idStr[ti++]=t;
                t=getchar();
            }
            idStr[ti]='\0';
            ungetc(t,stdin);

            int i=0;
            int hashcode=hash(idStr);
            for(i=0;i<cnt;++i){
                //本来就在符号表里，接下来可能会参与运算或者重新赋值
                if(idlist[i]==hashcode){
                    yylval=hashcode;//将assign_stat的$1设为hashcode
                    break;
                }
            }
            //没出现过肯定存到符号表里，等待赋值
            if(i==cnt){
                idlist[cnt++]=hashcode;
                yylval=hashcode;//将assign_stat的$1设为hashcode
            }
            return ID;
        }
        else{
            return t;
        }
    }
}
int main(void){
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char *s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}

// bison -d calc.y
// gcc calc.tab.c -o calc
// ./calc
