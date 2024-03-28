
<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin"></a>

# Module `0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776::liquid_coin`

Liquid coin allows for a coin liquidity on a set of TokenObjects (Token V2)

Note that tokens are mixed together in as if they were all the same value, and are
randomly chosen when withdrawing.  This might have consequences where too many
deposits & withdrawals happen in a short period of time, which can be counteracted with
a timestamp cooldown either for an individual account, or for the whole pool.

How does this work?
- Creator creates a token by calling <code><a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token">create_liquid_token</a>()</code>
- NFT owner calls <code><a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_liquify">liquify</a>()</code> to get a set of liquid coin in exchange for the NFT
- They can now trade the coin directly
- User can call <code><a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_claim">claim</a>()</code> which will withdraw a random NFT from the pool in exchange for tokens


-  [Resource `LiquidCoinMetadata`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata)
-  [Constants](#@Constants_0)
-  [Function `create_liquid_token`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token)
-  [Function `create_liquid_token_internal`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token_internal)
-  [Function `claim`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_claim)
-  [Function `liquify`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_liquify)


<pre><code><b>use</b> <a href="">0x1::aptos_account</a>;
<b>use</b> <a href="">0x1::bcs</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::from_bcs</a>;
<b>use</b> <a href="">0x1::hash</a>;
<b>use</b> <a href="">0x1::math64</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::smart_vector</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::transaction_context</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata"></a>

## Resource `LiquidCoinMetadata`

Metadata for a liquidity token for a collection


<pre><code><b>struct</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata">LiquidCoinMetadata</a>&lt;LiquidCoin&gt; <b>has</b> key
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_ENOUGH_LIQUID_TOKENS"></a>

Can't redeem for tokens, not enough liquid tokens


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_ENOUGH_LIQUID_TOKENS">E_NOT_ENOUGH_LIQUID_TOKENS</a>: u64 = 3;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_FIXED_SUPPLY"></a>

Supply is not fixed, so we can't liquify this collection


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_FIXED_SUPPLY">E_NOT_FIXED_SUPPLY</a>: u64 = 5;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_FRACTIONALIZED_DIGITAL_ASSET"></a>

Metadata object isn't for a fractionalized digital asset


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_FRACTIONALIZED_DIGITAL_ASSET">E_NOT_FRACTIONALIZED_DIGITAL_ASSET</a>: u64 = 4;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_IN_COLLECTION"></a>

Token being liquified is not in the collection for the LiquidToken


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_IN_COLLECTION">E_NOT_IN_COLLECTION</a>: u64 = 6;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_OWNER_OF_COLLECTION"></a>

Can't create fractionalize digital asset, not owner of collection


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_OWNER_OF_COLLECTION">E_NOT_OWNER_OF_COLLECTION</a>: u64 = 1;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_OWNER_OF_TOKEN"></a>

Can't liquify, not owner of token


<pre><code><b>const</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_E_NOT_OWNER_OF_TOKEN">E_NOT_OWNER_OF_TOKEN</a>: u64 = 2;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token"></a>

## Function `create_liquid_token`

Create a liquid token for a collection.

The collection is assumed to be fixed, if the collection is not fixed, then this doesn't work quite correctly


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token">create_liquid_token</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">collection::Collection</a>&gt;, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token_internal"></a>

## Function `create_liquid_token_internal`

Internal function to create the liquid token to help with testing


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_create_liquid_token_internal">create_liquid_token_internal</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">collection::Collection</a>&gt;, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8): <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_claim"></a>

## Function `claim`

Allows for claiming a token from the collection

The token claim is random from all the tokens stored in the contract and returns a list of token addresses


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_claim">claim</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, metadata: <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;, count: u64): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_liquify"></a>

## Function `liquify`

Allows for liquifying a token from the collection

Note: once a token is put into the


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_liquify">liquify</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, metadata: <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;, tokens: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;)
</code></pre>
