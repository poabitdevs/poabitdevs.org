# Como contribuir

Este documento descreve o ciclo completo de criação de uma edição do
Seminário Socrático do Porto Alegre BitDevs, do convite a sugestões de
pauta até o post publicado no site. Convenções técnicas de build e de
frontmatter ficam no [`AGENTS.md`](AGENTS.md); aqui o foco é o processo.

## Ciclo de uma edição

1. **Data e espaço confirmados.** A data (regra: 3ª quarta-feira do mês,
   salvo conflito de agenda relevante) e o espaço são decididos pelos
   organizadores fora deste repositório. Este ciclo só começa depois que
   os dois estiverem confirmados.

2. **Abrir a issue de sugestões de pauta.** Título no formato `<Mês>/<Ano>`
   (ex.: `Setembro/2026`). Corpo convidando a comunidade a deixar links de
   notícias/tópicos para a pauta, citando a data confirmada. Exemplo (issue
   [#10](https://github.com/poabitdevs/poabitdevs.org/issues/10)):

   > Deixe aqui a notícia (com link) que gostaria de incluir na pauta do
   > Bitdevs Porto Alegre do dia DD/MM/AA.

3. **Comunidade comenta.** Cada sugestão vira um comentário na issue, em
   geral um link (Bitcoin Optech, newsletters, blogs, X/Twitter etc.), às
   vezes com uma linha de contexto.

4. **Curadoria.** Um organizador reúne as sugestões da issue com curadoria
   própria (Bitcoin Optech, PRs relevantes do Bitcoin Core, newsletters) e
   classifica cada tópico em uma das categorias fixas do Seminário
   Socrático:
   - Aquecimento
   - Bitcoin L1
   - Lightning e L2
   - Segurança

5. **Criar a branch e o post.** Branch `feat/add-post-<NNN>`, onde `<NNN>`
   é o próximo número sequencial (sem zero à esquerda no nome da branch;
   com três dígitos no arquivo — ver abaixo). Criar
   `_posts/YYYY-MM-DD-socratic-seminar-<NNN>.md` (data = data confirmada do
   evento) com frontmatter:

   ```yaml
   ---
   layout: post
   type: socratic
   title: "Seminário Socrático <NNN>"
   luma: <url do evento na Luma>
   ---
   ```

   Inscrições em transição do Meetup para a Luma (ver
   [#25](https://github.com/poabitdevs/poabitdevs.org/pull/25)): use
   `luma:` nos posts novos. `meetup:` continua funcionando nos posts
   antigos que já o usam, mas não é mais o campo recomendado.

   Corpo com as seções `## Avisos`, `## Agradecimentos` e `## Cronograma`
   (uma subseção `###` por categoria, cada tópico como
   `* [Título](url){:target="_blank"} - resumo em uma frase`). Ver qualquer
   post recente em `_posts/` como referência de formato.

6. **Abrir o PR.** Da branch `feat/add-post-<NNN>` para `master`, resumindo
   no corpo os tópicos curados por categoria e fechando a issue de
   sugestões (`Closes #<número-da-issue>`). Ver PR
   [#18](https://github.com/poabitdevs/poabitdevs.org/pull/18) como
   exemplo.

7. **Merge.** Só depois que a pauta estiver fechada **e** o link real do
   evento na Luma estiver preenchido no frontmatter — nunca mergear com
   um link placeholder. O merge fecha a issue automaticamente e publica o
   post (Jekyll gera a página a partir de `_posts/`; `events.html` lista
   qualquer post com `type: socratic` sem trabalho manual adicional).

## Numeração dos posts

`<NNN>` é sequencial e contínuo, sempre com três dígitos no nome do
arquivo (`001`, `002`, ..., `016`, `017`, ...), independente de gaps de
calendário entre edições. Verificar o maior número já usado em
`_posts/` antes de abrir uma edição nova.
