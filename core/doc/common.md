
<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common"></a>

# Module `0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05::common`

This is a common friend module

The friend module here is so that logic can be used between all versions of the liquid nft module


-  [Function `create_sticky_object`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_sticky_object)
-  [Function `create_coin`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_coin)
-  [Function `create_fungible_asset`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_fungible_asset)
-  [Function `one_nft_in_coins`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_coins)
-  [Function `one_nft_in_fungible_assets`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_fungible_assets)
-  [Function `one_token_from_decimals`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_token_from_decimals)
-  [Function `pseudorandom_u64`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_pseudorandom_u64)


<pre><code></code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_sticky_object"></a>

## Function `create_sticky_object`

Common logic for creating sticky object for the liquid NFTs


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_sticky_object">create_sticky_object</a>(caller_address: <b>address</b>): (<a href="_ConstructorRef">object::ConstructorRef</a>, <a href="_ExtendRef">object::ExtendRef</a>, <a href="">signer</a>, <b>address</b>)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_coin"></a>

## Function `create_coin`

Mint the supply of the liquid token, destroying the mint capability afterwards


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_coin">create_coin</a>&lt;LiquidCoin&gt;(caller: &<a href="">signer</a>, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8, asset_supply: u64, destination_address: <b>address</b>)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_fungible_asset"></a>

## Function `create_fungible_asset`

Common logic for creating a fungible asset


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_create_fungible_asset">create_fungible_asset</a>(object_address: <b>address</b>, constructor: &<a href="_ConstructorRef">object::ConstructorRef</a>, asset_supply: u64, asset_name: <a href="_String">string::String</a>, asset_symbol: <a href="_String">string::String</a>, decimals: u8, collection_uri: <a href="_String">string::String</a>, project_uri: <a href="_String">string::String</a>)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_coins"></a>

## Function `one_nft_in_coins`

A convenience function, to get the entirety of 1 NFT in a coin's value
10^decimals = 1.0...


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_coins">one_nft_in_coins</a>&lt;LiquidCoin&gt;(): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_fungible_assets"></a>

## Function `one_nft_in_fungible_assets`

A convenience function, to get the entirety of 1 NFT in a fungible asset's value
10^decimals = 1.0...


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_nft_in_fungible_assets">one_nft_in_fungible_assets</a>&lt;T: key&gt;(metadata: <a href="_Object">object::Object</a>&lt;T&gt;): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_token_from_decimals"></a>

## Function `one_token_from_decimals`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_one_token_from_decimals">one_token_from_decimals</a>(decimals: u8): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_pseudorandom_u64"></a>

## Function `pseudorandom_u64`

Generate a pseudorandom number

We use AUID to generate a number from the transaction hash and a globally unique
number, which allows us to spin this multiple times in a single transaction.

We use timestamp to ensure that people can't predict it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="common.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_common_pseudorandom_u64">pseudorandom_u64</a>(size: u64): u64
</code></pre>
