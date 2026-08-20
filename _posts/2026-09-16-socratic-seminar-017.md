---
layout: post
type: socratic
title: "Seminário Socrático 017"
meetup: https://www.meetup.com/porto-alegre-bitdevs/events/316198858/
luma: https://luma.com/wpfaklie
---

## Avisos

- Respeite a privacidade dos participantes.
- Os meetups nunca são gravados. Queremos todos a vontade para participar e discutir os assuntos programados, de forma anônima se assim o desejarem.
- Entrem no grupo do Whatsapp "[BitdevsPOA](https://chat.whatsapp.com/I9OKdMexmXVBQMHEPb2Uyp){:target="_blank"}" para receber novidades sobre o grupo e ser notificado dos próximos encontros!
- [Curso de Bitcoin do Edil](https://www.youtube.com/watch?v=gCgdCgyHFqw&list=PLfdR3_dt2rbexb-ohbaLLzAuNAp7Ypt8u){:target="_blank"}

## Agradecimentos

- Agradecemos ao SENGE pela locação do espaço, à [Vinteum](https://vinteum.org){:target="_blank"} pelo apoio e à [GoBTC](https://gobtc.com.br){:target="_blank"} pela organização e divulgação do evento.

## Cronograma

### Aquecimento

* [Peter Todd revive proposta de emissão de cauda no Bitcoin](https://livecoins.com.br/emissao-de-cauda-pode-ser-a-proxima-grande-polemica-do-bitcoin-entenda-a-proposta/){:target="_blank"} - Peter Todd defende abandonar o teto de 21 milhões de bitcoins com emissão perpétua mínima para sustentar a recompensa dos mineradores; Adam Back e outros rejeitam publicamente
* [Payjoin chega à versão estável 1.0.0](https://github.com/payjoin/rust-payjoin/releases){:target="_blank"} - Biblioteca Payjoin (Rust) chega à primeira release estável após mais de 3 anos, suportando BIP78 e BIP77, quebrando uma das heurísticas mais usadas para rastrear transações Bitcoin
* [Vinteum abre novo ciclo de fellowship](https://vinteum.exe.xyz/blog/introducing-vinteums-new-fellowship-cycle){:target="_blank"} - 12 fellows e 2 grantees selecionados para trabalhar em projetos open-source do ecossistema Bitcoin

### Bitcoin L1

* ["Tripwire": desabilitar opcodes de curva elíptica contra ameaça quântica](https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U){:target="_blank"} - Pieter Wuille propõe mecanismos para desabilitar, via soft-fork, opcodes de curva elíptica em novos tipos de output resistentes a computação quântica
* [Bitcoin Core mescla novo rate-limiting global de transações (PR #34628)](https://github.com/bitcoin/bitcoin/pull/34628){:target="_blank"} - Substitui rate-limiting por-peer por um sistema global de filas, mitigando um vetor de negação de serviço por CPU causado por reordenação repetida de transações
* [BIP draft: "Segregated Data" — tirar dado arbitrário do OP_RETURN](https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641){:target="_blank"} - Soft-fork propõe região de bloco prunável dedicada a dados arbitrários; críticos apontam falta de incentivo de retenção obrigatória
* [libsecp256k1 v0.8.0](https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0){:target="_blank"} - Nova release traz módulo para silent payments (BIP352) e SHA-256 otimizado por hardware, ~11% de ganho na verificação de assinatura

### Lightning e L2

* [Boltz suspende operação após ataques assistidos por IA](https://x.com/Boltzhq/status/2087636521746674168){:target="_blank"} - Serviço não-custodial de swaps sobre Lightning suspenso desde 03/08/2026 após meses de ataques cada vez mais sofisticados; Blockstream lança concorrente ("Blockstream Swaps") em beta para preencher a lacuna
* [Conditional Message Transfer Contract (CMTC) contra channel jamming](https://delvingbitcoin.org/t/conditional-message-transfer-contract-to-solve-jamming/2772){:target="_blank"} - Antoine Riard propõe cobrar taxa proporcional ao tempo de retenção para tornar caro "segurar" pagamentos em rota
* [BOLT12 payer proofs vira parte da especificação](https://github.com/lightning/bolts/pull/1346){:target="_blank"} - Padroniza como um pagador prova que fez um pagamento, via preimage + assinatura

### Segurança

* [Vulnerabilidade de entropia insuficiente em wallets COLDCARD já rendeu mais de 1.500 BTC roubados](https://blog.coinkite.com/coldcard-mk3-seed-generation-warning/){:target="_blank"} - RNG do dispositivo com entropia insuficiente por bug de linkedição (ver [análise técnica da Wizardsardine](https://wizardsardine.com/blog/coldcard-vuln-deep-dive/){:target="_blank"}); Galaxy Research contabiliza 1.596 BTC roubados (~US$ 115 milhões) até 13/08/2026, com risco de novas perdas
* [Duas vulnerabilidades de exaustão de memória no Core Lightning (gossipd)](https://delvingbitcoin.org/t/vulnerability-disclosure-twin-memory-exhaustion-dos-vulnerabilidades-in-core-lightning/2731){:target="_blank"} - DoS por inundação de fila via `channel_update` e exaustão do mapa de SCID; ambas já corrigidas
* [Ataque de spam de endereços no P2P do Bitcoin](https://bnoc.xyz/t/address-relay-under-stress/163){:target="_blank"} - Injeção contínua de IPs falsos via gossip degradou a qualidade do addrman até o atacante cessar a atividade em meados de julho de 2026
