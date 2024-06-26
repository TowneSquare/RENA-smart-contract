
<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core"></a>

# Module `0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776::core`



-  [Struct `RenegadeCoin`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_RenegadeCoin)
-  [Resource `Fee`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Fee)
-  [Struct `CollectionCreated`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_CollectionCreated)
-  [Struct `LiquidTokensCreated`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidTokensCreated)
-  [Struct `LiquidCoinCreated`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidCoinCreated)
-  [Struct `FeeUpdated`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_FeeUpdated)
-  [Struct `Claimed`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Claimed)
-  [Struct `Liquified`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Liquified)
-  [Constants](#@Constants_0)
-  [Function `create_collection_and_mint_tokens`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_collection_and_mint_tokens)
-  [Function `mint_tokens`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_mint_tokens)
-  [Function `create_liquid_coin`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_liquid_coin)
-  [Function `claim`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_claim)
-  [Function `liquify`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_liquify)
-  [Function `set_fee`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_set_fee)
-  [Function `fee`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_fee)


<pre><code><b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::string_utils</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::royalty</a>;
<b>use</b> <a href="">0x4::token</a>;
<b>use</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin">0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776::liquid_coin</a>;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_RenegadeCoin"></a>

## Struct `RenegadeCoin`

The Renegade coin


<pre><code><b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_RenegadeCoin">RenegadeCoin</a>
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Fee"></a>

## Resource `Fee`

Global storage for fee


<pre><code><b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Fee">Fee</a> <b>has</b> key
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_CollectionCreated"></a>

## Struct `CollectionCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_CollectionCreated">CollectionCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidTokensCreated"></a>

## Struct `LiquidTokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidTokensCreated">LiquidTokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidCoinCreated"></a>

## Struct `LiquidCoinCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_LiquidCoinCreated">LiquidCoinCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_FeeUpdated"></a>

## Struct `FeeUpdated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_FeeUpdated">FeeUpdated</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Claimed"></a>

## Struct `Claimed`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Claimed">Claimed</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Liquified"></a>

## Struct `Liquified`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_Liquified">Liquified</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_ENOT_ENOUGH_APT_TO_PAY_FEE"></a>

The signer does not have enough APT to pay the fee.


<pre><code><b>const</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_ENOT_ENOUGH_APT_TO_PAY_FEE">ENOT_ENOUGH_APT_TO_PAY_FEE</a>: u64 = 2;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_ENOT_RENA"></a>

The signer is not Rena account.


<pre><code><b>const</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_ENOT_RENA">ENOT_RENA</a>: u64 = 1;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_EURI_COUNT_MISMATCH"></a>

The number of URIs does not match the number of tokens.


<pre><code><b>const</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_EURI_COUNT_MISMATCH">EURI_COUNT_MISMATCH</a>: u64 = 3;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_collection_and_mint_tokens"></a>

## Function `create_collection_and_mint_tokens`

Create a collection and mint tokens; this has a limit of 500 tokens minted at a time.


<pre><code>entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_collection_and_mint_tokens">create_collection_and_mint_tokens</a>(signer_ref: &<a href="">signer</a>, collection_description: <a href="_String">string::String</a>, collection_name: <a href="_String">string::String</a>, collection_supply: u64, collection_uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64, tokens_description: <a href="_String">string::String</a>, folder_uri: <a href="_String">string::String</a>, prefix: <a href="_String">string::String</a>, suffix: <a href="_String">string::String</a>, token_count: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_mint_tokens"></a>

## Function `mint_tokens`

Mint a batch of tokens


<pre><code>entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_mint_tokens">mint_tokens</a>(signer_ref: &<a href="">signer</a>, collection_name: <a href="_String">string::String</a>, token_count: u64, tokens_description: <a href="_String">string::String</a>, folder_uri: <a href="_String">string::String</a>, prefix: <a href="_String">string::String</a>, suffix: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_liquid_coin"></a>

## Function `create_liquid_coin`

Create a liquid coin (Legacy coin standard)


<pre><code>entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_create_liquid_coin">create_liquid_coin</a>&lt;CoinType&gt;(signer_ref: &<a href="">signer</a>, collection_addr: <b>address</b>, coin_name: <a href="_String">string::String</a>, coin_symbol: <a href="_String">string::String</a>, decimals: u8)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_claim"></a>

## Function `claim`

Claim an X number of liquid NFT by providing an X number of liquid coins


<pre><code>entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_claim">claim</a>&lt;CoinType&gt;(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, count: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_liquify"></a>

## Function `liquify`

Liquify an X number of liquid NFT to get an X number of liquid coins


<pre><code>entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_liquify">liquify</a>&lt;LiquidCoin&gt;(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, tokens: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_set_fee"></a>

## Function `set_fee`

Set fees for claiming and liquifying; Admin specific


<pre><code><b>public</b> entry <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_set_fee">set_fee</a>(signer_ref: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_fee"></a>

## Function `fee`

Get the fee


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_core_fee">fee</a>(): u64
</code></pre>
