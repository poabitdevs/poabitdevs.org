# 0002. Preview e produção via GitHub Actions e branch `gh-pages`

Substitui o [ADR 0001](0001-ambiente-homologacao-ad-hoc.md) e funde o escopo
das issues [#29](https://github.com/poabitdevs/poabitdevs.org/issues/29) e
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).

## Contexto

O [ADR 0001](0001-ambiente-homologacao-ad-hoc.md) optou por um provedor
externo de staging (Netlify) para os previews por PR, evitando mexer na
configuração de Pages de produção — especificamente, pela integração
nativa via GitHub App desse provedor (a que oferece Deploy Previews e
comentário automático no PR prontos, sem código nosso). Na tentativa de
instalar essa integração, esbarramos em um bloqueio de governança: a
organização `poabitdevs` não lista membros públicos, e a página de
instalações da organização
(`github.com/organizations/poabitdevs/settings/installations`) retorna 404
para quem tentou o setup — apesar de ser admin do repositório, não há
confirmação de quem é Owner da organização, e instalar um GitHub App num
repositório de organização exige aprovação de um Owner. Esse bloqueio não é
específico do Netlify: Vercel e Cloudflare Pages usam o mesmo modelo de
integração nativa via GitHub App, então trocar de provedor não resolveria.

Isso não bloqueia necessariamente um deploy via CLI/API desses mesmos
provedores (por exemplo, `netlify deploy` autenticado por um token salvo
como secret do repositório), chamado de dentro de uma GitHub Action — essa
via não depende de instalar nenhum App na organização. Não avaliamos essa
alternativa a fundo porque a solução que adotamos abaixo (Actions + branch
`gh-pages`) já resolve o problema sem depender de conta, token ou secret
externo nenhum — mas registrando aqui para não parecer que descartamos um
caminho viável por omissão: o custo de mantê-lo seria gerenciar uma conta e
secrets de um provedor externo só para ganhar a conveniência do comentário
automático no PR, que de qualquer forma teríamos que implementar nós
mesmos na nossa própria Action.

