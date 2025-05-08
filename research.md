
# Hướng dẫn thiết kế bộ xử lý RISC đơn giản bằng Verilog

Bộ xử lý RISC (Reduced Instruction Set Computer) đơn giản thường tuân theo kiến trúc von Neumann: dùng chung bộ nhớ cho lệnh và dữ liệu, thực hiện chu kỳ Fetch–Decode–Execute. Hệ thống bao gồm các khối chức năng cơ bản như Program Counter (PC), thanh ghi lệnh (IR), thanh ghi tích lũy (ACC), ALU, bộ điều khiển (Control Unit), thanh ghi chung (General Register), mạch chọn địa chỉ (Address MUX) và bộ nhớ. Mỗi khối đảm nhiệm vai trò riêng, phối hợp với nhau theo tín hiệu điều khiển. Ví dụ, PC chứa địa chỉ lệnh kế tiếp, IR lưu lệnh hiện hành, ALU thực hiện các phép toán số học, logic và truyền kết quả về ACC, trong khi bộ điều khiển giải mã lệnh và tạo ra các tín hiệu điều khiển. Hình sau đây minh họa sơ đồ khối tổng quát của CPU:

* **Program Counter (PC):** Thanh ghi đếm địa chỉ lệnh tiếp theo.
* **Address MUX:** Mạch đa hợp (multiplexer) chọn địa chỉ đầu vào cho bộ nhớ (địa chỉ từ PC hoặc từ tính toán của ALU, dùng cho lệnh nhảy hoặc truy xuất dữ liệu).
* **Instruction Register (IR):** Thanh ghi chứa lệnh đã đọc từ bộ nhớ chờ giải mã.
* **Accumulator (ACC):** Thanh ghi tích lũy giữ kết quả trung gian của ALU. Theo kiến trúc tích lũy, mọi phép tính sử dụng ACC làm toán hạng (ví dụ, AC ← AC + giá trị).
* **ALU (Arithmetic Logic Unit):** Thực hiện các phép toán số học (cộng, trừ, v.v.) và logic (AND, OR, NOT, dịch trái/phải, v.v.). Đầu vào của ALU có thể là nội dung ACC và một toán hạng từ thanh ghi khác hoặc hằng số.
* **Control Unit:** Giải mã opcode từ IR và tạo các tín hiệu điều khiển (ví dụ cho PC, ACC, ALU, thanh ghi chung) theo chu kỳ lệnh. Bộ điều khiển cũng điều phối việc đọc/ghi bộ nhớ và cập nhật PC.
* **General Register:** Một hay một số thanh ghi chung hỗ trợ lưu trữ dữ liệu tạm thời. Theo TotatalPhase, PC giữ địa chỉ lệnh kế tiếp; IR giữ lệnh hiện hành; ACC là thanh ghi dùng cho phép toán; các thanh ghi chung (R0, R1…) lưu dữ liệu phục vụ tính toán.
* **Memory:** Bộ nhớ (RAM) lưu trữ cả chương trình (lệnh) và dữ liệu. CPU đọc lệnh từ bộ nhớ qua PC/IR, đọc và ghi dữ liệu theo địa chỉ nhất định.

Dưới đây là các hướng dẫn chi tiết từng khối chức năng, kèm ví dụ khối mã Verilog và cách viết testbench.

## 1. Program Counter (PC)

**Mô tả:** PC là một thanh ghi đồng bộ, lưu địa chỉ của lệnh tiếp theo. Mỗi chu kỳ, PC được tăng lên hoặc tải giá trị mới trong trường hợp nhảy. Theo định nghĩa, “Program Counter (PC) keeps track of the memory address of the next instruction to be fetched and executed”. Nói cách khác, PC xác định địa chỉ truy xuất bộ nhớ để đọc lệnh tiếp theo.

**Sơ đồ khối:** PC thường là một bộ đếm (`reg`) có ngõ vào clock và reset. Có thể thêm tín hiệu `load` để nạp địa chỉ nhảy. Ví dụ:

