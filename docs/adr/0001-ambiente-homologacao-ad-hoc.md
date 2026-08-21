# 0001. Ambiente de homologação ad hoc via GitHub Pages

## Contexto

O site é publicado no GitHub Pages a partir do build Jekyll padrão da branch
`master` — não há workflow customizado em `.github/`. Isso significa que
qualquer merge em `master` vai direto para produção, sem etapa intermediária
de homologação: a única forma de validar uma alteração antes do merge é
rodar `make preview` localmente (ver [AGENTS.md](../../AGENTS.md)), o que
exige que quem revisa tenha o ambiente Ruby/Jekyll configurado localmente e
não deixa um link compartilhável para quem só quer conferir o resultado
visual do PR.

Como o projeto é um site estático hospedado no GitHub Pages, sem backend ou
banco de dados, o risco técnico de publicar direto é menor do que em uma
aplicação com estado — mas erros de renderização Markdown/Liquid, links
quebrados ou frontmatter mal formado (como já ocorreu em posts anteriores)
só são percebidos depois de já estarem em produção.

## Decisão

Adotar um ambiente de homologação ad hoc por Pull Request: um workflow de
GitHub Actions builda o site Jekyll a cada PR aberto contra `master` e
publica o resultado em um subcaminho da própria branch `gh-pages` (por
exemplo, `pr-preview/pr-<número>/`), comentando o link de preview
automaticamente no PR, e remove esse subcaminho quando o PR é fechado
(mergeado ou não). Esse é o padrão implementado por ferramentas como o
[rossjrw/pr-preview-action](https://github.com/rossjrw/pr-preview-action),
que reaproveitamos em vez de escrever a lógica de deploy do zero.

**Escopo explicitamente de fora desta decisão:** como a produção hoje usa o
build "legacy" do GitHub Pages (reconstruído pelo próprio GitHub a partir da
`master`, com o ambiente/gems dele — não o `Gemfile`/`Gemfile.lock` do
projeto), o artefato homologado no PR e o artefato publicado em produção
continuam sendo dois builds independentes após esta mudança. Fazer a
produção publicar exatamente o mesmo artefato binário homologado no PR (sem
rebuild adicional) exige trocar a fonte do GitHub Pages para um deploy
baseado em branch estática, o que é uma mudança de maior risco no pipeline
de produção — tratada separadamente, com mais calma, na issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).

Alternativas consideradas:

- **Serviço de staging externo (Netlify, Vercel, Cloudflare Pages)**:
  oferece preview por PR nativamente e com mais recursos (proteção por
  senha, HTTPS por preview, etc.), mas introduz um provedor novo fora do
  GitHub, com conta, billing e configuração próprios — desproporcional para
  um site estático que já vive inteiramente no ecossistema GitHub.
- **Manter só o `make preview` local**: não exige nenhuma mudança de
  infraestrutura, mas não valida o pipeline de build real do GitHub Pages
  nem gera um link compartilhável para quem revisa o PR sem rodar o projeto
  localmente.

## Consequências

**Positivas:**

- Quem revisa um PR pode conferir o resultado renderizado sem configurar o
  ambiente Ruby/Jekyll localmente.
- Erros de build, Markdown/Liquid ou frontmatter são detectados no CI antes
  do merge, não depois em produção.
- Continua usando só a infraestrutura já em uso (GitHub Pages/Actions), sem
  provedor externo novo.

**Negativas / trade-offs:**

- O deploy passa a depender de um workflow de Actions mantido pelo projeto,
  em vez do build automático nativo do GitHub Pages — mais uma peça de CI
  para manter.
- Os previews ficam publicamente acessíveis (GitHub Pages não oferece PRs
  privados/protegidos por padrão), então nenhum conteúdo sensível deve
  passar por esse fluxo antes de estar pronto para publicação.
- O artefato homologado no PR e o artefato publicado em produção continuam
  sendo builds independentes por enquanto (ver "Escopo" acima e
  [#32](https://github.com/poabitdevs/poabitdevs.org/issues/32)) — esta
  decisão não elimina, por si só, o risco de divergência de ambiente entre
  hml e prd, só cria a etapa de homologação.

## Próximos passos

Implementação do workflow de Actions (build + deploy do preview) e do
comentário automático de link no PR, incluindo a limpeza do subcaminho de
preview no fechamento do PR, ficam para as próximas etapas desta issue
([#29](https://github.com/poabitdevs/poabitdevs.org/issues/29)), fora do
escopo deste ADR. A promoção do artefato homologado para produção sem
rebuild fica para a issue [#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).
