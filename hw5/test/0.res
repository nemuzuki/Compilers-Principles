      ID       a       0
     INT       0
      ID       b       0
     INT       2
     INT       2
     INT       3
      ID       a       1
     INT       2
      ID       a       1
      ID       a       1
     INT       2
      ID       a       0
      ID       b       0
  STRING    "%d"
      ID       a       0
       0      NODE_PROG        .           [1,2,3,4]
       1      NODE_STMT  declare           [5,6]
       2      NODE_STMT  declare           [7,8]
       3      NODE_STMT       if           [9,10,11]
       4      NODE_STMT    while           [12,13]
       5      NODE_TYPE      int           []
       6 NODE_DECL_LIST        .           [14,15]
       7      NODE_TYPE      int           []
       8 NODE_DECL_LIST        .           [16,17]
       9        NODE_OP        !           [18]
      10      NODE_STMT  declare           [19,20]
      11 NODE_DECL_LIST        .           [21,22]
      12        NODE_OP       ==           [23,24]
      13      NODE_STMT   printf           [25,26]
      14       NODE_VAR        a           []                       0
      15     NODE_CONST        0           []
      16       NODE_VAR        b           []                       0
      17     NODE_CONST        2           []
      18        NODE_OP       ==           [27,28]
      19      NODE_TYPE      int           []
      20 NODE_DECL_LIST        .           [29,30]
      21       NODE_VAR        a           []                       1
      22        NODE_OP        +           [31,32]
      23       NODE_VAR        a           []                       0
      24       NODE_VAR        b           []                       0
      25    NODE_STRING    "%d",           []
      26       NODE_VAR        a           []                       0
      27     NODE_CONST        2           []
      28     NODE_CONST        3           []
      29       NODE_VAR        a           []                       1
      30     NODE_CONST        2           []
      31       NODE_VAR        a           []                       1
      32     NODE_CONST        2           []
