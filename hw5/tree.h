#ifndef TREE_H
#define TREE_H
#include<iostream>
#include <string>
#include <cstring>
#include <iomanip>
using namespace std;

using std::cerr;
using std::cout;
using std::endl;
using std::string;

enum NodeType{
    NODE_CONST,//常数
    NODE_BOOL,
    NODE_VAR,
    NODE_EXPR,
    NODE_TYPE,
    NODE_STMT,
    NODE_PROG,//整个程序
    NODE_OP,
    NODE_PARA,//参数类型int a
    NODE_FUNC,
    NODE_DECL_LIST,//声明list
    NODE_CHAR,
    NODE_STRING
};

enum StmtType{
    STMT_IF,
    STMT_WHILE,
    STMT_DECL,
    STMT_ASSIGN,
    STMT_PRINTF,
    STMT_SCANF,
    STMT_FOR,
    STMT_RETURN,
    STMTS
};


enum OpType{
    OP_EQUAL,
    OP_NOT,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_LARGER,
    OP_SMALLER,
    OP_LARGER_EQUAL,
    OP_SMALLER_EQUAL,
    OP_NOT_EQUAL,
    OP_AND,
    OP_OR,
    OP_ADD_SELF,
    OP_SUB_SELF,
    OP_ADD_ONE,
    OP_SUB_ONE
};


enum VarType{
    VAR_INTEGER,
    VAR_VOID,
    VAR_CHAR,
    VAR_STRING
};

struct TreeNode {
    int nodeID;
    NodeType nodeType;
    //多种类型
    int int_val;
    bool bool_val;
    char char_val;
    char *string_val;
    StmtType stmtType;
    OpType opType;
    VarType varType;
    string var_name;

    int zone;//作用域

    TreeNode *child = nullptr;
    TreeNode *sibling = nullptr;//链表连接子节点们


    TreeNode(NodeType type){
        nodeType=type;//先确定大类型
        //再确定具体是哪种语句

    }
    void addChild(TreeNode *);
    void addSibling(TreeNode *);

    void genNodeId();//从根节点开始逐个赋Id 实现方式同学们可以自行修改

    void printAST();//打印语法树s结点
    /***
     * 以下的几个函数皆为在printAST过程中辅助输出使用
     * 同学们可以根据需要自己使用其他方法
    ***/
    void printNodeInfo(TreeNode *node);
    void printNodeConnection(TreeNode *node);
    void printNodeTypeInfo(TreeNode *node);
};
#endif