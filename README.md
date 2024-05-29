# RV32S指令集

## 简介

这里的S是Square或者Single的首字母——表示这套指令集是基于单精度浮点数的矩阵指令集。

想要实现RV32S，需要实现RV32F。

## 指令

RV32S使用的opcode的高五位为

- 0x15 Y型，所有需要行列定位的指令，包括元素搬运和矩阵变换。
- 0x16 R型，基本的矩阵计算指令——迹、行列式、加减乘除矩阵积，以及矩阵转置。
- 0x17 R4型，只有一条指令，先乘后加，用来实现矩阵的分块计算。
- 0x1E I型。从内存中加载矩阵的指令。
- 0x1F S型。保存矩阵到内存中。

~~正在考虑是否添加矩阵的load和store指令。~~
已经添加矩阵的load和store指令。

一些被废除的早期构想：

- - 对单个元素的运送指令：将元素移动到浮点寄存器可以组合转置交换指令将元素移动到第0列然后计算一阶矩阵的迹，从浮点寄存器加载元素可以使用生成一阶对角阵的指令。
  - 现在上面的又加回来了
  - 移除了矩阵变换的行列指令，保留了行变换，列变换请通过矩阵转置和行变换实现。
- 现在随着整体架构的重构，以上全部被废除。

### 指令图

$$
\begin{array}{|l|}\hline\\
\text{matrix element move}\\\qquad
    \underline square\quad\underline matrix\quad\underline mo\underline ve\quad to\left\{\begin{array}{l}
        \underline {.f}loat\quad from\quad\underline {.e}lement\\
        \underline {.e}lement\quad from\quad\underline{.f}loat
    \end{array}\right\}
\\
\text{matrix generation}\\\qquad
    \underline square\quad\underline matrix\quad\underline{gen}eration\left\{\begin{array}{l}
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
    \underline square\quad\underline matrix\quad\underline transform\left\{\begin{array}{l}\left\{\begin{array}{l}
        \underline swap\\
        \underline multiply\\
        \underline addition
    \end{array}\right\}\left\{\begin{array}{l}
        \underline col\\
        \underline row
    \end{array}\right\}\\
        \underline transpose
    \end{array}\right\}
\\
\text{matrix calculate}\\\qquad
    \underline square\quad\underline matrix\left\{\begin{array}{l}
        \underline{tr}ace\\
        \underline{det}erminant\\
        element\left\{\begin{array}{l}
            \underline{add}\\
            \underline{sub}tract\\
            \underline{mul}tiply\\
            \underline{div}ision
        \end{array}\right\}\\
        \underline matrix\quad\underline multiplication\quad\underline product\\
    \end{array}\right\}
\\
\\
\hline\end{array}
$$

### 指令类型

新增了新的typeY，用于定位矩阵行列，因为ij长得像ÿ。:)

### 指令表

#### 元素移动指令

##### smmv.f.e rd,rs1,i,j

Y型。将m\[rs1]\[i,j]的元素的值写入f\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|000|rs2|rs1|rm|rd|1010111|

##### smmv.e.f rd,rs1,rs2,i,j

Y型。将m\[rs1]\[i,j]替换为f\[rs2]后写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|001|rs2|rs1|rm|rd|1010111|

#### 矩阵变换指令

##### smtsr rd,rs1,i,j

Y型。交换m\[rs1]的i、j两行，写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|010|rs2|rs1|rm|rd|1010111|

##### smtsc rd,rs1,i,j

Y型。交换m\[rs1]的i、j两列，写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|011|rs2|rs1|rm|rd|1010111|

##### smtmr rd,rs1,rs2,i

Y型。将m\[rs1]的第i行乘以f\[rs2]后写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|100|rs2|rs1|rm|rd|1010111|

##### smtmc rd,rs1,rs2,i

Y型。将m\[rs1]的第i列乘以f\[rs2]后写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|101|rs2|rs1|rm|rd|1010111|

##### smtar rd,rs1,rs2,i,j

Y型。将m\[rs1]的第i行乘以f\[rs2]后加到第j行，最后得到的矩阵写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|110|rs2|rs1|rm|rd|1010111|

##### smtac rd,rs1,rs2,i,j

Y型。将m\[rs1]的第i列乘以f\[rs2]后加到第j行，最后得到的结果写入m\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|111|rs2|rs1|rm|rd|1010111|

##### smtt rd,rs1

R型。将m\[rs1]转置后写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|010|rd|1011011|

#### 矩阵生成指令

##### smgen rd,rs1

R型。生成一个值全为f\[rs2]的矩阵，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|000|rd|1011011|

##### smgend rd,rs1

R型。生成一个值全为f\[rs2]的对角矩阵，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|001|rd|1011011|

