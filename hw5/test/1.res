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
       4      NODE_STMT  declare           [10,11]
       5 NODE_DECL_LIST        .           [12,13]
       6 NODE_DECL_LIST        .           [14,15]
       7      NODE_STMT  declare           [16,17]
       8      NODE_STMT    scanf           [18,19]
       9      NODE_STMT    while           [20,21,22,23,24,25]
      10      NODE_TYPE      int           []
      11 NODE_DECL_LIST        .           [26,27]
      12       NODE_VAR        a           []                       1
      13     NODE_CONST       10           []
      14       NODE_VAR        s           []                       1
      15     NODE_CONST        0           []
      16      NODE_TYPE     char           []
      17 NODE_DECL_LIST        .           [28]
      18    NODE_STRING    "%d",           []
      19       NODE_VAR       ch           []                       1
      20        NODE_OP       &&           [29,30]
      21        NODE_OP       -=           [31,32]
      22      NODE_STMT  declare           [33,34]
      23 NODE_DECL_LIST        .           [35,36]
      24        NODE_OP       +=           [37,38]
      25      NODE_STMT       if           [39,40,41,42,43]
      26 NODE_DECL_LIST        .           [44]
      27       NODE_VAR        s           []                       1
      28       NODE_VAR       ch           []                       1
      29        NODE_OP       ||           [45,46]
      30        NODE_OP        !           [47]
      31       NODE_VAR        a           []                       1
      32     NODE_CONST        1           []
      33      NODE_TYPE      int           []
      34 NODE_DECL_LIST        .           [48]
      35       NODE_VAR        a           []                       2
      36     NODE_CONST       10           []
      37       NODE_VAR        s           []                       1
      38       NODE_VAR        a           []                       2
      39        NODE_OP        <           [49,50]
      40      NODE_STMT   printf           [51,52]
      41      NODE_STMT  declare           [53,54]
      42 NODE_DECL_LIST        .           [55,56]
      43      NODE_STMT      for           [57,58,59,60,61]
      44       NODE_VAR        a           []                       1
      45        NODE_OP       &&           [62,63]
      46        NODE_OP       ==           [64,65]
      47        NODE_OP       ==           [66,67]
      48       NODE_VAR        a           []                       2
      49        NODE_OP        -           [68]
      50        NODE_OP        -           [69]
      51    NODE_STRING    "resu           []
      52       NODE_VAR        s           []                       1
      53      NODE_TYPE      int           []
      54 NODE_DECL_LIST        .           [70]
      55       NODE_VAR        b           []                       3
      56     NODE_CONST       10           []
      57      NODE_TYPE      int           []
      58 NODE_DECL_LIST        .           [71,72]
      59        NODE_OP        <           [73,74]
      60        NODE_OP       ++           [75]
      61      NODE_STMT   printf           [76,77]
      62        NODE_OP        >           [78,79]
      63        NODE_OP       <=           [80,81]
      64        NODE_OP        %           [82,83]
      65     NODE_CONST       10           []
      66       NODE_VAR        a           []                       1
      67     NODE_CONST       10           []
      68       NODE_VAR        s           []                       1
      69     NODE_CONST       10           []
      70       NODE_VAR        b           []                       3
      71       NODE_VAR        i           []                       4
      72     NODE_CONST        0           []
      73       NODE_VAR        i           []                       4
      74       NODE_VAR        b           []                       3
      75       NODE_VAR        i           []                       4
      76    NODE_STRING    "Have           []
      77       NODE_VAR        i           []                       4
      78       NODE_VAR        a           []                       1
      79     NODE_CONST        0           []
      80       NODE_VAR        a           []                       1
      81     NODE_CONST       10           []
      82       NODE_VAR        a           []                       1
      83     NODE_CONST      100           []
