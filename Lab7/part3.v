//
// This is the template for Part 3 of Lab 7.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREENSIZE, Y_SCREENSIZE are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part3(iColour,iResetn,iClock,oX,oY,oColour,oPlot);
   input wire [2:0] iColour;
   input wire 	    iResetn;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel drawn enable

   parameter
     X_SCREENSIZE = 160,  // X screen width for starting resolution and fake_fpga
     Y_SCREENSIZE = 120,  // Y screen height for starting resolution and fake_fpga
     CLOCKS_PER_SECOND = 5000, // 5 KHZ for fake_fpga
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_MAX = X_SCREENSIZE - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREENSIZE - 1 - Y_BOXSIZE,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60;

   //
   // Your code goes here
   //
   wire [3:0] counter;
   wire go, continue, refresh, delete, enable;

   reg [6:0] ratediv;
   reg [3:0] finalcount;

   control C0(iClock, iResetn, continue, counter, go, refresh, delete, oPlot);
   datapath D0(iClock, iResetn, go, refresh, delete, iColour, X_MAX, Y_MAX, oX, oY, oColour, counter);

    always @(posedge iClock)
    begin
        if (!iResetn) finalcount <= 4'd0;
        else if (finalcount == 4'd15) finalcount <= 4'd0;
        else if (enable) finalcount <= finalcount + 1;
    end

   always @(posedge iClock)
   begin
      if (!iResetn) ratediv <= 0;
      else if (ratediv == PULSES_PER_SIXTIETH_SECOND - 1) ratediv <= 0;
      else ratediv <= ratediv + 1;
   end
   assign enable = (ratediv == PULSES_PER_SIXTIETH_SECOND - 1) ? 1 : 0;
   assign continue = (finalcount == 4'd15) ? 1 : 0;

endmodule // part3

module control (input iClock,
                input iResetn,
                input continue,
                input [3:0] counter,
                output reg go,
                output reg refresh,
                output reg delete,
                output reg oPlot);

   reg [2:0] current_state, next_state;
   
   localparam   S_DRAW          = 3'd0,
                S_DRAW_WAIT     = 3'd1,
                S_DELETE        = 3'd2,
                S_DELETE_WAIT   = 3'd3,
                S_REFRESH       = 3'd4;
    

   
    // Next state logic aka our state table
    always @(*)
    begin: state_table
        case (current_state)
            S_DRAW: begin
                if (counter == 4'd15) next_state = S_DRAW_WAIT;
                else next_state = S_DRAW;
            end
            S_DRAW_WAIT: next_state = continue ? S_DELETE : S_DRAW_WAIT;
            S_DELETE: begin
               if (counter == 4'd15) next_state = S_DELETE_WAIT;
               else next_state = S_DELETE;
            end
            S_DELETE_WAIT: next_state = S_REFRESH;
            S_REFRESH: next_state = S_DRAW;
            default: next_state = S_DRAW;
        endcase
    end

    // Output logic aka all of our datapath control signals
    always @(*)
    begin
        go = 1'b0;
        refresh = 1'b0;
        delete = 1'b0;

        case (current_state)
            S_DRAW: begin
                go = 1'b1;
                oPlot = 1'b1;
            end
            S_DELETE: begin
                delete = 1'b1;
                oPlot = 1'b1;
            end
            S_REFRESH: begin
                refresh = 1'b1;
                oPlot = 1'b0;
            end
        endcase
    end

    //current_state registers
   always @(posedge iClock)
   begin: state_FFs
      if (!iResetn) current_state <= S_DRAW;
      else current_state <= next_state;
   end
endmodule

module datapath (input iClock,
                 input iResetn,
                 input go,
                 input refresh,
                 input delete,
                 input [2:0] iColour,
                 input [31:0] X_MAX,
                 input [31:0] Y_MAX,
                 output reg [7:0] oX,
                 output reg [6:0] oY,
                 output reg [2:0] oColour,
                 output reg [3:0] counter);

   reg [7:0] xstore;
   reg [6:0] ystore;
   reg r;
   reg d;

   wire enable = go | delete;
   
    always @(posedge iClock)
    begin
        if (!iResetn) counter <= 4'd0;
        else if (counter == 4'd15) counter <= 4'd0;
        else if (enable) counter <= counter + 1;
    end

    always @(posedge iClock)
    begin
        if (!iResetn)
        begin
            xstore <= 0;
            ystore <= 0;
            r <= 1;
            d <= 1;
        end
        else if (go)
        begin
            oX <= xstore + counter[1:0];
            oY <= ystore + counter[3:2];
            oColour <= iColour;
        end
        else if (refresh)
        begin
            if (r) xstore <= xstore + 1;
            if (~r) xstore <= xstore - 1;
            if (d) ystore <= ystore + 1;
            if (~d) ystore <= ystore - 1;
        end
        else if (delete)
        begin
            oX <= xstore + counter[1:0];
            oY <= ystore + counter[3:2];
            oColour <= 0;
        end
        if (xstore == 0) r <= 1;
        if (xstore == X_MAX) r <= 0;
        if (ystore == 0) d <= 1;
        if (ystore == Y_MAX) d <= 0;
    end
endmodule

