%option noyywrap

%top{
    #include <iostream>
    #include <map>
    #include <iomanip>
    #include <fstream>
    #include <stack>
    #include <vector>
    using namespace std;
    //为了实现作用域，必须存储作用域的结构，即哪个zone属于哪个zone 
    //zone栈，为了找父节点用 
    stack<int> zone_stack;

    //标识符，包含名称和符号表中的指针
    struct identifier{
    	string name;
    	int no;
        identifier(){}
        identifier(string n,int num){
            name=n;
            no=num;
        }
	};

    //结构体z是zone，每个zone包含一个id列表和一个父节点值
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
}

%{


    int id_cnt=0,chars=0,lines=0;//id数，字符数，行数 
    int zone_cnt=0;//zone总数 
    int zone_now=0;//当前作用域 
    int zone_switch_flag=0;//是否需要切换作用域（一个id前面有没有int ） 
%}
SUB     "-"
ASSIGN  "="
EQUAL   "=="
RETURN  "return"
WHILE   "while"
IF      "if"
INT     "int"
word   [a-zA-Z]+
line    \n
char    .
commentline     "//"
commentbegin    "/*"
commentelement .|\n
commentend      "*/"
%x COMMENT_1
%x COMMENT_2



%%
["+"] printer("ADD",yytext);
{SUB} printer("SUB",yytext);
["*"] printer("MUL",yytext);
["/"] printer("DIV",yytext);
["%"] printer("MOD",yytext);
["("] printer("S_LEFT",yytext);
[")"] printer("S_RIGHT",yytext);
["{"] {
    printer("B_LEFT",yytext);
    cout<<endl;
    zone_cnt++;
    zone[zone_cnt].father=zone_now;//设置父节点
    zone_now=zone_cnt;//当遇到左花括号，当前作用域必然是新的作用域
    zone_stack.push(zone_now);
}
["}"] {
    printer("B_RIGHT",yytext);
    zone_stack.pop();//遇到右括号，就从栈中pop掉zone_cnt
    zone_now=zone_stack.top();
}
[";"] {printer("SEMICOLON",yytext);cout<<endl;}
{ASSIGN} printer("ASSIGN",yytext);//多匹配情况下必须在定义段定义，短的在长的前面
{EQUAL} printer("EQUAL",yytext);
[0-9]+	printer("NUM",yytext,atoi(yytext));
{RETURN} printer("RETURN",yytext);
{INT} {
    zone_switch_flag=1;
    printer("INT",yytext);
}
{IF} printer("IF",yytext);
{WHILE} printer("WHILE",yytext);
{word} {
        chars+=strlen(yytext);
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
                zone[zone_now].id_list.push_back(identifier(yytext,id_cnt));
                printer("ID",yytext,id_cnt);
                id_cnt++;
            }
            zone_switch_flag=0;
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
                        break;
                    }
                }
			} 
        }
    }
{line} {lines++;}
{char} {chars++;}
{commentline}   {printf("this is comment part...\n");BEGIN COMMENT_1;}
<COMMENT_1>{line} {BEGIN INITIAL;}
{commentbegin} {printf("this is comment part...\n");BEGIN COMMENT_2;}
<COMMENT_2>{commentelement} {}
<COMMENT_2>{commentend} {BEGIN INITIAL;}
%%

int main(){
    ifstream input("./testin.cpp");
    // ofstream output("./testout");
    zone_stack.push(0);
    yyFlexLexer lexer(&input);
    lexer.yylex();
    cout<<setw(8)<<lines<<setw(8)<<chars<<setw(8)<<id_cnt<<endl;
    return 0;
}
