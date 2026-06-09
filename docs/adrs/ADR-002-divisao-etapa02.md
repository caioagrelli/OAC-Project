# ADR-002 — Divisão de Implementação da Etapa 02

**Data:** 2026-06-09  
**Status:** Aceito  
**Contexto:** Etapa 02 do projeto RV32I Pipeline — CIN0012/UFPE

---

## Contexto

A Etapa 02 exige a implementação de 15 novas instruções:

- 4 loads: `LB`, `LH`, `LBU`, `LHU`
- 2 stores: `SB`, `SH`
- 5 branches: `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- 2 saltos: `JAL`, `JALR`
- 2 U-type: `LUI`, `AUIPC`

---

## Divisão

| Pessoa | Instruções | Arquivos principais |
|--------|-----------|---------------------|
| **Thales** | JAL, JALR, LUI, AUIPC | `pl_pipe_pkg.sv`, `pl_sign_ext.sv`, `pl_control.sv`, `pl_datapath.sv` |
| **João** | BNE, BLT, BGE, BLTU, BGEU | `pl_datapath.sv` |
| **Caio** | LB, LH, LBU, LHU | `pl_dmem.sv`, `pl_datapath.sv` |
| **Lucas** | SB, SH | `pl_dmem.sv`, `pl_datapath.sv` |

---

## Ordem de execução

### 1. Thales — infraestrutura + JAL, JALR, LUI, AUIPC

**Deve ser feito primeiro. Os outros rebaseiam em cima.**

Motivo: JAL/JALR/LUI/AUIPC exigem novos campos nos registradores de pipeline
(`pl_pipe_pkg.sv`), novos formatos de imediato (`pl_sign_ext.sv`) e novos caminhos
no datapath — mudanças estruturais que afetam todos os outros.

### 2. João — BNE, BLT, BGE, BLTU, BGEU

Rebasear sobre Thales.

Única mudança: generalizar a condição de branch em `pl_datapath.sv`
(trocar `zero` hardcoded por lógica baseada em `funct3`). Cobre todos os 5 branches
de uma vez, inclusive conserta BEQ para não depender mais do sinal `zero` da ALU.

### 3. Caio e Lucas — loads e stores parciais

Rebasear sobre João.

Caio e Lucas modificam `pl_dmem.sv` em lados diferentes (leitura × escrita),
com baixo risco de conflito. Podem trabalhar em paralelo e abrir um PR conjunto
ou sequencial — combinar entre si.

---

## Arquivos por pessoa (resumo)

| Arquivo | Quem mexe |
|---------|-----------|
| `pl_pipe_pkg.sv` | Thales |
| `pl_sign_ext.sv` | Thales |
| `pl_control.sv` | Thales |
| `pl_datapath.sv` | Thales (estrutura) → João (branch) → Caio/Lucas (dmem interface) |
| `pl_dmem.sv` | Caio (leitura parcial) + Lucas (escrita parcial) |
| `pl_alu.sv` | nenhum — sem alterações |
| `pl_alu_ctrl.sv` | nenhum — sem alterações |
