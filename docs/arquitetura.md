# Arquitetura

Este documento descreve a arquitetura atual do projeto: stack, estrutura de
diretórios, modelo de conteúdo, pipeline de build/deploy e integrações
externas. Complementa, sem duplicar, o [`AGENTS.md`](../AGENTS.md)
(convenções técnicas e comandos) e o [`CONTRIBUTING.md`](../CONTRIBUTING.md)
(processo de criação de uma edição). Decisões e trade-offs do pipeline de
build/deploy ficam registrados em [`docs/adr/`](adr/) — este documento
descreve o estado resultante, não repete o raciocínio por trás dele. O
[`README.md`](../README.md) cobre o mesmo pipeline de build/deploy numa
versão curta, em inglês, voltada a quem só quer subir o projeto ou
entender o fluxo de PR sem ler a referência completa — as duas descrições
precisam ser mantidas em sincronia manualmente.

## Stack

- **Gerador de site estático:** [Jekyll](https://jekyllrb.com/) (Ruby),
  versão do Ruby pinada em [`.ruby-version`](../.ruby-version) e
  dependências travadas em [`Gemfile.lock`](../Gemfile.lock).
- **Markdown:** kramdown, com highlighting via Rouge.
- **CSS:** Sass (`assets/css/*.scss`), saída comprimida.
- **Plugins Jekyll:** `jekyll-sitemap`, `jekyll-feed`, `jekyll-seo-tag`
  (declarados em [`_config.yml`](../_config.yml)); `jekyll-paginate` está no
  [`Gemfile`](../Gemfile) mas não é usado hoje pelo site (não paginamos
  nenhuma listagem).
- **Servidor local:** `webrick`, usado por `jekyll serve`.
- **JavaScript:** vanilla, sem bundler nem framework — `assets/js/script.js`
  hoje está desativado (comentado em [`_includes/head.html`](../_includes/head.html));
  o único JS que roda em produção é o inline em
  [`_includes/footer.html`](../_includes/footer.html) (toggle do bloco de
  build info via `?debug`).
- **Sem backend nem banco de dados:** o site é inteiramente estático; toda
  publicação acontece via build + arquivos servidos como estão.
- **Sem suíte de testes automatizada** — ver [`AGENTS.md`](../AGENTS.md#test-commands).

## Estrutura de diretórios

```
_posts/       Conteúdo das edições (um arquivo por post, ver "Modelo de conteúdo")
_layouts/     Templates de página (default, page, post, blog)
_includes/    Partials Liquid (header, head, footer)
assets/css/   SCSS (variáveis, reset, componentes por seção)
assets/js/    JavaScript vanilla (hoje sem uso ativo em produção)
_data/        Dados injetados via Liquid (settings.yml versionado;
              build.yml gerado no build, nunca commitado)
_offline/     Scripts Node.js independentes do build do site (ver "Integrações externas")
docs/         Documentação do projeto (este arquivo, ADRs)
docs/adr/     Registro de decisões arquiteturais
.github/
  workflows/  Pipelines de CI/CD (build, preview, produção)
  scripts/    Scripts de apoio aos workflows, chamados por mais de um deles
index.html    Página inicial
events.html   Listagem de todas as edições do Seminário Socrático
404.html      Página de erro 404
```

O texto "sobre" do site existe em **três** cópias independentes, que
precisam ser mantidas em sincronia manualmente:

- `title`/`description` em `_config.yml`, usados por `site.title`/
  `site.description` — consumidos pelos plugins de SEO/feed
  (`jekyll-seo-tag`, `jekyll-feed`), não por nenhum template.
- `title`/`tagline` em `_data/settings.yml`, lidos como
  `site.data.settings.*` pelo header (`_includes/header.html`, nome do
  site) e pelo `<title>` da página (`_includes/head.html`).
- O parágrafo "sobre" da home está hardcoded em `index.html`, sem ler
  `site.data.settings.tagline` nem `site.description` — textualmente igual
  à `tagline` hoje, mas sem nenhum vínculo que garanta isso no futuro.

Atualizar só duas dessas três fontes deixa a divergência
visível para quem lê o site.

## Modelo de conteúdo

Cada edição do Seminário Socrático é um arquivo em `_posts/`, nomeado
`YYYY-MM-DD-titulo.md` (convenção padrão do Jekyll). Frontmatter:

```yaml
---
layout: post
type: socratic   # ou whitepaper
title: "Título"
luma: <url>      # plataforma de inscrição atual
meetup: <url>    # legado — mantido enquanto o post ainda precisar do link, ver abaixo
---
```

`type` distingue Seminários Socráticos de posts da série whitepaper; a home
(`index.html`) mostra os dois tipos, enquanto `events.html` filtra só por
`socratic`. `luma` e `meetup` são os campos de inscrição — o layout
`post.html` renderiza cada link independentemente, se o campo
correspondente existir, sem exigir os dois; qual usar, e o estado atual da
transição entre as duas plataformas, é convenção do processo de edição,
coberta abaixo. O processo completo de criação de uma edição — da issue de
sugestões de pauta ao merge do post — está no
[`CONTRIBUTING.md`](../CONTRIBUTING.md); convenções de frontmatter e
formatação do corpo estão no [`AGENTS.md`](../AGENTS.md).

## Layouts e templates

`_layouts/default.html` é a base (inclui `head`, `header`, `footer`),
usada diretamente por `index.html`, `events.html` e `404.html`.
`post.html` estende `default` e também está ativo: todos os posts em
`_posts/` usam `layout: post`. `page.html` e `blog.html` também estendem
`default`, mas nenhum conteúdo os usa hoje — são os únicos dois layouts
sem consumidor.
`_includes/header.html` lê o menu de navegação de
`site.data.settings.menu`; `_includes/footer.html` renderiza o link do
repositório, o feed RSS e o bloco de build info (ver "Identificando o
pipeline que gerou um build" abaixo). Todos os links internos usam o filtro
`relative_url` do Jekyll (não caminhos absolutos de raiz crus) — necessário
porque produção e cada preview são builds separados com `baseurl`
diferente (produção builda sem `--baseurl`, na raiz; cada preview builda
com `--baseurl /pr-preview/pr-<n>`, ver próxima seção). O porquê disso ser
necessário (o `baseurl` gravado no HTML no momento do build) está na
[ADR 0002](adr/0002-preview-e-producao-via-actions-gh-pages.md), seção
"Pré-requisito nos templates".

## Pipeline de build e deploy

Versão resumida, para quem só quer entender o fluxo de PR:
[`README.md#deploying--previews`](../README.md#deploying--previews).
Detalhado abaixo: quatro workflows de GitHub Actions constroem e publicam
a branch `gh-pages` — o destino já preparado para ser a fonte do GitHub
Pages, ainda não ativo como tal (ver "Estado transitório" abaixo):

- **`preview-build.yml`** (evento `pull_request`, sem permissão de escrita
  nem segredos): builda o Jekyll a partir de `refs/pull/<n>/merge` com
  `--baseurl /pr-preview/pr-<n>` e publica o `_site` só como artifact.
- **`preview-publish.yml`** (evento `workflow_run`, disparado pelo build
  anterior): roda sempre com a versão do workflow em `master` — nunca a de
  um PR, mesmo que o PR o tenha alterado —, baixa o artifact, escreve em
  `gh-pages:pr-preview/pr-<n>/` e comenta o link no PR. Também mantém um
  commit status `preview/publish` (pendente → sucesso/erro/falha) na tip do
  PR. Só publica para PRs do próprio repositório (condição
  `head_repository.full_name == github.repository`) — PRs de fork ficam
  só com o build sem privilégios de `preview-build.yml`, sem preview,
  comentário ou status.
- **`preview-cleanup.yml`** (evento `pull_request_target`, mesma garantia de
  rodar sempre a versão de `master`): ao fechar um PR, remove seu
  subcaminho de preview e invalida o status `preview/publish` associado.
- **`production.yml`** (evento `push` em `master`): builda o Jekyll a
  partir do HEAD atual de `master` (não do SHA que disparou o evento) e
  publica na raiz de `gh-pages`, preservando `pr-preview/` intacto.

Todo escritor de `gh-pages` usa `.github/scripts/publish-gh-pages.sh`, que
escreve de forma conflict-safe (fetch/clone + retry no push, nunca
force-push) só no subcaminho relevante — a raiz para produção, um
`pr-preview/pr-<n>/` isolado para cada PR — preservando o resto da árvore.
`.github/scripts/pr-state.sh` consulta o estado real de um PR via API
(nunca confia em payload de evento) antes de publicar ou limpar um preview,
para evitar corridas entre publicação e fechamento do PR. O racional
completo de cada uma dessas escolhas (separação build/publish, grupos de
`concurrency`, coalescência de merges, corridas entre publish e cleanup)
está em [`docs/adr/0002-preview-e-producao-via-actions-gh-pages.md`](adr/0002-preview-e-producao-via-actions-gh-pages.md).

**Estado transitório:** a fonte do GitHub Pages ainda é o build legacy a
partir de `master`, não a branch `gh-pages` — repontar isso exige acesso de
admin do repositório, pendente (issue
[#29](https://github.com/poabitdevs/poabitdevs.org/issues/29)). Até essa
troca acontecer, o site ao vivo continua sendo republicado pelo build
legacy do próprio GitHub a cada mudança em `master`, enquanto
`production.yml` builda e publica em `gh-pages` em paralelo, sem efeito
ainda no site ao vivo.

### Identificando o pipeline que gerou um build

Todo build (local via `make`, preview ou produção via Actions) grava SHA do
commit, timestamp UTC e nome do pipeline em `_data/build.yml` — gerado a
cada build, nunca commitado. `_includes/footer.html` renderiza esse dado
(oculto por padrão; `?debug` na URL revela, ou o comentário HTML acima do
bloco no código-fonte da página). Um build legacy do Pages nunca gera esse
arquivo, então seu rodapé sempre mostra `sha`/`timestamp` como "desconhecido"
e `pipeline` como "legacy-ou-local-sem-info" (defaults do Liquid em
`_includes/footer.html`) — forma rápida de diferenciar qual pipeline
publicou o que está sendo visto, relevante enquanto o estado transitório
acima persistir.

## Build local

`make build`/`make preview` (ou os comandos `bundle exec jekyll` diretos)
— ver [`AGENTS.md`](../AGENTS.md#build-commands) para a lista completa.
`shell.nix` disponibiliza via Nix os pacotes `jekyll` e `jekyll-feed`
prontos (`nix-shell`), por fora do `Gemfile`/`bundle` — não cobre os
demais gems do `Gemfile` (`jekyll-sitemap`, `jekyll-seo-tag`,
`kramdown-parser-gfm`, `webrick` etc.) nem toolchain de build para
extensões nativas. Não é um substituto completo de `bundle install`, só
uma forma rápida de ter um `jekyll` básico disponível sem instalar Ruby
diretamente.

## Integrações externas

- **Luma:** plataforma de inscrição atual para as edições, referenciada só
  via link (`luma:` no frontmatter) — sem integração de API.
- **Meetup:** plataforma de inscrição legada, ainda referenciada via link
  no menu principal (`_data/settings.yml`) e no campo `meetup:` dos posts
  que ainda precisam do link legado, independente da data.
  `_offline/scrape-events.js` é um script Node.js standalone
  (fora do pipeline de build do site) para fazer backfill de dados
  históricos de eventos: lê `_offline/events.json` local e só recorre à
  API pública do Meetup, sem autenticação, se essa leitura falhar — não
  roda como parte de nenhum workflow, só manualmente quando necessário. O
  `_offline/README.md` documenta uma variável `MEETUP_API_KEY` que o
  script hoje não lê nem usa.
- **GitHub:** hospedagem (Pages), CI/CD (Actions) e o próprio fluxo de
  contribuição (issues, PRs) descrito no [`CONTRIBUTING.md`](../CONTRIBUTING.md).

## Decisões arquiteturais

Decisões com trade-offs relevantes (não só o "como", mas o "por que" e as
alternativas descartadas) ficam registradas como ADRs em
[`docs/adr/`](adr/), não repetidas aqui. Hoje:

- [0001 — Ambiente de homologação ad hoc por Pull Request](adr/0001-ambiente-homologacao-ad-hoc.md)
  (substituído pelo 0002).
- [0002 — Preview e produção via GitHub Actions e branch `gh-pages`](adr/0002-preview-e-producao-via-actions-gh-pages.md)
  (decisão vigente, descrita na seção "Pipeline de build e deploy" acima).
