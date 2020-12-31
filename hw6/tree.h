#ifndef TREE_H
#define TREE_H
#include <iostream>
#include <string>
#include <cstring>
#include <iomanip>
#include <vector>
#include <queue>
using namespace std;

using std::cerr;
using std::cout;
using std::endl;
using std::string;
enum NodeType{
    NODE_STMT,//整个语句
    NODE_TYPE,//类型名
    NODE_CONST,//常量。包括int_value,char_value等
    NODE_BOOL,
    NODE_VAR,//变量名id
    NODE_OP,//运算符
    NODE_EXPR,
    NODE_PROG,//整个程序，由各种stmt构成
    NODE_PARA,//参数类型int a
    NODE_STMTS//一个作用域内stmt的集合
};

enum StmtType{
    STMT_DECL,//decl是a/a=4这种声明单元（element）
    STMT_IF,
    STMT_WHILE,
    STMT_PRINTF,
    STMT_SCANF,
    STMT_FOR,
    STMT_RETURN,
    STMT_FUNC
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
    VAR_STRING,
    VAR_FLOAT,
    Notype
};

union NodeAttr {
	int op;
	int vali;
	char valc;
	int symtbl_seq;
	
	NodeAttr(void) { op = 0; }
	NodeAttr(int i)	{ op = i; }
	NodeAttr(char c) { valc = c; }
};

struct Label {
    string true_label="";
	string false_label="";
	string begin_label="";
	string next_label="";
};

struct TreeNode {
    int nodeID;//语法树中的编号
    int lineno;//行号
    int zone;//作用域
    NodeType nodeType;//总节点类型

    //多种类型对应的值
    int int_val;
    float float_val;
    bool bool_val;
    char char_val;
    string string_val;

    StmtType stmtType;
    OpType opType;
    VarType varType;
    string var_name;


    TreeNode *child = nullptr;
    TreeNode *sibling = nullptr;//链表连接子节点们

    Label label;
    NodeAttr attr;
    int temp_var;//常量编号

    TreeNode(NodeType type){
        nodeType=type;//先确定大类型
        //再确定具体是哪种语句
        int_val=float_val=char_val=0;
        string_val="";
        varType=Notype;
    }

    /*添加子节点模块*/
    void addChild(TreeNode *);
    void addSibling(TreeNode *);

    /*打印语法树模块*/
    void genNodeId();//从根节点开始逐个赋Id
    void printAST();//打印语法树s结点
    void printNodeInfo(TreeNode *node);
    void printNodeConnection(TreeNode *node);
    void printNodeTypeInfo(TreeNode *node);

};
struct str_node{
    TreeNode *str=nullptr;
    int no;
    str_node(){}
    str_node(TreeNode *a,int b){
        str=a;
        no=b;
    }
};

//树结构
struct Tree{
    TreeNode *root=nullptr;
    int label_seq=0;
    int node_seq = 0;
	int temp_var_seq = 0;
    /*类型检查模块*/
    VarType find_id_type(TreeNode *id);
    void type_check(TreeNode *root);
    void stmt_check(TreeNode *root);

    void get_temp_var(TreeNode *root);

    /*标签生成模块*/
    void get_label();
    string new_label();
    void get_label(TreeNode *node);
    void recursive_get_label(TreeNode *root);
    void stmt_get_label(TreeNode *node);
    void expr_get_label(TreeNode *root);

    /*代码生成模块*/
    void gen_code(TreeNode *root);
    void recursive_gen_code(TreeNode *node);
    void stmt_gen_code(TreeNode *root);
    void expr_gen_code(TreeNode *root);

    void gen_header();
    void gen_decl();

    //小工具函数
    void print_value(TreeNode *node);
    void deal_with_judge(TreeNode *judge);
    void jump_true(TreeNode *judge);
    void jump_false(TreeNode *judge);

    //专门存字符串的队列，用于printf和scanf
    queue<str_node>strq;
    //存变量的队列，所有全局变量
    string varq[20];
    int varq_len=0;
};

#endif