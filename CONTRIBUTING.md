# Contribuindo para o RV32I Pipeline

Obrigado por querer contribuir! Siga as diretrizes abaixo para manter o projeto organizado.

## Fluxo de trabalho

1. Faça um fork do repositório
2. Crie uma branch a partir de `main`:
   ```bash
   git checkout -b feature/minha-contribuicao
   ```
3. Faça as alterações e commite seguindo o padrão de mensagens abaixo
4. Abra um Pull Request descrevendo o que foi feito

## Padrão de commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>: <descrição curta>
```

Tipos aceitos:

| Tipo       | Uso                                          |
|------------|----------------------------------------------|
| `feat`     | Nova instrução ou funcionalidade             |
| `fix`      | Correção de bug no hardware/testbench        |
| `test`     | Adição ou ajuste de testbenches              |
| `docs`     | Alterações em documentação ou ADRs          |
| `refactor` | Refatoração sem mudança de comportamento     |
| `chore`    | Tarefas de manutenção gerais                 |

Exemplos:
```
feat: add instrução SRA no estágio EX
fix: corrigir forwarding para instrução LW seguida de ADD
docs: atualizar ADR-001 com decisão de pipeline de 5 estágios
```

## Estrutura do projeto

Ao adicionar ou modificar arquivos, respeite a estrutura existente:

- `project/src/` — módulos SystemVerilog
- `project/tb/` — testbenches
- `project/programs/` — programas Assembly de teste
- `docs/adrs/` — Architecture Decision Records (ADRs)

## Adicionando novas instruções

1. Identifique o formato da instrução (R, I, S, B, U, J)
2. Modifique os módulos afetados (`alu.sv`, `control.sv`, `imm_gen.sv`, etc.)
3. Atualize ou crie um testbench que valide a instrução
4. Documente a decisão de implementação em um ADR se necessário

## Reportando problemas

Abra uma issue descrevendo:
- O comportamento esperado
- O comportamento observado
- O ambiente de simulação utilizado (ModelSim, Questa, Verilator, etc.)

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a [MIT License](LICENSE).
