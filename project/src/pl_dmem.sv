// =============================================================================
// pl_dmem.sv
// Memoria de dados -- RV32I pipelined
//
// Capacidade : 256 palavras x 32 bits = 1 KB
// Init file  : data.mif   (sintese Quartus)
//              data.hex   (simulacao ModelSim via $readmemh)
//
// Leitura  : assincrona (combinatorial) -- disponivel no estagio MEM
// Escrita  : sincrona (posedge clk, gated por MemWrite & ~mmio_sel)
// Endereco : alu_result[9:2]  (endereco de palavra de 8 bits)
// =============================================================================

`timescale 1ns / 1ps

module pl_dmem (
    input  logic        clk,
    input  logic        MemWrite,

    input  logic [2:0]  funct3,      // Para identificar tamanho da escrita
    input  logic [1:0]  byte_offset, // Para identificar a posicao na palavra

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

    always_ff @(posedge clk) begin
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
                default: begin // SW (Store Word)
                    ram[addr] <= WriteData;
                end
            endcase
        end
    end

    assign ReadData = ram[addr];

endmodule
