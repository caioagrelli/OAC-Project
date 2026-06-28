// =============================================================================
// pl_dmem.sv
// Memória de Dados - RV32I pipelined
// =============================================================================
`timescale 1ns / 1ps

module pl_dmem (
    input  logic        clk,
    input  logic        MemWrite,
    input  logic [2:0]  funct3,
    input  logic [1:0]  byte_offset,
    input  logic [7:0]  addr,
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData
);

    (* ram_init_file = "data.mif" *) logic [31:0] ram [0:255];

    // synthesis translate_off
    initial begin
        for (int i = 0; i < 256; i++) ram[i] = 32'h00000000;
        $readmemh("data.hex", ram);
    end
    // synthesis translate_on

    // Leitura (combinacional) - A extensão de sinal para LB/LH é feita no datapath
    assign ReadData = ram[addr];

    // Escrita (síncrona)
    // IMPORTANTE: Utilizar 'always' ao invés de 'always_ff' para evitar
    // o erro vlog-7061 no ModelSim devido ao conflito com o bloco initial.
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: begin // SB (Store Byte)
                    case (byte_offset)
                        2'b00: ram[addr][7:0]   <= WriteData[7:0];
                        2'b01: ram[addr][15:8]  <= WriteData[7:0];
                        2'b10: ram[addr][23:16] <= WriteData[7:0];
                        2'b11: ram[addr][31:24] <= WriteData[7:0];
                    endcase
                end
                
                3'b001: begin // SH (Store Halfword)
                    if (byte_offset[1] == 1'b0)
                        ram[addr][15:0]  <= WriteData[15:0];
                    else
                        ram[addr][31:16] <= WriteData[15:0];
                end
                
                3'b010: begin // SW (Store Word)
                    ram[addr] <= WriteData;
                end
                
                default: ram[addr] <= WriteData;
            endcase
        end
    end

endmodule