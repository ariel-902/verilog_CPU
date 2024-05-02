module Hazard_Detect(
    IF_ID_Rs1_i,
    IF_ID_Rs2_i,
    ID_EX_Rd_addr_i,
    ID_EX_MEMread_i,
    stall_bit_o
);


//Interface
input               ID_EX_MEMread_i;
input   [4:0]       IF_ID_Rs1_i, IF_ID_Rs2_i, ID_EX_Rd_addr_i;
output              stall_bit_o;

reg                 stall_bit_o;

always @(*) begin
    if(ID_EX_MEMread_i && ((ID_EX_Rd_addr_i == IF_ID_Rs1_i) || (ID_EX_Rd_addr_i == IF_ID_Rs2_i))) begin
        stall_bit_o <= 1;
    end
    else begin
        stall_bit_o <= 0;
    end
end
endmodule
