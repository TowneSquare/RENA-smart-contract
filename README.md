# RENA-modules

## Core

### Technical specs

- Internal common [common module](./doc/common.md)
- Public [core module](./doc/core.md)
- Internal [liquid_coin module](./doc/liquid_coin.md)

### Entry functions

To interact with the contract, one can use the following entry functions:

- [`create_collection_and_mint_tokens`](./doc/core.md#create_collection_and_mint_tokens)
- [`mint_tokens`](./doc/core.md#mint_tokens)
- [`create_liquid_coin`](./doc/liquid_coin.md#create_liquid_coin)
- [`claim`](./doc/liquid_coin.md#claim)
- [`liquify`](./doc/liquid_coin.md#liquify)

*admin functions*:

- [`set_fee`](./doc/core.md#set_fee)

Each function has a detailed description of its parameters and triggers events that can be used to track specific actions.

## Presale

### Technical specs

Public [presale module](./presale/doc/presale.md)

## Stake

### Technical specs

- [stake module](./stake/doc/stake.md)

- deployed on testnet: `0xce06dd72899bc314cf458ab1c6ae47011df6ba62176135c6d78ef6fafb38bdd5`
