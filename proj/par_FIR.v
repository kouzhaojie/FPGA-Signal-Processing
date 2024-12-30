
module par_FIR(
    input               i_Clk   ,
    input               i_Rst   ,
    input               i_Vld   ,
    input       [15:0]  i_Din   ,
    output              o_Vld   ,
    output      [15:0]  o_Dout
    );
    
    localparam  RANK = 32;
    
    integer i;
    reg             [7:0]   r_Cnt;
    reg     signed  [15:0]  r_Add       [0:RANK/2-1];
    reg     signed  [15:0]  r_Din_reg   [0:RANK-1];
    reg     signed  [31:0]  r_MUL       [0:RANK/2];
    reg     signed  [15:0]  r_Sum;
    wire    signed  [15:0]  w_Coe       [0:RANK/2];//无符号
    assign  w_Coe[0] = 15'b0;
    assign  w_Coe[1] = 15'b0;
    assign  w_Coe[2] = 15'b0;
    assign  w_Coe[3] = 15'b0;
    assign  w_Coe[4] = 15'b0;
    assign  w_Coe[5] = 15'b0;
    assign  w_Coe[6] = 15'b0;
    assign  w_Coe[7] = 15'b0;
    assign  w_Coe[8] = 15'b0;    
    assign  w_Coe[9] = 15'b0;    
    assign  w_Coe[10] = 15'b0;
    assign  w_Coe[11] = 15'b0;
    assign  w_Coe[12] = 15'b0;    
    assign  w_Coe[13] = 15'b0;    
    assign  w_Coe[14] = 15'b0;
    assign  w_Coe[15] = 15'b0;
    assign  o_Dout = r_Sum;
    assign  o_Vld = r_Cnt == RANK;
    always@(posedge i_Clk or negedge i_Rst) 
        if(i_Rst)
            for(i = 0; i < RANK; i = i+1) begin
                r_Din_reg[i] <= 'd0;
            end
        else if(i_Vld) begin
            r_Din_reg[0] <= i_Din; 
            for(i = 1; i < RANK; i = i+1) begin
                r_Din_reg[i] <= r_Din_reg[i-1];
            end
        end
        else 
            for(i = 0; i < RANK; i = i+1) begin
                r_Din_reg[i] <= r_Din_reg[i];
            end
    //pipline 2   
    always@(posedge i_Clk or posedge i_Rst)
        if(i_Rst)
            for(i = 0; i < RANK/2; i = i+1) begin
                r_Add[i] <= 'd0;
            end
        else if(i_Vld) 
            for(i = 0; i < RANK/2; i = i+1) begin
                r_Add[i] <= (r_Din_reg[i] >>> 1) + (r_Din_reg[RANK-i] >>> 1);
            end
        else 
            for(i = 0; i < RANK/2; i = i+1) begin
                r_Add[i] <= r_Add[i];
            end
    //pipline 3    
    always@(posedge i_Clk or posedge i_Rst) 
        if(i_Rst)
            for(i = 0; i < RANK/2; i = i+1) begin
                r_MUL[i] <= 'd0;
            end
        else if(i_Vld) 
            for(i = 0; i < RANK/2; i = i+1) begin
                r_MUL[i] <= w_Coe[i] * r_Add[i];
            end
        else 
            for(i = 0; i < RANK/2; i = i+1) begin
                r_MUL[i] <= r_MUL[i];
            end
    //pipline 4
    always@(posedge i_Clk or posedge i_Rst)
        if(i_Rst)
            r_Sum <= 'd0;
        else if(i_Vld)
            for(i = 0; i < RANK/2; i = i+1) begin
                r_Sum = r_Sum + r_MUL[i];
            end
        else
            r_Sum <= r_Sum;
    
    always@(posedge i_Clk or posedge i_Rst)
        if(i_Rst)
            r_Cnt <= 'd0;
        else if(i_Vld && r_Cnt < RANK)
            r_Cnt <= r_Cnt + 1;
        else
            r_Cnt <= r_Cnt;
            
endmodule