```
module PC(
    input clk, reset,   // xung clock, reset
    input load,         // tín hiệu cho phép nạp địa chỉ mới (nhảy)
    input [7:0] din,    // giá trị địa chỉ nạp vào
    output reg [7:0] pc_out  // địa chỉ hiện tại
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 8'b0;
        end else if (load) begin
            pc_out <= din;       // tải địa chỉ từ nhảy
        end else begin
            pc_out <= pc_out + 1; // tăng PC tuần tự
        end
    end
endmodule
```

**Giải thích tín hiệu:** `reset` khởi PC về 0. Nếu không reset, mỗi xung clock bình thường PC tăng thêm 1. Nếu có nhảy (`load=1`), PC sẽ nhận giá trị mới từ `din`. Độ rộng tín hiệu (ví dụ 8-bit) tùy thuộc lượng bộ nhớ sử dụng.

**Testbench mẫu:** Trong testbench ta có thể mô phỏng các trường hợp: reset về 0, tăng tuần tự vài lần, sau đó cấp `load` với một giá trị nào đó và quan sát PC nhận đúng. Ví dụ:

```verilog
initial begin
    reset = 1; #10; reset = 0;
    load = 0; #50;
    load = 1; din = 8'h10; #10;  // thử nạp PC = 0x10
    load = 0; #50;
    $finish;
end
```

## 2. Address MUX (Multiplexer địa chỉ)

**Mô tả:** Mạch đa hợp địa chỉ (Address MUX) chọn nguồn cấp địa chỉ cho bộ nhớ: khi CPU thực hiện fetch lệnh, địa chỉ cấp từ PC; khi thực hiện lệnh truy xuất dữ liệu (LOAD/STORE), địa chỉ cấp từ ALU (hoặc trường địa chỉ lệnh). Có thể dùng một MUX 2:1 hoặc nhiều cấp, tuỳ thuộc ISA. Ví dụ nếu bộ nhớ chung lệnh+dữ liệu, Address MUX chọn giữa PC và ALU. Tín hiệu điều khiển (ví dụ `mem_addr_sel`) do Control Unit cấp để chọn.

**Sơ đồ khối:** MUX 2 ngõ vào, 1 ngõ ra. Ví dụ:

```
module AddrMux(
    input sel,              // 0 chọn PC, 1 chọn ALU
    input [7:0] pc_addr,    // địa chỉ từ PC
    input [7:0] alu_addr,   // địa chỉ tính từ ALU (ví dụ cho load/store)
    output [7:0] addr_out   // địa chỉ ra bộ nhớ
);
    assign addr_out = sel ? alu_addr : pc_addr;
endmodule
```

**Giải thích tín hiệu:** Nếu `sel=0`, bộ nhớ sẽ được cấp địa chỉ từ PC (`pc_addr`). Nếu `sel=1`, địa chỉ cấp từ ALU (`alu_addr`), dùng trong trường hợp truy xuất dữ liệu hoặc nhánh tính toán (branch). Lưu ý: với lệnh nhảy (jump/branch), một vài kiến trúc tính toán địa chỉ đích ở ALU hoặc dùng chương trình offset; MUX sẽ chọn địa chỉ đó thay vì PC+1.

**Testbench mẫu:** Có thể lần lượt cấp các giá trị khác nhau cho `sel`, `pc_addr`, `alu_addr` và kiểm tra `addr_out`. Ví dụ, khi `sel=0`, `addr_out` bằng `pc_addr`; khi `sel=1`, bằng `alu_addr`.

## 3. Instruction Register (IR) – Thanh ghi lệnh

**Mô tả:** IR lưu mã lệnh vừa được đọc từ bộ nhớ, dùng để giải mã (decode) và điều khiển các khối khác. Theo GeeksforGeeks, “an instruction register ... holds programming instructions that will be executed at the beginning of the next clock cycle”. Hay nói cách khác, IR **chứa nhị phân mã lệnh hiện tại** chờ giải mã.

**Sơ đồ khối:** IR là một thanh ghi chuyển mạch (thường là bộ thanh ghi D flip-flop) có ngõ vào đồng bộ với CPU. Vào mỗi chu kỳ fetch, dữ liệu từ bộ nhớ (đầu ra của cổng Memory) được nạp vào IR:

```
module InstrReg(
    input clk, reset,
    input [15:0] data_in,   // dữ liệu từ bộ nhớ (giả sử 16-bit lệnh)
    output reg [15:0] IR    // nội dung lệnh
);
    always @(posedge clk or posedge reset) begin
        if (reset) 
            IR <= 16'b0;
        else 
            IR <= data_in;  // nạp lệnh mới
    end
endmodule
```

**Giải thích tín hiệu:** `data_in` là bus dữ liệu từ bộ nhớ (có thể là từ bộ nhớ lệnh). Mỗi xung clock (khi đã tính toán xong địa chỉ mới và triac bô nhớ), IR nhận dữ liệu `data_in`. Reset có thể xóa IR. Giá trị IR sau đó được giải mã: phần mã lệnh (opcode) cấp cho Control Unit, các trường còn lại thành toán hạng hay địa chỉ dữ liệu.

**Testbench mẫu:** Trong testbench, mô phỏng việc nạp IR: cung cấp xung clock liên tục, thiết lập `data_in` thành một giá trị cố định hoặc thay đổi mỗi chu kỳ, và kiểm tra IR cập nhật đúng. Ví dụ:

```verilog
initial begin
    reset = 1; #10; reset = 0;
    data_in = 16'hA5A5; #10; // sau xung, IR sẽ = 0xA5A5
    data_in = 16'h3C4D; #10;
    $finish;
end
```

## 4. Accumulator (ACC) – Thanh ghi tích lũy

**Mô tả:** ACC là thanh ghi đặc biệt dùng làm toán hạng chung và lưu kết quả của ALU. Trong các CPU kiến trúc tích lũy, “the accumulator is a register in which intermediate arithmetic and logic results are stored”, và mọi phép tính sử dụng nội dung ACC là toán hạng đầu tiên. Tổng hợp từ nhiều nguồn, ACC là “general-purpose register used for arithmetic and logical operations. It stores intermediate results during calculations”. Ví dụ, lệnh `ADD M[X]` có thể hiểu là `AC <- AC + M[X]`. ACC tương tác chặt với ALU: ALU đọc ACC (đầu vào A) và toán hạng thứ hai (đầu vào B từ thanh ghi khác hoặc immediate), thực hiện phép tính, sau đó kết quả ghi trở lại ACC.

**Sơ đồ khối:** ACC cũng là một thanh ghi đồng bộ (như IR). Nó nhận đầu ra ALU khi cần và cho phép đọc nội dung. Ví dụ:

```
module Accumulator(
    input clk, reset,
    input load,            // 1 nếu ghi kết quả ALU vào ACC
    input [15:0] alu_out,  // dữ liệu từ ALU
    output reg [15:0] ACC  // giá trị hiện tại của ACC
);
    always @(posedge clk or posedge reset) begin
        if (reset) 
            ACC <= 16'b0;
        else if (load) 
            ACC <= alu_out; // ghi kết quả ALU
    end
endmodule
```

**Giải thích tín hiệu:** `load` là tín hiệu cho phép ghi kết quả của ALU vào ACC (do Control Unit điều khiển). Khi `load=0`, ACC giữ nguyên giá trị cũ; khi `load=1`, ACC cập nhật với kết quả ALU. Kết quả phép toán cũng có thể cần xuất ra cho bộ nhớ hoặc thanh ghi khác nếu lệnh là STORE.

**Testbench mẫu:** Mô phỏng ACC tương tự: sau khi reset, đặt `alu_out` thành một giá trị, kích `load=1` một xung clock, và kiểm tra ACC nhận đúng. Ví dụ:

```verilog
initial begin
    reset = 1; #10; reset = 0;
    load = 1; alu_out = 16'h00FF; #10; 
    load = 0; #10;
    $finish;
end
```

## 5. ALU (Arithmetic Logic Unit)

