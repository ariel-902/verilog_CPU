module ForwardingMUX(
    ForwardBits_i,
    ID_EX_data_i,
    MEM_ALUResult,
    WB_writeData,
    data_o
);


input	[1:0]		ForwardBits_i;
input	[31:0]		ID_EX_data_i, MEM_ALUResult, WB_writeData;
output  [31:0]	    data_o;

reg     [31:0]	    data_o;


always @(*) begin
	case(ForwardBits_i)
        2'b00: data_o = ID_EX_data_i;

        2'b01: data_o = WB_writeData;

		2'b10: data_o = MEM_ALUResult;	

        default : data_o = ID_EX_data_i;
	endcase
end

endmodule