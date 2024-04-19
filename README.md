# RV32S指令集

## 简介

这里的S是Square或者Single的首字母——表示这套指令集是基于单精度浮点数的矩阵指令集。

想要实现RV32S，需要实现RV32F。

## 指令

RV32S使用的opcode的高五位为0x15、0x16。

S指令集一共有两种类型的指令：

- 单个元素的搬运指令
- 对单个矩阵的操作指令
- 对两个矩阵进行计算并将结果存储到第三个矩阵

一些被废除的早期构想：

- 对单个元素的运送指令：将元素移动到浮点寄存器可以组合转置交换指令将元素移动到第0列然后计算一阶矩阵的迹，从浮点寄存器加载元素可以使用生成一阶对角阵的指令。
- 现在上面的又加回来了
- 移除了矩阵变换的行列指令，保留了行变换，列变换请通过矩阵转置和行变换实现。

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

Y型。将s\[rs1]\[i,j]的元素的值写入f\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|000|rs2|rs1|000|rd|1010111|

##### smmv.e.f rd,rs1,i,j

Y型。将f\[rs2]的元素的值写入s\[rd]\[i,j]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|001|rs2|rs1|000|rd|1010111|

#### 矩阵变换指令

##### smtsr rd,rs1,i,j

Y型。交换s\[rs1]的i、j两行，写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|000|rs2|rs1|001|rd|1010111|

##### smtsc rd,rs1,i,j

Y型。交换s\[rs1]的i、j两列，写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|001|rs2|rs1|001|rd|1010111|

##### smtmr rd,rs1,rs2,i

Y型。将s\[rs1]的第i行乘以f\[rs2]后写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|010|rs2|rs1|001|rd|1010111|

##### smtmc rd,rs1,rs2,i

Y型。将s\[rs1]的第i列乘以f\[rs2]后写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|011|rs2|rs1|001|rd|1010111|

##### smtar rd,rs1,rs2,i,j

Y型。将s\[rs1]的第i行乘以f\[rs2]后加到第j行，最后得到的矩阵写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|100|rs2|rs1|001|rd|1010111|

##### smtac rd,rs1,rs2,i,j

Y型。将s\[rs1]的第i列乘以f\[rs2]后加到第j行，最后得到的结果写入s\[rd]。

|31:30|29:28|27:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|---|---|
|i|j|101|rs2|rs1|001|rd|1010111|

##### smtt rd,rs1

R型。将s\[rs1]转置后写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|001|rd|1011011|

#### 矩阵生成指令

##### smgen rd,rs1

R型。生成一个值全为f\[rs1]的矩阵，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|000|rd|1011011|

##### smgend rd,rs1

R型。生成一个值全为f\[rs1]的对角矩阵，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000001|rs2|rs1|000|rd|1011011|

#### 矩阵计算指令

##### smtr rd,rs1

R型。计算s\[rs1]的迹写入f\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000010|rs2|rs1|001|rd|1011011|

##### smdet rd,rs1

R型。计算s\[rs1]的行列式写入f\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000011|rs2|rs1|001|rd|1011011|

##### smadd rd,rs1,rs2

R型。计算s\[rs1]和s\[rs2]的对应元素和，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000000|rs2|rs1|010|rd|1011011|

##### smsub rd,rs1,rs2

R型。计算s\[rs1]和s\[rs2]的对应元素差，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000001|rs2|rs1|010|rd|1011011|

##### smmul rd,rs1,rs2

R型。计算s\[rs1]和s\[rs2]的对应元素积，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000010|rs2|rs1|010|rd|1011011|

##### smdiv rd,rs1,rs2

R型。计算s\[rs1]和s\[rs2]的对应元素商，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000011|rs2|rs1|010|rd|1011011|

##### smmmp rd,rs1,rs2

R型。计算s\[rs1]和s\[rs2]的矩阵乘积，写入s\[rd]。

|31:25|24:20|19:15|14:12|11:7|6:0|
|---|---|---|---|---|---|
|0000100|rs2|rs1|010|rd|1011011|

## 架构

### 寄存器

S指令集除了依赖的F指令集所携带的32个浮点寄存器外，还有32个4×4的单精度浮点矩阵寄存器，这些寄存器的名称和浮点寄存器的名称是一致的，只是把f换成了s。