**Mô tả:** ALU thực hiện các phép toán số học và logic cơ bản. ALU nhận hai đầu vào (ví dụ A từ ACC và B từ thanh ghi hoặc immediate) cùng tín hiệu điều khiển chức năng (ALU opcode) để quyết định phép tính. Theo Wikipedia, các ALU thông dụng thực hiện cộng, trừ, NOT, AND, OR, XOR, dịch bit, so sánh, v.v.. Ví dụ, ALU có thể có ba bit điều khiển tương ứng với các hàm: 000: ADD, 001: SUB, 010: NOT A, 011: AND, 100: OR, 101: SL (shift left), 110: SR (shift right), 111: XNOR… (tùy thiết kế). Kết quả tính được xuất ra ngõ ra (ALU\_out), đồng thời có thể cập nhật các cờ trạng thái (Zero, Carry…) nếu cần.

**Sơ đồ khối:** ALU là một khối tổ hợp (combinational) hoặc đăng ký (tùy thiết kế). Đơn giản nhất, ALU chỉ gồm toán tử Verilog. Ví dụ:

```verilog
module ALU(
    input [15:0] A, B,
    input [2:0] op,      // mã lệnh ALU
    output reg [15:0] Y
);
    always @(*) begin
        case (op)
            3'b000: Y = A + B;      // ADD
            3'b001: Y = A - B;      // SUB
            3'b010: Y = ~A;         // NOT (1's complement)
            3'b011: Y = A & B;      // AND
            3'b100: Y = A | B;      // OR
            3'b101: Y = (A << 1);   // LSL
            3'b110: Y = (A >> 1);   // LSR
            3'b111: Y = (A < B) ? 16'b1 : 16'b0; // SLT (set on less than)
            default: Y = 16'b0;
        endcase
    end
endmodule
```

**Giải thích tín hiệu:** `A`, `B` là hai toán hạng. Tín hiệu `op` (ALU opcode) do Control Unit sinh ra từ opcode của lệnh. ALU tính toán và đưa kết quả ra `Y`. Ví dụ, nếu op=000, thực hiện phép cộng và gán kết quả lên Y. Cờ như Zero (kiểm tra `Y==0`) hoặc Carry (từ phép cộng) có thể xuất ra thêm nếu kiến trúc yêu cầu. Theo tài liệu, ALU “thực hiện phép tính cộng, trừ, chuyển vị và đặt bit (set on less than)”, cũng như các phép logic AND, OR, XOR và NOT. Các tín hiệu đầu ra này được đưa về ACC hoặc bộ nhớ tuỳ lệnh tiếp theo.

**Testbench mẫu:** Kiểm tra từng tính năng của ALU: gán các giá trị A, B khác nhau, thay đổi `op`, và kiểm tra `Y` có đúng không. Ví dụ:

```verilog
initial begin
    A = 16'h0003; B = 16'h0005; op = 3'b000; #10; // 3+5
    $display("Add: %h", Y); 
    op = 3'b001; #10;  // 3-5
    $display("Sub: %h", Y); 
    A = 16'h0001; B = 16'h0002; op = 3'b111; #10; // SLT
    $display("SLT: %h", Y); 
    $finish;
end
```

## 6. Control Unit (Bộ điều khiển)

**Mô tả:** Bộ điều khiển (Control Unit) giải mã opcode của lệnh từ IR và tạo ra các tín hiệu điều khiển phù hợp để điều phối các khối khác. Nó thuộc phần điều khiển của CPU, không thực hiện xử lý dữ liệu trực tiếp, nhưng “điều khiển hoạt động của tất cả các phần trong CPU”. Cụ thể, Control Unit nhận vào mã lệnh (opcode) và các tín hiệu cờ (như Zero từ ALU), rồi xuất ra bộ tín hiệu như: `load_pc`, `load_ir`, `load_acc`, `alu_op`, `mem_read`, `mem_write`, `reg_write`, v.v. Các tín hiệu này cho phép các khối tương ứng thực hiện hành động đúng. Ví dụ, lệnh ADD có thể kích `alu_op=000` và `load_acc=1`; lệnh LD (load) kích `mem_read=1`, `load_acc=1`; lệnh BEQ (branch if equal) kiểm tra Zero=1 và nếu đúng sẽ kích `load_pc=1` với địa chỉ nhảy.

