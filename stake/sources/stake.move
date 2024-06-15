/*
    Stake Rena Token

    TODOs: 
        - 
*/

module rena::stake {

    use aptos_framework::object::{Self, ExtendRef};
    use aptos_framework::timestamp;
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_token_objects::token::{Self, Token};
    use aptos_token_objects::collection::{Collection};
    use std::event;
    use std::signer; 
    use std::vector;

    // ---------
    // Constants
    // ---------

    // ------
    // Errors
    // ------

    /// The signer is not the owner of the token
    const ENOT_OWNER: u64 = 0;
    /// The token is not from the rena collection
    const ENOT_RENA: u64 = 1;
    /// The token is already staked
    const EALREADY_STAKED: u64 = 2;
    /// The token is not staked
    const ENOT_STAKED: u64 = 3;
    /// The staker does not exist
    const ENOT_STAKER: u64 = 4;

    // ---------
    // Resources
    // ---------

    /// Global storage for the global stake activity
    struct GlobalInfo has key {
        /// table holding the stake information for each user
        table: SmartTable<address, StakeInfo>,
        /// Object that holds the staked tokens
        obj: address,
        /// Extend Ref
        extend_ref: ExtendRef
    }

    /// Global storage for the stake activity of a user
    struct StakeInfo has copy, drop, key, store {
        // table holding the tokens staked <token_addr, stake_timestamp>
        tokens: SimpleMap<address, u64>,
        accumulated_time: u64,
    }

    // ------
    // Events
    // ------

    #[event]
    struct Staked has drop, store {
        user: address,
        token: address
    }

    #[event]
    struct Unstaked has drop, store {
        user: address,
        token: address
    }

    // -------
    // Asserts
    // -------

    /// Assert that the signer is the owner of the token
    inline fun assert_signer_is_owner(signer_ref: &signer, token_addr: address) {
        let token_obj = object::address_to_object<Token>(token_addr);
        let signer_addr = signer::address_of(signer_ref);
        assert!(object::is_owner(token_obj, signer_addr), ENOT_OWNER);
    }

    /// Assert that the token is from the rena collection
    inline fun assert_token_is_rena(token_addr: address) {
        assert!(is_rena(token_addr), ENOT_RENA);
    }

    /// Assert that the token is already staked
    inline fun assert_token_staked(user_addr: address, token_addr: address) {
        assert!(is_staked(user_addr, token_addr), ENOT_STAKED);
    }

    /// Assert that the token is not already staked
    inline fun assert_token_not_staked(user_addr: address, token_addr: address) {
        assert!(!is_staked(user_addr, token_addr), EALREADY_STAKED);
    }
    /// Asserts that the staker exists
    inline fun assert_staker_exists(staker_addr: address) acquires GlobalInfo {
        let global_info = borrow_global<GlobalInfo>(@rena);
        assert!(smart_table::contains<address, StakeInfo>(&global_info.table, staker_addr), ENOT_STAKER);
    }

    // --------------------
    // Initializer Function
    // --------------------

    fun init_module(admin_ref: &signer) {
        let constructor = object::create_sticky_object(signer::address_of(admin_ref));
        move_to(
            admin_ref,
            GlobalInfo { 
                table: smart_table::new<address, StakeInfo>(),
                obj: object::address_from_constructor_ref(&constructor),
                extend_ref: object::generate_extend_ref(&constructor)
            }
        )
    }

    // ---------------
    // Entry Functions
    // ---------------

    /// Stake rena tokens
    entry fun stake(signer_ref: &signer, tokens: vector<address>) acquires GlobalInfo {
        stake_internal(signer_ref, tokens);
    }

    /// Unstake rena tokens
    entry fun unstake(signer_ref: &signer, tokens: vector<address>) acquires GlobalInfo {
        unstake_internal(signer_ref, tokens);
    }
    
    // ----------------
    // Helper Functions
    // ----------------

    /// Internal function to stake tokens
    fun stake_internal(signer_ref: &signer, tokens: vector<address>): vector<address> acquires GlobalInfo {
        let staked_tokens = vector::empty<address>();
        for (i in 0..vector::length(&tokens)) {
            let staked_token = stake_one_token(signer_ref, *vector::borrow(&tokens, i));
            vector::push_back(&mut staked_tokens, staked_token);
        };

        staked_tokens
    }

    /// Helper function to stake one token
    inline fun stake_one_token(signer_ref: &signer, token: address): address {
        let signer_addr = signer::address_of(signer_ref);
        // assert signer is owner of the token
        assert_signer_is_owner(signer_ref, token);
        // assert token is from the rena collection
        assert_token_is_rena(token);
        // assert token is not already staked
        assert_token_not_staked(signer_addr, token);
        // add token to the staked tokens
        if (!staker_exists(signer_addr)) {
            // add a new entry for the staker
            let global_info = borrow_global_mut<GlobalInfo>(@rena);
            smart_table::add<address, StakeInfo>(
                &mut global_info.table,
                signer::address_of(signer_ref),
                StakeInfo {
                    tokens: simple_map::new<address, u64>(),
                    accumulated_time: 0
                }
            );
            // add the token to the staked tokens
            let stake_info = user_stake_info(signer::address_of(signer_ref));
            simple_map::add<address, u64>(&mut stake_info.tokens, token, timestamp::now_microseconds());
        } else { 
            let stake_info = user_stake_info(signer::address_of(signer_ref));
            simple_map::add<address, u64>(&mut stake_info.tokens, token, timestamp::now_microseconds());
        };
        // transfer the token to the staking object
        object::transfer_call(signer_ref, token, obj());
        // emit the staked event
        event::emit(Staked { user: signer_addr, token } );

        token
    }

