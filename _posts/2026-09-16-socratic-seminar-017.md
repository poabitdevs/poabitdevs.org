---
layout: post
type: socratic
title: "Seminário Socrático 017"
meetup: https://www.meetup.com/porto-alegre-bitdevs/events/316198858/
luma: https://luma.com/wpfaklie
---

## Avisos

- Respeite a privacidade dos participantes.
- Os meetups nunca são gravados. Queremos todos à vontade para participar e discutir os assuntos programados, de forma anônima se assim o desejarem.
- Entrem no grupo do Whatsapp "[BitdevsPOA](https://chat.whatsapp.com/I9OKdMexmXVBQMHEPb2Uyp){:target="_blank"}" para receberem novidades sobre o grupo e serem notificados dos próximos encontros!
- [Curso de Bitcoin do Edil](https://www.youtube.com/watch?v=gCgdCgyHFqw&list=PLfdR3_dt2rbexb-ohbaLLzAuNAp7Ypt8u){:target="_blank"}

## Agradecimentos

- Agradecemos ao SENGE pela locação do espaço, à [Vinteum](https://vinteum.org){:target="_blank"} pelo apoio e à [GoBTC](https://gobtc.com.br){:target="_blank"} pela organização e divulgação do evento.

## Cronograma

### Aquecimento

* [Peter Todd revive proposta de emissão de cauda no Bitcoin](https://livecoins.com.br/emissao-de-cauda-pode-ser-a-proxima-grande-polemica-do-bitcoin-entenda-a-proposta/){:target="_blank"} - Peter Todd voltou a defender publicamente abandonar o teto de 21 milhões de bitcoins por uma emissão perpétua mínima que sustente a recompensa dos mineradores no longo prazo, comparando o modelo ao do ouro; Adam Back e outros desenvolvedores rejeitaram a proposta publicamente.
* [Payjoin chega à versão estável 1.0.0](https://github.com/payjoin/rust-payjoin/releases){:target="_blank"} - Depois de mais de três anos de desenvolvimento, a biblioteca Payjoin (Rust, com bindings para Python, Dart, C# e JS) chegou à primeira release estável suportando BIP78 e BIP77 — uma forma de pagamento colaborativo que quebra uma das heurísticas mais usadas para rastrear transações Bitcoin.
* [Vinteum abre novo ciclo de fellowship](https://vinteum.exe.xyz/blog/introducing-vinteums-new-fellowship-cycle){:target="_blank"} - A Vinteum anunciou 12 fellows e 2 grantees trabalhando em projetos open-source do ecossistema Bitcoin, na sequência do "Bitcoin Dev Launchpad Cohort 2".

### Bitcoin L1

* ["Tripwire": desabilitar opcodes de curva elíptica contra ameaça quântica](https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U){:target="_blank"} - Thread de Pieter Wuille propondo mecanismos apelidados "Tripwire" e "Miner Lockdown" para desabilitar, via soft-fork, opcodes de curva elíptica em novos tipos de output resistentes à computação quântica, com debate técnico girando em torno de incentivos de mineradores e reversibilidade da mudança.
* [Primeira transação com resistência pós-quântica minerada na mainnet do Bitcoin sem soft fork](https://starkware.co/blog/the-first-quantum-safe-bitcoin-transaction-has-been-mined/){:target="_blank"} - Em 27/08/2026, a StarkWare minerou a primeira transação com resistência pós-quântica na mainnet do Bitcoin, usando o método QSB de Avihu Levy — uma técnica de "signature grinding" que roda inteiramente dentro do Bitcoin Script existente sem exigir soft fork, mas que, por gerar um formato não padrão, precisou ser enviada diretamente a um minerador (via MARA Slipstream) em vez do mempool normal.
* [Bitcoin Core mescla novo rate-limiting global de transações (PR #34628)](https://github.com/bitcoin/bitcoin/pull/34628){:target="_blank"} - Anthony Towns teve mesclada uma mudança que substitui o rate-limiting por peer por um sistema global com um único backlog ordenado por taxa, controlado por dois limitadores ("token buckets") — um por contagem e outro por tamanho serializado das transações —, mitigando um vetor de negação de serviço por CPU causado por reordenação repetida de transações.
* [BIP draft: "Segregated Data" - tirar dado arbitrário do OP_RETURN](https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641){:target="_blank"} - Proposta de soft-fork para criar uma região de bloco prunável e isolada de script dedicada a dados arbitrários, tirando esse uso do OP_RETURN e reacendendo a discussão sobre o que a chain deveria guardar — críticos apontam que, sem incentivo de retenção obrigatória, os nós não têm motivo para de fato guardar esses dados.
* [libsecp256k1 v0.8.0](https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0){:target="_blank"} - Nova release da biblioteca criptográfica usada pelo Bitcoin Core traz um módulo para silent payments (BIP352) e um novo ponto de extensão para plugar implementações de SHA-256 otimizadas por hardware, além de melhorias no elemento de campo de 64 bits que renderam ganho reportado de até ~11% na verificação de assinaturas ECDSA e Schnorr.
* [Bitcoin Core encerra desenvolvimento do HWI (Python) e comunidade migra para o BHWI (Rust)](https://livecoins.com.br/bitcoin-core-se-prepara-para-encerrar-desenvolvimento-de-ferramenta-que-oferece-suporte-para-carteiras-de-hardware/){:target="_blank"} - A desenvolvedora Ava Chow (`achow101`) anunciou o fim do desenvolvimento ativo da Hardware Wallet Interface (HWI) em Python — que entra em manutenção mínima após o suporte a MuSig2, por limitações da linguagem para builds determinísticos —, com a comunidade migrando os esforços para o **BHWI** (Rust), que já suporta Coldcard, Jade, Ledger e BitBox02.

### Lightning e L2

* [Boltz suspende operação após ataques assistidos por IA](https://x.com/Boltzhq/status/2087636521746674168){:target="_blank"} - A Boltz, serviço não custodial de swaps sobre Lightning, suspendeu a operação em 03/08/2026 após meses sob ataques cada vez mais frequentes e sofisticados assistidos por IA — vários tiveram sucesso, mas fundos de usuários nunca ficaram em risco porque o serviço é não custodial —; os três fundadores saíram sem papel formal no projeto; um grupo não identificado de "veteranos" do Bitcoin assumiu o controle com o objetivo declarado de restabelecer o serviço o quanto antes; e em 10/08/2026 a [Blockstream lançou um serviço concorrente](https://blog.blockstream.com/announcing-blockstream-swaps/){:target="_blank"} ("Blockstream Swaps", em beta) para preencher a lacuna.
* [Conditional Message Transfer Contract (CMTC) contra channel jamming](https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772){:target="_blank"} - Antoine Riard propôs um mecanismo que torna caro "segurar" pagamentos em rota (jamming) cobrando uma taxa proporcional ao tempo de retenção, com três caminhos de liquidação possíveis (sucesso, desafio de liveness, falha) — o próprio autor reconhece que a proposta ainda precisa de mais análise criptográfica e de incentivos.
* [BOLT12 payer proofs viram parte da especificação](https://github.com/lightning/bolts/pull/1346){:target="_blank"} - Mudança mesclada no repositório oficial dos BOLTs padroniza como um pagador prova que fez um pagamento (via preimage + assinatura, com prefixo `lnp`).

### Segurança

* [Vulnerabilidade de entropia insuficiente em wallets COLDCARD já rendeu mais de 1.500 BTC roubados](https://blog.coinkite.com/coldcard-mk3-seed-generation-warning/){:target="_blank"} - Bug de linkedição (detalhado pela [Wizardsardine](https://wizardsardine.com/blog/coldcard-vuln-deep-dive/){:target="_blank"}) fazia o RNG da Coldcard cair para um gerador de software, reduzindo a entropia da seed a ~72 bits nos modelos Mk4/Mk5/Q e ~40 bits nos Mk2/Mk3 (128 esperados); [segundo a Galaxy Research](https://x.com/glxyresearch/status/2084411904924045370){:target="_blank"}, já são 1.596+ BTC (mais de US$ 100 milhões) roubados, com a [Coinkite suspeitando de ataque assistido por IA](https://decrypt.co/374766/38m-in-bitcoin-drained-by-coldcard-key-flaw-its-maker-thinks-ai-found){:target="_blank"}.
* [Sparrow Wallet v2.5.4 passa por auditoria defensiva assistida por IA após caso Coldcard](https://x.com/Lab312_/status/2093636592346771921){:target="_blank"} - Após indícios de que o ataque à Coldcard envolveu auxílio de IA, o desenvolvedor Craig Raw usou ferramentas de IA para uma auditoria defensiva do Sparrow Wallet, resultando na release 2.5.4 — que corrige vetores em respostas do Electrum server, implementa verificações anti-klepto para BitBox02 (firmware 9.4.0+), sanitiza credenciais do Core nos logs de debug e fecha vazamentos DNS sob Tor.
* [Duas vulnerabilidades de exaustão de memória no Core Lightning (connectd e gossipd)](https://delvingbitcoin.org/t/vulnerability-disclosure-twin-memory-exhaustion-dos-vulnerabilidades-in-core-lightning/2731){:target="_blank"} - Disclosure detalha dois vetores de negação de serviço por exaustão de memória no Core Lightning — inundação da fila de mensagens inter-daemon entre `connectd` e `gossipd` via `channel_update` e exaustão do mapa de SCID no `gossipd` via IDs de canal falsos —, ambos já corrigidos (limitando a fila a 500 mil mensagens e tornando a coleta de lixo no mapa mais agressiva, respectivamente), sem que a disclosure afirme se houve exploração em produção.
* [Ataque de spam de endereços no P2P do Bitcoin](https://bnoc.xyz/t/address-relay-under-stress/163){:target="_blank"} - Pesquisadores caracterizaram um ataque de injeção contínua de IPs falsos via gossip normal de endereços, degradando a qualidade do `addrman` (taxa de aceitação de novos endereços e sucesso do mecanismo "feeler") em nós afetados, até o atacante cessar a atividade em meados de julho de 2026.