**Sơ đồ khối:** Bộ điều khiển có thể là mạch kết hợp (hardwired) hoặc FSM (microprogrammed). Ví dụ đơn giản nhất, Control Unit có thể là khối kết hợp mã hóa trực tiếp opcode sang tín hiệu điều khiển. Ví dụ (giả định):

```verilog
module ControlUnit(
    input [3:0] opcode,  // mã lệnh
    input zero,          // cờ Zero từ ALU
    output reg load_ir, load_pc, load_acc, sel_alu_b, mem_read, mem_write, reg_write,
    output reg [2:0] alu_op
);
    always @(*) begin
        // Reset mặc định
        load_ir = 0; load_pc = 0; load_acc = 0;
        sel_alu_b = 0; mem_read = 0; mem_write = 0; reg_write = 0;
        alu_op = 3'b000;
        case (opcode)
            4'b0000: begin // NOP
            end
            4'b0001: begin // ADD
                alu_op = 3'b000; // cộng
                load_acc = 1;
            end
            4'b0010: begin // SUB
                alu_op = 3'b001;
                load_acc = 1;
            end
            4'b0011: begin // NOT (A <- !A)
                alu_op = 3'b010;
                load_acc = 1;
            end
            4'b0100: begin // AND
                alu_op = 3'b011;
                load_acc = 1;
            end
            4'b0101: begin // OR
                alu_op = 3'b100;
                load_acc = 1;
            end
            4'b0110: begin // LOAD from memory
                mem_read = 1;
                load_acc = 1;
            end
            4'b0111: begin // STORE to memory
                mem_write = 1;
            end
            4'b1000: begin // BRANCH if ZERO (BEQ)
                if (zero) load_pc = 1; // nếu Zero, tải địa chỉ nhảy
            end
            // …các lệnh khác tùy ISA…
            default: ;
        endcase
    end
endmodule
```

**Giải thích tín hiệu:** Tín hiệu đầu vào `opcode` lấy từ IR. Các tín hiệu đầu ra (điều khiển) định hướng hành vi: `load_acc` cho phép cập nhật ACC, `alu_op` chọn phép tính, `mem_read/mem_write` điều khiển bộ nhớ, `load_pc` khi thực hiện nhảy (khi lệnh jump/branch thỏa điều kiện), v.v. Như GeeksforGeeks miêu tả, Control Unit “fetches instructions from main memory to IR và dựa trên nội dung này tạo tín hiệu điều khiển để giám sát việc thực thi các lệnh”.

**Testbench mẫu:** Với Control Unit, testbench có thể cung cấp một loạt opcode và các trạng thái cờ, kiểm tra xem các tín hiệu điều khiển ra đúng hay không. Ví dụ:

```verilog
initial begin
    opcode = 4'b0001; zero = 0; #5; // lệnh ADD
    $display("LOAD_ACC=%b, ALU_OP=%b", load_acc, alu_op);
    opcode = 4'b0110; #5; // LOAD
    $display("MEM_READ=%b, LOAD_ACC=%b", mem_read, load_acc);
    opcode = 4'b1000; zero = 1; #5; // BEQ, Zero=1
    $display("LOAD_PC=%b", load_pc);
    $finish;
end
```

## 7. Register (Thanh ghi chung)

**Mô tả:** Ngoài ACC, CPU có thể có một hoặc nhiều thanh ghi chung (register file hoặc các thanh ghi đơn lẻ) để lưu dữ liệu phụ. Trong kiến trúc đơn giản, ta có thể dùng một thanh ghi dữ liệu (như R0) để lấy toán hạng thứ hai cho ALU. Theo TotalPhase, “General-Purpose Registers (R0, R1…) are used to store data during calculations”.

**Sơ đồ khối:** Đơn giản nhất, ta triển khai một thanh ghi (hoặc một mảng thanh ghi) với đồng bộ ghi. Ví dụ với một thanh ghi R0:

```
module RegisterFile(
    input clk, reset,
    input write_en,         // 1 nếu ghi vào thanh ghi
    input [7:0] din,        // dữ liệu ghi
    output reg [7:0] dout   // dữ liệu đọc
);
    always @(posedge clk or posedge reset) begin
        if (reset) 
            dout <= 8'b0;
        else if (write_en) 
            dout <= din;
    end
endmodule
```

Nếu có nhiều thanh ghi, thiết kế phức tạp hơn (có địa chỉ thanh ghi, nhiều cổng đọc/ghi). Ở mức đơn giản, thanh ghi này sẽ giữ một giá trị từ bộ nhớ nạp vào (ví dụ lệnh LD lưu dữ liệu trong R0) hoặc giữ một toán hạng để ALU dùng.

**Giải thích tín hiệu:** `write_en` do Control Unit cấp. Khi cần lưu giá trị vào thanh ghi, set `write_en=1` và `din` lấy từ bus dữ liệu (có thể từ Memory hoặc ACC). Đầu ra `dout` luôn đưa ra nội dung hiện tại.

**Testbench mẫu:** Tương tự, testbench thay đổi `write_en` và `din`, quan sát `dout`. Ví dụ:

```verilog
initial begin
    reset = 1; #10; reset = 0;
    write_en = 1; din = 8'h3C; #10;
    write_en = 0; #10;
    $display("Register = %h", dout); // Kỳ vọng 0x3C
    $finish;
end
```

## 8. Memory (Bộ nhớ)

**Mô tả:** Bộ nhớ chính (RAM) lưu trữ cả chương trình (dãy lệnh) và dữ liệu. Trong mô hình von Neumann, CPU sử dụng cùng một bộ nhớ cho cả hai. Memory có địa chỉ đầu vào (`addr`), tín hiệu đọc/ghi (`read`, `write`), và bus dữ liệu (`data_in`, `data_out`). Khi CPU fetch, `addr=PC`, `read=1`, CPU nhận lệnh qua `data_out` vào IR. Khi LOAD dữ liệu, `addr` lấy từ ALU hoặc thanh ghi, `read=1` để đưa dữ liệu về ACC. Khi STORE, `addr` từ ALU, `write=1` và `data_in` lấy từ ACC (hoặc thanh ghi).

**Sơ đồ khối:** Memory có thể được viết bằng `reg` mảng trong Verilog, ví dụ 256 từ x 16 bit:

```verilog
module DataMemory(
    input clk,
    input [7:0] address,
    input write_en,
    input [15:0] data_in,
    output reg [15:0] data_out
);
    reg [15:0] mem [0:255]; // 256 từ
    always @(posedge clk) begin
        if (write_en)
            mem[address] <= data_in;
        data_out <= mem[address]; // đọc thụ động hoặc pipelined tuỳ thiết kế
    end
endmodule
```

**Giải thích tín hiệu:** Khi `write_en=1`, bộ nhớ ghi `data_in` vào `mem[address]`. Dòng `data_out <= mem[address]` có thể đọc giá trị (kiểu dưới một xung clock) tại cùng địa chỉ. Trong một số thiết kế, đọc là ngay lập tức (combinational read) hoặc một bước pipelined. Chú ý rằng để fetch lệnh, bộ nhớ có thể tách riêng thành Instruction Memory và Data Memory (Harvard) hoặc một chung (Von Neumann); ở đây giả sử chung.

**Testbench mẫu:** Đầu tiên khởi bộ nhớ với một số giá trị (có thể dùng khối `initial` trong Verilog). Sau đó, mô phỏng read/write:

```verilog
initial begin
    write_en = 1; address = 8'd10; data_in = 16'h1234; #10; 
    write_en = 0; address = 8'd10; #10;
    $display("Mem[10]=%h", data_out); // Kỳ vọng 0x1234
    $finish;
end
```

## 9. Kết nối các module thành hệ thống CPU

Khi đã thiết kế xong các khối đơn lẻ, ta tạo khối **CPU top-level** để kết nối chúng. Ví dụ:

```verilog
module SimpleRISC_CPU(input clk, reset);
    // Tín hiệu dây nối giữa các khối
    wire [7:0] pc_val, addr_bus;
    wire [15:0] ir_val, acc_val, alu_out, mem_data;
    wire load_ir, load_pc, load_acc, sel_addr, mem_read, mem_write;
    wire [2:0] alu_op;
    wire zero_flag;

    // Khối bộ nhớ: đọc lệnh và dữ liệu
    // Ví dụ đây dùng chung Memory. Có thể tách bộ nhớ lệnh (ROM) và bộ nhớ dữ liệu (RAM) nếu muốn.
    DataMemory MEM(.clk(clk), .address(addr_bus), .write_en(mem_write), 
                   .data_in(acc_val), .data_out(mem_data));

    // PC và MUX địa chỉ
    PC pc_inst(.clk(clk), .reset(reset), .load(load_pc), .din(alu_out[7:0]), .pc_out(pc_val));
    AddrMux amux(.sel(sel_addr), .pc_addr(pc_val), .alu_addr(alu_out[7:0]), .addr_out(addr_bus));

    // Instruction Register (lệnh lấy từ bộ nhớ)
    InstrReg ir(.clk(clk), .reset(reset), .data_in(mem_data), .IR(ir_val));

    // Control Unit giải mã opcode (giả sử opcode là 4 bit đầu của IR)
    wire [3:0] opcode = ir_val[15:12];
    ControlUnit ctrl(.opcode(opcode), .zero(zero_flag), .load_ir(load_ir),
                     .load_pc(load_pc), .load_acc(load_acc), .sel_alu_b(sel_addr),
                     .mem_read(mem_read), .mem_write(mem_write), .reg_write(), .alu_op(alu_op));

    // ALU và ACC
    ALU alu_inst(.A(acc_val), .B(mem_data), .op(alu_op), .Y(alu_out));
    // Giả sử dữ liệu thứ hai luôn đọc trực tiếp từ bộ nhớ (còn gọi là đề bài là một thanh ghi tạm).
    Accumulator acc(.clk(clk), .reset(reset), .load(load_acc), .alu_out(alu_out), .ACC(acc_val));

    // Chú ý: Control Unit có thể cần tín hiệu zero_flag (ví dụ từ ALU: Y==0)
    assign zero_flag = (acc_val == 16'b0);
endmodule
```

Trên đây minh họa cách kết nối cơ bản: PC đi tới MUX địa chỉ (để đọc lệnh hoặc nhánh), kết quả bộ nhớ (IR) đi vào Instruction Register, Control Unit lấy opcode để tạo tín hiệu điều khiển, ACC và ALU tính toán. Có thể cần chỉnh sửa hoặc bổ sung khối đọc ghi cho lệnh riêng (ROM) và dữ liệu (RAM) tuỳ yêu cầu đề bài.

## 10. Viết testbench cho hệ thống tổng thể và kiểm thử

Sau khi thiết kế top-level, ta viết testbench toàn hệ thống. Các bước kiểm thử tổng thể:

1. **Nạp chương trình mẫu:** Tạo một tệp thông số hoặc khối `initial` nạp dãy lệnh vào bộ nhớ (DataMemory). Ví dụ: lệnh số học đơn giản, load-store, branch, v.v. Ví dụ chương trình:

   ```
   0x00: LOAD 0x10    // đưa giá trị ở ô nhớ 0x10 vào ACC
   0x02: ADD  0x11    // cộng ACC với nội dung ô 0x11
   0x04: STORE 0x12   // lưu ACC vào ô 0x12
   0x06: HALT (ví dụ mã 1111)
   0x10: 0x000A      // dữ liệu 10 tại địa chỉ 0x10
   0x11: 0x0005      // dữ liệu 5 tại địa chỉ 0x11
   ```

   (Giả sử mỗi lệnh 16-bit, bộ đếm PC nhảy theo 16 bit, v.v.) Nạp dữ liệu 0x0A và 0x05 tại địa chỉ dữ liệu tương ứng.