    /// Internal function to unstake tokens
    fun unstake_internal(signer_ref: &signer, tokens: vector<address>): vector<address> acquires GlobalInfo {
        let unstaked_tokens = vector::empty<address>();
        for (i in 0..vector::length(&tokens)) {
            let unstaked_token = unstake_one_token(signer_ref, *vector::borrow(&tokens, i));
            vector::push_back(&mut unstaked_tokens, unstaked_token);
        };

        unstaked_tokens
    }

    /// Helper function to unstake one token
    inline fun unstake_one_token(signer_ref: &signer, token: address): address acquires GlobalInfo {
        assert_token_staked(signer::address_of(signer_ref), token);
        let stake_info = user_stake_info(signer::address_of(signer_ref));
        let stake_timestamp = *simple_map::borrow<address, u64>(&stake_info.tokens, &token);
        let accumulated_time = timestamp::now_microseconds() - stake_timestamp;
        // update the accumulated time
        let mut_global_info = borrow_global_mut<GlobalInfo>(@rena);
        let mut_stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut mut_global_info.table, signer::address_of(signer_ref));
        mut_stake_info.accumulated_time = mut_stake_info.accumulated_time + accumulated_time;
        // remove the token from the staked tokens
        let (token, _) = simple_map::remove<address, u64>(&mut mut_stake_info.tokens, &token);
        // transfer the token back to the user
        object::transfer_call(&staking_object_signer(), token, signer::address_of(signer_ref));
        // if the staker has no more staked tokens, remove the staker
        let mut_global_info = borrow_global_mut<GlobalInfo>(@rena);
        let mut_stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut mut_global_info.table, signer::address_of(signer_ref));
        if (simple_map::length(&mut_stake_info.tokens) == 0) {
            smart_table::remove<address, StakeInfo>(&mut mut_global_info.table, signer::address_of(signer_ref));
        };
        // emit the unstaked event
        event::emit(Unstaked { user: signer::address_of(signer_ref), token } );

        token
    }

    /// Get Stake Info of an input address
    inline fun user_stake_info(staker_addr: address): StakeInfo acquires GlobalInfo {
        assert_staker_exists(staker_addr);
        let global_info = borrow_global<GlobalInfo>(@rena);
        *smart_table::borrow<address, StakeInfo>(&global_info.table, staker_addr)
    }

    /// Checks if the token is rena
    inline fun is_rena(token_addr: address): bool {
        let token_obj = object::address_to_object<Token>(token_addr);
        let collection_obj = object::address_to_object<Collection>(@rena_collection);
        if (token::collection_object(token_obj) == collection_obj) true else false
    }

    /// Checks if a token is staked
    inline fun is_staked(staker_addr: address, token_addr: address): bool {
        let stake_info = user_stake_info(staker_addr);
        simple_map::contains_key<address, u64>(&stake_info.tokens, &token_addr)
    }

    /// Gets the object holding the staked tokens
    inline fun obj(): address acquires GlobalInfo {
        let global_info = borrow_global<GlobalInfo>(@rena);
        global_info.obj
    }

    /// Gets the staking object signer
    inline fun staking_object_signer(): signer acquires GlobalInfo {
        let global_info = borrow_global<GlobalInfo>(@rena);
        object::generate_signer_for_extending(&global_info.extend_ref)
    }

    /// Check if a staker exists
    inline fun staker_exists(staker_addr: address): bool {
        let global_info = borrow_global<GlobalInfo>(@rena);
        smart_table::contains<address, StakeInfo>(&global_info.table, staker_addr)
    }

    // -----------
    // Public APIs
    // -----------

    #[view]
    /// Get the stake info of the caller
    public fun stake_info(addr: address): StakeInfo acquires GlobalInfo { user_stake_info(addr) }

    #[view]
    /// Get the staked tokens of the staker
    public fun staked_tokens(addr: address): SimpleMap<address, u64> acquires GlobalInfo { 
        stake_info(addr).tokens
    }

    #[view]
    /// Get the accumulated stake time of the staker
    public fun accumulated_stake_time(addr: address): u64 acquires GlobalInfo {
        stake_info(addr).accumulated_time
    }

    #[view]
    /// Rena collection address
    public fun rena_collection(): address { @rena_collection }

    #[view]
    /// Rena staking object address
    public fun staking_object(): address acquires GlobalInfo { obj() }

    #[view]
    /// Returns whether the token is eligible for staking
    public fun is_eligible(user: address, token: address): bool {
        let token_obj = object::address_to_object<Token>(token);
        if (object::is_owner(token_obj, user) && is_rena(token)) true else false
    }

    #[view]
    /// Returns the stake time of a token
    public fun stake_time(user: address, token: address): u64 acquires GlobalInfo {
        let stake_info = user_stake_info(user);
        let start_stake_timestamp = *simple_map::borrow<address, u64>(&stake_info.tokens, &token);
        (timestamp::now_microseconds() - start_stake_timestamp)
    }
    
}