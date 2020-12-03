%option noyywrap
%{
    #include"common.h"
    #include"main.tab.hh"
    #include <stack>
    using namespace std;
    //为了实现作用域，必须存储作用域的结构，即哪个zone属于哪个zone 
    //zone栈，为了找父节点用 
    stack<int>zone_stack;

    //标识符，包含名称和符号表中的指针
    struct identifier{
    	string name;
    	int no; //作用域的编号
        VarType type;//类型
        identifier(){}
        identifier(string n,int num){
            name=n;
            no=num;
        }
	};

    //结构体z是zone，每个zone包含一个符号表和一个父节点值
    struct z{
        vector<identifier>id_list;
        int father;
        z(){
            father=-1;
        }
    }zone[20];

    //从p节点向上找是否前面定义过标识符id
    int find_zone(int p,string id){
	    int i;
        while(p>=0){
        	for(i=0;i<zone[p].id_list.size();++i){
        		if(zone[p].id_list[i].name==id){
        			return p; 
				}
        	}
        	p=zone[p].father;
		}
		return -1;
	}
    void printer(string a,string b){
        cout<<setw(8)<<a<<setw(8)<<b<<endl;
    }
    void printer(string a,string b,int c){
        cout<<setw(8)<<a<<setw(8)<<b<<setw(8)<<c<<endl;
    }
    //int id_cnt=0;//id数
    int zone_cnt=0;//zone总数 
    int zone_now=0;//当前作用域 
    int zone_switch_flag=0;//是否需要切换作用域（一个id前面有没有int ） 
    bool init_stack=false;
    bool for_flag=false;//for的花括号不影响作用域，是一个特例
%}
BLOCKCOMMENT \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT \/\/[^\n]*

INTEGER [0-9]+
ID [[:alpha:]_][[:alpha:][:digit:]_]*
CHAR \'.?\'
STRING \".+\"
EOL (\r\n|\n)
WHITE [\t ]
%%
{BLOCKCOMMENT} {cout<<"COMMENT:"<<yytext<<endl;} /* do nothing */
{LINECOMMENT}  {cout<<"COMMENT:"<<yytext<<endl;}/* do nothing */

"true" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = true;
    yylval = node;
    return TRUE;
}
"false" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = false;
    yylval = node;
    return FALSE;
}

"int" {
    if(init_stack==false){//初始化栈
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;//新定义了变量
    return INT;
}
"void" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    return VOID;
}
"char" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    return CHAR;
}

"if" return IF;
"while" return WHILE;
"else" return ELSE;
"for" {//注意for里面定义的i作用域变化
    for_flag=true;
    zone_cnt++;     //作用域总数++
    zone[zone_cnt].father=zone_now;     //设置父节点
    zone_now=zone_cnt;      //当遇到for，当前作用域必然是新的作用域
    zone_stack.push(zone_now);
    return FOR;
}
"return" return RETURN;

"printf" return PRINTF;
"scanf" return SCANF;

"==" return EQUAL;
"=" return ASSIGN;

"+" return ADD;
"-" return SUB;
"*" return MUL;
"/" return DIV;
"%" return MOD;
">" return LARGER;
"<" return SMALLER;
">=" return LARGER_EQUAL;
"<=" return SMALLER_EQUAL;
"!=" return NOT_EQUAL;
"&&" return AND;
"||" return OR;
"+=" return ADD_SELF;
"-=" return SUB_SELF;
"++" return ADD_ONE;
"--" return SUB_ONE;

"!" return NOT;

"&" return GET_ADDR;//取地址

"\"" return QUOTA;
"," return COMMA;
";" {
    zone_switch_flag=0;
    return SEMICOLON;
}
"(" return LPAREN;
")" return RPAREN;
"{" {
    if(for_flag==true){//如果在for后面，作用域不变
        return LBRACE;
    }
    zone_cnt++;     //作用域总数++
    zone[zone_cnt].father=zone_now;     //设置父节点
    zone_now=zone_cnt;      //当遇到左花括号，当前作用域必然是新的作用域
    zone_stack.push(zone_now);
    return LBRACE;
}
"}" {
    if(for_flag==true){
        for_flag=false;//结束for的作用域
    }
    zone_stack.pop();//遇到右括号，就从栈中pop掉一个zone
    zone_now=zone_stack.top();
    return RBRACE;
}

{STRING} {
    TreeNode *node = new TreeNode(NODE_STRING);
    node->string_val = yytext;
    yylval = node;
    printer("STRING",yytext);
    return STRING;
}

{INTEGER} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->int_val = atoi(yytext);
    yylval = node;
    printer("INT",yytext);
    return INTEGER;
}
{CHAR} {
    TreeNode* node = new TreeNode(NODE_CHAR);
    node->char_val = yytext[1];
    yylval = node;
    printer("INT",yytext);
    return CHAR;
}
{ID} {
    TreeNode *node = new TreeNode(NODE_VAR);
    node->var_name = string(yytext);
    yylval = node;

    if(zone_switch_flag==1){//如果前面有int，相当于新的id
        int i;
        for(i=0;i<zone[zone_now].id_list.size();++i){
            //如果当前作用域内已经定义过，那么报错
            if(zone[zone_now].id_list[i].name==yytext){
                cout<<"error,'"<<yytext<<"' has been declared in this zone"<<endl;
                break;
            }
        }
        if(i==zone[zone_now].id_list.size()){//如果没定义过，成功创建新id
            zone[zone_now].id_list.push_back(identifier(yytext,zone_now));
            printer("ID",yytext,zone_now);
            node->zone=zone_now;
            //id_cnt++;
        }
    }
    else{//如果前面没有int，向上找是不是定义过id
        int p=zone_now;
        int find_zone_result=find_zone(p,yytext);
        if(find_zone_result==-1){//如果找不到，未定义error 
            cout<<"error,'"<<yytext<<"' has not been declared"<<endl;
        }
        else{//找到了正确的作用域 
            p=find_zone_result;
            for(int i=0;i<zone[p].id_list.size();++i){
                if(zone[p].id_list[i].name==yytext){
                    printer("ID",yytext,zone[p].id_list[i].no);

                    node->zone=zone[p].id_list[i].no;
                    break;
                }
            }
        } 
    }
    return ID;
}
{EOL}
{WHITE}


%%

