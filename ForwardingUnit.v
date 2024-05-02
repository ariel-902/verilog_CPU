module forwardingUnit
(  
    ID_EX_Rs1,
    ID_EX_Rs2,     
    EX_MEM_RegWrite,
    EX_MEM_Rd,
    MEM_WB_RegWrite,
    MEM_WB_Rd,
    ForwardA_o,
    ForwardB_o
);


input			    EX_MEM_RegWrite, MEM_WB_RegWrite;
input	    [4:0]	ID_EX_Rs1, ID_EX_Rs2, EX_MEM_Rd, MEM_WB_Rd;
output  	[1:0]	ForwardA_o, ForwardB_o;

reg 	    [1:0]	ForwardA_o, ForwardB_o;

always@(*)begin
    ForwardA_o = 2'b00;
    ForwardB_o = 2'b00;

    // EX hazard
    if(EX_MEM_RegWrite && 
    (EX_MEM_Rd != 5'b00000) && 
    (EX_MEM_Rd == ID_EX_Rs1)) ForwardA_o = 2'b10;

    if(EX_MEM_RegWrite && 
    (EX_MEM_Rd != 5'b00000) && 
    (EX_MEM_Rd == ID_EX_Rs2)) ForwardB_o = 2'b10;


    if (MEM_WB_RegWrite &&
    (MEM_WB_Rd != 0)
    && !(EX_MEM_RegWrite && (EX_MEM_Rd != 0)
        && (EX_MEM_Rd == ID_EX_Rs1))
    && (MEM_WB_Rd == ID_EX_Rs1)) ForwardA_o = 2'b01;
 
    if (MEM_WB_RegWrite &&
    (MEM_WB_Rd != 0)
    && !(EX_MEM_RegWrite && (EX_MEM_Rd != 0)
        && (EX_MEM_Rd == ID_EX_Rs2))
    && (MEM_WB_Rd == ID_EX_Rs2)) ForwardB_o = 2'b01;

end
endmodule