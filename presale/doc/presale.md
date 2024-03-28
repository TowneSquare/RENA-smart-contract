
<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale"></a>

# Module `0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776::presale`



-  [Resource `Info`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Info)
-  [Struct `PresaleInitialized`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleInitialized)
-  [Struct `Contributed`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Contributed)
-  [Struct `ContributionUpdated`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ContributionUpdated)
-  [Struct `ShareDistributed`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ShareDistributed)
-  [Struct `PresaleFinalized`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleFinalized)
-  [Constants](#@Constants_0)
-  [Function `init`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_init)
-  [Function `contribute`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contribute)
-  [Function `finalize`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_finalize)
-  [Function `treasury_address`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_treasury_address)
-  [Function `start_time`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_start_time)
-  [Function `end_time`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_end_time)
-  [Function `remaining_time`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_remaining_time)
-  [Function `is_completed`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_is_completed)
-  [Function `raised_funds`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_raised_funds)
-  [Function `total_contributors`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_total_contributors)
-  [Function `contributed_amount`](#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contributed_amount)


<pre><code><b>use</b> <a href="">0x1::aptos_account</a>;
<b>use</b> <a href="">0x1::aptos_coin</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::error</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::math64</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::simple_map</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
<b>use</b> <a href="">0x1::type_info</a>;
<b>use</b> <a href="">0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776::core</a>;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Info"></a>

## Resource `Info`

Global storage for the presale


<pre><code><b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Info">Info</a> <b>has</b> key
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleInitialized"></a>

## Struct `PresaleInitialized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleInitialized">PresaleInitialized</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Contributed"></a>

## Struct `Contributed`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_Contributed">Contributed</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ContributionUpdated"></a>

## Struct `ContributionUpdated`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ContributionUpdated">ContributionUpdated</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ShareDistributed"></a>

## Struct `ShareDistributed`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ShareDistributed">ShareDistributed</a> <b>has</b> drop, store
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleFinalized"></a>

## Struct `PresaleFinalized`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_PresaleFinalized">PresaleFinalized</a> <b>has</b> drop, store
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINSUFFICIENT_FUNDS"></a>

The signer has insufficient funds


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINSUFFICIENT_FUNDS">EINSUFFICIENT_FUNDS</a>: u64 = 7;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_END_TIME"></a>

The end time is invalid


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_END_TIME">EINVALID_END_TIME</a>: u64 = 4;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_START_TIME"></a>

The start time is invalid


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_START_TIME">EINVALID_START_TIME</a>: u64 = 3;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_SUPPLY"></a>

The supply is invalid


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EINVALID_SUPPLY">EINVALID_SUPPLY</a>: u64 = 2;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EMIN_CONTRIBUTION_AMOUNT_IS_1_APT"></a>

The minimum contribution amount is 1 APT


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EMIN_CONTRIBUTION_AMOUNT_IS_1_APT">EMIN_CONTRIBUTION_AMOUNT_IS_1_APT</a>: u64 = 8;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ENOT_rena"></a>

The signer is not the RENA treasury


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_ENOT_rena">ENOT_rena</a>: u64 = 1;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EPRESALE_ACTIVE"></a>

The presale is active


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EPRESALE_ACTIVE">EPRESALE_ACTIVE</a>: u64 = 5;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EPRESALE_NOT_ACTIVE"></a>

The presale is not active


<pre><code><b>const</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_EPRESALE_NOT_ACTIVE">EPRESALE_NOT_ACTIVE</a>: u64 = 6;
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_init"></a>

## Function `init`

Initialize/schedule the presale


<pre><code>entry <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_init">init</a>(signer_ref: &<a href="">signer</a>, treasury_addr: <b>address</b>, start: u64, end: u64, sale_supply: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contribute"></a>

## Function `contribute`

Contribute to the presale


<pre><code>entry <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contribute">contribute</a>(signer_ref: &<a href="">signer</a>, amount: u64)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_finalize"></a>

## Function `finalize`

TODO: Withdraw contribution amount/all amount
Finalize the presale


<pre><code>entry <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_finalize">finalize</a>(signer_ref: &<a href="">signer</a>)
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_treasury_address"></a>

## Function `treasury_address`

Get the treasury address


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_treasury_address">treasury_address</a>(): <b>address</b>
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_start_time"></a>

## Function `start_time`

Get the start time of the presale


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_start_time">start_time</a>(): u64
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_end_time"></a>

## Function `end_time`

Get the end time of the presale


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_end_time">end_time</a>(): u64
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_remaining_time"></a>

## Function `remaining_time`

Get the remaining time of the presale


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_remaining_time">remaining_time</a>(): u64
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_is_completed"></a>

## Function `is_completed`

Check if the presale is completed


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_is_completed">is_completed</a>(): bool
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_raised_funds"></a>

## Function `raised_funds`

Get the amount of funds raised


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_raised_funds">raised_funds</a>(): u64
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_total_contributors"></a>

## Function `total_contributors`

Get the total number of contributors


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_total_contributors">total_contributors</a>(): u64
</code></pre>



<a id="0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contributed_amount"></a>

## Function `contributed_amount`

Get the contributed amount of the signer


<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="presale.md#0xa408eaf6de821be63ec47b5da16cbb5a3ab1af6a351d0bab7b6beddaf7802776_presale_contributed_amount">contributed_amount</a>(signer_ref: &<a href="">signer</a>): u64
</code></pre>
