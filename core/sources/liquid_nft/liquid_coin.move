/// Liquid coin allows for a coin liquidity on a set of TokenObjects (Token V2)
///
/// Note that tokens are mixed together in as if they were all the same value, and are
/// randomly chosen when withdrawing.  This might have consequences where too many
/// deposits & withdrawals happen in a short period of time, which can be counteracted with
/// a timestamp cooldown either for an individual account, or for the whole pool.
///
/// How does this work?
/// - Creator creates a token by calling `create_liquid_token()`
/// - NFT owner calls `liquify()` to get a set of liquid coin in exchange for the NFT
/// - They can now trade the coin directly
/// - User can call `claim()` which will withdraw a random NFT from the pool in exchange for tokens
module rena::liquid_coin {

    use std::option;
    use std::signer;
    use std::string::String;
    use std::vector;
    use aptos_std::smart_vector::{Self, SmartVector};
    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::object::{Self, Object, ExtendRef, object_address, is_owner};
    use aptos_token_objects::collection::{Self, Collection};
    use aptos_token_objects::token::{Self, Token as TokenObject};
    use rena::common::{
        one_nft_in_coins,
        pseudorandom_u64,
        create_sticky_object,
        create_coin,
        one_token_from_decimals
    };

    friend rena::core;

    /// Can't create fractionalize digital asset, not owner of collection
    const E_NOT_OWNER_OF_COLLECTION: u64 = 1;
    /// Can't liquify, not owner of token
    const E_NOT_OWNER_OF_TOKEN: u64 = 2;
    /// Can't redeem for tokens, not enough liquid tokens
    const E_NOT_ENOUGH_LIQUID_TOKENS: u64 = 3;
    /// Metadata object isn't for a fractionalized digital asset
    const E_NOT_FRACTIONALIZED_DIGITAL_ASSET: u64 = 4;
    /// Supply is not fixed, so we can't liquify this collection
    const E_NOT_FIXED_SUPPLY: u64 = 5;
    /// Token being liquified is not in the collection for the LiquidToken
    const E_NOT_IN_COLLECTION: u64 = 6;
    /// Can't release token, it's in the pool.
    const E_IN_POOL: u64 = 7;

    /// Metadata for a liquidity token for a collection
    struct LiquidCoinMetadata<phantom LiquidCoin> has key {
        /// The collection associated with the liquid token
        collection: Object<Collection>,
        /// Used for transferring objects
        extend_ref: ExtendRef,
        /// The list of all tokens locked up in the contract
        token_pool: SmartVector<Object<TokenObject>>
    }

    /// Create a liquid token for a collection.
    ///
    /// The collection is assumed to be fixed, if the collection is not fixed, then this doesn't work quite correctly
    public(friend) fun create_liquid_token<LiquidCoin>(
        caller: &signer,
        collection: Object<Collection>,
        asset_name: String,
        asset_symbol: String,
        decimals: u8,
    ) {
        create_liquid_token_internal<LiquidCoin>(caller, collection, asset_name, asset_symbol, decimals);
    }

    /// Internal function to create the liquid token to help with testing
    public(friend) fun create_liquid_token_internal<LiquidCoin>(
        caller: &signer,
        collection: Object<Collection>,
        asset_name: String,
        asset_symbol: String,
        decimals: u8,
    ): Object<LiquidCoinMetadata<LiquidCoin>> {
        // Assert ownership before fractionalizing, this is to ensure there are not duplicates of it
        let caller_address = signer::address_of(caller);
        assert!(object::is_owner(collection, caller_address), E_NOT_OWNER_OF_COLLECTION);

        // Ensure collection is fixed, and determine the number of tokens to mint
        let maybe_collection_supply = collection::count(collection);
        assert!(option::is_some(&maybe_collection_supply), E_NOT_FIXED_SUPPLY);
        let collection_supply = option::destroy_some(maybe_collection_supply);
        let asset_supply = collection_supply * one_token_from_decimals(decimals);

        // Build the object to hold the liquid token
        // This must be a sticky object (a non-deleteable object) to be fungible
        let (_, extend_ref, object_signer, object_address) = create_sticky_object(caller_address);

        // Mint the supply of the liquid token, destroying the mint capability afterwards
        create_coin<LiquidCoin>(caller, asset_name, asset_symbol, decimals, asset_supply, object_address);

        // Add the Metadata, and return the object
        move_to(&object_signer, LiquidCoinMetadata<LiquidCoin> {
            collection, extend_ref, token_pool: smart_vector::new()
        });
        object::address_to_object(object_address)
    }

