COMMENT:/*
I'm level 1 test.
*/
      ID    main       0
      ID       a       1
      ID       s       1
      ID       a       1
     INT      10
      ID       s       1
     INT       0
      ID      ch       1
  STRING    "%d"
      ID      ch       1
      ID       a       1
     INT       0
      ID       a       1
     INT      10
      ID       a       1
     INT     100
     INT      10
      ID       a       1
     INT      10
      ID       a       1
     INT       1
      ID       a       2
      ID       a       2
     INT      10
      ID       s       1
      ID       a       2
      ID       s       1
     INT      10
  STRING"result is: %d\n"
      ID       s       1
      ID       b       3
      ID       b       3
     INT      10
      ID       i       4
     INT       0
      ID       i       4
      ID       b       3
      ID       i       4
  STRING"Have fun: %d\n"
      ID       i       4
COMMENT:// No more compilation error.
       0      NODE_PROG        .           [1]
       1      NODE_FUNC   void_f           [2,3,4,5,6,7,8,9]
       2      NODE_TYPE     void           []
       3       NODE_VAR     main           []                       0
       4      NODE_STMT  declare           [10,11,12]
       5      NODE_DECL        .           [13,14]
       6      NODE_DECL        .           [15,16]
       7      NODE_STMT  declare           [17,18]
       8      NODE_STMT    scanf           [19,20]
       9      NODE_STMT    while           [21,22,23,24,25,26]
      10      NODE_TYPE      int           []
      11      NODE_DECL        .           [27]
      12      NODE_DECL        .           [28]
      13       NODE_VAR        a           []                       1
      14     NODE_CONST       10           []
      15       NODE_VAR        s           []                       1
      16     NODE_CONST        0           []
      17      NODE_TYPE     char           []
      18      NODE_DECL        .           [29]
      19    NODE_STRING    "%d",           []
      20       NODE_VAR       ch           []                       1
      21        NODE_OP       ||           [30,31]
      22        NODE_OP       -=           [32,33]
      23      NODE_STMT  declare           [34,35]
      24      NODE_DECL        .           [36,37]
      25        NODE_OP       +=           [38,39]
      26      NODE_STMT       if           [40,41,42,43,44]
      27       NODE_VAR        a           []                       1
      28       NODE_VAR        s           []                       1
      29       NODE_VAR       ch           []                       1
      30        NODE_OP       &&           [45,46]
      31        NODE_OP       &&           [47,48]
      32       NODE_VAR        a           []                       1
      33     NODE_CONST        1           []
      34      NODE_TYPE      int           []
      35      NODE_DECL        .           [49]
      36       NODE_VAR        a           []                       2
      37     NODE_CONST       10           []
      38       NODE_VAR        s           []                       1
      39       NODE_VAR        a           []                       2
      40        NODE_OP        <           [50,51]
      41      NODE_STMT   printf           [52,53]
      42      NODE_STMT  declare           [54,55]
      43      NODE_DECL        .           [56,57]
      44      NODE_STMT      for           [58,59,60,61]
      45        NODE_OP        >           [62,63]
      46        NODE_OP       <=           [64,65]
      47        NODE_OP       ==           [66,67]
      48        NODE_OP        !           [68]
      49       NODE_VAR        a           []                       2
      50        NODE_OP        -           [69]
      51        NODE_OP        -           [70]
      52    NODE_STRING    "resu           []
      53       NODE_VAR        s           []                       1
      54      NODE_TYPE      int           []
      55      NODE_DECL        .           [71]
      56       NODE_VAR        b           []                       3
      57     NODE_CONST       10           []
      58      NODE_STMT  declare           [72,73]
      59        NODE_OP        <           [74,75]
      60        NODE_OP       ++           [76]
      61      NODE_STMT   printf           [77,78]
      62       NODE_VAR        a           []                       1
      63     NODE_CONST        0           []
      64       NODE_VAR        a           []                       1
      65     NODE_CONST       10           []
      66        NODE_OP        %           [79,80]
      67     NODE_CONST       10           []
      68        NODE_OP       ==           [81,82]
      69       NODE_VAR        s           []                       1
      70     NODE_CONST       10           []
      71       NODE_VAR        b           []                       3
      72      NODE_TYPE      int           []
      73      NODE_DECL        .           [83,84]
      74       NODE_VAR        i           []                       4
      75       NODE_VAR        b           []                       3
      76       NODE_VAR        i           []                       4
      77    NODE_STRING    "Have           []
      78       NODE_VAR        i           []                       4
      79       NODE_VAR        a           []                       1
      80     NODE_CONST      100           []
      81       NODE_VAR        a           []                       1
      82     NODE_CONST       10           []
      83       NODE_VAR        i           []                       4
      84     NODE_CONST        0           []
