#include"main.tab.hh"
#include"common.h"
#include<iostream>
using std::cout;
using std::endl;
TreeNode *root=nullptr;
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
extern vector<id>v; 
int main ()
{
    yyparse();
    if(root){
        root->genNodeId();
        root->printAST();
    }
    for(int i=0;i<v.size();++i){
        cout<<v[i].name<<' '<<v[i].type<<endl;
    }
}
int yyerror(char const* message)
{
    cout << message << endl;
    return -1;
}