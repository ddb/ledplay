`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:16:26 10/20/2012 
// Design Name: 
// Module Name:    ledplay 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module four_digit_display(
    input clock,
    input [6:0] seg_state_1,
    input [6:0] seg_state_2,
    input [6:0] seg_state_3,
    input [6:0] seg_state_4,
    output [3:0] anodes,
    output [6:0] segments
);

    reg [3:0] anodes_aux;
    reg [16:0] mux_counter;
    reg [6:0] segments_out;
    
    assign segments = segments_out;
    assign anodes = anodes_aux;
        
    always @(posedge clock)
        mux_counter <= mux_counter + 1;
        
	always @(mux_counter[16:15] or seg_state_1 or seg_state_2 or seg_state_3 or seg_state_4) begin
        case (mux_counter[16:15])
            2'b00  : begin
                segments_out <= seg_state_4;
                anodes_aux <= 4'b1110;
            end
            2'b01  : begin
                segments_out <= seg_state_3;
                anodes_aux <= 4'b1101;
            end
            2'b10  : begin
                segments_out <= seg_state_2;
                anodes_aux <= 4'b1011;
            end
            2'b11  : begin
                segments_out <= seg_state_1;
                anodes_aux <= 4'b0111;
            end
            default: begin
                segments_out <= seg_state_1;
                anodes_aux <= 4'b1110;
            end
        endcase
    end

endmodule

module bidirectional_fader(
    input clk,
    output fade_up, fade_down, complete
);

    parameter counter_size = 25;
    parameter resolution = 8;

    reg [counter_size - 1:0] counter;
    
    wire [resolution - 1:0] PWM_fade_up_input = counter[counter_size - 2:counter_size - 1 - resolution];
    wire [resolution - 1:0] PWM_fade_down_input = ~counter[counter_size - 2:counter_size - 1 - resolution];
    reg [resolution:0] PWM_fade_up;
    reg [resolution:0] PWM_fade_down;
    
    always @(posedge clk) begin
        PWM_fade_up <= PWM_fade_up[resolution - 1:0] + PWM_fade_up_input;
        PWM_fade_down <= PWM_fade_down[resolution - 1:0] + PWM_fade_down_input;
    end
    
    always @(posedge clk)
        if (complete == 1'b1)
            counter <= 0;
        else
            counter <= counter + 1;
        
    assign fade_up = PWM_fade_up[resolution];
    assign fade_down = PWM_fade_down[resolution];
    assign complete = counter[counter_size - 1];

endmodule

module cylon8bit(
    input clk,
    output [7:0] leds
);

    parameter [4:0] offset = 0;

    wire fade_up;
    wire fade_down;
    wire complete;
    
    reg [4:0] current_state;
    reg [7:0] leds_state;
    
    assign leds = leds_state;
    
    bidirectional_fader fader(
        .clk(clk),
        .fade_up(fade_up),
        .fade_down(fade_down),
        .complete(complete)
    );
    
    always @(posedge clk) begin
        if (complete == 1'b1) begin
            if (current_state == 5'd17)
                current_state <= 5'd0;
            else
                current_state <= current_state + 1;
        end
            
        case (current_state + offset)
            5'd0:    leds_state <= {                 1'b1,  fade_up,   6'b0};
            5'd1:    leds_state <= {                 2'b11, fade_up,   5'b0};
            5'd2:    leds_state <= {      fade_down, 2'b11, fade_up,   4'b0};
            5'd3:    leds_state <= {1'b0, fade_down, 2'b11, fade_up,   3'b0};
            5'd4:    leds_state <= {2'b0, fade_down, 2'b11, fade_up,   2'b0};
            5'd5:    leds_state <= {3'b0, fade_down, 2'b11, fade_up,   1'b0};
            5'd6:    leds_state <= {4'b0, fade_down, 2'b11, fade_up        };
            5'd7:    leds_state <= {5'b0, fade_down, 2'b11                 };
            5'd8:    leds_state <= {6'b0, fade_down, 1'b1                  };
            5'd9:    leds_state <= {6'b0, fade_up, 1'b1                  }; 
            5'd10:   leds_state <= {5'b0, fade_up,   2'b11                 };
            5'd11:   leds_state <= {4'b0, fade_up,   2'b11, fade_down      };
            5'd12:   leds_state <= {3'b0, fade_up,   2'b11, fade_down, 1'b0};
            5'd13:   leds_state <= {2'b0, fade_up,   2'b11, fade_down, 2'b0};
            5'd14:   leds_state <= {1'b0, fade_up,   2'b11, fade_down, 3'b0};
            5'd15:   leds_state <= {      fade_up,   2'b11, fade_down, 4'b0};
            5'd16:   leds_state <= {                 2'b11, fade_down, 5'b0};
            5'd17:   leds_state <= {                 1'b1,  fade_down, 6'b0};
            default: leds_state <= 8'b0;
        endcase
    end
endmodule

module bargraph8bit(
    input clk,
    output [7:0] leds
);

    parameter [3:0] offset = 0;

    wire fade_up;
    wire fade_down;
    wire complete;
    
    reg [3:0] current_state;
    reg [7:0] leds_state;
    
    assign leds = leds_state;
    
    bidirectional_fader fader(
        .clk(clk),
        .fade_up(fade_up),
        .fade_down(fade_down),
        .complete(complete)
    );
    
    always @(posedge clk) begin
        if (complete == 1'b1)
            current_state = current_state + 1;
            
        case (current_state + offset)
            4'd0:    leds_state <= {fade_up, 7'b0};
            4'd1:    leds_state <= {1'b1, fade_up, 6'b0};
            4'd2:    leds_state <= {2'b11, fade_up, 5'b0};
            4'd3:    leds_state <= {3'b111, fade_up, 4'b0};
            4'd4:    leds_state <= {4'b1111, fade_up, 3'b0};
            4'd5:    leds_state <= {5'b11111, fade_up, 2'b0};
            4'd6:    leds_state <= {6'b111111, fade_up, 1'b0};
            4'd7:    leds_state <= {7'b1111111, fade_up};
            4'd8:    leds_state <= {7'b1111111, fade_down};
            4'd9:    leds_state <= {6'b111111, fade_down, 1'b0};
            4'd10:   leds_state <= {5'b11111, fade_down, 2'b0};
            4'd11:   leds_state <= {4'b1111, fade_down, 3'b0};
            4'd12:   leds_state <= {3'b111, fade_down, 4'b0};
            4'd13:   leds_state <= {2'b11, fade_down, 5'b0};
            4'd14:   leds_state <= {1'b1, fade_down, 6'b0};
            4'd15:   leds_state <= {fade_down, 7'b0};
            default: leds_state <= 8'b0;
        endcase
    end
endmodule

module ledplay(
    input clock,
    input [2:0] switch,
    output [7:0] leds,
    output [3:0] Seg7_AN,
    output [6:0] Seg7,
    output Seg7_DP
);

    reg [2:0] switch_buf;
    reg [2:0] switch_safe;

    reg [7:0] seven_seg_leds_1;
    wire [7:0] seven_seg_leds_wire_1;
    reg [7:0] seven_seg_leds_2;
    wire [7:0] seven_seg_leds_wire_2;
    
    wire [7:0] leds_buf;
    
    wire local_clock;
    
    wire [6:0] seg_state_1 = {1'b1, ~seven_seg_leds_2[6], ~seven_seg_leds_1[6], 1'b1, ~seven_seg_leds_1[7], ~seven_seg_leds_2[7], 1'b1};
    wire [6:0] seg_state_2 = {1'b1, ~seven_seg_leds_2[4], ~seven_seg_leds_1[4], 1'b1, ~seven_seg_leds_1[5], ~seven_seg_leds_2[5], 1'b1};
    wire [6:0] seg_state_3 = {1'b1, ~seven_seg_leds_2[2], ~seven_seg_leds_1[2], 1'b1, ~seven_seg_leds_1[3], ~seven_seg_leds_2[3], 1'b1};
    wire [6:0] seg_state_4 = {1'b1, ~seven_seg_leds_2[0], ~seven_seg_leds_1[0], 1'b1, ~seven_seg_leds_1[1], ~seven_seg_leds_2[1], 1'b1};
    
    my_clock the_clock(
        .CLKIN_IN(clock), 
        .CLKFX_OUT(local_clock)
    );
    
    assign leds = switch_safe[2] ? leds_buf : 8'b0;
    
    always @(posedge local_clock) begin
        switch_safe <= switch_buf;
        switch_buf <= switch;
        
        seven_seg_leds_1 <= switch_safe[0] ? seven_seg_leds_wire_1 : 8'b0;
        seven_seg_leds_2 <= switch_safe[1] ? seven_seg_leds_wire_2 : 8'b0;
    end

    cylon8bit #(0) cylon(
        .clk(local_clock),
        .leds(leds_buf)
    );
    
    four_digit_display disp(
        .clock(local_clock),
        .seg_state_1(seg_state_1),
        .seg_state_2(seg_state_2),
        .seg_state_3(seg_state_3),
        .seg_state_4(seg_state_4),
        .anodes(Seg7_AN),
        .segments(Seg7)
    );
    
    bargraph8bit #(0) bargraph1(
        .clk(local_clock),
        .leds(seven_seg_leds_wire_1)
    );
    
    bargraph8bit #(4) bargraph2(
        .clk(local_clock),
        .leds(seven_seg_leds_wire_2)
    );
    
//    cylon8bit #(4) seven_seg_cylon_1(
//        .clk(local_clock),
//        .leds(seven_seg_leds_wire_1)
//    );

    assign Seg7_DP = 1'b1;

endmodule
