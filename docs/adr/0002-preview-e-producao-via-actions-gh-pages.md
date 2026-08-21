# 0002. Preview e produção via GitHub Actions e branch `gh-pages`

Substitui o [ADR 0001](0001-ambiente-homologacao-ad-hoc.md) e funde o escopo
das issues [#29](https://github.com/poabitdevs/poabitdevs.org/issues/29) e
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).

## Contexto

O [ADR 0001](0001-ambiente-homologacao-ad-hoc.md) optou por um provedor
externo de staging (Netlify) para os previews por PR, evitando mexer na
configuração de Pages de produção. Na tentativa de conectar o repositório ao
Netlify, esbarramos em um bloqueio de governança: a organização
`poabitdevs` não lista membros públicos, e a página de instalações da
organização (`github.com/organizations/poabitdevs/settings/installations`)
retorna 404 para quem tentou o setup — apesar de ser admin do repositório,
não há confirmação de quem é Owner da organização, e instalar um GitHub App
num repositório de organização exige aprovação de um Owner. Esse bloqueio
não é específico do Netlify: Vercel e Cloudflare Pages usam o mesmo modelo
de autenticação via GitHub App, então trocar de provedor não resolveria.

Duas alternativas foram cogitadas para contornar isso: usar um repositório
privado pessoal só para homologação (rejeitada — fragmenta a governança de
um projeto comunitário para uma conta pessoal, e exigiria automação extra
para espelhar PRs do repositório oficial) e reavaliar o desenho original
considerado no ADR 0001 antes da escolha do provedor externo: publicar
previews em subcaminhos de uma branch `gh-pages` do próprio GitHub Pages.
Esse desenho tinha sido descartado por um motivo diferente — o GitHub Pages
serve apenas uma fonte de deploy por repositório, e a fonte configurada era
`master` (build legacy) — não por um problema de permissão. Ao revisitá-lo,
percebemos que ele resolve exatamente o bloqueio atual: uma GitHub Action
roda com o `GITHUB_TOKEN` do próprio repositório, sem exigir instalação de
App nenhum — só permissão de admin do repositório, que já temos.

## Decisão

Buildar e publicar tanto os previews quanto a produção através de GitHub
Actions, usando a branch `gh-pages` como única fonte do GitHub Pages:

- **Fonte do Pages:** trocar de "legacy build a partir de `master`" para a
  branch `gh-pages`, path `/`, com um arquivo `.nojekyll` na raiz — o
  GitHub passa a servir os arquivos estáticos como estão, sem reconstruir
  nada do lado dele.
- **No PR** (aberto, sincronizado ou reaberto contra `master`): uma Action
  builda o Jekyll uma única vez (`bundle exec jekyll build`) e publica o
  `_site` resultante em `gh-pages:pr-preview/pr-<número>/`, comentando o
  link de preview automaticamente no PR.
- **No fechamento do PR:**
  - Se mergeado: o conteúdo já buildado em `pr-preview/pr-<número>/`
    (o mesmo artefato homologado, sem rebuild) é movido para a raiz de
    `gh-pages`, substituindo a produção.
  - Se fechado sem merge: o subcaminho `pr-preview/pr-<número>/` é
    simplesmente removido.

Isso resolve, na mesma decisão, o objetivo original da issue #32: o
artefato publicado em produção é binariamente igual ao artefato homologado
no PR, porque é literalmente o mesmo diretório, só promovido de lugar — sem
nenhum build adicional acontecendo após o merge.

Alternativas descartadas: provedor externo de staging (bloqueado por
governança da organização, ver Contexto — decisão original registrada no
[ADR 0001](0001-ambiente-homologacao-ad-hoc.md)); repositório privado
pessoal para homologação (fragmenta a governança do projeto).

## Consequências

**Positivas:**

- Não depende de nenhum GitHub App externo nem de aprovação de Owner da
  organização — só de permissões de admin do repositório, já disponíveis.
- O artefato publicado em produção é o mesmo artefato homologado no PR, sem
  rebuild adicional — elimina a divergência de ambiente entre hml e prd que
  motivou a issue #32.
- Continua usando só a infraestrutura já em uso (GitHub Actions/Pages), sem
  provedor externo novo.

**Negativas / trade-offs:**

- Mexe no pipeline de produção (a fonte do GitHub Pages deixa de ser o
  build legacy a partir de `master`) — o risco que o ADR 0001 tinha
  deliberadamente adiado para depois é assumido agora.
- O workflow de Actions fica mais complexo do que uma integração nativa de
  provedor externo: precisa tratar corretamente PR aberto/sincronizado,
  fechado com merge e fechado sem merge, além de operações de escrita
  diretamente na branch `gh-pages` (risco de condição de corrida se dois
  PRs forem mergeados em sequência muito rápida — a considerar na
  implementação).
- Os previews continuam publicamente acessíveis (GitHub Pages não oferece
  PRs privados/protegidos por padrão), então nenhum conteúdo sensível deve
  passar por esse fluxo antes de estar pronto para publicação.

## Próximos passos

Implementação do workflow de Actions (build, publicação do preview,
comentário automático no PR, promoção/limpeza no fechamento do PR) e
migração da fonte do GitHub Pages para `gh-pages` ficam para os próximos
PRs da issue [#29](https://github.com/poabitdevs/poabitdevs.org/issues/29),
que passa a cobrir também o que estava reservado para a issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32). Os arquivos
`netlify.toml` e `.ruby-version` (do provedor externo descartado) devem ser
removidos ou adaptados na implementação — `.ruby-version` continua útil
para pinar a versão do Ruby usada no workflow de Actions.
