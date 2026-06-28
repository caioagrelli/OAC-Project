# Relatório de Implementação — Etapas 01 e 02

**Projeto:** RV32I Pipelined — CIN0012/UFPE  
**Equipe:** Caio Agrelli, João, Lucas (ldlfcin), Thales  
**Referência base:** `docs/utils/project-instructions.md`

---

## Visão geral

O projeto parte de um processador RISC-V RV32I com pipeline de 5 estágios que implementava apenas 8 instruções (ADD, SUB, OR, AND, SLT, LW, SW, BEQ). As duas etapas descritas neste relatório adicionam 27 instruções ao ISA, completando os tipos R, I aritmético, I load, S, B, J e U.

| Etapa | Instruções adicionadas | Total acumulado |
|-------|----------------------|-----------------|
| Base  | ADD, SUB, OR, AND, SLT, LW, SW, BEQ | 8 |
| 01    | XOR, SLL, SRL, SRA, SLTU + ADDI, ANDI, ORI, SLTI, SLLI, SRLI, SRAI | 20 |
| 02    | LB, LH, LBU, LHU, SB, SH, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR, LUI, AUIPC | 35 |

---

## Etapa 01 — Aritmética, lógica e deslocamentos

### Instruções implementadas

#### R-type (opcode `0110011`)

| Instrução | funct3 | funct7[5] | Operação ALU | Código |
|-----------|--------|-----------|--------------|--------|
| `XOR`     | `100`  | 0         | `SrcA ^ SrcB` | `4'd03` |
| `SLL`     | `001`  | 0         | `SrcA << SrcB[4:0]` | `4'd06` |
| `SRL`     | `101`  | 0         | `SrcA >> SrcB[4:0]` | `4'd07` |
| `SRA`     | `101`  | 1         | `$signed(SrcA) >>> SrcB[4:0]` | `4'd08` |
| `SLTU`    | `011`  | 0         | `$unsigned(SrcA) < $unsigned(SrcB)` | `4'd12` |

#### I-type aritmético (opcode `0010011`)

| Instrução | funct3 | funct7[5] | Operação ALU | Código |
|-----------|--------|-----------|--------------|--------|
| `ADDI`    | `000`  | —         | ADD          | `4'd01` |
| `XORI`    | `100`  | —         | XOR          | `4'd03` |
| `ORI`     | `110`  | —         | OR           | `4'd04` |
| `ANDI`    | `111`  | —         | AND          | `4'd05` |
| `SLLI`    | `001`  | —         | SLL          | `4'd06` |
| `SLTI`    | `010`  | —         | SLT          | `4'd11` |
| `SRLI`    | `101`  | 0         | SRL          | `4'd07` |
| `SRAI`    | `101`  | 1         | SRA          | `4'd08` |

> `SLTIU` (funct3=`011`) não possui caso explícito em `pl_alu_ctrl.sv` — cai no `default` (ADD). Comportamento intencional para esta entrega.

### Arquivos modificados

#### `pl_alu.sv`

Adicionados os cinco novos casos no `case (Operation)`:

```systemverilog
4'd03: ALUResult = SrcA ^ SrcB;
4'd06: ALUResult = SrcA << SrcB[4:0];
4'd07: ALUResult = SrcA >> SrcB[4:0];
4'd08: ALUResult = $signed(SrcA) >>> SrcB[4:0];
4'd12: ALUResult = 32'($unsigned(SrcA) < $unsigned(SrcB));
```

#### `pl_alu_ctrl.sv`

Adicionados os blocos R-type (`ALUOp=2'b10`) e I-type (`ALUOp=2'b11`):

```systemverilog
2'b10: begin   // R-type
    case (Funct3)
        3'h0: Operation = Funct7[5] ? 4'd02 : 4'd01; // SUB / ADD
        3'h1: Operation = 4'd06;  // SLL
        3'h2: Operation = 4'd11;  // SLT
        3'h3: Operation = 4'd12;  // SLTU
        3'h4: Operation = 4'd03;  // XOR
        3'h5: Operation = Funct7[5] ? 4'd08 : 4'd07; // SRA / SRL
        3'h6: Operation = 4'd04;  // OR
        3'h7: Operation = 4'd05;  // AND
    endcase
end

2'b11: begin   // I-type aritmético
    case (Funct3)
        3'h0: Operation = 4'd01;  // ADDI
        3'h1: Operation = 4'd06;  // SLLI
        3'h2: Operation = 4'd11;  // SLTI
        3'h4: Operation = 4'd03;  // XORI
        3'h5: Operation = Funct7[5] ? 4'd08 : 4'd07; // SRAI / SRLI
        3'h6: Operation = 4'd04;  // ORI
        3'h7: Operation = 4'd05;  // ANDI
        default: Operation = 4'd01;
    endcase
end
```

#### `pl_control.sv`

Adicionado o opcode `I_TYPE = 7'b0010011`:

