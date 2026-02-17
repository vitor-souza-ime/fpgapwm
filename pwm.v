module pwm_button (
    input wire clk,
    input wire reset,     // active-low (botão ao GND)
    input wire btn,       // active-low (botão ao GND)
    output reg led
);
    parameter MAX         = 255;
    parameter STEP        = 10;
    parameter DEBOUNCE_MAX = 540_000;

    // Inversão para lógica interna active-high
    wire reset_in = ~reset;
    wire btn_in   = ~btn;

    reg [19:0] debounce_cnt = 0;
    reg btn_stable = 0;
    reg btn_prev   = 0;
    reg btn_edge   = 0;

    always @(posedge clk or posedge reset_in) begin
        if (reset_in) begin
            debounce_cnt <= 0;
            btn_stable   <= 0;
            btn_prev     <= 0;
            btn_edge     <= 0;
        end else begin
            btn_prev <= btn_stable;
            btn_edge <= 0;

            if (btn_in == btn_stable) begin
                debounce_cnt <= 0;
            end else begin
                if (debounce_cnt >= DEBOUNCE_MAX - 1) begin
                    debounce_cnt <= 0;
                    btn_stable   <= btn_in;
                    btn_edge     <= btn_in;
                end else begin
                    debounce_cnt <= debounce_cnt + 1;
                end
            end
        end
    end

    reg [7:0] duty_cycle = 0;

    always @(posedge clk or posedge reset_in) begin
        if (reset_in)
            duty_cycle <= 0;
        else if (btn_edge) begin
            if (duty_cycle + STEP > MAX)
                duty_cycle <= 0;
            else
                duty_cycle <= duty_cycle + STEP;
        end
    end

    reg [7:0] pwm_counter = 0;

    always @(posedge clk or posedge reset_in) begin
        if (reset_in) begin
            pwm_counter <= 0;
            led         <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            led <= (pwm_counter < duty_cycle) ? 1'b1 : 1'b0;
        end
    end

endmodule
