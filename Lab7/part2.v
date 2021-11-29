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
   wire loadX, loadY, loadOut;
   wire [3:0] counter;

   control C0(iClock, iResetn, iPlotBox, iLoadX, counter, loadX, loadY, loadOut, oPlot);
   datapath D0(iClock, iResetn, loadX, loadY, loadOut, iColour, iXY_Coord, oX, oY, oColour, counter);
endmodule // part2

module control(input iClock,
               input iResetn,
               input iPlotBox,
               input iLoadX,
               input [3:0] counter,
               output reg loadX,
               output reg loadY,
               output reg loadOut,
               output reg oPlot);
    
    reg [2:0] current_state, next_state;
    
    localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y        = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
                S_DRAW          = 3'd4,
                S_DRAW_WAIT     = 3'd5;
    
    // Next state logic aka our state table
    always @(*)
    begin: state_table
        case (current_state)
            S_LOAD_X: next_state = iLoadX ? S_LOAD_X_WAIT : S_LOAD_X;
            S_LOAD_X_WAIT: next_state = iLoadX ? S_LOAD_X_WAIT : S_LOAD_Y;
            S_LOAD_Y: next_state = iPlotBox ? S_LOAD_Y_WAIT : S_LOAD_Y;
            S_LOAD_Y_WAIT: next_state = iPlotBox ? S_LOAD_Y_WAIT : S_DRAW;
            S_DRAW: begin
                if (counter == 4'd15) next_state = S_DRAW_WAIT;
                else next_state = S_DRAW;
            end
            S_DRAW_WAIT: next_state = S_LOAD_X;
            default: next_state = S_LOAD_X;
        endcase
    end

    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        loadX = 1'b0;
        loadY = 1'b0;
        loadOut = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                loadX = 1'b1;
                oPlot = 1'b0;
            end
            S_LOAD_Y: begin
                loadY = 1'b1;
            end
            S_DRAW: begin
                loadOut = 1'b1;
                oPlot = 1'b1;
            end
        endcase
    end
        

    //current_state registers
    always @(posedge iClock)
    begin: state_FFs
        if (!iResetn) current_state <= S_LOAD_X;
        else current_state <= next_state;
    end

endmodule

module datapath(input iClock,
                input iResetn,
                input loadX,
                input loadY,
                input loadOut,
                input [2:0] iColour,
                input [6:0] iXY_Coord,
                output reg [7:0] oX,
                output reg [6:0] oY,
                output reg [2:0] oColour,
                output reg [3:0] counter);

    reg [7:0] xstore;
    reg [6:0] ystore;
    reg [2:0] colourstore;
    always @(posedge iClock)
    begin
        if (!iResetn) counter <= 4'd0;
        else if (counter == 4'd15) counter <= 4'd0;
        else if (loadOut) counter <= counter + 1;
    end

    always @(posedge iClock)
    begin
        if (!iResetn)
        begin
            oX <= 0;
            oY <= 0;
            oColour <= 0;
        end
        else if (loadX)
        begin
            xstore <= {1'b0, iXY_Coord};
        end
        else if (loadY)
        begin
            ystore <= iXY_Coord;
            colourstore <= iColour;
        end
        else if (loadOut)
        begin
            oX <= xstore + counter[1:0];
            oY <= ystore + counter[3:2];
            oColour <= colourstore;
        end
    end
endmodule


