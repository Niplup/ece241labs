//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
   
   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable

   //
   // Your code goes here
   //
   
   wire ldx, ldy, ldb, ldp;
    control C0(
        .clk(iClock),
        .resetn(iResetn),
        .go(iLoadX),
        .iBlack(iBlack),
        .iPlot(iPlotBox), 
        .LoadX(ldx),
        .LoadY(ldy),
        .LoadB(ldb)
        .LoadP(ldp)
    );

    datapath D0(
        .clk(iClock),
        .resetn(iResetn),
        .iXY_Coord(iXY_Coord), 
        .iColour(iColour),
        .LoadX(ldx),
        .LoadY(ldy),
        .oX(oX), 
        .oY(oY), 
        .oColour(oColour),
    );

    assign oPlot = ldp;
endmodule // part2

module control(
    input clk,
    input resetn,
    input go,
    input iBlack,
    input iPlot,
    output reg LoadX,
    output reg LoadY,
    output reg LoadB,
    output reg LoadP,
    );

    reg [2:0] current_state, next_state; 
    
    localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y        = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
                S_LOAD_B        = 3'd4,
                S_LOAD_P        = 3'd5,
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_P; // Loop in current state until go signal goes low
                S_LOAD_P: next_state = S_LOAD_X; // Loop in current state until value is input
                S_LOAD_B: next_state = S_LOAD_X; // Loop in current state until value is input
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        LoadX = 1'b0;
        LoadY = 1'b0;
        LoadB = 1'b0;
        LoadP = 1'b0;

        case (current_state)
            S_LOAD_X_WAIT: begin
                LoadX = 1'b1;
                end
            S_LOAD_Y_WAIT: begin
                LoadY = 1'b1;
                end
            S_LOAD_B: begin
                LoadB = 1'b1;
                end
            S_LOAD_P: begin
                LoadP = 1'b1;
                end
            /*S_CYCLE_0: begin // Do B <- B * x 
                ld_alu_out = 1'b1; ld_b = 1'b1; // store result back into B
                alu_select_a = 2'b01; // Select register B
                alu_select_b = 2'b11; // Also select register x
                alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_1: begin // Do x <- x * x 
                ld_alu_out = 1'b1; ld_x = 1'b1; // store result back into x
                alu_select_a = 2'b11; // Select register x
                alu_select_b = 2'b11; // Also select register x
                alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_2: begin // Do A <- A * x 
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into A
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b11; // Also select register x
                alu_op = 1'b1; // Do multiply operation
            end
            S_CYCLE_3: begin // Do A <- A + B  
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into A
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b01; // Also select register B
                alu_op = 1'b0; // Do Add operation
            end
            S_CYCLE_4: begin
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b10; // Select register C
                alu_op = 1'b0; // Do Add operation
            end  */
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        if (iBlack)
            current_state <= S_LOAD_B;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
   input clk,
   input resetn,
   input [6:0] iXY_Coord, 
   input [2:0] iColour,
   input LoadX,
   input LoadY,
   input iBlack,
   output reg [7:0] oX, 
   output reg [6:0] oY, 
   output reg [2:0] oColour,
   );
    
   integer i, j; 
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            oX <= 8'b0; 
            oY <= 7'b0; 
            oColour <= 3'b0; 
        end
        else begin
            if(LoadX)
                oX <= {1'b0, iXY_Coord}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(LoadY) begin
                oY <= iXY_Coord; // load alu_out if load_alu_out signal is high, otherwise load from data_in
                oColour <= iColour;
            end
            if(~iBlack) begin
                oColour <= 3'b0;
                for(j = 0; j < Y_SCREEN_PIXELS; j = j + 1) begin
                    for (i = 0; i < X_SCREEN_PIXELS; i = i + 1) begin
                        oX <= i;
                        oY <= j;
                        oColour <= 3'b0;
                    end
                end
            end

            if(~iPlotBox) begin
                for (j = oY; j < 4; j = j + 1) begin
                    for (i = oX; i < 4; i = i + 1) begin
                        oX <= i;
                        oY <= j;
                    end
                end
        end
        //oColour <= iColour;
    end
 
    // Output result register
    /*always@(posedge clk) begin
        if(!resetn) begin
            data_result <= 8'b0; 
        end
        else 
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = x;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = a;
            2'd1:
                alu_b = b;
            2'd2:
                alu_b = c;
            2'd3:
                alu_b = x;
            default: alu_b = 8'b0;
        endcase
    end

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'b0;
        endcase
    end */
    
endmodule