    /// Allows for claiming a token from the collection
    ///
    /// The token claim is random from all the tokens stored in the contract and returns a list of token addresses
    public(friend) fun claim<LiquidCoin>(
        caller: &signer,
        metadata: Object<LiquidCoinMetadata<LiquidCoin>>,
        count: u64
    ): vector<address> acquires LiquidCoinMetadata {
        let caller_address = signer::address_of(caller);
        let redeem_amount = one_nft_in_coins<LiquidCoin>() * count;

        // Take coins
        assert!(coin::balance<LiquidCoin>(caller_address) >= redeem_amount,
            E_NOT_ENOUGH_LIQUID_TOKENS
        );
        let object_address = object_address(&metadata);
        coin::transfer<LiquidCoin>(caller, object_address, redeem_amount);

        // Transfer tokens
        let liquid_token = borrow_global_mut<LiquidCoinMetadata<LiquidCoin>>(object_address);
        let tokens = vector[];
        for (i in 0..count) {
            let num_tokens = smart_vector::length(&liquid_token.token_pool);
            // Transfer random token to caller
            let random_nft_index = pseudorandom_u64(num_tokens);
            // // if that nft doesn't exist, fetch for another one
            // let maybe_token = *smart_vector::borrow(&liquid_token.token_pool, random_nft_index);
            // // if (!object::is_owner(maybe_token, object_address)) {
            // //     random_nft_index = pseudorandom_u64(num_tokens);
            // // };
            let token = smart_vector::swap_remove(&mut liquid_token.token_pool, random_nft_index);
            let object_signer = object::generate_signer_for_extending(&liquid_token.extend_ref);
            vector::push_back(&mut tokens, object::object_address(&token));
            object::transfer(&object_signer, token, caller_address);
            // num_tokens = num_tokens - 1;
        };

        tokens
    }

    public(friend) fun lockup_nfts<LiquidCoin>(
        caller: &signer,
        object_address: address,
        tokens_addr: vector<address>
    ) acquires LiquidCoinMetadata {
        let liquid_token = borrow_global_mut<LiquidCoinMetadata<LiquidCoin>>(object_address);
        // Take tokens add them to the pool
        vector::for_each(tokens_addr, |token| {
            let token_obj = object::address_to_object<TokenObject>(token);
            object::transfer(caller, token_obj, object_address);
            smart_vector::push_back(&mut liquid_token.token_pool, token_obj);
        });
    }

    public(friend) fun lockup_nfts_with_check<LiquidCoin>(
        caller: &signer,
        object_address: address,
        tokens_addr: vector<address>
    ) acquires LiquidCoinMetadata {
        let caller_address = signer::address_of(caller);
        let liquid_token = borrow_global_mut<LiquidCoinMetadata<LiquidCoin>>(object_address);
        // Take tokens add them to the pool
        vector::for_each(tokens_addr, |token| {
            let token_obj = object::address_to_object<TokenObject>(token);
            assert!(object::is_owner(token_obj, caller_address), E_NOT_OWNER_OF_TOKEN);
            object::transfer(caller, token_obj, object_address);

            // Only add if it doesn't contain it in the list, this is for reconciling
            if (!smart_vector::contains(&mut liquid_token.token_pool, &token_obj)) {
                smart_vector::push_back(&mut liquid_token.token_pool, token_obj);
            }
        });
    }

    /// Release an NFT that is in the pool object but not in the smart vector pool.
    /// Used when a token is mistankenly transferred to the pool object.
    /// Called only by the admin.
    public(friend) fun release_nft<LiquidCoin>(
        caller: &signer,
        pool_address: address,
        token: Object<TokenObject>
    ) acquires LiquidCoinMetadata {
        // Assert the token is in the pool object
        assert!(object::is_owner(token, pool_address), E_NOT_OWNER_OF_TOKEN);
        // Assert the token is not in the smart vector pool
        let liquid_token = borrow_global<LiquidCoinMetadata<LiquidCoin>>(pool_address);
        assert!(!smart_vector::contains(&liquid_token.token_pool, &token), E_IN_POOL);
        // Transfer the token back to the caller
        let object_signer = object::generate_signer_for_extending(&liquid_token.extend_ref);
        object::transfer(&object_signer, token, signer::address_of(caller));
    }

    /// Allows for liquifying a token from the collection
    ///
    /// Note: once a token is put into the
    ///
    public(friend) fun liquify<LiquidCoin>(
        caller: &signer,
        metadata: Object<LiquidCoinMetadata<LiquidCoin>>,
        tokens_addr: vector<address>
    ) acquires LiquidCoinMetadata {
        let caller_address = signer::address_of(caller);
        let liquidify_amount = one_nft_in_coins<LiquidCoin>() * vector::length(&tokens_addr);
        let object_address = object_address(&metadata);
        let collection = borrow_global<LiquidCoinMetadata<LiquidCoin>>(object_address).collection;

        // Check ownership on all tokens and that they're in the collection
        vector::for_each_ref(&tokens_addr, |token| {
            let token_obj = object::address_to_object<TokenObject>(*token);
            assert!(is_owner(token_obj, caller_address), E_NOT_OWNER_OF_TOKEN);
            assert!(token::collection_object(token_obj) == collection, E_NOT_IN_COLLECTION);
        });

        // Ensure there's enough liquid tokens to send out
        assert!(
            coin::balance<LiquidCoin>(object_address) >= liquidify_amount,
            E_NOT_ENOUGH_LIQUID_TOKENS
        );

        // Take tokens add them to the pool
        lockup_nfts<LiquidCoin>(caller, object_address, tokens_addr);

        // Return to caller liquidity coins
        let liquid_token = borrow_global<LiquidCoinMetadata<LiquidCoin>>(object_address);
        let object_signer = object::generate_signer_for_extending(&liquid_token.extend_ref);
        aptos_account::transfer_coins<LiquidCoin>(&object_signer, caller_address, liquidify_amount);
    }