#### 矩阵加载指令

##### sml rd,offset(rs1)

I型。从M\[x\[rs1]+sgx_ext(offset)]按照行优先规则加载一个矩阵到m\[rd]。

|31:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|
|imm\[11:0]|rs1|000|rd|1111011|

##### smld rd,offset(rs1)

I型。从M\[x\[rs1]+sext(offset)]按照行优先规则加载一个对角矩阵到m\[rd]。

|31:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|
|imm\[11:0]|rs1|001|rd|1111011|

#### 矩阵存储指令

##### sms rs2,offset(rs1)

S型。将矩阵m\[rs2]以行优先的方式保存到M\[x\[rs1]+sext(offset)]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|imm\[11:5]|rs2|rs1|000|imm\[4:0]|1111111|

##### smsd rs2,offset(rs1)

S型。将矩阵m\[rs2]的对角线保存到M\[x\[rs1]+sext(offset)]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|imm\[11:5]|rs2|rs1|001|imm\[4:0]|1111111|

#### 矩阵计算指令

##### smtr rd,rs1

R型。计算m\[rs1]的迹写入f\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000010|rs2|rs1|rm|rd|1011011|

##### smdet rd,rs1

R型。计算m\[rs1]的行列式写入f\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000011|rs2|rs1|rm|rd|1011011|

##### smadd rd,rs1,rs2

R型。计算m\[rs1]和m\[rs2]的对应元素和，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000100|rs2|rs1|rm|rd|1011011|

##### smsub rd,rs1,rs2

R型。计算m\[rs1]和m\[rs2]的对应元素差，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000101|rs2|rs1|rm|rd|1011011|

##### smmul rd,rs1,rs2

R型。计算m\[rs1]和m\[rs2]的对应元素积，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000110|rs2|rs1|rm|rd|1011011|

##### smdiv rd,rs1,rs2

R型。计算m\[rs1]和m\[rs2]的对应元素商，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000111|rs2|rs1|rm|rd|1011011|

##### smmmp rd,rs1,rs2

R型。计算m\[rs1]和m\[rs2]的矩阵乘积，写入m\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0001000|rs2|rs1|rm|rd|1011011|

##### smma rd,rs1,rs2,rs3

R4型。计算m\[rs1]和m\[rs2]的矩阵积后与m\[rs3]求和，写入m\[rd]。

|31:27|26:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|
|rs3|00|rs2|rs1|rm|rd|1011111|

## 架构

### 寄存器

S指令集除了依赖的F指令集所携带的32个浮点寄存器外，还有32个4×4的单精度浮点矩阵寄存器，这些寄存器的名称和浮点寄存器的名称是一致的，只是把f换成了m。

## 仿真

本项目采用Verilog进行仿真，并使用verilator进行编译。

### 访存

实现中将CPU和RAM分开，使用AXI协议通讯。

指令和数据共用一条读内存总线。读写总线互不干扰。

读写内存延迟至少一个周期后返回结果。

### 流水线

采用分布式控制的五级流水线，无乱序，无分支预测，无数据前递。具体流程如下：

- 取指（IF）：时钟上升沿时将指令从内存中写入指令寄存器（Inst）
- 译码（ID）：译码器通过组合电路译码，时钟上升沿将译码结果写入控制器
- 执行（EX）：根ALU将使用组合电路进行计算，时钟上升沿时将结果写入ALU_OUT1
- 访存（ME）：根据ALU_OUT和DR进行访存，数据会被存入DATA_CACHE
- 写回（WB）：将计算或访存结果写入GPR或PC

这五个阶段除了有各自的必要存储器外，还有用于控制流水线的XX_CTRL控制器。通常情况下，流水控制器都有输出到上一阶段的ready信号和输出到下一阶段的valid信号。其中ready信号是组合逻辑，valid信号用有一个专用的寄存器存储。伪代码表示如下：

```verilog
assign ready = 下一阶段的ready | !本阶段的valid;
always@(posedge clk)
    valid <= ready ? 上一阶段的valid : 本阶段的valid;
```

一些特殊的情况：

1. 写回阶段没有输出到下一阶段的valid信号
2. 写回阶段总是ready的
3. 当前指令流中存在分支或跳转指令时，IF不接受新的指令
4. 当前指令流中存在写后读冲突时，ID不接受新的指令
5. 只要EX做好接收准备，ID就将指令流出
6. 当DATA_CACHE正在读写数据时，ME不接受新的指令，valid保持

上述的第2、3点的目的是用流水线停顿法解决流水线冒险。

### 浮点

理想状态下应该用组合逻辑实现浮点数和矩阵的计算，但我偷懒了。

项目中涉及的浮点运算全部使用DPI-C来实现。
