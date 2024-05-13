
module Top (
    input clk,
    input rst
);


    always @(*) begin
        $display("Hello, World!");
        $finish;
    end
endmodule
