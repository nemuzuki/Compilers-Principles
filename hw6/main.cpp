#include"main.tab.hh"
#include"common.h"
#include<iostream>
using std::cout;
using std::endl;
TreeNode *root=nullptr; 

action_zone zone[20];

int main ()
{
    yyparse();
    Tree *tree=new Tree;;
    tree->root=root;
    if(root){
        //root->genNodeId();
        //root->printAST();
        tree->type_check(root);
        cerr<<"type_check ok!"<<endl;
        tree->gen_code(root);
    }
}
int yyerror(char const* message)
{
    cout << message << endl;
    return -1;
}
