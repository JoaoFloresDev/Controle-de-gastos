# ASO Pipeline — My Expenses: Personal Finances

App ID: `6502218501`
Bundle ID: `com.gambit.meusgastos`
Primary locale: `pt-BR`
Baseline at init: 1.5 downloads/dia
Created: 2026-05-23

Estrutura e workflow: ver `~/Documents/GambitStudio/aso-pipeline-template/README.md`.
Aprendizados cross-app: ver `~/Documents/GambitStudio/aso_cross_project_learnings.md` ANTES de começar iter-01.

## Quick start

```bash
# 1) Sync current/ from ASC live state
./scripts/verify_current.sh

# 2) Start first iteration
./scripts/new_iteration.sh text pt-BR keywords

# 3) Research → write proposed/ → validate → deploy
./scripts/validate_proposed.sh iterations/<iter_id>
./scripts/deploy.sh iterations/<iter_id>
```