Duas outras alternativas foram cogitadas: usar um repositório privado
pessoal só para homologação (rejeitada — fragmenta a governança de um
projeto comunitário para uma conta pessoal, e exigiria automação extra
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
  em `_includes/footer.html`, `/favicon.ico` em `_includes/head.html`,
  `{{ post.url }}` em `index.html` e `events.html` (gerado pelo Jekyll já
  relativo à raiz, sem levar `baseurl` em conta) —, nenhum usa
  `site.baseurl`. Um preview publicado num subcaminho com esses templates
  navegaria de volta para produção. Antes do workflow de preview
  funcionar, os cinco arquivos (`_includes/header.html`,
  `_includes/head.html`, `_includes/footer.html`, `index.html`,
  `events.html`) precisam trocar essas referências pelo filtro
  `relative_url` do Jekyll.
- **Pré-requisito no `_config.yml`:** a chave `baseurl` já está definida lá
  como `https://poabitdevs.com` — um domínio completo (e errado: o CNAME
  real do Pages é `poabitdevs.org`) onde deveria haver só um path relativo
  vazio. Isso está adormecido hoje porque nenhum template usa
  `site.baseurl`/`relative_url`; assim que os templates forem corrigidos,
  esse valor passaria a vazar para qualquer build que não sobrescreva
  `--baseurl` explicitamente — inclusive o de produção. `_config.yml`
  precisa zerar essa chave (`baseurl: ""`) antes da migração dos
  templates.
- **No PR** (aberto, sincronizado ou reaberto, só de branches do próprio
  repositório — ver "Fora de escopo" abaixo): uma Action builda o Jekyll a
  partir de `refs/pull/<número>/merge` (o merge sintético do PR com o
  estado atual de `master`, mantido pelo próprio GitHub) com
  `bundle exec jekyll build --baseurl /pr-preview/pr-<número>`, publica o
  `_site` resultante em `gh-pages:pr-preview/pr-<número>/` e comenta o
  link automaticamente no PR. Buildar a partir desse ref, em vez do HEAD
  isolado da branch do PR, já deixa a árvore de fontes do preview
  equivalente à que a produção vai usar — se `master` avançou entre um
  build e outro, o próximo push ao PR (ou o requisito de "up to date" no
  merge, abaixo) atualiza esse ref antes do merge acontecer de fato.
- **No fechamento do PR:**
  - Se mergeado: em vez de mover o diretório do preview como se fosse o
    artefato final, a Action builda a produção **de novo**, com
    `bundle exec jekyll build` (sem `--baseurl`, contando com o
    `baseurl: ""` corrigido no `_config.yml` — ver pré-requisito acima),
    a partir do commit de merge resultante, e publica esse resultado na
    raiz de `gh-pages`. Isso abandona a garantia literal de "zero rebuild"
    — necessária porque o
    Jekyll grava o `baseurl` no HTML no momento do build, então o mesmo
    artefato do preview não pode ser servido correto em dois caminhos
    diferentes (subcaminho e raiz). A garantia que sobra é mais modesta,
    mas ainda real: **árvore de fontes equivalente** (o commit de merge
    real, criado no momento do merge, tem SHA distinto do que foi
    homologado no preview por definição — não é "o mesmo commit") e mesmo
    toolchain/`Gemfile.lock`, dois builds determinísticos diferindo só nos
    caminhos dependentes de `baseurl` — não dois pipelines de build
    diferentes como no ADR 0001.
  - A branch `master` passa a exigir "Require branches to be up to date
    before merging" **e** o status check do workflow de preview como
    obrigatório para o merge. A primeira regra sozinha não bastaria: ela
    garante que a árvore está fresca, mas não impede o merge enquanto o
    preview daquele estado específico ainda está rodando ou falhou —
    furando a premissa de que nada vai para produção sem ter sido
    homologado antes. As duas regras juntas fecham essa lacuna.
  - A publicação de produção usa seu **próprio** grupo de `concurrency`
    (`gh-pages-production`), separado do grupo usado por preview/limpeza.
    `concurrency` não é uma fila: por grupo, o GitHub Actions mantém no
    máximo uma execução em andamento e uma pendente — uma nova execução
    *substitui* a pendente, não entra atrás dela. Um único grupo
    compartilhado entre produção e preview criaria um risco novo: um
    preview de PR não relacionado poderia cancelar um deploy de produção
    que estava pendente, e esse merge nunca seria publicado. Manter grupos
    separados evita que atividade de preview descarte trabalho de
    produção pendente (preview/limpeza entre si podem se coalescer sem
    problema, já que cada nova execução reflete o estado mais atual do
    seu próprio PR).
  - Mesmo isolado, o grupo de produção ainda pode coalescer dois merges
    muito próximos (o mais antigo, pendente, é substituído pelo mais
    novo). Por isso o job de publicação de produção não confia no SHA que
    o disparou: ele sempre builda e publica o HEAD **atual** de `master`
    no momento em que roda, não o commit do evento que o originou. Assim,
    mesmo que uma execução intermediária seja descartada pela
    coalescência, a que efetivamente rodar por último publica o estado
    mais recente — nenhum merge fica de fora permanentemente.
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
- O artefato publicado em produção sai de uma árvore de fontes equivalente,
  mesmo toolchain e mesmo `Gemfile.lock` que o artefato homologado no PR —
  reduz bem a divergência de ambiente que motivou a issue #32, mesmo sem
  ser um artefato literalmente idêntico byte a byte nem vir do mesmo commit
  (ver "Decisão").
- Continua usando só a infraestrutura já em uso (GitHub Actions/Pages), sem
  provedor externo novo.

**Negativas / trade-offs:**

- Mexe no pipeline de produção (a fonte do GitHub Pages deixa de ser o
  build legacy a partir de `master`) — o risco que o ADR 0001 tinha
  deliberadamente adiado para depois é assumido agora.
- Não elimina totalmente a divergência hml/prd: produção é buildada de novo
  no merge (com `baseurl` diferente do preview), não é uma promoção sem
  rebuild — objetivo original da issue #32 só parcialmente alcançado.
- Exige corrigir os templates do site (`site.github.url`, caminhos
  absolutos de raiz e `post.url`) para usar `relative_url`, e zerar o
  `baseurl` incorreto do `_config.yml`, antes de qualquer preview
  funcionar corretamente.
- O workflow de Actions fica mais complexo do que uma integração nativa de
  provedor externo: precisa tratar PR aberto/sincronizado, fechado com
  merge e fechado sem merge, usar grupos de `concurrency` separados para
  produção e para preview/limpeza, e fazer a publicação de produção
  sempre reconciliar com o HEAD atual de `master` (não com o SHA que
  disparou o job) para sobreviver à coalescência de execuções.
- Previews não são suportados para PRs de forks nesta etapa (ver "Fora de
  escopo" acima) — só contribuições via branch do próprio repositório.
- Os previews continuam publicamente acessíveis (GitHub Pages não oferece
  PRs privados/protegidos por padrão), então nenhum conteúdo sensível deve
  passar por esse fluxo antes de estar pronto para publicação.

## Próximos passos

- Zerar o `baseurl` do `_config.yml` (hoje `https://poabitdevs.com`,
  incorreto e adormecido).
- Corrigir os templates (`_includes/header.html`, `_includes/head.html`,
  `_includes/footer.html`, `index.html`, `events.html`) para usar
  `relative_url` em vez de `site.github.url`/caminhos absolutos/`post.url`
  cru.
- Implementar o workflow de Actions: build + publicação do preview com
  `baseurl` a partir de `refs/pull/<N>/merge`, comentário automático no
  PR, rebuild de produção no merge (sempre a partir do HEAD atual de
  `master` no momento em que roda, não do SHA que disparou o job),
  limpeza no fechamento sem merge — produção usando um grupo de
  `concurrency` próprio, separado do grupo de preview/limpeza.
- Habilitar "Require branches to be up to date before merging" **e**
  marcar o status check do workflow de preview como obrigatório para o
  merge, na `master`.
- Migrar a fonte do GitHub Pages para a branch `gh-pages` (com
  `.nojekyll`).
- Remover `netlify.toml` (já feito) e reaproveitar `.ruby-version` para
  pinar a versão do Ruby no workflow de Actions.

Essas etapas ficam para os próximos PRs da issue
[#29](https://github.com/poabitdevs/poabitdevs.org/issues/29), que passa a
cobrir também o que estava reservado para a issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).
