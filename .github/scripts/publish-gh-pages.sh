#!/usr/bin/env bash
set -euo pipefail

# Escreve de forma conflict-safe (fetch/clone + retry no push, nunca
# force-push) num subcaminho da branch gh-pages, preservando o resto da
# árvore intacto — usado por preview, limpeza de preview e produção.
#
# Uso:
#   publish-gh-pages.sh <subpath> <source-dir> <commit-message> [cname-file]
#   publish-gh-pages.sh <subpath> --delete <commit-message>
#
# subpath vazio ("") = raiz (produção, preserva pr-preview/ intacto);
# qualquer outro valor = subcaminho isolado (ex.: "pr-preview/pr-42").

# Sem ":" nos testes abaixo: subpath pode ser string vazia (raiz) sem
# disparar o erro — só dispara se o argumento não for passado (unset).
SUBPATH="${1?subpath obrigatório (vazio para raiz)}"
SOURCE="${2?source-dir ou --delete obrigatório}"
MESSAGE="${3?mensagem de commit obrigatória}"
CNAME_FILE="${4:-}"

: "${GITHUB_TOKEN:?GITHUB_TOKEN obrigatório}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY obrigatório}"

if [ "$SOURCE" = "--delete" ] && [ -z "$SUBPATH" ]; then
  echo "Recusando: --delete com subpath vazio apagaria a raiz inteira de gh-pages." >&2
  exit 1
fi

REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
MAX_ATTEMPTS=10
WORKTREE="$(mktemp -d)"
trap 'rm -rf "$WORKTREE"' EXIT

git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

apply_change() {
  if [ "$SOURCE" = "--delete" ]; then
    rm -rf "$WORKTREE${SUBPATH:+/$SUBPATH}"
  elif [ -z "$SUBPATH" ]; then
    # Raiz (produção): substitui tudo, exceto .git/ e pr-preview/ (previews
    # abertos não são um artefato desta publicação).
    find "$WORKTREE" -mindepth 1 -maxdepth 1 \
      ! -name '.git' ! -name 'pr-preview' -exec rm -rf {} +
    cp -a "$SOURCE"/. "$WORKTREE"/
  else
    rm -rf "$WORKTREE/$SUBPATH"
    mkdir -p "$WORKTREE/$SUBPATH"
    cp -a "$SOURCE"/. "$WORKTREE/$SUBPATH"/
  fi

  touch "$WORKTREE/.nojekyll"
  if [ -n "$CNAME_FILE" ]; then
    cp "$CNAME_FILE" "$WORKTREE/CNAME"
  fi
}

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  rm -rf "$WORKTREE"
  mkdir -p "$WORKTREE"

  if git ls-remote --exit-code --heads "$REPO_URL" gh-pages >/dev/null 2>&1; then
    git clone -q --depth 1 --branch gh-pages "$REPO_URL" "$WORKTREE"
  else
    git -C "$WORKTREE" init -q -b gh-pages
  fi

  apply_change

  git -C "$WORKTREE" add -A
  if git -C "$WORKTREE" diff --cached --quiet; then
    echo "Nada a publicar: gh-pages já reflete o estado desejado."
    exit 0
  fi

  git -C "$WORKTREE" commit -q -m "$MESSAGE"

  if git -C "$WORKTREE" push "$REPO_URL" HEAD:gh-pages 2>/tmp/publish-gh-pages-push.log; then
    echo "Publicado em gh-pages na tentativa $attempt."
    exit 0
  fi

  echo "Push rejeitado (provável non-fast-forward). Tentativa $attempt/$MAX_ATTEMPTS; refazendo..."
  sed 's#https://x-access-token:[^@]*@#https://***@#' /tmp/publish-gh-pages-push.log >&2 || true
  sleep $(( (RANDOM % 4) + 1 ))
done

echo "Falha ao publicar em gh-pages após $MAX_ATTEMPTS tentativas." >&2
exit 1
