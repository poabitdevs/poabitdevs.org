#!/usr/bin/env bash
set -euo pipefail

# Consulta o estado atual de um PR via API (nunca confia em payload de
# evento, que pode estar obsoleto no momento em que o chamador realmente
# age). Uso:
#   pr-state.sh <número-do-pr> [head-sha-esperado]
#
# Imprime exatamente um destes, em stdout:
#   closed      - PR não está mais aberto
#   superseded  - aberto, mas o head.sha atual não bate com o esperado
#                 (só possível quando head-sha-esperado é passado)
#   open        - aberto, e (se head-sha-esperado foi passado) bate

PR_NUMBER="${1:?número do PR obrigatório}"
EXPECTED_SHA="${2:-}"

: "${GITHUB_TOKEN:?GITHUB_TOKEN obrigatório}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY obrigatório}"

pr="$(gh api "repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}")"
state="$(echo "$pr" | jq -r .state)"
current_sha="$(echo "$pr" | jq -r .head.sha)"

if [ "$state" != "open" ]; then
  echo "closed"
elif [ -n "$EXPECTED_SHA" ] && [ "$current_sha" != "$EXPECTED_SHA" ]; then
  echo "superseded"
else
  echo "open"
fi
