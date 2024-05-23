/*
    One can liquify the Renegade NFT to get one Renegade coin.
    Similarly, one can claim a Renegade NFT by providing one Renegade coin.

    TODO:
*/

module rena::core {

    use aptos_framework::aptos_coin::AptosCoin as APT;
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object};

    use aptos_std::string_utils;

    use aptos_token_objects::collection::{Self, Collection};
    use aptos_token_objects::royalty;
    use aptos_token_objects::token::{Self, Token as TokenV2};

    use rena::liquid_coin::{Self, LiquidCoinMetadata};

    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    // ---------
    // Constants
    // ---------

    // ------
    // Errors
    // ------

    /// The signer is not Rena account.
    const ENOT_RENA: u64 = 1;
    /// The signer does not have enough APT to pay the fee.
    const ENOT_ENOUGH_APT_TO_PAY_FEE: u64 = 2;
    /// The number of URIs does not match the number of tokens.
    const EURI_COUNT_MISMATCH: u64 = 3;

    // ---------
    // Resources
    // ---------

    /// The Renegade coin
    struct RenegadeCoin {}

    /// Global storage for fee
    struct Fee has key {
        // in APT
        amount: u64
    }

    // ------
    // Events
    // ------

    #[event]
    struct CollectionCreated has drop, store {
        collection_addr: address
    }

    #[event]
    struct LiquidTokensCreated has drop, store {
        collection_obj: Object<Collection>,
        tokens_addr: vector<address>
    }

    #[event]
    struct LiquidCoinCreated has drop, store {
        liquid_coin_metadata_obj_addr: address
    }

    #[event]
    struct FeeUpdated has drop, store {
        old_fee: u64,
        new_fee: u64
    }

    #[event]
    struct Claimed has drop, store {
        tokens: vector<address>,
        coins_deducted: u64
    }

    #[event]
    struct Liquified has drop, store {
        tokens: vector<address>,
        coins_received: u64
    }

    // -----------
    // Initializer
    // -----------

    fun init_module(signer_ref: &signer) {
        // init fee; 0.05 APT
        move_to(signer_ref, Fee { amount: 1000000 });
    }

    // -----------
    // Public APIs
    // -----------

    /// Create a collection
    entry fun create_collection(
        signer_ref: &signer,
        // collection
        collection_description: String,
        collection_name: String,
        collection_supply: u64,
        collection_uri: String,
        // royalty - e.g 5% = 5/100 = 1/20
        royalty_numerator: u64,
        royalty_denominator: u64,
    ) {
        assert!(signer::address_of(signer_ref) == @rena, ENOT_RENA);
        let royalty = option::some(
            royalty::create(royalty_numerator, royalty_denominator, signer::address_of(signer_ref))
        );
        // create a fixed supply collection
        let constructor_ref = collection::create_fixed_collection(
            signer_ref,
            collection_description,
            collection_supply,
            collection_name,
            royalty,
            collection_uri
        );

        // emit events
        event::emit(
            CollectionCreated {
                collection_addr: object::address_from_constructor_ref(&constructor_ref)
            }
        );
    }

    /// Mint a batch of tokens
    entry fun mint_tokens(
        signer_ref: &signer,
        collection_obj: Object<Collection>,
        token_count: u64,
        tokens_description: String,
        folder_uri: String,
        prefix: String,
        suffix: String,
        royalty_numerator: u64,
        royalty_denominator: u64,
    ) {
        assert!(signer::address_of(signer_ref) == @rena, ENOT_RENA);
        let royalty = option::some(
            royalty::create(royalty_numerator, royalty_denominator, signer::address_of(signer_ref))
        );
        let (_, tokens_addr) = create_tokens(
            signer_ref,
            collection_obj,
            token_count,
            tokens_description,
            prefix,
            suffix,
            royalty,
            folder_uri
        );

        // emit events
        event::emit(
            LiquidTokensCreated {
                collection_obj,
                tokens_addr
            }
        );
    }

    /// Create a liquid coin (Legacy coin standard)
    entry fun create_liquid_coin<CoinType>(
        signer_ref: &signer,
        collection_addr: address,
        coin_name: String,
        coin_symbol: String,
        decimals: u8
    ) {
        let collection_obj = object::address_to_object<Collection>(collection_addr);
        // create liquid coin
        let liquid_coin_metadata_obj = liquid_coin::create_liquid_token_internal<CoinType>(
            signer_ref,
            collection_obj,
            coin_name,
            coin_symbol,
            decimals
        );

        // collection created event emission
        event::emit(
            LiquidCoinCreated {
                liquid_coin_metadata_obj_addr: object::object_address(&liquid_coin_metadata_obj)
            }
        );
    }

    /// Claim an X number of liquid NFT by providing an X number of liquid coins
    entry fun claim<CoinType>(
        signer_ref: &signer,
        metadata: address,
        count: u64
    ) acquires Fee {
        retrieve_fee(signer_ref);
        let metadata_obj = object::address_to_object<LiquidCoinMetadata<CoinType>>(metadata);
        let tokens = liquid_coin::claim(signer_ref, metadata_obj, count);
        // emit event
        event::emit(Claimed { tokens, coins_deducted: count });
    }


    /// Liquify an X number of Renegade NFT to get an X number of Renegade coins
    entry fun liquify_rena(
        signer_ref: &signer,
        metadata: address,
        tokens: vector<address>
    ) acquires Fee {
        retrieve_fee(signer_ref);
        let metadata_obj = object::address_to_object<LiquidCoinMetadata<RenegadeCoin>>(metadata);
        liquid_coin::liquify<RenegadeCoin>(signer_ref, metadata_obj, tokens);
        // emit event
        event::emit(Liquified { tokens, coins_received: vector::length(&tokens) });
    }

    /// For initial lockup, and in the event some NFTs are transferred incorrectly
    entry fun admin_lockup_nfts(
        signer_ref: &signer,
        metadata: Object<LiquidCoinMetadata<RenegadeCoin>>,
        tokens: vector<address>
    ) {
        let caller = signer::address_of(signer_ref);
        assert!(object::is_owner(metadata, caller), ENOT_RENA);

        // Note: All Tokens need to be owned by the signer OR the lockup object
        let object_address = object::object_address(&metadata);

        liquid_coin::lockup_nfts_with_check<RenegadeCoin>(signer_ref, object_address, tokens);
    }

    /// Release NFTs that are in the lockup object but not in the list.
    entry fun admin_release_nfts(
        signer_ref: &signer,
        metadata: Object<LiquidCoinMetadata<RenegadeCoin>>,
        token: Object<TokenV2>
    ) {
        let caller = signer::address_of(signer_ref);
        assert!(caller == @rena, ENOT_RENA);

        // release NFTs
        liquid_coin::release_nfts<RenegadeCoin>(signer_ref, metadata, token);
    }

    // -------
    // Helpers
    // -------

    inline fun create_tokens(
        signer_ref: &signer,
        collection: Object<Collection>,
        token_count: u64,
        tokens_description: String,
        prefix: String,
        suffix: String,
        royalty: Option<royalty::Royalty>,
        folder_uri: String // e.g: https://bafybeigha5ts6nn3d362nqb2fsxkyomq5u2lei2a3u32uwz7qz7jy4gg4i.ipfs.nftstorage.link
    ): (vector<Object<TokenV2>>, vector<address>) {
        let tokens = vector::empty<Object<TokenV2>>();
        let tokens_addr = vector::empty();

        // mint tokens
        let first_index = 1 + *option::borrow(&collection::count(collection));
        let last_index = first_index + token_count;
        for (i in first_index..last_index) {
            let token_uri = folder_uri;
            // folder_uri + "/" + i + ".png"
            string::append_utf8(&mut token_uri, b"/");
            string::append(&mut token_uri, string_utils::to_string(&i));
            string::append_utf8(&mut token_uri, b".png");

            let (constructor) = token::create_numbered_token(
                signer_ref,
                collection::name(collection),
                tokens_description,
                prefix,
                suffix,
                royalty,
                token_uri
            );

            vector::push_back(&mut tokens, object::object_from_constructor_ref<TokenV2>(&constructor));
            vector::push_back(&mut tokens_addr, object::address_from_constructor_ref(&constructor));
        };

        (tokens, tokens_addr)
    }

    /// Retrieve fee from the caller
    inline fun retrieve_fee(signer_ref: &signer) acquires Fee {
        let signer_addr = signer::address_of(signer_ref);
        if (signer_addr != @rena) {
            let fee = borrow_global<Fee>(@rena);
            assert!(coin::balance<APT>(signer_addr) >= fee.amount, ENOT_ENOUGH_APT_TO_PAY_FEE);
            // transfer fee
            coin::transfer<APT>(signer_ref, @rena, fee.amount);
        };
    }

    // --------
    // Mutators
    // --------

    /// Set fees for claiming and liquifying; Admin specific
    public entry fun set_fee(
        signer_ref: &signer,
        amount: u64
    ) acquires Fee {
        assert!(signer::address_of(signer_ref) == @rena, ENOT_RENA);
        let fee = borrow_global_mut<Fee>(@rena);
        fee.amount = amount;
        event::emit(FeeUpdated { old_fee: fee.amount, new_fee: amount });
    }

    // ---------
    // View APIs
    // ---------

    #[view]
    /// Get the fee
    public fun fee(): u64 acquires Fee {
        let fee = borrow_global<Fee>(@rena);
        fee.amount
    }

}