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
oac-project/
├── project/
│   ├── src/                    # Arquivos SystemVerilog do processador
│   │   ├── pl_pipe_pkg.sv      # Package com structs dos registradores de pipeline
│   │   ├── pl_alu.sv           # Unidade Lógica e Aritmética
│   │   ├── pl_alu_ctrl.sv      # Decodificador de operação da ALU
│   │   ├── pl_control.sv       # Unidade de controle principal
│   │   ├── pl_datapath.sv      # Datapath completo
│   │   ├── pl_regfile.sv       # Banco de registradores (32x32)
│   │   ├── pl_sign_ext.sv      # Extensão de sinal para imediatos
│   │   ├── pl_hazard.sv        # Detecção de load-use hazards
│   │   ├── pl_forward.sv       # Forwarding de dados
│   │   ├── pl_imem.sv          # Memória de instruções
│   │   ├── pl_dmem.sv          # Memória de dados (com acesso parcial)
│   │   ├── pl_mmio.sv          # Mapeamento de periféricos em memória
│   │   ├── pl_cpu.sv           # CPU (datapath + controle)
│   │   ├── pl_top.sv           # Top-level com PLL
│   │   ├── pl_top_no_pll.sv    # Top-level sem PLL (simulação)
│   │   └── pl_cpu_tb.sv        # Testbench
│   ├── assembler/
│   │   ├── assembler.py        # Assembler RV32I em Python
│   │   ├── etapa01_test.asm    # Programa de teste — Etapa 01
│   │   ├── hello_e2.asm        # Programa de teste — Etapa 02
│   │   ├── program.hex         # Hex de instruções (Etapa 01)
│   │   ├── program_e2.hex      # Hex de instruções (Etapa 02)
│   │   └── data.hex            # Hex de dados iniciais
│   └── modelsim/
│       ├── golden.txt          # Saída esperada — Etapa 01
│       ├── golden_e2.txt       # Saída esperada — Etapa 02
│       ├── sim_e2.do           # Script ModelSim — Etapa 02
│       └── run_e2.ps1          # Script PowerShell para simular Etapa 02
├── docs/
│   ├── report.md               # Relatório do projeto
│   ├── adrs/                   # Architecture Decision Records
│   │   ├── ADR-001-divisao-etapa01.md
│   │   └── ADR-002-divisao-etapa02.md
│   ├── tests/                  # Documentação das simulações
│   │   ├── teste-etapa1.md
│   │   └── teste-etapa2.md
│   └── utils/
│       └── general-structure.png
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

## 📄 Documentação

| Documento | Link |
|-----------|------|
| Relatório do Projeto | [docs/report.md](docs/report.md) |
| ADR-001 — Divisão Etapa 01 | [docs/adrs/ADR-001-divisao-etapa01.md](docs/adrs/ADR-001-divisao-etapa01.md) |
| ADR-002 — Divisão Etapa 02 | [docs/adrs/ADR-002-divisao-etapa02.md](docs/adrs/ADR-002-divisao-etapa02.md) |
| Teste de Simulação — Etapa 01 | [docs/tests/teste-etapa1.md](docs/tests/teste-etapa1.md) |
| Teste de Simulação — Etapa 02 | [docs/tests/teste-etapa2.md](docs/tests/teste-etapa2.md) |

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
| João Gustavo | jggp@cin.ufpe.br |
| Thales Afonso | tadg@cin.ufpe.br |

---

## 🏫 Contexto Acadêmico

| Campo         | Informação                                                |
|-------        |------------                                               |
| Disciplina    | Laboratório de Organização e Arquitetura de Computadores  |
| Código        | CIN0012                                                   |
| Instituição   | Centro de Informática – UFPE (CIn)                        |
| Professores   | Victor Medeiros e Edna Barros                             |
| Linguagem     | SystemVerilog                                             |
| Arquitetura   | RISC-V RV32I                                              |
| Ano           | 2026                                                      |
