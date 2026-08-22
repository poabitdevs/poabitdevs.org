# 0001. Ambiente de homologação ad hoc por Pull Request

> **Status: substituído pelo [ADR 0002](0002-preview-e-producao-via-actions-gh-pages.md).**
> Na prática, a instalação da integração nativa via GitHub App do provedor
> externo escolhido aqui (Netlify) na organização `poabitdevs` ficou
> bloqueada por exigir aprovação de um Owner da organização, sem acesso
> claro/alcançável no momento — um bloqueio inerente a esse modelo de
> integração (Netlify, Vercel, Cloudflare Pages usam o mesmo App nativo),
> não específico do Netlify. Isso não bloqueia necessariamente um deploy
> via CLI/API desses mesmos provedores, autenticado por token, chamado de
> dentro de uma GitHub Action — alternativa não avaliada nesta decisão (ver
> ADR 0002). O conteúdo abaixo permanece como registro histórico da decisão
> original.

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

Adotar um ambiente de homologação ad hoc por Pull Request, usando um
provedor externo de staging (Netlify, Vercel ou Cloudflare Pages — a
escolha específica fica para a implementação, ver "Próximos passos") para
buildar o site Jekyll e publicar um preview a cada PR aberto contra
`master`, com link comentado automaticamente no PR. A produção continua
publicada pelo GitHub Pages exatamente como hoje, sem nenhuma mudança nesta
etapa.

**Por que não usar o próprio GitHub Pages para os previews:** a primeira
versão desta decisão propunha publicar previews em subcaminhos de uma
branch `gh-pages` (padrão implementado por ferramentas como o
[rossjrw/pr-preview-action](https://github.com/rossjrw/pr-preview-action)).
Isso se mostrou inviável dentro do escopo desta issue: o GitHub Pages expõe
apenas **uma fonte de deploy por repositório**, e hoje essa fonte é
`master` (build legacy). Para servir previews a partir de `gh-pages`, seria
necessário repontar essa fonte — uma mudança no pipeline de produção, que é
exatamente o que ficou deferido para a issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32). Esse
problema foi identificado em revisão do PR [#33](https://github.com/poabitdevs/poabitdevs.org/pull/33#discussion_r3830731488).
Também não existe hoje um site de Pages a nível de organização disponível
para hospedar previews à parte. Um provedor externo resolve isso
nativamente: hospeda os previews em domínio próprio, inteiramente
dissociado da configuração de Pages deste repositório.

**Escopo explicitamente de fora desta decisão:** o artefato homologado no
PR (buildado pelo provedor externo) e o artefato publicado em produção
(build legacy do GitHub Pages) continuam sendo builds independentes, agora
inclusive com motores de build/ambiente diferentes entre si. Unificar isso
— fazendo produção publicar exatamente o artefato homologado, sem rebuild
adicional — é uma mudança de maior risco no pipeline de produção, tratada
separadamente, com mais calma, na issue
[#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).

Alternativas consideradas:

- **Preview via branch `gh-pages` do próprio GitHub Pages** (escolha
  original desta decisão): mantém tudo dentro do ecossistema GitHub, sem
  provedor novo, mas exige repontar a fonte de deploy do Pages — inviável
  sem tocar o pipeline de produção nesta issue (ver acima).
- **Manter só o `make preview` local**: não exige nenhuma mudança de
  infraestrutura, mas não valida o pipeline de build em CI nem gera um
  link compartilhável para quem revisa o PR sem rodar o projeto localmente.

## Consequências

**Positivas:**

- Quem revisa um PR pode conferir o resultado renderizado sem configurar o
  ambiente Ruby/Jekyll localmente.
- Erros de build, Markdown/Liquid ou frontmatter são detectados antes do
  merge, não depois em produção.
- Não exige nenhuma mudança na configuração de Pages de produção — resolve
  a limitação de "uma fonte de deploy por repositório" sem tocar o
  pipeline atual.
- A maioria desses provedores já builda, publica e limpa previews antigos
  automaticamente ao fechar o PR, e comenta o link no PR nativamente —
  menos lógica de CI para o projeto manter do que um workflow de Actions
  próprio faria.

**Negativas / trade-offs:**

- Introduz um provedor novo fora do GitHub, com conta, billing (mesmo que
  em free tier) e configuração próprios.
- O artefato homologado no PR e o artefato publicado em produção passam a
  usar motores de build/ambiente diferentes entre si (o provedor externo
  de um lado, o build legacy do GitHub Pages do outro) — a divergência de
  ambiente entre hml e prd citada no contexto original fica maior com essa
  escolha do que seria com um preview dentro do próprio GitHub Pages. Vale
  reavaliar esse ponto quando a issue [#32](https://github.com/poabitdevs/poabitdevs.org/issues/32)
  tratar a promoção de artefato para produção.
- Os previews ficam publicamente acessíveis no free tier da maioria desses
  provedores, então nenhum conteúdo sensível deve passar por esse fluxo
  antes de estar pronto para publicação.

## Próximos passos

Escolher o provedor específico (Netlify, Vercel ou Cloudflare Pages),
configurar a integração (conta, deploy por PR, secret/token como necessário)
e confirmar o comentário automático do link no PR — a maioria desses
provedores já oferece isso nativamente via GitHub App, o que dispensa
escrever um workflow de Actions dedicado só para isso. Essas etapas ficam
para os próximos PRs desta issue ([#29](https://github.com/poabitdevs/poabitdevs.org/issues/29)),
fora do escopo deste ADR. A promoção do artefato homologado para produção
sem rebuild fica para a issue [#32](https://github.com/poabitdevs/poabitdevs.org/issues/32).