    // --------------
    // View functions
    // --------------

    #[view]
    /// Lookup the locked up NFT count
    public(friend) fun lockup_nft_count<LiquidCoin>(object_address: address): u64 acquires LiquidCoinMetadata {
        let liquid_token = borrow_global_mut<LiquidCoinMetadata<LiquidCoin>>(object_address);
        smart_vector::length(&liquid_token.token_pool)
    }

    #[view]
    /// Lookup the locked up coin count
    public(friend) fun locked_up_coin_count<LiquidCoin>(object_address: address): u64 {
        coin::balance<LiquidCoin>(object_address)
    }

    #[view]
    public(friend) fun contains_nft<LiquidCoin>(
        object_address: address,
        nft: Object<TokenObject>
    ): bool acquires LiquidCoinMetadata {
        let liquid_token = borrow_global_mut<LiquidCoinMetadata<LiquidCoin>>(object_address);
        smart_vector::contains(&liquid_token.token_pool, &nft)
    }

    #[test_only]
    use std::debug;
    #[test_only]
    use std::string;
    #[test_only]
    use rena::common::{setup_test, create_token_objects_collection, create_token_objects};

    #[test_only]
    struct TestToken {}

    #[test_only]
    const ASSET_NAME: vector<u8> = b"LiquidToken";
    #[test_only]
    const ASSET_SYMBOL: vector<u8> = b"L-NFT";

    #[test(creator = @rena, collector = @0xbeef)]
    fun test_nft_e2e(creator: &signer, collector: &signer) acquires LiquidCoinMetadata {
        let (_, collector_address) = setup_test(creator, collector);

        // Setup collection, moving all to a collector
        let collection = create_token_objects_collection(creator);
        let tokens = create_token_objects(creator, collector);

        // Create liquid token
        let metadata_object = create_liquid_token_internal<TestToken>(
            creator,
            collection,
            string::utf8(ASSET_NAME),
            string::utf8(ASSET_SYMBOL),
            8,
        );
        let object_address = object::object_address(&metadata_object);

        // Liquify some tokens
        assert!(!coin::is_account_registered<TestToken>(collector_address), 0);
        for (i in 0..500) {
            liquify(collector, metadata_object, vector[*vector::borrow(&tokens, i)]);
        };
        // liquify(collector, metadata_object, vector[*vector::borrow(&tokens, 0), *vector::borrow(&tokens, 499)]);

        // The tokens should now be in the contract
        debug::print<u64>(&coin::balance<TestToken>(collector_address));
        assert!(coin::balance<TestToken>(collector_address) == 500 * one_nft_in_coins<TestToken>(), 2);
        let metadata = borrow_global<LiquidCoinMetadata<TestToken>>(object_address);
        assert!(500 == smart_vector::length(&metadata.token_pool), 3);

        // Claim the NFTs back
        claim(collector, metadata_object, 500);

        // Tokens should be back with the collector
        assert!(coin::balance<TestToken>(collector_address) == 0, 4);
        let metadata = borrow_global<LiquidCoinMetadata<TestToken>>(object_address);
        assert!(0 == smart_vector::length(&metadata.token_pool), 5);
    }

    #[test(creator = @rena, collector = @0xbeef)]
    #[expected_failure(abort_code = E_NOT_OWNER_OF_COLLECTION, location = Self)]
    fun test_not_owner_of_collection(creator: &signer, collector: &signer) {
        let (_, _) = setup_test(creator, collector);

        // Setup collection, moving all to a collector
        let collection = create_token_objects_collection(creator);
        create_token_objects(creator, collector);
        create_liquid_token_internal<TestToken>(
            collector,
            collection,
            string::utf8(ASSET_NAME),
            string::utf8(ASSET_SYMBOL),
            8,
        );
    }

    #[test(creator = @rena, collector = @0xbeef)]
    #[expected_failure(abort_code = E_NOT_OWNER_OF_TOKEN, location = Self)]
    fun test_not_owner_of_token(creator: &signer, collector: &signer) acquires LiquidCoinMetadata {
        let (_, _) = setup_test(creator, collector);

        // Setup collection, moving all to a collector
        let collection = create_token_objects_collection(creator);
        let tokens = create_token_objects(creator, collector);
        let metadata_object = create_liquid_token_internal<TestToken>(
            creator,
            collection,
            string::utf8(ASSET_NAME),
            string::utf8(ASSET_SYMBOL),
            8,
        );


        liquify(creator, metadata_object, tokens);
    }

    #[test_only]
    public fun create_liquid_coin_for_test(caller: &signer): Object<LiquidCoinMetadata<TestToken>> {
        let collection = create_token_objects_collection(caller);
        let metadata = create_liquid_token_internal<TestToken>(
            caller,
            collection,
            string::utf8(ASSET_NAME),
            string::utf8(ASSET_SYMBOL),
            8,
        );
        // let object_address = object_address(&metadata);

        metadata
    }
}
