
<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake"></a>

# Module `0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05::stake`



-  [Resource `GlobalInfo`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_GlobalInfo)
-  [Resource `StakeInfo`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_StakeInfo)
-  [Struct `Staked`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Staked)
-  [Struct `Unstaked`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Unstaked)
-  [Constants](#@Constants_0)
-  [Function `stake`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_stake)
-  [Function `unstake`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_unstake)
-  [Function `stake_info`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_stake_info)
-  [Function `staked_tokens`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staked_tokens)
-  [Function `accumulated_stake_time`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_accumulated_stake_time)
-  [Function `rena_collection`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_rena_collection)
-  [Function `staking_object`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staking_object)
-  [Function `is_eligible`](#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_is_eligible)


<pre><code><b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::smart_table</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x4::collection</a>;
<b>use</b> <a href="">0x4::token</a>;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_GlobalInfo"></a>

## Resource `GlobalInfo`

Global storage for the global stake activity


<pre><code><b>struct</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_GlobalInfo">GlobalInfo</a> <b>has</b> key
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_StakeInfo"></a>

## Resource `StakeInfo`

Global storage for the stake activity of a user


<pre><code><b>struct</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_StakeInfo">StakeInfo</a> <b>has</b> <b>copy</b>, drop, store, key
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Staked"></a>

## Struct `Staked`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Staked">Staked</a> <b>has</b> drop, store
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Unstaked"></a>

## Struct `Unstaked`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_Unstaked">Unstaked</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_OWNER"></a>

The signer is not the owner of the token


<pre><code><b>const</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_OWNER">ENOT_OWNER</a>: u64 = 0;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_EALREADY_STAKED"></a>

The token is already staked


<pre><code><b>const</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_EALREADY_STAKED">EALREADY_STAKED</a>: u64 = 2;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_RENA"></a>

The token is not from the rena collection


<pre><code><b>const</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_RENA">ENOT_RENA</a>: u64 = 1;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_STAKED"></a>

The token is not staked


<pre><code><b>const</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_STAKED">ENOT_STAKED</a>: u64 = 3;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_STAKER"></a>

The staker does not exist


<pre><code><b>const</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_ENOT_STAKER">ENOT_STAKER</a>: u64 = 4;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_stake"></a>

## Function `stake`

Stake rena tokens


<pre><code>entry <b>fun</b> <a href="">stake</a>(signer_ref: &<a href="">signer</a>, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_unstake"></a>

## Function `unstake`

Unstake rena tokens


<pre><code>entry <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_unstake">unstake</a>(signer_ref: &<a href="">signer</a>, tokens: <a href="">vector</a>&lt;<b>address</b>&gt;)
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_stake_info"></a>

## Function `stake_info`

Get the stake info of the caller


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_stake_info">stake_info</a>(addr: <b>address</b>): stake::StakeInfo
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staked_tokens"></a>

## Function `staked_tokens`

Get the staked tokens of the staker


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staked_tokens">staked_tokens</a>(addr: <b>address</b>): <a href="_SimpleMap">simple_map::SimpleMap</a>&lt;<b>address</b>, u64&gt;
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_accumulated_stake_time"></a>

## Function `accumulated_stake_time`

Get the accumulated stake time of the staker


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_accumulated_stake_time">accumulated_stake_time</a>(addr: <b>address</b>): u64
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_rena_collection"></a>

## Function `rena_collection`

Rena collection address


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_rena_collection">rena_collection</a>(): <b>address</b>
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staking_object"></a>

## Function `staking_object`

Rena staking object address


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_staking_object">staking_object</a>(): <b>address</b>
</code></pre>



<a id="0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_is_eligible"></a>

## Function `is_eligible`

Returns whether the token is eligible for staking


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="stake.md#0x4ed27736e724e403f9b4645ffef0ae86fd149503f45b37c428ffabd7e46e5b05_stake_is_eligible">is_eligible</a>(user: <b>address</b>, <a href="">token</a>: <b>address</b>): bool
</code></pre>
