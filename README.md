# ⚙️ RV32I Pipeline — Processador RISC-V com Pipeline

<div align="center">

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-HDL-blue?style=for-the-badge)
![RISC-V](https://img.shields.io/badge/RISC--V-RV32I-blueviolet?style=for-the-badge)
![UFPE](https://img.shields.io/badge/UFPE-CIn-red?style=for-the-badge)
![Status](https://img.shields.io/badge/status-acadêmico-lightgrey?style=for-the-badge)
![Pipeline](https://img.shields.io/badge/pipeline-5%20estágios-orange?style=for-the-badge)

**Projeto acadêmico desenvolvido para a disciplina de Laboratório de Organização e Arquitetura de Computadores (CIN0012) — CIn/UFPE (2026)**

> Implementação em SystemVerilog de um processador RISC-V RV32I com pipeline de 5 estágios, baseado no livro *Computer Organization and Design RISC-V* de Patterson e Hennessy (2ª edição).

</div>

---

## 📌 Sobre o Projeto

Este repositório contém a implementação de um **processador RISC-V RV32I com pipeline de 5 estágios** em SystemVerilog. O projeto parte de um código-base público disponível no GitHub e expande o suporte a instruções progressivamente ao longo de duas etapas, culminando em uma demonstração em hardware (FPGA).

O processador implementa a arquitetura **RISC** (Reduced Instruction Set Computer), utilizando **registradores e endereçamento de 32 bits** e o conjunto básico de instruções inteiras (I). O pipeline de 5 estágios inclui suporte a **forwarding** e **detecção de hazards**, conforme o diagrama clássico de Patterson e Hennessy.

**Código-base:** [`https://gitlab.com/jualabs-teaching/oac/rv32i_pipelined_base_project.git`](https://gitlab.com/jualabs-teaching/oac/rv32i_pipelined_base_project.git)

---

## 🗂️ Estrutura do Repositório

```
rv32i-pipeline/
├── src/
│   ├── datapath/
│   │   ├── alu.sv              # Unidade Lógica e Aritmética
│   │   ├── regfile.sv          # Banco de registradores
│   │   ├── imm_gen.sv          # Gerador de imediatos
│   │   └── datapath.sv         # Datapath completo
│   ├── control/
│   │   ├── control.sv          # Unidade de controle principal
│   │   ├── hazard_unit.sv      # Detecção e tratamento de hazards
│   │   └── forwarding_unit.sv  # Forwarding de dados
│   ├── memory/
│   │   ├── instr_mem.sv        # Memória de instruções
│   │   └── data_mem.sv         # Memória de dados
│   ├── pipeline_regs/
│   │   ├── if_id.sv            # Registrador de pipeline IF/ID
│   │   ├── id_ex.sv            # Registrador de pipeline ID/EX
│   │   ├── ex_mem.sv           # Registrador de pipeline EX/MEM
│   │   └── mem_wb.sv           # Registrador de pipeline MEM/WB
│   └── top.sv                  # Módulo top-level
├── tb/
│   ├── tb_etapa1.sv            # Testbench — Etapa 01
│   └── tb_etapa2.sv            # Testbench — Etapa 02
├── programs/
│   ├── etapa1_test.s           # Programa de teste para Etapa 01
│   └── etapa2_test.s           # Programa de teste para Etapa 02
└── README.md
```

---

## 🏗️ Arquitetura do Pipeline

O processador implementa um pipeline clássico de **5 estágios**:

| Estágio | Sigla | Descrição |
|---------|-------|-----------|
| Instruction Fetch | **IF** | Busca a instrução na memória de instruções usando o PC |
| Instruction Decode | **ID** | Decodifica a instrução, lê registradores e gera o imediato |
| Execute | **EX** | Executa operação na ALU ou calcula endereço de memória |
| Memory Access | **MEM** | Acessa a memória de dados (load/store) |
| Write Back | **WB** | Escreve o resultado no banco de registradores |

### Unidades de Controle Avançadas

- **Forwarding Unit** — Resolve hazards de dados encaminhando resultados de estágios anteriores diretamente para a ALU, evitando stalls desnecessários.
- **Hazard Detection Unit** — Detecta dependências de dados (load-use hazards) e insere bolhas no pipeline quando necessário.
- **Flush de estágios** — Suporte a flush de IF, ID e EX para tratamento de desvios tomados.

---

## 📋 Instruções Implementadas

### Etapa 01 — Aritmética, Lógica e Deslocamentos (R-type e I-type)
**Entrega:** 02/06/2026

| Formato | Instruções |
|---------|-----------|
| R-type  | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU` |
| I-type  | `ADDI`, `ANDI`, `ORI`, `SLTI`, `SLLI`, `SRLI`, `SRAI` |

### Etapa 02 — Memória, Desvios e Imediato Superior
**Entrega:** 09/06/2026

| Formato | Instruções |
|---------|-----------|
| I-type (load) | `LB`, `LH`, `LW`, `LBU`, `LHU` |
| S-type (store) | `SB`, `SH`, `SW` |
| B-type | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| J-type | `JAL`, `JALR` |
| U-type | `LUI`, `AUIPC` |

---

## 📊 Avaliação

| Componente | Peso | Tipo |
|------------|------|------|
| Implementação + Relatório | 70% | Nota da Equipe |
| Apresentação oral (16/06/2026) | 20% | Nota Individual |
| Participação nos acompanhamentos | 10% | Nota Individual |

### Apresentação — 16/06/2026

A apresentação deverá cobrir a **explicação da implementação em etapas**, incluindo:

- Aritmética, lógica e deslocamentos (R-type)
- Aritmética, lógica e deslocamentos com imediatos (I-type)
- Acesso à memória — loads (I-type) e stores (S-type)
- Desvios condicionais (B-type)
- Jumps (J-type)
- Imediato superior (U-type)
- **Demonstração no FPGA**

---

## 🗓️ Cronograma dos Acompanhamentos

| Data | Conteúdo |
|------|----------|
| 02/06/2026 | Acompanhamento Etapa 01 — R-type e I-type (aritmética, lógica, deslocamentos) |
| 09/06/2026 | Acompanhamento Etapa 02 — Loads, Stores, Desvios, Jumps e U-type |
| 16/06/2026 | Apresentação final do projeto |

---

## 🔧 Como Executar

### Simulação

1. Clone o repositório base:
```bash
git clone https://gitlab.com/jualabs-teaching/oac/rv32i_pipelined_base_project.git
```

2. Substitua/adicione os arquivos `.sv` com a implementação do grupo.

3. Execute a simulação com sua ferramenta de preferência (ModelSim, Questa, Verilator):
```bash
# Exemplo com Verilator
verilator --cc top.sv --exe tb/tb_etapa1.sv --build
./obj_dir/Vtop
```

### Síntese no FPGA

1. Importe o projeto na ferramenta de síntese (Quartus, Vivado, etc.)
2. Configure os pinos conforme a placa disponível no laboratório
3. Compile e faça o upload para a FPGA
4. Execute a demonstração ao vivo na apresentação

---

## 📖 Referências

- Patterson, D. A.; Hennessy, J. L. *Computer Organization and Design RISC-V Edition*, 2ª edição.
- Especificação ISA RISC-V: [riscv.org](https://riscv.org/technical/specifications/)
- Repositório base: [gitlab.com/jualabs-teaching/oac/rv32i_pipelined_base_project](https://gitlab.com/jualabs-teaching/oac/rv32i_pipelined_base_project.git)

---

## 👥 Integrantes

| Nome | E-mail |
|------|--------|
| Caio Agrelli | caarr@cin.ufpe.br |
| Lucas David | ldlf@cin.ufpe.br |

---

## 🏫 Contexto Acadêmico

| Campo | Informação |
|-------|------------|
| Disciplina | Laboratório de Organização e Arquitetura de Computadores |
| Código | CIN0012 |
| Instituição | Centro de Informática – UFPE (CIn) |
| Professores | Victor Medeiros e Edna Barros |
| Linguagem | SystemVerilog |
| Arquitetura | RISC-V RV32I |
| Ano | 2026 |