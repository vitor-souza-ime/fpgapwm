# FPGA PWM – Controle de Duty Cycle por Botão

Este repositório contém a implementação de um **gerador PWM (Pulse Width Modulation)** para a placa **Tang Nano 1K** baseada no FPGA **GW1NZ-LV1**. O projeto demonstra como controlar o **duty cycle** de um sinal PWM com um botão, incrementando de 0 a 255 em passos de 10 a cada pressionamento e retornando a 0 ao ocorrer overflow.

O sinal PWM pode ser usado para modular a intensidade de um LED, motor, ou outro atuador digital. A frequência do PWM é definida pelo clock da placa (27 MHz), e o duty cycle é ajustado dinamicamente por um botão físico.

## Arquivos Principais

- `main.py` – Arquivo de referência (pode conter notas, scripts auxiliares ou testes).  
- `pwm.v` – Módulo Verilog que implementa o PWM com controle por botão.  
- `pwm.cst` – Arquivo de restrições de pinos para a placa Tang Nano 1K.

## Visão Geral do Projeto

O módulo PWM implementado em Verilog recebe um botão de usuário como entrada e gera um sinal PWM de 8 bits na saída. A cada pressionamento do botão:

- O duty cycle aumenta em **10 unidades**;
- Quando o valor ultrapassa **255**, ele é redefinido para **0**;
- O sinal PWM é comparado com um contador que varre de 0 a 255;
- Com isso, a saída gerada tem duty cycle proporcional ao valor configurado.

Esse comportamento permite, por exemplo, controlar o brilho de um LED ou a velocidade de um motor DC com controle digital simples.

## Requisitos de Desenvolvimento

Para sintetizar e programar a FPGA é necessário:

- **Gowin FPGA Designer – Education Edition** (IDE de síntese e implementação).  
- Placa de desenvolvimento **Tang Nano 1K** (GW1NZ-LV1) com clock de 27 MHz integrado. :contentReference[oaicite:0]{index=0}  
- Cabo USB para programação via interface JTAG.

## Síntese e Geração de Bitstream

1. Clone o repositório:
   ```bash
   git clone https://github.com/vitor-souza-ime/fpgapwm.git
   cd fpgapwm


2. Abra o **Gowin FPGA Designer** e crie um novo projeto.
3. Selecione o dispositivo alvo **GW1NZ-LV1QN48C6/I5** (Tang Nano 1K).
4. Adicione os arquivos `.v` e `.cst` ao projeto.
5. Execute **Synthesis** e **Place & Route**.
6. Gere o **bitstream** (`.bit`) para programar o FPGA.
7. Programe a Tang Nano 1K com o bitstream gerado.

## Uso

* Conecte a placa Tang Nano 1K ao computador.
* Programe a FPGA com o bitstream gerado.
* Pressione o botão da placa repetidamente — o LED conectado ao sinal PWM deverá variar o brilho conforme o duty cycle é incrementado.

## Exemplo de Código Verilog (pwm.v)

```verilog
module pwm_button (
    input wire clk,
    input wire reset,
    input wire btn,
    output reg led
);
    parameter MAX = 255;
    parameter STEP = 10;
    reg [7:0] duty_cycle = 0;
    reg [7:0] pwm_counter = 0;
    reg btn_prev = 0;
    wire btn_edge;
    assign btn_edge = btn & ~btn_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) btn_prev <= 0;
        else btn_prev <= btn;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) duty_cycle <= 0;
        else if (btn_edge) begin
            if (duty_cycle + STEP > MAX)
                duty_cycle <= 0;
            else
                duty_cycle <= duty_cycle + STEP;
        end
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter <= 0;
            led <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            led <= (pwm_counter < duty_cycle) ? 1'b1 : 1'b0;
        end
    end
endmodule
```

## Licença

Este projeto está disponível sob a **MIT License** (ou outra de sua preferência).

