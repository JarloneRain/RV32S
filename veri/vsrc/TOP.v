
module Mux (
    input select,
    input [1:0] data,
    output reg  result
);
    always @(select) begin
        case (select)
            0: result = data[0];
            1: result = data[1];
        endcase
    end
endmodule