```systemverilog
I_TYPE: begin
    ALUSrc   = 1'b1;
    RegWrite = 1'b1;
    ALUOp    = 2'b11;
end
```

#### `pl_sign_ext.sv`

Adicionado o caso de extensão de sinal para I-type aritmético (mesmo encoding do LOAD):

```systemverilog
I_TYPE: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
```

---

## Etapa 02 — Loads/Stores parciais, Branches, Jumps e U-type

### Instruções implementadas

#### Loads parciais — I-type (opcode `0000011`)

| Instrução | funct3 | Operação em `pl_datapath.sv` |
|-----------|--------|------------------------------|
| `LB`      | `000`  | `{{24{byte_val[7]}}, byte_val}` — sign-ext de 8 bits |
| `LH`      | `001`  | `{{16{half_val[15]}}, half_val}` — sign-ext de 16 bits |
| `LBU`     | `100`  | `{24'b0, byte_val}` — zero-ext de 8 bits |
| `LHU`     | `101`  | `{16'b0, half_val}` — zero-ext de 16 bits |

A seleção do byte/halfword usa `alu_result[1:0]` (byte offset) e `funct3` do registrador MEM/WB.

#### Stores parciais — S-type (opcode `0100011`)

| Instrução | funct3 | Operação em `pl_dmem.sv` |
|-----------|--------|--------------------------|
| `SB`      | `000`  | Escreve apenas o byte selecionado por `byte_offset` |
| `SH`      | `001`  | Escreve apenas o halfword selecionado por `byte_offset` |
| `SW`      | `010`  | Escreve a palavra completa (comportamento original) |

#### Desvios condicionais — B-type (opcode `1100011`)

A condição de branch foi generalizada em `pl_datapath.sv` com um comparador dedicado (`branch_cond`) baseado em `funct3`, eliminando a dependência do sinal `zero` da ALU:

| Instrução | funct3 | Condição |
|-----------|--------|----------|
| `BEQ`     | `000`  | `rs1 == rs2` |
| `BNE`     | `001`  | `rs1 != rs2` |
| `BLT`     | `100`  | `$signed(rs1) < $signed(rs2)` |
| `BGE`     | `101`  | `$signed(rs1) >= $signed(rs2)` |
| `BLTU`    | `110`  | `$unsigned(rs1) < $unsigned(rs2)` |
| `BGEU`    | `111`  | `$unsigned(rs1) >= $unsigned(rs2)` |

```systemverilog
// branch_cond em pl_datapath.sv
always_comb begin
    case (id_ex.funct3)
        3'h0: branch_cond = (fwd_srca == fwd_srcb);
        3'h1: branch_cond = (fwd_srca != fwd_srcb);
        3'h4: branch_cond = ($signed(fwd_srca) < $signed(fwd_srcb));
        3'h5: branch_cond = ($signed(fwd_srca) >= $signed(fwd_srcb));
        3'h6: branch_cond = ($unsigned(fwd_srca) < $unsigned(fwd_srcb));
        3'h7: branch_cond = ($unsigned(fwd_srca) >= $unsigned(fwd_srcb));
        default: branch_cond = 1'b0;
    endcase
end
```

#### Saltos — J-type e I-type

| Instrução | Tipo | Opcode     | Alvo do PC | Link (rd) |
|-----------|------|------------|------------|-----------|
| `JAL`     | J    | `1101111`  | `PC + imm_J` | `PC + 4` |
| `JALR`    | I    | `1100111`  | `(rs1 + imm_I) & ~1` | `PC + 4` |

- `JAL`: `ResultSrc=2'b10` (escreve `PC+4` em rd), `Jump=1`
- `JALR`: `Jump=1`, `Jalr=1`; o bit 0 do alvo é mascarado conforme a especificação RISC-V

```systemverilog
// alvo JALR em pl_datapath.sv
assign jalr_target = (fwd_srca + id_ex.imm_ext) & ~32'd1;
assign pc_src = id_ex.jump || (id_ex.branch && branch_cond);
```

#### U-type

| Instrução | Opcode    | ALUSrcA | ALUSrcB | Operação |
|-----------|-----------|---------|---------|----------|
| `LUI`     | `0110111` | Zero    | `imm_U` | `0 + imm_U` → rd |
| `AUIPC`   | `0010111` | PC      | `imm_U` | `PC + imm_U` → rd |

- `LUI`: `ALUSrcA=2'b10` (força zero), `ALUSrcB=1`, `ALUOp=2'b00`
- `AUIPC`: `ALUSrcA=2'b01` (PC), `ALUSrcB=1`, `ALUOp=2'b00`

### Arquivos modificados

| Arquivo | Modificação |
|---------|-------------|
| `pl_pipe_pkg.sv` | Adição de campos `jump`, `jalr`, `funct3` nos structs de pipeline |
| `pl_control.sv` | Novos opcodes: JAL, JALR, LUI, AUIPC; `ALUSrcA` ampliado para 2 bits |
| `pl_sign_ext.sv` | Novos formatos: U-type e J-type |
| `pl_datapath.sv` | Comparador `branch_cond`; mux `ALUSrcA` (rs1/PC/zero); lógica JAL/JALR; extensão load parcial |
| `pl_dmem.sv` | Escrita parcial (SB, SH) usando `funct3` e `byte_offset` |