2. **Chạy mô phỏng:** Tạo testbench với clock giả lập, reset, và nhịp cấp liên tục. Chạy trong một số chu kỳ đủ để thực hiện chương trình. Quan sát đầu ra (kết quả ACC, ô nhớ, PC) theo từng chu kỳ.

3. **Kiểm tra kết quả:** Ví dụ với chương trình trên, sau khi chạy đến lệnh HALT, bộ nhớ tại địa chỉ 0x12 phải có giá trị 0x0F (10+5) hoặc bằng kết quả ACC. Kiểm tra xem ACC, các thanh ghi, cờ trạng thái có đúng theo kỳ vọng.

4. **In ra hoặc so sánh:** Đưa ra báo cáo cho từng bước: có thể dùng `$display` trong Verilog để in giá trị, hoặc viết file log. Đảm bảo ghi rõ địa chỉ và dữ liệu sau mỗi bước.

Ví dụ đoạn testbench (giả sử thêm điều kiện HALT để dừng) có thể như:

```verilog
initial begin
    reset = 1; #10; reset = 0;
    // Nạp bộ nhớ: ở đây đơn giản nạp trực tiếp trong khối initial
    // Giả sử có phương thức nạp (có thể thêm một cổng init vào DataMemory)
    // ...
    // Bắt đầu chạy clock
    repeat (20) begin
        #5 clk = ~clk;
    end
    // Kiểm tra kết quả ở đây
    $display("Mem[0x12] = %h", MEM.mem[16'h12]); // hay đọc qua bus
    $finish;
end
```

Trong môi trường Cadence (ví dụ Verilog-XL, Xcelium) hoặc tương đương (ModelSim, Icarus Verilog), ta có thể đặt break tại HALT để kết thúc.

## 11. Công cụ thiết kế

Đề bài yêu cầu sử dụng Cadence hoặc công cụ tương đương. Điều này nghĩa là:

* Viết code Verilog cho từng module và hệ thống trên, lưu trong môi trường Cadence (ví dụ Capture + NC-Verilog hoặc Xcelium).
* Dùng Cadence Xcelium (hoặc Icarus, ModelSim) để biên dịch và mô phỏng. Viết testbench như phần trên, chạy mô phỏng để kiểm tra từng module và hệ thống.
* Đối với Cadence, có thể sử dụng môi trường có GUI hoặc CLI. Đảm bảo tạo thư mục dự án, thêm tất cả file `.v`, sau đó chạy `xelab` và `xsim` (hoặc lệnh tương đương).
* Chú ý định dạng mạch theo quy chuẩn (ví dụ đặt tên tín hiệu rõ ràng, chú thích, v.v.) để dễ debug.

## Tóm tắt

Các bước chính trong thiết kế là:

1. **Thiết kế từng module** (PC, Address MUX, IR, ACC, ALU, Control Unit, Register, Memory) với mô tả chức năng và Verilog code mẫu.
2. **Viết testbench module** cho mỗi đơn vị để đảm bảo hoạt động đúng từng thành phần.
3. **Kết nối các module** trong mô-đun CPU lớn, mô tả rõ tín hiệu vào/ra mỗi module, sau đó thử nghiệm toàn hệ thống.
4. **Kiểm thử chương trình mẫu**: nạp một chương trình đơn giản (có load, add, store, branch) vào bộ nhớ, chạy mô phỏng theo chu trình fetch-decode-execute và kiểm tra kết quả trên ACC hoặc bộ nhớ đích.
5. **Sử dụng Cadence** (hoặc ModelSim, Icarus Verilog, v.v.) để mô phỏng và xác nhận kết quả. Kết quả đúng yêu cầu khi các module hoạt động đúng theo thiết kế và chương trình mẫu tính toán đúng theo ngữ nghĩa.

Trình bày theo từng phần rõ ràng cùng sơ đồ khối minh hoạ (nếu có) và code mẫu sẽ giúp sinh viên nắm quy trình từng bước và thực hiện đúng. Nguồn tham khảo: định nghĩa các thành phần CPU (PC, IR, ACC, ALU, Control Unit) từ tài liệu kiến trúc máy tính.
