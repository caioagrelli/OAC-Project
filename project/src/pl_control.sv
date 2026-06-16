// =============================================================================
// pl_control.sv
// Unidade de Controle Principal -- RV32I pipelined (P&H secao 4.4)
//
// Decodifica o opcode de 7 bits (estagio ID) e gera os sinais de controle
// que serao propagados pelos registradores de pipeline.
//
// Instrucoes suportadas:
//   R-type  (0110011): add, and
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//
// Tabela de sinais de controle:
//   Sinal     | R-type | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imm
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
// =============================================================================

`timescale 1ns / 1ps

module pl_control (
    input  logic [6:0] Opcode,
    output logic [1:0] ALUSrcA,   // 00=Reg(rs1), 01=PC, 10=Zero
    output logic       ALUSrcB,   // 0=Reg(rs2),  1=Imediato (Antigo ALUSrc)
    output logic [1:0] ResultSrc, // 00=ALU, 01=Mem, 10=PC+4 (Antigo MemtoReg)
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic       Jump,      // 1 para JAL e JALR
    output logic       Jalr,      // 1 específico para JALR
    output logic [1:0] ALUOp
);

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111;
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;

    always_comb begin
        // Valores por defeito (Segurança)
        ALUSrcA   = 2'b00;
        ALUSrcB   = 1'b0;
        ResultSrc = 2'b00;
        RegWrite  = 1'b0;
        MemRead   = 1'b0;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        Jump      = 1'b0;
        Jalr      = 1'b0;
        ALUOp     = 2'b00;

        case (Opcode)
            R_TYPE: begin
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            I_TYPE: begin
                ALUSrcB  = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end
            LOAD: begin
                ALUSrcB  = 1'b1;
                ResultSrc = 2'b01; // Escolhe Memória
                RegWrite = 1'b1;
                MemRead  = 1'b1;
            end
            STORE: begin
                ALUSrcB  = 1'b1;
                MemWrite = 1'b1;
            end
            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            JAL: begin
                Jump      = 1'b1;
                ResultSrc = 2'b10; // Escolhe PC+4 para gravar no registo
                RegWrite  = 1'b1;
            end
            JALR: begin
                Jump      = 1'b1;
                Jalr      = 1'b1;
                ResultSrc = 2'b10; // Escolhe PC+4 para gravar no registo
                RegWrite  = 1'b1;
            end
            LUI: begin
                ALUSrcA   = 2'b10; // ALU recebe Zero
                ALUSrcB   = 1'b1;  // ALU recebe Imediato U-Type
                RegWrite  = 1'b1;
                ALUOp     = 2'b00; // Força operação de Soma (ADD) na ALU
            end
            AUIPC: begin
                ALUSrcA   = 2'b01; // ALU recebe o PC
                ALUSrcB   = 1'b1;  // ALU recebe Imediato U-Type
                RegWrite  = 1'b1;
                ALUOp     = 2'b00; // Força operação de Soma (ADD) na ALU
            end

            default: ; // sinais permanecem em zero (seguro)
        endcase
    end

endmodule
