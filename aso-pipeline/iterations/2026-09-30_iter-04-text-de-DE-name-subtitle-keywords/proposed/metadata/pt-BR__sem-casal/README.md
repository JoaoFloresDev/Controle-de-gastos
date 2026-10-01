# pt-BR sem `casal` — variante B, composta e validada, NÃO aplicada

Este diretório **não é alvo de deploy**. É o pt-BR honesto: o campo sem o cluster
`casal` / `compartilhados`. Foi composto, passou pelo `protection_map` token a token
e pelo `validate_proposed.py` (0 blockers). Não foi aplicado por decisão do João.

| campo | variante B (aqui, NÃO aplicada) | variante A (aplicada, `../pt-BR/`) |
|---|---|---|
| name | `Meus Gastos: Contas e Despesas` (30) | `Meus Gastos: Contas e Despesas` (30) |
| subtitle | `Finanças pessoais e categorias` (30) | `Finanças do casal e pessoais` (28) |
| keywords | `diario,mensais,extrato,fixas,resumo,orcamento,economias,controle,recorrentes,offline,excel,grafico` (98) | `diario,mensais,categorias,extrato,fixas,resumo,orcamento,economias,compartilhados,planilha,offline` (98) |

## Por que B existe

O app **não tem casal, split, rateio nem ledger compartilhado**: `CardModel` não tem
campo de pessoa e todo path do Firestore é `.collection(userId)` (N1/N2). A promessa
vive **inteira no subtitle** — nem a description pt-BR a menciona. Install que chega
por `gastos do casal` ou `planilha compartilhada` espera conta a dois, não acha, e sai.
BR é 37% das instalações (161 de 439 `1*`/90d) e o **único storefront com massa de
avaliação** (18; 21 das 29 storefronts têm zero). É o lugar onde install que não fica
custa mais caro, porque contamina a única base de avaliação que existe.

B troca tráfego por retenção e nota: o campo passa a prometer só o que o produto
entrega, e os 23 chars liberados voltam como `controle` + `recorrentes` (vocabulário de
UI, FIT) e as apostas `excel` / `grafico`.

## Por que B NÃO foi aplicada

**Decisão do João, 2026-10-01** (revisão da decisão que ele mesmo tinha tomado mais cedo
no mesmo dia): `casal` **fica**. Ele quer manter as **40 posições ≤#50** enquanto elas
ainda trazem tráfego — 21 de `casal`, 9 de `compartilhados`, 7 de `do`, 3 de `planilha`.
As 40 são MISMATCH; nenhuma posição FIT ou PARTIAL do pt-BR depende do cluster.

Trade-off aceito conscientemente, por escrito:
- a promessa de casal segue viva no subtitle **sem a feature existir**;
- risco de nota no único locale que tem nota;
- risco de App Review **2.3.1** (metadata que descreve função inexistente).

## Quando reabrir B

Dois gatilhos, qualquer um deles:

1. **A nota do BR virar o gargalo medido** — não "parecer": medido. Hoje o gargalo é
   massa de avaliação (18 ratings). Se a MÉDIA cair e as reviews citarem expectativa de
   conta compartilhada, o custo do cluster passou a ser maior que o tráfego e B entra.
2. **O app ganhar modo casal de verdade** — aí nem A nem B: o subtitle vira promessa
   verdadeira e o cluster deixa de ser MISMATCH. É a saída boa.

Se B for aplicada um dia, aplicar o conjunto **inteiro**: tirar `casal` e manter
`compartilhados` é a pior das três opções — mantém a promessa errada e perde metade das
posições (protection_map, explícito).

## Procedência

Composta no estágio 5 desta iteração. O diretório original foi apagado pelo estágio 5
quando a decisão da manhã de 01/10 era "tirar o cluster"; esta cópia foi reconstituída
no estágio 7 a partir dos arquivos que estavam em `../pt-BR/` imediatamente antes do
revert — ou seja, é o texto original de B, não uma reescrita.
