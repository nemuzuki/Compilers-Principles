#include "tree.h"
#include <queue>
using namespace std;

string stmt_type[]={"if","while","declare","assign","printf","scanf","for","return","stmts"};
string op_type[]={"==","!","+","-","*","/","%",">","<",">=","<=","!=","&&","||","+=","-=","++","--"};
string var_type[]={"int","void","char"};
//加入子节点（注意，因为不知道有几个儿子，所以每个节点的child只有一个）
//而后面的儿子加入child->sibling形成一个链表
void TreeNode::addChild(TreeNode *node){
    if(this->child!=NULL){
        // node->sibling=this->child->sibling;
        // this->child->sibling=node;
        this->child->addSibling(node);
    }
    else this->child=node;//设定第一个儿子为child 
}
void TreeNode::addSibling(TreeNode *node){
    // node->sibling=this->sibling;
    // this->sibling=node;
    TreeNode *p=this;
    while (p->sibling){
        p=p->sibling;
    }
    p->sibling=node;
    
}
void TreeNode::genNodeId(){//从根节点开始逐个赋Id 实现方式同学们可以自行修改
    int cnt=0;
    queue<TreeNode*>q;
    q.push(this);
    while(!q.empty()){
        TreeNode *p=q.front();
        q.pop();
        p->nodeID=cnt++;
        if(p->child){
            p=p->child;
            q.push(p);
            while(p->sibling){
                q.push(p->sibling);
                p=p->sibling;
            }
        }
    }
}

void TreeNode::printAST(){//打印语法树结点，先序遍历
    //cout<<setw(8)<<"编号"<<setw(16)<<"类型"<<setw(16)<<"值"<<setw(16)<<"子节点"<<setw(16)<<"作用域"<<setw(16)<<endl;
    queue<TreeNode*>q;
    q.push(this);
    while(!q.empty()){
        TreeNode *p=q.front();
        q.pop();
        printNodeInfo(p);
        if(p->child){
            p=p->child;
            q.push(p);
            while(p->sibling){
                q.push(p->sibling);
                p=p->sibling;
            }
        }
    }
}
/***
 * 以下的几个函数皆为在printAST过程中辅助输出使用
 * 同学们可以根据需要自己使用其他方法
***/
void TreeNode::printNodeInfo(TreeNode *node){
    cout<<setw(8)<<node->nodeID<<setw(16);
    printNodeTypeInfo(node);
    printNodeConnection(node);
    if(node->nodeType==2){//变量的话，输出作用域
        cout<<setw(24)<<node->zone;
    }
    cout<<endl;
}

void TreeNode::printNodeTypeInfo(TreeNode *node){
    const int size=8;
    switch(node->nodeType){
        case 0:
            cout<<"NODE_CONST "<<setw(size)<<node->int_val;break;
        case 1:
            cout<<"NODE_BOOL "<<setw(size)<<node->bool_val;break;
        case 2:
            cout<<"NODE_VAR "<<setw(size)<<node->var_name;break;
        case 3:
            cout<<"NODE_EXPR "<<setw(size)<<".";break;
        case 4:
            cout<<"NODE_TYPE "<<setw(size)<<var_type[node->varType];break;
        case 5:
            cout<<"NODE_STMT "<<setw(size)<<stmt_type[node->stmtType];break;
        case 6:
            cout<<"NODE_PROG "<<setw(size)<<".";break;
        case 7:
            cout<<"NODE_OP "<<setw(size)<<op_type[node->opType];break;
        case 8:
            cout<<"NODE_PARA "<<setw(size)<<var_type[node->varType];break;
        case 9:
            cout<<"NODE_FUNC "<<setw(size)<<var_type[node->varType]+"_f";break;
        case 10:
            cout<<"NODE_DECL_LIST "<<setw(size)<<".";break;
        case 11:
            cout<<"NODE_CHAR "<<setw(size)<<node->char_val;break;
        case 12:
            string s=node->string_val;
            cout<<"NODE_STRING "<<setw(size)<<s.substr(0,5);
            break;
    }
}

//输出子节点编号
void TreeNode::printNodeConnection(TreeNode *p){
    cout<<setw(12)<<'[';
    if(p->child){
        p=p->child;
        cout<<p->nodeID;
        while(p->sibling){
            cout<<','<<p->sibling->nodeID;
            p=p->sibling;
        }
    }
    cout<<']';
}


//int a=0;int b=2;if(2==3){int a=4;}