---

## Simulação e verificação

### Programa de teste — Etapa 01

As instruções da Etapa 01 são exercitadas implicitamente pelo programa `hello_e2.asm` (ADDI é a instrução mais usada) e verificadas individualmente na RTL pelo ModelSim.

### Programa de teste — Etapa 02 (`hello_e2.asm`)

47 instruções cobrindo todas as instruções da Etapa 02. Executado e verificado no ModelSim ASE 20.1.

#### Como rodar

```powershell
# A partir de project/modelsim/
.\run_e2.ps1
```

O script troca automaticamente `program.hex` e `data.hex` para os arquivos da Etapa 02, executa o ModelSim, compara com `golden_e2.txt` e restaura os arquivos base ao final.

#### Resultado esperado — registradores

| Registrador | Valor esperado | Instrução responsável |
|-------------|----------------|----------------------|
| `x1`  | `0xFFFFFF95` | `ADDI x1,x0,-107` |
| `x2`  | `0x00000032` | `ADDI x2,x0,50` |
| `x3`  | `0xFFFFFF95` | `LB x3,0(x0)` — sign-ext de 0x95 |
| `x4`  | `0x00000095` | `LBU x4,0(x0)` — zero-ext de 0x95 |
| `x5`  | `0xFFFFFF95` | `LH x5,4(x0)` — sign-ext de 0xFF95 |
| `x6`  | `0x0000FF95` | `LHU x6,4(x0)` — zero-ext de 0xFF95 |
| `x7`  | `0x00003000` | `LUI x7,3` |
| `x8`  | `0x00000024` | `AUIPC x8,0` — PC=0x24 naquele momento |
| `x9`  | `0x00000001` | `BNE` tomado (branch correto) |
| `x10` | `0x00000001` | `BLT` tomado |
| `x11` | `0x00000001` | `BGE` tomado |
| `x12` | `0x00000001` | `BLTU` tomado |
| `x14` | `0x00000001` | `BGEU` tomado |
| `x15` | `0x00000001` | `JAL` — pula reset, executa `addi x15,x0,1` |
| `x16` | `0x0000006C` | `JAL` — link = PC+4 = 0x6C |
| `x17` | `0x00000001` | `JALR` — pula reset, executa `addi x17,x0,1` |
| `x18` | `0x0000007C` | `JALR` — link = PC+4 = 0x7C |

#### Resultado esperado — memória de dados

| Endereço | Valor | Instrução de escrita |
|----------|-------|---------------------|
| `dmem[0]`  | `0xFFFFFF95` | `SW x3` |
| `dmem[1]`  | `0x00000095` | `SW x4` |
| `dmem[2]`  | `0xFFFFFF95` | `SW x5` |
| `dmem[3]`  | `0x0000FF95` | `SW x6` |
| `dmem[4]`  | `0x00003000` | `SW x7` |
| `dmem[5]`  | `0x00000024` | `SW x8` |
| `dmem[6..12]` | `0x00000001` | `SW x9..x17` |

#### Resultado da simulação

```
Halt detectado em PC=0x000000C0 após 65 ciclos.
PASS: saída corresponde ao golden.
ModelSim ASE 20.1 | Errors: 0, Warnings: 1 (arquivo golden ausente — esperado)
```

---

## Cobertura do ISA após Etapa 02

| Categoria          | Total ISA | Implementadas | Faltando |
|--------------------|:---------:|:-------------:|:--------:|
| R-type             | 10        | 10            | 0        |
| I-type aritmético  | 9         | 8 (sem SLTIU) | 1        |
| I-type load        | 5         | 5             | 0        |
| S-type             | 3         | 3             | 0        |
| B-type             | 6         | 6             | 0        |
| U-type             | 2         | 2             | 0        |
| J-type             | 2         | 2             | 0        |
| **Total**          | **37**    | **36**        | **1**    |

---

## Arquivos de simulação (branch `simulation`)

| Arquivo | Descrição |
|---------|-----------|
| `project/assembler/program.hex` | Programa base (hello.asm) — Etapa 01 |
| `project/assembler/data.hex` | Dados base (word0=10, word1=20) |
| `project/assembler/program_e2.hex` | Programa Etapa 02 (hello_e2.asm, 47 instruções) |
| `project/assembler/data_e2.hex` | Memória zerada para Etapa 02 |
| `project/modelsim/golden.txt` | Saída esperada — programa base |
| `project/modelsim/golden_e2.txt` | Saída esperada — Etapa 02 (verificada) |
| `project/modelsim/run_e2.ps1` | Script PowerShell para simular Etapa 02 |
| `project/modelsim/sim_e2_inner.do` | Script ModelSim de compilação e execução |
