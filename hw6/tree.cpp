#include "tree.h"
#include "common.h"
using namespace std;
string node_type[]={"stmt","type","const","bool","var","op","expr","prog","para","stmts"};
string stmt_type[]={"declare","if","while","printf","scanf","for","return","func","decl_char"};
string op_type[]={"==","!","+","-","*","/","%",">","<",">=","<=","!=","&&","||","+=","-=","++","--"};
string var_type[]={"int","void","char","string","float","notype"};
//加入子节点（注意，因为不知道有几个儿子，所以每个节点的child只有一个）
//而后面的儿子加入child->sibling形成一个链表

void TreeNode::addChild(TreeNode *node){
    if(this->child!=NULL){
        this->child->addSibling(node);
    }
    else this->child=node;//设定第一个儿子为child 
}

void TreeNode::addSibling(TreeNode *node){
    TreeNode *p=this;
    while (p->sibling){
        p=p->sibling;
    }
    p->sibling=node;
    
}

void TreeNode::genNodeId(){//从根节点开始逐个赋Id
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
    cerr<<"no/type/value/children\n";
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
void TreeNode::printNodeInfo(TreeNode *node){
    cerr<<setw(8)<<node->nodeID;
    printNodeTypeInfo(node);
    printNodeConnection(node);
    cerr<<"\n";
}
void TreeNode::printNodeTypeInfo(TreeNode *node){
    cerr<<setw(16);
    const int size=8;
    switch(node->nodeType){
        case NODE_CONST:
            if(node->char_val)cerr<<"NODE_CHAR "<<setw(size)<<node->char_val;
            else if(node->float_val)cerr<<"NODE_FLOAT "<<setw(size)<<node->float_val;
            else if(node->string_val!="")cerr<<"NODE_STRING "<<setw(size)<<node->string_val;
            else cerr<<"NODE_INT "<<setw(size)<<node->int_val;
            break;
        case NODE_BOOL:
            cerr<<"NODE_BOOL "<<setw(size)<<op_type[node->opType];break;
        case NODE_VAR:
            cerr<<"NODE_VAR "<<setw(size)<<node->var_name;break;
        case NODE_TYPE:
            cerr<<"NODE_TYPE "<<setw(size)<<var_type[node->varType];break;
        case NODE_STMT:
            cerr<<"NODE_STMT "<<setw(size)<<stmt_type[node->stmtType];break;
        case NODE_PROG:
            cerr<<"NODE_PROG "<<setw(size)<<".";break;
        case NODE_EXPR:
            cerr<<"NODE_EXPR "<<setw(size)<<op_type[node->opType];break;
        case NODE_PARA:
            cerr<<"NODE_PARA "<<setw(size)<<var_type[node->varType];break;
        case NODE_STMTS:
            cerr<<"NODE_STMTS "<<setw(size)<<".";break;
    }
}
//输出子节点编号
void TreeNode::printNodeConnection(TreeNode *p){
    if(p->child){
        cerr<<setw(12)<<'[';
        p=p->child;
        cerr<<p->nodeID;
        while(p->sibling){
            cerr<<','<<p->sibling->nodeID;
            p=p->sibling;
        }
        cerr<<']';
    }
}
//#######################################################################################
//################################ 类型检查 ###########################################
//#######################################################################################
extern action_zone zone[20];

//后序遍历，检查每个中间节点
void Tree::type_check(TreeNode *root){
    if(root->child==NULL){
        return;
    }
    TreeNode *p=root->child;
    type_check(p);
    while(p->sibling){
        type_check(p->sibling);
        p=p->sibling;
    }
    stmt_check(root);//后序遍历最后处理根
    get_temp_var(root);//顺便生成临时变量
}


VarType Tree::find_id_type(TreeNode *id){//根据符号表查id的类型
    if(id->nodeType==NODE_CONST || id->varType!=Notype){
        return id->varType;
    }
    int zone_no=id->zone;
    int len=zone[zone_no].id_list.size();
    for(int i=0;i<len;++i){
        if(zone[zone_no].id_list[i].name==id->var_name){
            string type = zone[zone_no].id_list[i].type;
            if(type=="int"){
                return VAR_INTEGER;
            }
            else if(type=="char"){
                return VAR_CHAR;
            }
            else if(type=="void"){
                return VAR_VOID;
            }
            else if(type=="float"){
                return VAR_FLOAT;
            }
        }
    }
    return Notype;
}
//对所有类型为NODE_STMT的语句进行检查（注：我只赋给了id行号）
void Tree::stmt_check(TreeNode *node)
{
    //表达式：9+3.4，检查两项类型是否相同
    if(node->nodeType==NODE_EXPR){
        TreeNode *e1,*e2;
        e1=node->child;
        e2=e1->sibling;
        //双目运算
        if(e2){
            VarType type1=find_id_type(e1),type2=find_id_type(e2);
            if(type1!=type2)
            {
                cerr<<"line "<<e1->lineno<<": EXPR TypeError : "<<var_type[type1]<<" and "<<var_type[type2]<<endl;
            }
            node->varType=type1;
        }
        //单目运算，-/+
        else{//设置父节点类型
            node->varType=e1->varType;
        }
    }
    //声明语句：a=2，表达式前面检查过了，这里只检查等号右边是一个数值或者id的情况
    //如果右边是id，a=b，那么必须检查符号表，确定它的类型
    else if(node->stmtType==STMT_DECL){
        TreeNode *id,*expr;
        id=node->child;
        expr=id->sibling;
        if(id && expr){
            VarType type1=find_id_type(id),type2=find_id_type(expr);
            if(type1!=type2)
            {
                cerr<<"line "<<id->lineno<<": DECL TypeError: "<<var_type[type1]<<" and "<<var_type[type2]<<endl;
            }
        }
    }

    else if(node->stmtType==STMT_SCANF){//scanf("%c",&a);
        TreeNode *type,*real;
        type=node->child;
        real=type->sibling;
        if(real==nullptr)return;
        if(type->string_val=="%c" && real->varType!=VAR_CHAR||
        type->string_val=="%d" && real->varType!=VAR_INTEGER||
        type->string_val=="%f" && real->varType!=VAR_FLOAT){
            cerr<<"line "<<real->lineno<<": SCANF TypeError: "<<type->string_val<<" and "<<var_type[real->varType]<<endl;
        }
    }

    else if(node->stmtType==STMT_PRINTF){
        TreeNode *type,*real;
        type=node->child;
        real=type->sibling;
        if(real==nullptr)return;
        if(type->string_val=="%c" && real->varType!=VAR_CHAR||
        type->string_val=="%d" && real->varType!=VAR_INTEGER||
        type->string_val=="%f" && real->varType!=VAR_FLOAT){
            cerr<<"line "<<real->lineno<<": PRINTF TypeError: "<<type->string_val<<" and "<<var_type[real->varType]<<endl;
        }
    }
    else if(node->stmtType==STMT_WHILE){//while保证后面的是布尔型a<b,a+b,或者是a++这种equation
        TreeNode *judge;
        judge=node->child;
        if(judge->nodeType!=NODE_BOOL){
            cerr<<"line "<<judge->lineno<<": WHILE TypeError: "<<var_type[judge->nodeType]<<" is not boolean type"<<endl;
        }
    }
}

//#######################################################################################
//################################ 标签生成 ###########################################
//#######################################################################################


/*标签生成模块*/
void Tree::get_label(){
    TreeNode *p=root;
    p->label.begin_label = "_start";
    //给每个stmt节点提前设置好标签，以便代码生成时直接使用
    for(p=root->child;p;p=p->sibling){
        recursive_get_label(p);
    }
}
//分配新的label
string Tree::new_label(){
    char tmp[20];
    sprintf(tmp, ".L%d", label_seq);
    label_seq++;
    return tmp;
}
void Tree::recursive_get_label(TreeNode *node){
    if(node->nodeType==NODE_STMTS){
        TreeNode *stmts=node,*stmt;
        for(stmt=stmts->child;stmt;stmt=stmt->sibling){
            recursive_get_label(stmt);
        }
    }
    else if(node->nodeType==NODE_STMT){
        stmt_get_label(node);
    }
    else if(node->nodeType==NODE_EXPR||node->nodeType==NODE_BOOL){
        expr_get_label(node);
    }
}
//给stmt的各个子节点赋予前后标签(while,if,for)
//设定judge的true和false；stmts的begin和next；t的begin和next（如果一个语句的前后有标签，就需要设定）
//注意这里的stmts不是一个语句，而是语句的集合
void Tree::stmt_get_label(TreeNode *t){
    switch(t->stmtType){
        case STMT_DECL:{
            TreeNode *id=t->child;
            int i;
            for(i=0;i<varq_len;++i){
                if(varq[i]->var_name==id->var_name){
                    break;
                }
            }
            if(i==varq_len){
                varq[varq_len++]=id;//所有变量当成全局变量
            }

            break;
        }
        case STMT_DECL_CHAR:{
            TreeNode *id=t->child;
            int i;
            for(i=0;i<varq_len;++i){
                if(varq[i]->var_name==id->var_name){
                    break;
                }
            }
            if(i==varq_len){
                varq[varq_len++]=id;//所有变量当成全局变量
            }
            break;
        }
        case STMT_IF:{//if有两种，一种没有else，一种有else
            /*
            没有else
            L0: judge
                jne L2
            L1: stmts
            L2:

            有else
            L0: judge
                jne L2
            L1: stmts
                jmp L3
            L2: else_stmts
            L3:
            */
            TreeNode *judge,*stmts,*else_stmts;
            judge=t->child;
            stmts=judge->sibling;
            else_stmts=stmts->sibling;
            //没有else
            if(else_stmts==NULL){
                if (t->label.next_label == "")
                {
                    t->label.next_label = new_label();//L2
                }
                judge->label.true_label=stmts->label.begin_label= new_label();//L1
                judge->label.false_label=stmts->label.next_label=t->label.next_label;
                //judge在物理上的下一块代码，next标签在输出跳转指令时至关重要
                judge->label.next_label=stmts->label.begin_label;
                if (t->sibling){
                    t->sibling->label.begin_label = t->label.next_label;
                }
                recursive_get_label(judge);
                recursive_get_label(stmts);
            }
            //有else
            else{
                if (t->label.next_label == "")
                {
                    t->label.next_label = new_label();//L3
                }
                judge->label.true_label=stmts->label.begin_label= new_label();//L1
                judge->label.false_label=else_stmts->label.begin_label= new_label();//L2

                judge->label.next_label=stmts->label.begin_label;
                stmts->label.next_label=else_stmts->label.begin_label;
                else_stmts->label.next_label=t->label.next_label;
                if (t->sibling){
                    t->sibling->label.begin_label = t->label.next_label;
                }
                recursive_get_label(judge);
                recursive_get_label(stmts);
                recursive_get_label(else_stmts);
            }
            break;
        }
        
        case STMT_WHILE:{
            /*node是整个while语句
            
            L1: stmts
            L0: judge 
                je L1
            L2:

            */
            TreeNode *judge,*stmts;//判断语句和循环体
            judge=t->child;
            stmts=judge->sibling;
            //分配整个循环开始的标签
            if(t->label.begin_label==""){
                t->label.begin_label=new_label();//L0
            }
            //循环体的下一条语句是循环的开始
            stmts->label.next_label=t->label.begin_label;
            //如果判断正确，则开始循环体
            stmts->label.begin_label=judge->label.true_label=new_label();//L1

            //分配整个循环结束的标号
            if (t->label.next_label == ""){
                t->label.next_label = new_label();//L2
            }
            //循环条件的假值标号即为整个循环的下一条语句标号
            judge->label.false_label = t->label.next_label;
            //兄弟节点的开始标号即为当前节点的下一条语句的标号
            if (t->sibling){
                t->sibling->label.begin_label = t->label.next_label;
            }

            judge->label.next_label=t->label.next_label;
            //递归生成
            recursive_get_label(judge);
            recursive_get_label(stmts);
            break;
        }

        case STMT_FOR:{
            //for 语句有四个部分：初始化语句，judge，迭代语句trans和stmts
            /*for(init;judge;trans)stmts;
            先去判断judge，如果正确去stmts，然后迭代trans
            L0: init
                jmp L2
            L1: stmts
                trans
            L2: judge
                正确则 L1
            L3:
            */
            TreeNode *init,*judge,*trans,*stmts;
            init=t->child;
            judge=init->sibling;
            trans=judge->sibling;
            stmts=trans->sibling;

            judge->label.true_label=new_label();//L1
            init->label.next_label=new_label();//L2

            if (t->label.next_label == ""){
                t->label.next_label = new_label();//L3
            }
            judge->label.false_label=t->label.next_label;


            if (t->sibling){
                t->sibling->label.begin_label = t->label.next_label;
            }
            judge->label.next_label=t->label.next_label;
            recursive_get_label(init);
            recursive_get_label(judge);
            recursive_get_label(trans);
            recursive_get_label(stmts);
            
            break;
        }
	    
        case STMT_FUNC:{
            TreeNode *stmts=t->child->sibling;
            recursive_get_label(stmts);
            break;
        }
    
        case STMT_SCANF:{
            TreeNode *str=t->child;
            strq.push(str_node(str,0));
            break;
        }
        case STMT_PRINTF:{
            TreeNode *str=t->child;
            strq.push(str_node(str,0));
            break;
        }
    }
}
//处理bool表达式标签(&&,||,!)
void Tree::expr_get_label(TreeNode *judge){
    if(judge->nodeType!=NODE_BOOL){
        return;
    }
    TreeNode *e1,*e2;
    e1=judge->child;
    e2=e1->sibling;
    //judge的true和false继承给子节点
    switch (judge->opType){
        //与运算，如果有一个错，则整体错；都对，进入true标签
        /*and代码格式如下
        begin:
            e1
            jne false
            e2
            jne false
        true:######
        false:######
        */
        case OP_AND:{
            e1->label.begin_label=judge->label.begin_label;//代码块的开始标签别忘了设置，为了多个与或非组合的情况（例31）

            e1->label.true_label=e2->label.begin_label=new_label();
            e2->label.true_label=judge->label.true_label;
            e1->label.false_label=e2->label.false_label=judge->label.false_label;

            e1->label.next_label=e2->label.begin_label;
            e2->label.next_label=judge->label.next_label;
            expr_get_label(e1);
            expr_get_label(e2);
            break;
        }
        /*or代码格式如下
        begin:
            e1
            je ture
            e2
            jne false
        true:######
        false:######
        */
        case OP_OR:{
            e1->label.begin_label=judge->label.begin_label;

            e1->label.true_label=e2->label.true_label=judge->label.true_label;
            e1->label.false_label=e2->label.begin_label=new_label();
            e2->label.false_label=judge->label.false_label;
            //定义代码的next标签，在输出跳转指令时至关重要！
            e1->label.next_label=e2->label.begin_label;
            e2->label.next_label=judge->label.next_label;
            expr_get_label(e1);
            expr_get_label(e2);
            break;
        }
        /*
        begin:
            if e1 is true goto false
        true:#####
        false:#####
        */
        case OP_NOT:{
            e1->label.begin_label=judge->label.begin_label;

            e1->label.true_label=judge->label.false_label;
            e1->label.false_label=judge->label.true_label;
            e1->label.next_label=judge->label.next_label;
            expr_get_label(e1);
            break;
        }
    }
}

//#######################################################################################
//################################ 代码生成 ###########################################
//#######################################################################################

//第一遍扫描语法树时，对于表达式，如a+b+c需要临时变量存储a+b，该函数用来作为计数器
void Tree::get_temp_var(TreeNode *t){
    if (t->nodeType != NODE_EXPR)
		return;

	TreeNode *arg1 = t->child;
	TreeNode *arg2 = arg1->sibling;
    //单目运算的情况，不用新的临时变量
	if (arg1->nodeType == NODE_OP){//-(a+b)
		temp_var_seq--;
    }
	if (arg2 && arg2->nodeType == NODE_OP){//a++
		temp_var_seq--;
    }
	t->temp_var = temp_var_seq;
	temp_var_seq++;
}

/*
代码生成的入口
（1）生成头部
（2）把变量（临时和非临时的）放前面
（3）代码主体部分：通过recursive和stmt进行从上到下的递归
（4）ret
*/

void Tree::gen_code(TreeNode *root){
    get_label();
    gen_header();//生成头部

    //从一开始代码开始找所有的声明语句，这些都是全局变量，放在主体代码前面
    gen_decl();
    
    cout << endl << endl << "# your asm code here" << endl;
	cout << "\t.text" << endl;
    cout << "\t.globl _start" << endl;

    TreeNode *p;
    for(p=root->child;p;p=p->sibling){
        recursive_gen_code(p);//代码生成，从根开始递归
    }


    //printf必备
    cout<<"\tmovl\t$0, %eax\n";
	cout<<"\tmovl\t-4(%ebp), %ecx\n";
	cout<<"\tleave\n";
	cout<<"\tleal\t-4(%ecx), %esp\n";
	cout << "\tret" << endl;
    cout<<"\t.section\t.note.GNU-stack,\"\",@progbits\n";//允许使用栈
}


void Tree::gen_header(){
    /*定义字符串
    .LC0:
	.string	"%d"
	.text
	.globl	main
	.type	main, @function
    */
    int cnt=0;
    while(!strq.empty()){
        string s=strq.front().str->string_val;
        cout<<".LC"<<cnt<<":\n";
        cout<<"\t.string\t"<<s<<"\n";
        strq.front().str->int_val=cnt++;//int_val赋为编号
        strq.pop();
    }
    cout<<"\t.text\n\t.globl\tmain\n\t.type	main, @function\n";
    
}

//全局变量和临时变量放在主体代码前面
void Tree::gen_decl(){
    cout << endl << "# define your veriables and temp veriables here" << endl;
	cout << "\t.bss" << endl;

    //声明语句.comm	a,4,4
    for(int i=0;i<varq_len;++i){
        if(varq[i]->varType==VAR_INTEGER){
            cout<<"\t.comm "<<varq[i]->var_name<<",4,4"<<endl;
        }
        else if(varq[i]->varType==VAR_CHAR){
            cout<<"\t.comm "<<varq[i]->var_name<<",1,1"<<endl;
        }
    }
	//打印临时变量
	for (int i = 0; i < temp_var_seq; i++)
	{
		cout<<"\t.comm "<< "t" <<  i <<",4,4"<<endl;
	}
}


//对一个节点生成代码
void Tree::recursive_gen_code(TreeNode *node){
    if(node->nodeType==NODE_STMTS){
        TreeNode *stmts=node,*stmt;
        for(stmt=stmts->child;stmt;stmt=stmt->sibling){
            recursive_gen_code(stmt);
        }
    }
    else if(node->nodeType==NODE_STMT){
        stmt_gen_code(node);
    }
    else if(node->nodeType==NODE_EXPR||node->nodeType==NODE_BOOL){
        expr_gen_code(node);
    }
}


//node_stmt生成代码
/*jne:如果cmpl两个操作数不等则跳转；je：如果cmpl两个操作数相等则跳转；jmp：直接跳转
不过对于testl是测试操作数是否为0，也就是说希望为0
所以jne:如果testl为1则跳转；je：如果testl为0则跳转
*/
void Tree::stmt_gen_code(TreeNode *t){
    if(t->stmtType==STMT_FUNC){
        TreeNode *id=t->child;
        TreeNode *stmts=id->sibling;
        cout<<id->var_name<<":\n";
        cout<<"\tendbr32\n";

        //printf必要语句
        cout<<"\tleal\t4(%esp), %ecx\n";
        cout<<"\tandl\t$-16, %esp\n";
        cout<<"\tpushl\t-4(%ecx)\n";


        cout<<"\tpushl\t%ebp"<<endl;
        cout<<"\tmovl\t%esp, %ebp"<<endl;
        cout<<"\tpushl\t%ecx"<<endl;
        for(TreeNode *stmt=stmts->child;stmt;stmt=stmt->sibling){
            recursive_gen_code(stmt);
        }
    }
    else if(t->stmtType==STMT_DECL){
        /*赋值语句，有四种情况：
        a
        a=expr
        a+=expr（opType==OP_ADD_SELF,OP_SUB_SELF）
        a++（opType==OP_ADD_ONE,OP_SUB_ONE）
        */
        TreeNode *expr=t->child->sibling;
        if(t->opType==OP_ADD_SELF){
            recursive_gen_code(expr);
            if(expr->child){//是表达式
                cout<<"\tmovl\tt"<<expr->temp_var<<", %eax\n";
                cout<<"\taddl\t%eax, "<<t->child->var_name<<endl;
            }
            else{//是id或者常数
                cout<<"\tmovl\t";
                print_value(expr);
                cout<<", %eax\n";
                cout<<"\taddl\t%eax, "<<t->child->var_name<<endl;
            }
        }
        else if(t->opType==OP_SUB_SELF){
            recursive_gen_code(expr);
            if(expr->child){//是表达式
                cout<<"\tmovl\tt"<<expr->temp_var<<", %eax\n";
                cout<<"\tsubl\t%eax, "<<t->child->var_name<<endl;
            }
            else{//是id或者常数
                cout<<"\tmovl\t";
                print_value(expr);
                cout<<", %eax\n";
                cout<<"\tsubl\t%eax, "<<t->child->var_name<<endl;
            }
        }
        else if(t->opType==OP_ADD_ONE){
            cout<<"\taddl\t$1, "<<t->child->var_name<<endl;
        }
        else if(t->opType==OP_SUB_ONE){
            cout<<"\tsubl\t$1, "<<t->child->var_name<<endl;
        }
        else if(expr){//a=expr
            TreeNode *id=t->child;
            //连等，先找到最末的表达式
            while(expr->child && expr->nodeType==NODE_STMT){
                expr=expr->child->sibling;
            }
            recursive_gen_code(expr);
            //把表达式对应的临时变量赋给左边的每个id，一定小心空指针
            while(id){
                if(expr->child){//最右是表达式
                    cout<<"\tmovl\tt"<<expr->temp_var<<", %eax\n";
                    cout<<"\tmovl\t%eax, "<<id->var_name<<endl;
                }
                else{//是id或者常数
                    cout<<"\tmovl\t";
                    print_value(expr);
                    cout<<", %eax\n";
                    cout<<"\tmovl\t%eax, "<<id->var_name<<endl;
                }
                if(id->sibling->nodeType==NODE_STMT){
                    id=id->sibling->child;
                }
                else break;
            }
        }
    }

    else if(t->stmtType==STMT_DECL_CHAR){//字符赋值
        /*
        movb	$57, s
        movb	s, %al
        movsbl	%al, %eax
        */
        TreeNode *id,*value;
        id=t->child;
        value=id->sibling;
        cout<<"\tmovb\t";
        print_value(value);
        cout<<", "<<id->var_name<<endl;

    }
    else if(t->stmtType==STMT_IF){
        TreeNode *judge,*stmts,*else_stmts;
        judge=t->child;
        stmts=judge->sibling;
        else_stmts=stmts->sibling;

        deal_with_judge(judge);//判断语句
        cout<<stmts->label.begin_label<<":\n";//正确标签
        recursive_gen_code(stmts);
        if(else_stmts){//如果有else
            cout<<"\tjmp\t"<<else_stmts->label.next_label<<endl;
            cout<<stmts->label.next_label<<":\n";
            recursive_gen_code(else_stmts);
        }
        cout<<t->label.next_label<<":\n";
    } 
    //while语句先生成judge，然后jump到judge的next
    else if(t->stmtType==STMT_WHILE){
        TreeNode *judge=t->child;
        TreeNode *stmts=judge->sibling;

        cout<<"\tjmp "<<t->label.begin_label<<endl;
        cout<<judge->label.true_label<<":\n";
        recursive_gen_code(stmts);

        cout<<t->label.begin_label<<":\n";    

        //接下来需要对judge按照与或非符号进行划分，即遍历语法树，并生成judge的代码
        deal_with_judge(judge);
        cout<<t->label.next_label<<":\n";
    }

    else if(t->stmtType==STMT_FOR){
        TreeNode *init,*judge,*trans,*stmts;
        init=t->child;
        judge=init->sibling;
        trans=judge->sibling;
        stmts=trans->sibling;

        recursive_gen_code(init);
        cout<<"\tjmp\t"<<init->label.next_label<<endl;
        cout<<judge->label.true_label<<":\n";
        recursive_gen_code(stmts);
        recursive_gen_code(trans);
        cout<<init->label.next_label<<":\n";

        deal_with_judge(judge);
        cout<<t->label.next_label<<":\n";
    }
    else if(t->stmtType==STMT_RETURN){
        TreeNode *expr=t->child;
        cout<<"\tmovl\t";
        print_value(expr);
        cout<<", %eax\n";
    }

    else if(t->stmtType==STMT_SCANF){
        /*
        subl	$12, %esp
        pushl	$b
        pushl	$.LC1
        call	scanf
        addl	$16, %esp
        */
        TreeNode *str,*id;
        str=t->child;
        id=str->sibling;
        cout<<"\tsubl\t$12, %esp\n";
        cout<<"\tpushl\t$";//取地址
        print_value(id);
        cout<<endl;
        cout<<"\tpushl\t$.LC"<<str->int_val<<endl;//字符串的标签
        cout<<"\tcall\tscanf\n";
        cout<<"\taddl\t$16, %esp\n";
    }

    else if(t->stmtType==STMT_PRINTF){
        /*
        subl	$8, %esp
        pushl	a
        pushl	$.LC0
        call	printf
        addl	$16, %esp

	    movb	t, %al
        movsbl	%al, %eax
        subl	$12, %esp
        pushl	%eax
        call	putchar
        addl	$16, %esp
        */
        TreeNode *str,*id;
        str=t->child;
        id=str->sibling;
        VarType id_type=Notype;
        if(id){
            id_type=find_id_type(id);
        }
        if(id==NULL ||id_type==VAR_INTEGER){
            cout<<"\tsubl\t$8, %esp\n";//先让栈顶-8，留出两个空间，才能压栈
            cout<<"\tpushl\t";
            if(id){
                print_value(id);//printf有两个参数
            }
            else{
                cout<<"%eax";
            }
            cout<<endl;
            cout<<"\tpushl\t$.LC"<<str->int_val<<endl;//字符串的标签
            cout<<"\tcall\tprintf\n";
            cout<<"\taddl\t$16, %esp\n";
        }
        else if(id_type==VAR_CHAR){

            cout<<"\tmovb\t"<<id->var_name<<", %al\n";
            cout<<"\tmovsbl\t%al, %eax\n";
            cout<<"\tsubl\t$12, %esp\n";
            cout<<"\tpushl\t%eax"<<endl;
            cout<<"\tcall\tputchar\n";
            cout<<"\taddl\t$16, %esp\n";
        }
    }
}

//所属stmt的类型，judge节点
void Tree::deal_with_judge(TreeNode *judge){
    TreeNode *e1=judge->child;
    TreeNode *e2=e1->sibling;
    if(judge->opType==OP_NOT){
        deal_with_judge(e1);
    }
    else if(judge->opType==OP_OR||judge->opType==OP_AND){
        deal_with_judge(e1);
        deal_with_judge(e2);
    }
    else if(judge->nodeType==NODE_BOOL){
        //输出这一块的开始标签
        if(judge->label.begin_label!="")cout<<judge->label.begin_label<<":\n";
        recursive_gen_code(judge);
        //如果跳转标签和下面一块的开始标签相同，就不输出
        if(judge->label.true_label!="" && judge->label.next_label!=judge->label.true_label)
        {
            jump_true(judge);
            cout<<judge->label.true_label<<endl;
        }
        if(judge->label.false_label!=""&& judge->label.next_label!=judge->label.false_label)
        {
            jump_false(judge);
            cout<<judge->label.false_label<<endl;
        }
    }
}
//处理expr的汇编
void Tree::expr_gen_code(TreeNode *t){
    TreeNode *e1,*e2;
    e1=t->child;
    e2=e1->sibling;
    //首先，如果子节点还是表达式，需要先生成子节点的代码。如a+b+c+d
    if(e1 && (e1->nodeType==NODE_EXPR)){
        expr_gen_code(e1);
    }
    if(e2 && (e2->nodeType==NODE_EXPR)){
        expr_gen_code(e2);
    }
    //双目运算符
    if(t->opType==OP_ADD && t->child->sibling){//e1+e2
        //先判断e1的类型
        cout << "\tmovl\t";
        print_value(e1);
        cout<< ", %eax" <<endl;//把e1结果赋给eax
        
        //判断e2的类型
        cout << "\taddl\t";
        print_value(e2);
        cout << ", %eax" << endl;
        
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;//每计算一步，把eax赋给一个临时变量
    }
    else if(t->opType==OP_SUB && t->child->sibling){//e1-e2，SUB作为双目运算符
        //先判断e1的类型
        cout << "\tmovl\t";
        print_value(e1);//后面就是常量的值
        cout<< ", %eax" <<endl;//把e1结果赋给eax

        //判断e2的类型
        cout << "\tsubl\t";
        print_value(e2);
        cout << ", %eax" << endl;
        
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;//每计算一步，把eax赋给一个临时变量
    }
    else if(t->opType==OP_MUL){//e1*e2
        //先判断e1的类型
        cout << "\tmovl\t";
        print_value(e1);//后面就是常量的值
        cout<< ", %eax" <<endl;//把e1结果赋给eax
        
        //判断e2的类型
        cout << "\timull\t";
        print_value(e2);
        cout << ", %eax" << endl;
        
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;//每计算一步，把eax赋给一个临时变量
    }

    else if(t->opType==OP_DIV){//a/b
        //e1,e2都进入寄存器
        cout << "\tmovl\t";
        print_value(e1);
        cout<< ", %eax" <<endl;

        cout << "\tmovl\t";
        print_value(e2);
        cout << ", %ecx" << endl;
        
        cout<<"\tcltd\n";//32位扩展为64位
        cout<<"\tidivl\t%ecx\n";
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;////做除法后，商保存在eax
    }
    else if(t->opType==OP_MOD){
        //e1,e2都进入寄存器
        cout << "\tmovl\t";
        print_value(e1);
        cout<< ", %eax" <<endl;

        cout << "\tmovl\t";
        print_value(e2);
        cout << ", %ecx" << endl;
        
        cout<<"\tcltd\n";//32位扩展为64位
        cout<<"\tidivl\t%ecx\n";
        cout << "\tmovl\t%edx, %eax\n";//做除法后，余数保存在edx
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;
    }

    //单目运算符
    else if(t->opType==OP_SUB && t->child->sibling==nullptr){
        cout << "\tmovl\t";
        print_value(e1);
        cout << ", %eax" << endl;
        cout<<"\tnegl\t%eax\n";
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;
    }
    else if(t->opType==OP_ADD && t->child->sibling==nullptr){
        cout << "\tmovl\t";
        print_value(e1);
        cout << ", %eax" << endl;
        cout << "\tmovl\t%eax, t" << t->temp_var << endl;
    }

    //bool表达式的代码除了判断语句都一样，但判断语句与if,while,for的类型有关，所以写在stmt_gen_code里面
    else if(t->nodeType==NODE_BOOL){
        //把e1,e2存到eax,edx
        cout<<"\tmovl\t";
        print_value(e1);
        cout<<", %eax\n";
        
        cout<<"\tmovl\t";
        print_value(e2);
        cout<<", %edx\n";
        //这里有个大坑，cmpl a,b后面jle代表b<=a!
        cout<<"\tcmpl\t"<<"%edx, %eax\n";
    }
}
//bool表达式正确时的跳转语句
void Tree::jump_true(TreeNode *judge){
    if(judge->nodeType==NODE_EXPR){
        cout<<"\ttestl\t%eax, %eax\n";//testl 是测试eax是否为0，
    }
    //如果judge是bool_expr，用cmpl语句，这在expr_gen_code里面定义
    else if(judge->nodeType==NODE_BOOL){
        switch(judge->opType){
            case OP_EQUAL:{cout<<"\tje\t";break;}
            case OP_LARGER:{cout<<"\tjg\t";break;}//j的类型与符号相同
            case OP_LARGER_EQUAL:{cout<<"\tjge\t";break;}
            case OP_SMALLER:{cout<<"\tjl\t";break;}
            case OP_SMALLER_EQUAL:{cout<<"\tjle\t";break;}
            case OP_NOT_EQUAL:{cout<<"\tjne\t";break;}
        }
    }
}
//bool表达式错误时的跳转语句
void Tree::jump_false(TreeNode *judge){
    if(judge->nodeType==NODE_EXPR){
        cout<<"\ttestl\t%eax, %eax\n";
        //if和while的跳转语句不同，因为标签不同；for和while相同
    }
    else if(judge->nodeType==NODE_BOOL){
        switch(judge->opType){
            case OP_EQUAL:{cout<<"\tjne\t";break;}
            case OP_LARGER:{cout<<"\tjle\t";break;}
            case OP_LARGER_EQUAL:{cout<<"\tjl\t";break;}
            case OP_SMALLER:{cout<<"\tjge\t";break;}
            case OP_SMALLER_EQUAL:{cout<<"\tjg\t";break;}
            case OP_NOT_EQUAL:{cout<<"\tje\t";break;}
        }
    }
}
//小工具：打印一个节点的值
void Tree::print_value(TreeNode *e1){
    if (e1->nodeType == NODE_VAR){//变量
        cout << e1->var_name;
    }
    else if(e1->nodeType==NODE_EXPR){
        cout<<"t"<<e1->temp_var;
    }
    else if(e1->nodeType==NODE_CONST){
        cout<<"$";
        if(e1->varType==VAR_INTEGER)cout << e1->int_val;
        else if(e1->varType==VAR_CHAR)cout << (int)e1->char_val;
    }
}
