# Prints da App Store — macOS

Pipeline de screenshots do My Expenses para Mac. Tudo roda sem injetar clique
ou tecla na máquina: o app percorre as abas sozinho em modo de captura.

## Uso

```sh
# 1. dados de demonstração no container do app (e desliga o RatingGate)
python3 seed_demo.py pt          # ou: en

# 2. compila o Debug (o modo de captura vive atrás de kDebugMode)
flutter build macos --debug

# 3. fotografa as 5 abas — a janela abre em 1440x900 = 2880x1800 @2x,
#    exatamente o tamanho máximo de screenshot de Mac da App Store
MG_SHOT_INTERVAL=6 ./capture.sh pt /tmp/shots_pt \
  "../../build/macos/Build/Products/Debug/My expenses.app"

# 4. compõe cada print (fundo de marca + headline verb-split + breakout)
swift render_print.swift --window /tmp/shots_pt/raw_02.png --out out/01.png \
  --first "Registre" --rest "um gasto em segundos" --language pt-BR \
  --breakout 545,278,1055,205 --breakout-scale 2.72

# 5. sobe pra uma versão EDITÁVEL e confere por checksum
python3 upload_prints.py <appStoreVersionId> pt-BR=out_pt en-US=out_en
```

## O que cuidar

- **Screenshot de versão publicada é imutável** (LEARNINGS #73): criar a versão
  nova ANTES de renderizar, senão o upload falha no fim do trabalho.
- A versão nova herda os prints antigos clonados dentro dos sets; o
  `upload_prints.py` reconcilia por `sourceFileChecksum` em vez de por nome.
- Só `pt-BR` e `en-US` têm set próprio no Mac; os outros 11 idiomas herdam do
  primário.
- As telas escolhidas são as 5 abas, nesta ordem: Adicionar, Gráficos,
  Orçamento, Transações, Ajustes (as três primeiras aparecem na lista de
  resultados da busca, então carregam as features principais).
- O `capture.sh` fotografa a cada 0,6 s e as abas trocam a cada
  `MG_SHOT_INTERVAL` segundos — escolha o frame do meio de cada bloco, porque o
  primeiro pega a transição da barra lateral pela metade.
