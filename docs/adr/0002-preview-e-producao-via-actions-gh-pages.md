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
- **Pré-requisito nos templates:** os templates do site hoje usam
  `site.github.url` (`_includes/header.html`, `_includes/head.html`) e
  caminhos absolutos de raiz — `/events.html` em `index.html`, `/feed.xml`
  em `_includes/footer.html`, `/favicon.ico` em `_includes/head.html` —,
  nenhum usa `site.baseurl`. Um preview publicado num subcaminho com esses
  templates navegaria de volta para produção. Antes do workflow de preview
  funcionar, os templates precisam trocar essas referências por
  `{{ site.baseurl }}`/o filtro `relative_url` do Jekyll.
- **No PR** (aberto, sincronizado ou reaberto, só de branches do próprio
  repositório — ver "Fora de escopo" abaixo): uma Action builda o Jekyll
  com `bundle exec jekyll build --baseurl /pr-preview/pr-<número>` e
  publica o `_site` resultante em `gh-pages:pr-preview/pr-<número>/`,
  registrando o SHA buildado (por exemplo, num arquivo `.build-sha` dentro
  do próprio diretório do preview) e comentando o link automaticamente no
  PR.
- **No fechamento do PR:**
  - Se mergeado: em vez de mover o diretório do preview como se fosse o
    artefato final, a Action builda a produção **de novo**, com
    `bundle exec jekyll build` (sem `baseurl`), a partir do commit de merge
    resultante, e publica esse resultado na raiz de `gh-pages`. Isso
    abandona a garantia literal de "zero rebuild" — necessária porque o
    Jekyll grava o `baseurl` no HTML no momento do build, então o mesmo
    artefato do preview não pode ser servido correto em dois caminhos
    diferentes (subcaminho e raiz). A garantia que sobra é mais modesta,
    mas ainda real: mesmo commit, mesmo toolchain/`Gemfile.lock`, dois
    builds determinísticos — diferindo só nos caminhos dependentes de
    `baseurl` —, não dois pipelines de build diferentes como no ADR 0001.
  - Antes de publicar, a Action confere se o SHA-base do PR no momento do
    build ainda é o HEAD atual de `gh-pages`'s fonte (`master`); se
    `master` avançou entre o último build do preview e o merge (outro PR
    foi mergeado nesse meio-tempo), o build de produção usa o commit de
    merge atual — que já contém as duas mudanças — então esse cenário fica
    coberto pelo próprio rebuild, não por uma promoção "cega" do artefato
    antigo. Como defesa em profundidade, a branch `master` passa a exigir
    "Require branches to be up to date before merging".
  - Se fechado sem merge: o subcaminho `pr-preview/pr-<número>/` é
    simplesmente removido.

**Fora de escopo nesta decisão:** preview para PRs vindos de forks. No
evento `pull_request`, o `GITHUB_TOKEN` de um PR de fork é somente leitura
por restrição da própria plataforma GitHub — não escreveria em `gh-pages`
nem comentaria no PR. Resolver isso exigiria separar build (sem
privilégios, disparado por `pull_request`) de publicação (privilegiada,
disparada por `workflow_run` depois do build, sem nunca rodar código do
fork com token de escrita — o padrão seguro documentado pelo GitHub para
esse cenário). Como hoje o projeto não recebe contribuições via fork, essa
separação fica de fora por ora; revisitar se isso mudar.

Alternativas descartadas: provedor externo de staging (bloqueado por
governança da organização, ver Contexto — decisão original registrada no
[ADR 0001](0001-ambiente-homologacao-ad-hoc.md)); repositório privado
pessoal para homologação (fragmenta a governança do projeto); mover o
diretório do preview para a raiz sem rebuild (inviável — o `baseurl`
gravado no HTML no momento do build torna o mesmo artefato incorreto em
qualquer um dos dois caminhos).

## Consequências

**Positivas:**

- Não depende de nenhum GitHub App externo nem de aprovação de Owner da
  organização — só de permissões de admin do repositório, já disponíveis.
- O artefato publicado em produção sai do mesmo commit, mesmo toolchain e
  mesmo `Gemfile.lock` que o artefato homologado no PR — reduz bem a
  divergência de ambiente que motivou a issue #32, mesmo sem ser um
  artefato literalmente idêntico byte a byte (ver "Decisão").
- Continua usando só a infraestrutura já em uso (GitHub Actions/Pages), sem
  provedor externo novo.

**Negativas / trade-offs:**

- Mexe no pipeline de produção (a fonte do GitHub Pages deixa de ser o
  build legacy a partir de `master`) — o risco que o ADR 0001 tinha
  deliberadamente adiado para depois é assumido agora.
- Não elimina totalmente a divergência hml/prd: produção é buildada de novo
  no merge (com `baseurl` diferente do preview), não é uma promoção sem
  rebuild — objetivo original da issue #32 só parcialmente alcançado.
- Exige corrigir os templates do site (`site.github.url` e caminhos
  absolutos de raiz) para usar `site.baseurl`/`relative_url` antes de
  qualquer preview funcionar corretamente.
- O workflow de Actions fica mais complexo do que uma integração nativa de
  provedor externo: precisa tratar PR aberto/sincronizado, fechado com
  merge (com checagem de SHA-base) e fechado sem merge, além de operações
  de escrita diretamente na branch `gh-pages`.
- Previews não são suportados para PRs de forks nesta etapa (ver "Fora de
  escopo" acima) — só contribuições via branch do próprio repositório.
- Os previews continuam publicamente acessíveis (GitHub Pages não oferece
  PRs privados/protegidos por padrão), então nenhum conteúdo sensível deve
  passar por esse fluxo antes de estar pronto para publicação.

## Próximos passos

- Corrigir os templates (`_includes/header.html`, `_includes/head.html`,
  `index.html`, `_includes/footer.html`) para usar `site.baseurl`/
  `relative_url` em vez de `site.github.url`/caminhos absolutos.
- Implementar o workflow de Actions: build + publicação do preview com
  `baseurl`, comentário automático no PR, rebuild + publicação de produção
  no merge (com checagem de SHA-base), limpeza no fechamento sem merge.
- Habilitar "Require branches to be up to date before merging" na
  `master`.
- Migrar a fonte do GitHub Pages para a branch `gh-pages` (com
  `.nojekyll`).
- Remover `netlify.toml` (já feito) e reaproveitar `.ruby-version` para
  pinar a versão do Ruby no workflow de Actions.

Essas etapas ficam para os próximos PRs da issue
[#29](https://github.com/poabitdevs/poabitdevs.org/issues/29), que passa a
cobrir também o que estava reservado para a issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).
