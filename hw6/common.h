#ifndef COMMON_H
#define COMMON_H

#include "tree.h"
#define YYSTYPE TreeNode *

//标识符，包含名称和符号表中的指针
/*
    type：id的类型，这个属性未必在语法分析中才能获得，只要设定一个全局变量last_type（最近遇到的type关键字），
    即可在第一次定义时确定它的type，后面就不可以改了，除非是不同的作用域的同名变量！
*/
struct identifier{
    string name;
    int no; //作用域的编号
    string type;
    identifier(){}
    identifier(string n,int num,string t){
        name=n;
        no=num;
        type=t;
    }
};

//结构体action_zon是作用域，每个zone包含一个符号表和一个父节点值
struct action_zone{
    vector<identifier>id_list;//符号表！超级关键
    int father;
    action_zone(){
        father=-1;
    }
};

#endif