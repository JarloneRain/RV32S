RV32S指令集

# 简介

这里的S是Square或者Single的首字母——表示这套指令集是基于单精度浮点数的矩阵指令集。

想要实现RV32S，需要实现RV32F。

# 指令

RV32S使用的opcode的高五位为0x15。

S指令集一共有两种类型的指令：

- 对单个矩阵的操作指令
- 对两个矩阵进行计算并将结果存储到第三个矩阵

一些被废除的早期构想：

- 对单个元素的运送指令：将元素移动到浮点寄存器可以组合转置交换指令将元素移动到第0列然后计算一阶矩阵的迹，从浮点寄存器加载元素可以使用生成一阶对角阵的指令。
- 移除了矩阵变换的行列指令，保留了行变换，列变换请通过矩阵转置和行变换实现。

## 指令图

$$
\begin{array}{|l|}\hline\\
\text{matrix generation}\\\qquad
    \underline square\quad\underline matrix\quad\underline generation\left\{\begin{array}{l}
        \underline \quad\\
        \underline diagonal
    \end{array}\right\}
\\
\text{load and stroe}\\\qquad
    \underline square\quad\underline matrix\left\{\begin{array}{l}
        \underline load\\
        \underline store
    \end{array}\right\}\left\{\begin{array}{l}
        \underline \quad\\
        \underline diagonal
    \end{array}\right\}
\\
\text{matrix transform}\\\qquad
    \underline square\quad\underline matrix\quad\underline transform\left\{\begin{array}{l}
        \underline swap\\
        \underline multiply\\
        \underline addition\\
        \underline transpose
    \end{array}\right\}
\\
\text{matrix calculate}\\\qquad
    \underline square\quad\underline matrix\left\{\begin{array}{l}
        \underline{add}\\
        \underline{sub}tract\\
        \underline{tr}ace\\
        \left\{\begin{array}{l}
            \underline element\\
            \underline matrix
        \end{array}\right\} \underline{mul}tiply\\
        \underline{div}ision
    \end{array}\right\}
\\
\\
\hline\end{array}
$$

## 指令表

只要不特别说明，以下出现的$N$均为$2^W$。

### smg\[W] rd rs1

生成一个值全为f\[rs1]的N阶方阵，写入SM\[x\[rd]+:N]\[0+:N]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|~|rs1|W|rd|101011|

### smgd\[W] rd rs1

生成一个对角线全为f\[rs1]的N阶方阵，写入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000001|~|rs1|W|rd|101011|

### sml\[W] rd rs1

从内存M\[x\[rs1]+:N×N]中加载N×N个单精度浮点，以满矩阵的形式写入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000010|~|rs1|W|rd|101011|

### smld\[W] rd rs1

从内存M\[x\[rs1]+:N]中加载N个单精度浮点，以对角矩阵的形式写入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000011|~|rs1|W|rd|101011|

### sms\[W] rs1,rs2

将SM\[x\[rs2]+:N]\[0+:N]以行优先二维数组的形式写入M\[x\[rs1]+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000100|~|rs1|W|rd|101011|

### smsd\[W] rs1,rs2

将SM\[x\[rs2]+:N]\[0+:N]的对角线写入M\[x\[rs1]+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000101|~|rs1|W|rd|101011|

### smtt\[W] rd,rs1

将SM\[x\[rs1]+:N]\[0+:N]转置后存入SM\[x\[rsd]+:N]\[0+:N]处

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0001000|~|rs1|W|rd|101011|

### smts\[W] rs1,rs2

交换SM\[x\[rs1]]和SM\[x\[rs2]]两行的\[0+:N]列

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0001001|rs2|rs1|W|~|101011|

### smtm\[W] rd,rs1,rs2

将SM\[x\[rs2]]\[0+:N]乘上f\[rs1]写入SM\[x\[rd]]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0001010|rs2|rs1|W|rd|101011|

### smta\[W] rd,rs1,rs2

将SM\[x\[rs2]]\[0+:N]乘上f\[rs1]与SM\[x\[rd]]\[0+:N]求和送入SM\[x\[rd]]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0001011|rs2|rs1|W|rd|101011|

### smadd\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]与SM\[x\[rs2]+:N]\[0+:N]的和，存入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010000|rs2|rs1|W|rd|101011|

### smsub\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]与SM\[x\[rs2]+:N]\[0+:N]的差，存入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010001|rs2|rs1|W|rd|101011|

### smtr\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]的迹，存入f\[rd]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010010|rs2|rs1|W|rd|101011|

### smdiv\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]与SM\[x\[rs2]+:N]\[0+:N]对应元素的商，存入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010011|rs2|rs1|W|rd|101011|

### smemul\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]与SM\[x\[rs2]+:N]\[0+:N]对应元素的积，存入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010100|rs2|rs1|W|rd|101011|

### smmmul\[W] rd,rs1,rs2

计算SM\[x\[rs1]+:N][0+:N]与SM\[x\[rs2]+:N]\[0+:N]的矩阵积，存入SM\[x\[rd]+:N]\[0+:N]

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0010101|rs2|rs1|W|rd|101011|

# 寄存器

除了依赖的RV32F指令集所需的32个浮点寄存器外，S指令集额外附带一了一块用于进行矩阵计算的寄存器组SM，大小为N（行）×128（列）×32bits，目前N的大小暂定为4096。

|N|col=0 | |col=127|
|-|-|-|-|
|0|float32\[0]\[0]|...|float32\[0]\[127]|
|1|float32\[1]\[0]|...|float32\[1]\[127]|
|...|...|...|...|
|MAX_N|float32\[MAX_N]\[0]|...|float32\[MAX_N]\[127]|
