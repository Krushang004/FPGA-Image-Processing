`timescale 1ns / 1ps

module vga_syncIndex (
    input clock,                    // 100 MHz clock on Basys 3
    input reset,
    input [7:0] val,               // Input to adjust brightness and filters
    input [3:0] sel_module,        // Select one of 16 functions
    output reg hsync,
    output reg vsync,
    output reg [3:0] red,          // 4-bit VGA outputs for Basys 3
    output reg [3:0] green,
    output reg [3:0] blue
);
    reg [7:0] gray, left, right, up, down, leftup, leftdown, rightup, rightdown;
    reg [7:0] red_o, blue_o, green_o;
    reg [15:0] r, b, g;
    reg [7:0] tred, tgreen, tblue;

    reg clk;
    initial begin
        clk = 0;
    end
    always @(posedge clock) begin
        clk <= ~clk;
    end

    reg [14:0] addra = 0;
    wire [95:0] out2;

    // Block memory IP instantiation (ROM mode, no wea/dina ports)
    image inst1 (
        .clka(clk),
        .addra(addra),
        .douta(out2)
    );

    wire pixel_clk;
    reg pcount = 0;
    wire ec = (pcount == 0);
    always @(posedge clk) pcount <= ~pcount;
    assign pixel_clk = ec;

    reg hblank = 0, vblank = 0;
    initial begin
        hsync = 0;
        vsync = 0;
    end
    reg [9:0] hc = 0;
    reg [9:0] vc = 0;

    wire hsyncon, hsyncoff, hreset, hblankon;
    assign hblankon = ec & (hc == 639);
    assign hsyncon  = ec & (hc == 655);
    assign hsyncoff = ec & (hc == 751);
    assign hreset   = ec & (hc == 799);

    wire blank = (vblank | (hblank & ~hreset));

    wire vsyncon, vsyncoff, vreset, vblankon;
    assign vblankon = hreset & (vc == 479);
    assign vsyncon  = hreset & (vc == 490);
    assign vsyncoff = hreset & (vc == 492);
    assign vreset   = hreset & (vc == 523);

    always @(posedge clk) begin
        hc     <= ec ? (hreset ? 0 : hc + 1) : hc;
        hblank <= hreset ? 0 : hblankon ? 1 : hblank;
        hsync  <= hsyncon ? 0 : hsyncoff ? 1 : hsync;

        vc     <= hreset ? (vreset ? 0 : vc + 1) : vc;
        vblank <= vreset ? 0 : vblankon ? 1 : vblank;
        vsync  <= vsyncon ? 0 : vsyncoff ? 1 : vsync;
    end

    always @(posedge pixel_clk) begin
        if (blank == 0 && hc >= 100 && hc < 260 && vc >= 100 && vc < 215) begin
            gray      = out2[95:88];
            left      = out2[87:80];
            right     = out2[79:72];
            up        = out2[71:64];
            down      = out2[63:56];
            leftup    = out2[55:48];
            leftdown  = out2[47:40];
            rightup   = out2[39:32];
            rightdown = out2[31:24];
            tblue     = out2[23:16];
            tgreen    = out2[15:8];
            tred      = out2[7:0];

            // RGB to grayscale
            if (sel_module == 4'b0000) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    red_o   = ((tred >> 2) + (tred >> 5) + (tgreen >> 1) + (tgreen >> 4) + (tblue >> 4) + (tblue >> 5)) >> 4;
                    green_o = red_o;
                    blue_o  = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Increase brightness
            end else if (sel_module == 4'b0001) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = tred  + val; g = tgreen + val; b = tblue + val;
                    red_o   = ((r > 255) ? 255 : r[7:0]) >> 4;
                    green_o = ((g > 255) ? 255 : g[7:0]) >> 4;
                    blue_o  = ((b > 255) ? 255 : b[7:0]) >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Decrease brightness
            end else if (sel_module == 4'b0010) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = tred  - val; g = tgreen - val; b = tblue - val;
                    red_o   = ((r[15] || r > 255) ? 0 : r[7:0]) >> 4;
                    green_o = ((g[15] || g > 255) ? 0 : g[7:0]) >> 4;
                    blue_o  = ((b[15] || b > 255) ? 0 : b[7:0]) >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Color inversion
            end else if (sel_module == 4'b0011) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    red_o   = (255 - tred)   >> 4;
                    green_o = (255 - tgreen) >> 4;
                    blue_o  = (255 - tblue)  >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Red filter
            end else if (sel_module == 4'b0100) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = tred - val;
                    red_o   = ((r[15] || r > 255) ? 0 : r[7:0]) >> 4;
                    green_o = tgreen >> 4;
                    blue_o  = tblue  >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Blue filter
            end else if (sel_module == 4'b0101) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    b = tblue - val;
                    red_o   = tred   >> 4;
                    green_o = tgreen >> 4;
                    blue_o  = ((b[15] || b > 255) ? 0 : b[7:0]) >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Green filter
            end else if (sel_module == 4'b0110) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    g = tgreen - val;
                    red_o   = tred  >> 4;
                    green_o = ((g[15] || g > 255) ? 0 : g[7:0]) >> 4;
                    blue_o  = tblue >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Original image
            end else if (sel_module == 4'b0111) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    red_o   = tred   >> 4;
                    green_o = tgreen >> 4;
                    blue_o  = tblue  >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Average blurring
            end else if (sel_module == 4'b1000) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (gray + left + right + up + down + leftup + leftdown + rightup + rightdown) / 9;
                    red_o = r[7:0] >> 4; green_o = red_o; blue_o = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Sobel edge detection
            end else if (sel_module == 4'b1001) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (rightup - leftup + 2*right - 2*left + rightdown - leftdown);
                    g = (rightup + 2*up + leftup - rightdown - 2*down - leftdown);
                    if      (r[15] && g[15])  b = -(r + g) / 2;
                    else if (r[15] && !g[15]) b = (-r + g) / 2;
                    else if (!r[15] && !g[15])b = (r + g)  / 2;
                    else                      b = (r - g)  / 2;
                    red_o = b[7:0] >> 4; green_o = red_o; blue_o = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Edge detection (Laplacian)
            end else if (sel_module == 4'b1010) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (8*gray - left - right - up - down - leftup - leftdown - rightup - rightdown);
                    if      (r[15] || r > 2048) begin red_o = 0;   green_o = 0;   blue_o = 0;   end
                    else if (r > 255)           begin red_o = 255; green_o = 255; blue_o = 255; end
                    else                        begin red_o = r[7:0]; green_o = red_o; blue_o = red_o; end
                    red_o = red_o >> 4; green_o = green_o >> 4; blue_o = blue_o >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Motion blur XY
            end else if (sel_module == 4'b1011) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (gray + leftdown + rightup) / 3;
                    red_o = r[7:0] >> 4; green_o = red_o; blue_o = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Emboss
            end else if (sel_module == 4'b1100) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (gray + left - right - up + down + 2*leftdown - 2*rightup);
                    if      (r[15] || r > 1280) begin red_o = 0;   green_o = 0;   blue_o = 0;   end
                    else if (r > 255)           begin red_o = 255; green_o = 255; blue_o = 255; end
                    else                        begin red_o = r[7:0]; green_o = red_o; blue_o = red_o; end
                    red_o = red_o >> 4; green_o = green_o >> 4; blue_o = blue_o >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Sharpen
            end else if (sel_module == 4'b1101) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (5*gray - left - right - up - down);
                    if      (r[15] || r > 1280) begin red_o = 0;   green_o = 0;   blue_o = 0;   end
                    else if (r > 255)           begin red_o = 255; green_o = 255; blue_o = 255; end
                    else                        begin red_o = r[7:0]; green_o = red_o; blue_o = red_o; end
                    red_o = red_o >> 4; green_o = green_o >> 4; blue_o = blue_o >> 4;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Motion blur X
            end else if (sel_module == 4'b1110) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (up + leftup + rightup) / 3;
                    red_o = r[7:0] >> 4; green_o = red_o; blue_o = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end

            // Gaussian blur (custom)
            end else if (sel_module == 4'b1111) begin
                if (reset) begin red = 0; green = 0; blue = 0; end
                else begin
                    r = (rightup + 2*up + leftup + 2*right + 4*gray + 2*left + rightdown + 2*down + 2*leftdown) / 16;
                    red_o = r[7:0] >> 4; green_o = red_o; blue_o = red_o;
                    red = red_o[3:0]; green = green_o[3:0]; blue = blue_o[3:0];
                end
            end

            if (addra < 18399)
                addra <= addra + 1;
            else
                addra <= 0;

        end else begin
            red = 0; green = 0; blue = 0;
        end
    end

endmodule