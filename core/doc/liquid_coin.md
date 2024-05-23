
<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin"></a>

# Module `0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05::liquid_coin`

Liquid coin allows for a coin liquidity on a set of TokenObjects (Token V2)

Note that tokens are mixed together in as if they were all the same value, and are
randomly chosen when withdrawing.  This might have consequences where too many
deposits & withdrawals happen in a short period of time, which can be counteracted with
a timestamp cooldown either for an individual account, or for the whole pool.

How does this work?
- Creator creates a token by calling <code><a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token">create_liquid_token</a>()</code>
- NFT owner calls <code><a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_liquify">liquify</a>()</code> to get a set of liquid coin in exchange for the NFT
- They can now trade the coin directly
- User can call <code><a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_claim">claim</a>()</code> which will withdraw a random NFT from the pool in exchange for tokens


-  [Resource `LiquidCoinMetadata`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata)
-  [Constants](#@Constants_0)
-  [Function `create_liquid_token`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token)
-  [Function `create_liquid_token_internal`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token_internal)
-  [Function `claim`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_claim)
-  [Function `lockup_nfts`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts)
-  [Function `lockup_nfts_with_check`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts_with_check)
-  [Function `release_nft`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_release_nft)
-  [Function `liquify`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_liquify)
-  [Function `reconcile_pool`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_reconcile_pool)
-  [Function `remove_from_pool`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_remove_from_pool)
-  [Function `lockup_nft_count`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nft_count)
-  [Function `locked_up_coin_count`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_coin_count)
-  [Function `contains_nft`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_contains_nft)
-  [Function `locked_up_nfts`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_nfts)


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



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata"></a>

## Resource `LiquidCoinMetadata`

Metadata for a liquidity token for a collection


<pre><code><b>struct</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata">LiquidCoinMetadata</a>&lt;LiquidCoin&gt; <b>has</b> key
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_IN_POOL"></a>

Can't release token, it's in the pool.


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_IN_POOL">E_IN_POOL</a>: u64 = 7;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_ENOUGH_LIQUID_TOKENS"></a>

Can't redeem for tokens, not enough liquid tokens


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_ENOUGH_LIQUID_TOKENS">E_NOT_ENOUGH_LIQUID_TOKENS</a>: u64 = 3;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_FIXED_SUPPLY"></a>

Supply is not fixed, so we can't liquify this collection


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_FIXED_SUPPLY">E_NOT_FIXED_SUPPLY</a>: u64 = 5;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_FRACTIONALIZED_DIGITAL_ASSET"></a>

Metadata object isn't for a fractionalized digital asset


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_FRACTIONALIZED_DIGITAL_ASSET">E_NOT_FRACTIONALIZED_DIGITAL_ASSET</a>: u64 = 4;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_IN_COLLECTION"></a>

Token being liquified is not in the collection for the LiquidToken


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_IN_COLLECTION">E_NOT_IN_COLLECTION</a>: u64 = 6;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_OWNER_OF_COLLECTION"></a>

Can't create fractionalize digital asset, not owner of collection


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_OWNER_OF_COLLECTION">E_NOT_OWNER_OF_COLLECTION</a>: u64 = 1;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_OWNER_OF_TOKEN"></a>

Can't liquify, not owner of token


<pre><code><b>const</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_E_NOT_OWNER_OF_TOKEN">E_NOT_OWNER_OF_TOKEN</a>: u64 = 2;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token"></a>

## Function `create_liquid_token`

Create a liquid token for a collection.

The collection is assumed to be fixed, if the collection is not fixed, then this doesn't work quite correctly


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token">create_liquid_token</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">collection::Collection</a>&gt;, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token_internal"></a>

## Function `create_liquid_token_internal`

Internal function to create the liquid token to help with testing


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_create_liquid_token_internal">create_liquid_token_internal</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, <a href="">collection</a>: <a href="_Object">object::Object</a>&lt;<a href="_Collection">collection::Collection</a>&gt;, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8): <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_claim"></a>

## Function `claim`

Allows for claiming a token from the collection

The token claim is random from all the tokens stored in the contract and returns a list of token addresses


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_claim">claim</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, metadata: <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;, count: u64): <a href="">vector</a>&lt;<b>address</b>&gt;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts"></a>

## Function `lockup_nfts`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts">lockup_nfts</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, object_address: <b>address</b>, tokens_addr: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts_with_check"></a>

## Function `lockup_nfts_with_check`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nfts_with_check">lockup_nfts_with_check</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, object_address: <b>address</b>, tokens_addr: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_release_nft"></a>

## Function `release_nft`

Release an NFT that is in the pool object but not in the smart vector pool.
Used when a token is mistankenly transferred to the pool object.
Called only by the admin.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_release_nft">release_nft</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, pool_address: <b>address</b>, <a href="">token</a>: <a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_liquify"></a>

## Function `liquify`

Allows for liquifying a token from the collection

Note: once a token is put into the


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_liquify">liquify</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, metadata: <a href="_Object">object::Object</a>&lt;<a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_LiquidCoinMetadata">liquid_coin::LiquidCoinMetadata</a>&lt;LiquidCoin&gt;&gt;, tokens_addr: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_reconcile_pool"></a>

## Function `reconcile_pool`

Clear the token pool smart vector and add the given tokens
Useful for reconciling the pool


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_reconcile_pool">reconcile_pool</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>, tokens_addr: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_remove_from_pool"></a>

## Function `remove_from_pool`

Look for a token in the pool and remove it


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_remove_from_pool">remove_from_pool</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>, tokens: <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nft_count"></a>

## Function `lockup_nft_count`

Lookup the locked up NFT count


<pre><code>#[view]
<b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_lockup_nft_count">lockup_nft_count</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_coin_count"></a>

## Function `locked_up_coin_count`

Lookup the locked up coin count


<pre><code>#[view]
<b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_coin_count">locked_up_coin_count</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_contains_nft"></a>

## Function `contains_nft`



<pre><code>#[view]
<b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_contains_nft">contains_nft</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>, nft: <a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;): bool
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_nfts"></a>

## Function `locked_up_nfts`

lookup the locked up NFT adddresses


<pre><code>#[view]
<b>public</b>(<b>friend</b>) <b>fun</b> <a href="liquid_coin.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_liquid_coin_locked_up_nfts">locked_up_nfts</a>&lt;LiquidCoin&gt;(object_address: <b>address</b>): <a href="">vector</a>&lt;<a href="_Object">object::Object</a>&lt;<a href="_Token">token::Token</a>&gt;&gt;
</code></pre>
