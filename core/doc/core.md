
<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core"></a>

# Module `0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05::core`



-  [Struct `RenegadeCoin`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_RenegadeCoin)
-  [Resource `Fee`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Fee)
-  [Struct `CollectionCreated`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_CollectionCreated)
-  [Struct `LiquidTokensCreated`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidTokensCreated)
-  [Struct `LiquidCoinCreated`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidCoinCreated)
-  [Struct `FeeUpdated`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_FeeUpdated)
-  [Struct `Claimed`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Claimed)
-  [Struct `Liquified`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Liquified)
-  [Constants](#@Constants_0)
-  [Function `create_collection`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_collection)
-  [Function `mint_tokens`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_mint_tokens)
-  [Function `create_liquid_coin`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_liquid_coin)
-  [Function `claim`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_claim)
-  [Function `liquify_rena`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_liquify_rena)
-  [Function `admin_lockup_nfts`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_lockup_nfts)
-  [Function `admin_release_nft`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_release_nft)
-  [Function `admin_reconcile_pool`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_reconcile_pool)
-  [Function `set_fee`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_set_fee)
-  [Function `fee`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_fee)


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
<b>use</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin">0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05::liquid_coin</a>;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_RenegadeCoin"></a>

## Struct `RenegadeCoin`

The Renegade coin


<pre><code><b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_RenegadeCoin">RenegadeCoin</a>
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Fee"></a>

## Resource `Fee`

Global storage for fee


<pre><code><b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Fee">Fee</a> <b>has</b> key
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_CollectionCreated"></a>

## Struct `CollectionCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_CollectionCreated">CollectionCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidTokensCreated"></a>

## Struct `LiquidTokensCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidTokensCreated">LiquidTokensCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidCoinCreated"></a>

## Struct `LiquidCoinCreated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_LiquidCoinCreated">LiquidCoinCreated</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_FeeUpdated"></a>

## Struct `FeeUpdated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_FeeUpdated">FeeUpdated</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Claimed"></a>

## Struct `Claimed`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Claimed">Claimed</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Liquified"></a>

## Struct `Liquified`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_Liquified">Liquified</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_ENOT_ENOUGH_APT_TO_PAY_FEE"></a>

The signer does not have enough APT to pay the fee.


<pre><code><b>const</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_ENOT_ENOUGH_APT_TO_PAY_FEE">ENOT_ENOUGH_APT_TO_PAY_FEE</a>: u64 = 2;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_ENOT_RENA"></a>

The signer is not Rena account.


<pre><code><b>const</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_ENOT_RENA">ENOT_RENA</a>: u64 = 1;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_EURI_COUNT_MISMATCH"></a>

The number of URIs does not match the number of tokens.


<pre><code><b>const</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_EURI_COUNT_MISMATCH">EURI_COUNT_MISMATCH</a>: u64 = 3;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_collection"></a>

## Function `create_collection`

Create a collection


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_collection">create_collection</a>(signer_ref: &<a href="">signer</a>, collection_description: <a href="_String">string::String</a>, collection_name: <a href="_String">string::String</a>, collection_supply: u64, collection_uri: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_mint_tokens"></a>

## Function `mint_tokens`

Mint a batch of tokens


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_mint_tokens">mint_tokens</a>(signer_ref: &<a href="">signer</a>, collection_obj: <a href="_Object">object::Object</a>&lt;<a href="_Collection">collection::Collection</a>&gt;, token_count: u64, tokens_description: <a href="_String">string::String</a>, folder_uri: <a href="_String">string::String</a>, prefix: <a href="_String">string::String</a>, suffix: <a href="_String">string::String</a>, royalty_numerator: u64, royalty_denominator: u64)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_liquid_coin"></a>

## Function `create_liquid_coin`

Create a liquid coin (Legacy coin standard)


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_create_liquid_coin">create_liquid_coin</a>&lt;CoinType&gt;(signer_ref: &<a href="">signer</a>, collection_addr: <b>address</b>, coin_name: <a href="_String">string::String</a>, coin_symbol: <a href="_String">string::String</a>, decimals: u8)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_claim"></a>

## Function `claim`

Claim an X number of liquid NFT by providing an X number of liquid coins


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_claim">claim</a>&lt;CoinType&gt;(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, count: u64)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_liquify_rena"></a>

## Function `liquify_rena`

Liquify an X number of Renegade NFT to get an X number of Renegade coins


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_liquify_rena">liquify_rena</a>(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_lockup_nfts"></a>

## Function `admin_lockup_nfts`

For initial lockup, and in the event some NFTs are transferred incorrectly


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_lockup_nfts">admin_lockup_nfts</a>(signer_ref: &<a href="">signer</a>, metadata: <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;<a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_RenegadeCoin">core::RenegadeCoin</a>&gt;&gt;, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_release_nft"></a>

## Function `admin_release_nft`

Release NFTs that are in the lockup object but not in the list.


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_release_nft">admin_release_nft</a>(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_reconcile_pool"></a>

## Function `admin_reconcile_pool`

Reconile pool


<pre><code>entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_admin_reconcile_pool">admin_reconcile_pool</a>&lt;<a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_RenegadeCoin">RenegadeCoin</a>&gt;(signer_ref: &<a href="">signer</a>, metadata: <b>address</b>, tokens: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_set_fee"></a>

## Function `set_fee`

Set fees for claiming and liquifying; Admin specific


<pre><code><b>public</b> entry <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_set_fee">set_fee</a>(signer_ref: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_fee"></a>

## Function `fee`

Get the fee


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="core.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_core_fee">fee</a>(): u64
</code></pre>
