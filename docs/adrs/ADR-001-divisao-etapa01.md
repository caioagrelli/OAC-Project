# ADR-001 — Divisão de Implementação da Etapa 01

**Data:** 2026-06-02  
**Status:** Aceito  
**Contexto:** Etapa 01 do projeto RV32I Pipeline — CIN0012/UFPE

---

## Contexto

A Etapa 01 exige a implementação de 12 novas instruções no processador RV32I pipelined:

- 5 instruções R-type: `XOR`, `SLL`, `SRL`, `SRA`, `SLTU`
- 7 instruções I-type aritmético: `ADDI`, `ANDI`, `ORI`, `SLTI`, `SLLI`, `SRLI`, `SRAI`

As modificações impactam os seguintes arquivos:
- `project/src/pl_alu.sv` — novas operações
- `project/src/pl_alu_ctrl.sv` — novos casos de decodificação
- `project/src/pl_control.sv` — novo opcode I-type
- `project/src/pl_sign_ext.sv` — novo caso de extensão de sinal

---

## Decisão

Dividir as 12 instruções igualmente entre os 4 integrantes, 3 instruções por pessoa, priorizando agrupar instruções com lógica similar (ex: `SRL`/`SRA` têm o mesmo `funct3` e só diferem no `funct7[5]`).

---

## Divisão

### Caio — XOR, ADDI, ANDI

**`pl_alu.sv`**
- Adicionar operação XOR (`SrcA ^ SrcB`)
- ADDI reutiliza ADD (`4'd01`)
- ANDI reutiliza AND (`4'd05`)

**`pl_alu_ctrl.sv`**
- R-type: `funct3=100` → XOR
- I-type (`ALUOp=11`): `funct3=000` → ADDI, `funct3=111` → ANDI

**`pl_control.sv`** *(coordenar com equipe)*
- Adicionar `I_TYPE = 7'b0010011` com `ALUSrc=1`, `RegWrite=1`, `ALUOp=2'b11`

**`pl_sign_ext.sv`** *(coordenar com equipe)*
- Adicionar caso `I_TYPE`: mesmo encoding do LOAD (`Instr[31:20]`)

---

### Lucas — SLL, ORI, SLTI

**`pl_alu.sv`**
- Adicionar operação SLL (`SrcA << SrcB[4:0]`)
- ORI reutiliza OR (`4'd04`)
- SLTI reutiliza SLT (`4'd11`)

**`pl_alu_ctrl.sv`**
- R-type: `funct3=001` → SLL
- I-type (`ALUOp=11`): `funct3=110` → ORI, `funct3=010` → SLTI

**`pl_control.sv`** *(coordenar com equipe)*  
**`pl_sign_ext.sv`** *(coordenar com equipe)*

---

### João — SRL, SRA, SLLI

**`pl_alu.sv`**
- Adicionar operação SRL (`SrcA >> SrcB[4:0]`)
- Adicionar operação SRA (`$signed(SrcA) >>> SrcB[4:0]`)
- SLLI reutiliza SLL

**`pl_alu_ctrl.sv`**
- R-type: `funct3=101`, `funct7[5]=0` → SRL
- R-type: `funct3=101`, `funct7[5]=1` → SRA
- I-type (`ALUOp=11`): `funct3=001` → SLLI

**`pl_control.sv`** *(coordenar com equipe)*  
**`pl_sign_ext.sv`** *(coordenar com equipe)*

---

### Thales — SLTU, SRLI, SRAI

**`pl_alu.sv`**
- Adicionar operação SLTU (`$unsigned(SrcA) < $unsigned(SrcB)`)
- SRLI reutiliza SRL
- SRAI reutiliza SRA

**`pl_alu_ctrl.sv`**
- R-type: `funct3=011` → SLTU
- I-type (`ALUOp=11`): `funct3=101`, `funct7[5]=0` → SRLI
- I-type (`ALUOp=11`): `funct3=101`, `funct7[5]=1` → SRAI

**`pl_control.sv`** *(coordenar com equipe)*  
**`pl_sign_ext.sv`** *(coordenar com equipe)*

---

## Arquivos compartilhados

`pl_control.sv` e `pl_sign_ext.sv` precisam da **mesma modificação** nas 4 pessoas. Para evitar conflito no git, uma única pessoa deve fazer essa alteração e os demais fazem rebase em cima.

### Modificação em `pl_control.sv`

```systemverilog
localparam I_TYPE = 7'b0010011;

I_TYPE: begin
    ALUSrc   = 1'b1;
    RegWrite = 1'b1;
    ALUOp    = 2'b11;
end
```

### Modificação em `pl_sign_ext.sv`

```systemverilog
localparam I_TYPE = 7'b0010011;

I_TYPE: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
```

---

## Consequências

- Cada integrante trabalha principalmente em `pl_alu.sv` e `pl_alu_ctrl.sv` — arquivos com baixo risco de conflito entre as pessoas
- `pl_control.sv` e `pl_sign_ext.sv` devem ser alterados por uma única pessoa e commitados antes dos demais iniciarem
- Instruções que reusam operações já existentes na ALU não precisam de nova entrada no `case` — apenas o `pl_alu_ctrl.sv` precisa ser atualizado para mapear o novo `funct3` para o código de operação existente
