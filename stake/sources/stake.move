/*
    Stake Rena Token

    TODOs: 
        - should view functions return option?
*/

module rena::stake {

    use aptos_framework::object::{Self, ExtendRef};
    use aptos_framework::timestamp;
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::simple_map::{Self, SimpleMap};
    use aptos_token_objects::token::{Self, Token};
    use std::event;
    use std::signer; 
    use std::vector;

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
        if (staker_exists(user_addr)) {
            assert!(is_staked(user_addr, token_addr), ENOT_STAKED);
        };
    }

    /// Assert that the token is not already staked
    inline fun assert_token_not_staked(user_addr: address, token_addr: address) {
        if (staker_exists(user_addr)) {
            assert!(!is_staked(user_addr, token_addr), EALREADY_STAKED);
        };
    }

    /// Asserts that the staker exists
    inline fun assert_staker_exists(staker_addr: address) acquires GlobalInfo {
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
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
            stake_token_new_staker(signer_ref, token);
        } else {
            stake_token_existing_staker(signer_ref, token);
        };
        // transfer the token to the staking object
        object::transfer_call(signer_ref, token, obj());
        // emit the staked event
        event::emit(Staked { user: signer_addr, token } );

        token
    }

    /// Internal function to stake a token assuming the staker does not exist
    inline fun stake_token_new_staker(signer_ref: &signer, token: address): address acquires GlobalInfo {
        let tokens = simple_map::new<address, u64>();
        simple_map::add<address, u64>(&mut tokens, token, timestamp::now_seconds());
        // add a new entry for the staker
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        smart_table::add<address, StakeInfo>(
            &mut global_info.table,
            signer::address_of(signer_ref),
            StakeInfo {
                tokens,
                accumulated_time: 0
            }
        );

        token
    }

    /// Internal function to stake a token assuming the staker exists
    inline fun stake_token_existing_staker(signer_ref: &signer, token: address): address acquires GlobalInfo {
        // let stake_info = user_stake_info(signer::address_of(signer_ref));
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, signer::address_of(signer_ref));
        simple_map::add<address, u64>(&mut stake_info.tokens, token, timestamp::now_seconds());

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
        // let stake_info = user_stake_info(signer::address_of(signer_ref));
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, signer::address_of(signer_ref));
        let stake_timestamp = *simple_map::borrow<address, u64>(&stake_info.tokens, &token);
        let accumulated_time = timestamp::now_seconds() - stake_timestamp;
        // update the accumulated time
        let mut_global_info = borrow_global_mut<GlobalInfo>(@rena);
        let mut_stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut mut_global_info.table, signer::address_of(signer_ref));
        mut_stake_info.accumulated_time = mut_stake_info.accumulated_time + accumulated_time;
        // remove the token from the staked tokens
        let (token, _) = simple_map::remove<address, u64>(&mut mut_stake_info.tokens, &token);
        // transfer the token back to the user
        object::transfer_call(&staking_object_signer(), token, signer::address_of(signer_ref));
        // emit the unstaked event
        event::emit(Unstaked { user: signer::address_of(signer_ref), token } );

        token
    }

    /// Checks if the token is rena
    inline fun is_rena(token_addr: address): bool {
        let token_obj = object::address_to_object<Token>(token_addr);
        let collection_obj = token::collection_object(token_obj);
        let collection_addr = object::object_address(&collection_obj);
        if (collection_addr == @rena_collection) true else false
    }

    /// Checks if a token is staked
    inline fun is_staked(staker_addr: address, token_addr: address): bool {
        // let stake_info = user_stake_info(staker_addr);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, staker_addr);
        if (
            simple_map::contains_key<address, u64>(&mut stake_info.tokens, &token_addr)
            && object::is_owner(object::address_to_object<Token>(token_addr), obj())
        ) true else false
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
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        smart_table::contains<address, StakeInfo>(&global_info.table, staker_addr)
    }

    // -----------
    // Public APIs
    // -----------

    #[view]
    /// Get the stake info of the caller
    public fun stake_info(addr: address): StakeInfo acquires GlobalInfo { 
        // *user_stake_info(addr) 
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        *smart_table::borrow<address, StakeInfo>(&global_info.table, addr)
    }

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
        // let stake_info = user_stake_info(user);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, user);
        let start_stake_timestamp = *simple_map::borrow<address, u64>(&stake_info.tokens, &token);
        (timestamp::now_seconds() - start_stake_timestamp)
    }

    // ----------
    // Unit tests
    // ----------

    #[test_only]
    use std::option::{Self, Option};
    #[test_only]
    use aptos_framework::object::{ConstructorRef, Object};
    #[test_only]
    use std::string::{Self, String};
    #[test_only]
    use aptos_token_objects::collection;
    #[test_only]
    use std::debug;

    #[test_only]
    fun setup_test(std: &signer, rena: &signer, creator: &signer, staker: &signer): (ConstructorRef, vector<address>) {
        timestamp::set_time_has_started_for_testing(std);
        init_module(rena);
        let name = string::utf8(b"collection name");
        let constructor = collection::create_fixed_collection(
            creator, 
            string::utf8(b""), 
            10, 
            name, 
            option::none(), 
            string::utf8(b"")
        );

        let token_one = token::create_token(
            creator,
            object::object_from_constructor_ref(&constructor),
            string::utf8(b"token one description"),
            string::utf8(b"token one"),
            option::none(),
            string::utf8(b"uri")
        );

        let token_two = token::create_token(
            creator,
            object::object_from_constructor_ref(&constructor),
            string::utf8(b"token two description"),
            string::utf8(b"token two"),
            option::none(),
            string::utf8(b"uri")
        );

        object::transfer_call(creator, object::address_from_constructor_ref(&token_one), @0x222);
        object::transfer_call(creator, object::address_from_constructor_ref(&token_two), @0x222);

        let tokens = vector[
            object::address_from_constructor_ref(&token_one),
            object::address_from_constructor_ref(&token_two)
        ];

        (constructor, tokens)
    }

    #[test(std= @0x1, rena = @rena, creator = @0x111, staker = @0x222)]
    /// Common lifecycle of staking and unstaking a token
    fun test_stake(std: &signer, rena: &signer, creator: &signer, staker: &signer) acquires GlobalInfo {
        let (_ /*collection_constructor*/, tokens_addr) = setup_test(std, rena, creator, staker);
        let token_one_addr = *vector::borrow(&tokens_addr, 0);
        let token_two_addr = *vector::borrow(&tokens_addr, 1);

        // stake and unstake token one
        assert!(is_eligible(@0x222, token_one_addr), 1);
        assert!(!staker_exists(@0x222), 2);
        stake(staker, vector[token_one_addr]);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 2);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 1);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 3);
        assert!(is_staked(@0x222, token_one_addr), 4);
        
        unstake(staker, vector[token_one_addr]);
        // let global_info = borrow_global<GlobalInfo>(@rena);
        // assert!(smart_table::length(&global_info.table) == 0, 4);
        // let stake_info = borrow_global_mut<GlobalInfo>(@rena);
        // assert!(smart_table::length(&stake_info.table) == 0, 5);
        // assert!(!staker_exists(@0x222), 5);

        // stake and unstake token two
        assert!(is_eligible(@0x222, token_two_addr), 1);
        // assert!(!staker_exists(@0x222), 2);
        stake(staker, vector[token_two_addr]);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 6);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 7);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 8);
        
        unstake(staker, vector[token_two_addr]);
        // let global_info = borrow_global<GlobalInfo>(@rena);
        // assert!(smart_table::length(&global_info.table) == 0, 9);
        // let stake_info = borrow_global_mut<GlobalInfo>(@rena);
        // assert!(smart_table::length(&stake_info.table) == 0, 10);
        // assert!(!staker_exists(@0x222), 10);
    }

    #[test(std= @0x1, rena = @rena, creator = @0x111, staker = @0x222)]
    /// Test view functions
    fun test_view_functions(std: &signer, rena: &signer, creator: &signer, staker: &signer) acquires GlobalInfo {
        let (_ /*collection_constructor*/, tokens_addr) = setup_test(std, rena, creator, staker);
        let token_one_addr = *vector::borrow(&tokens_addr, 0);
        let token_two_addr = *vector::borrow(&tokens_addr, 1);

        // stake token one
        assert!(is_eligible(@0x222, token_one_addr), 1);
        assert!(!staker_exists(@0x222), 2);
        stake(staker, vector[token_one_addr]);
        let global_info = borrow_global<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 3);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 4);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);

        // move forward in time with 10 seconds
        timestamp::fast_forward_seconds(10);

        // view functions
        stake_info(@0x222);
        // debug::print<SimpleMap<address, u64>>(&staked_tokens(@0x222));
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 5);
        // debug::print<u64>(&stake_time(@0x222, token_one_addr));
        assert!(stake_time(@0x222, token_one_addr) == 10, 7);
        assert!(is_staked(@0x222, token_one_addr), 6);
        // accumlated time updates only when unstaking
        assert!(accumulated_stake_time(@0x222) == 0, 10);
        assert!(is_eligible(@0x222, token_two_addr), 11);

        // unstake
        unstake(staker, vector[token_one_addr]);
        let global_info = borrow_global<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 12);
        assert!(accumulated_stake_time(@0x222) == 10, 14);
    }

    #[test(std= @0x1, rena = @rena, creator = @0x111, staker = @0x222)]
    /// Test staking one token and then staking another token
    fun test_stake_multiple_one_by_one(std: &signer, rena: &signer, creator: &signer, staker: &signer) acquires GlobalInfo {
        let (_ /*collection_constructor*/, tokens_addr) = setup_test(std, rena, creator, staker);
        let token_one_addr = *vector::borrow(&tokens_addr, 0);
        let token_two_addr = *vector::borrow(&tokens_addr, 1);

        // stake token one
        assert!(is_eligible(@0x222, token_one_addr), 1);
        assert!(!staker_exists(@0x222), 2);
        stake(staker, vector[token_one_addr]);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 3);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 4);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 5);
        // debug::print<SimpleMap<address, u64>>(&stake_info.tokens);

        // stake token two
        assert!(is_eligible(@0x222, token_two_addr), 1);
        assert!(staker_exists(@0x222), 2);
        stake(staker, vector[token_two_addr]);
        assert!(staker_exists(@0x222), 7);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 6);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        // debug::print<address>(&token_one_addr);
        // debug::print<address>(&token_two_addr);
        // debug::print<SimpleMap<address, u64>>(&stake_info.tokens);
        assert!(simple_map::length(&stake_info.tokens) == 2, 7);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 2, 8);

    }

    #[test(std= @0x1, rena = @rena, creator = @0x111, staker = @0x222)]
    /// Test staking both tokens, unstaking one token and restaking it
    fun test_restake(std: &signer, rena: &signer, creator: &signer, staker: &signer) acquires GlobalInfo {
        let (_ /*collection_constructor*/, tokens_addr) = setup_test(std, rena, creator, staker);
        let token_one_addr = *vector::borrow(&tokens_addr, 0);
        let token_two_addr = *vector::borrow(&tokens_addr, 1);
        // stake both tokens, unstake one token and restake it
        assert!(is_eligible(@0x222, token_one_addr), 1);
        assert!(is_eligible(@0x222, token_two_addr), 2);
        assert!(!staker_exists(@0x222), 3);
        stake(staker, vector[token_one_addr, token_two_addr]);

        let global_info = borrow_global<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 4);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        // debug::print<address>(&token_one_addr);
        // debug::print<address>(&token_two_addr);
        // debug::print<SimpleMap<address, u64>>(&stake_info.tokens);
        assert!(simple_map::length(&stake_info.tokens) == 2, 5);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 2, 6);

        unstake(staker, vector[token_one_addr]);
        let global_info = borrow_global<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 7);
        assert!(staker_exists(@0x222), 8);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 9);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 1, 10);

        stake(staker, vector[token_one_addr]);
        let global_info = borrow_global_mut<GlobalInfo>(@rena);
        assert!(smart_table::length(&global_info.table) == 1, 11);
        let stake_info = smart_table::borrow_mut<address, StakeInfo>(&mut global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 2, 12);
        // debug::print<u64>(&simple_map::length(&stake_info.tokens));
        // let stake_info = user_stake_info(@0x222);
        let global_info = borrow_global<GlobalInfo>(@rena);
        let stake_info = smart_table::borrow<address, StakeInfo>(&global_info.table, @0x222);
        assert!(simple_map::length(&stake_info.tokens) == 2, 13);

        unstake(staker, vector[token_one_addr, token_two_addr]);
        // let global_info = borrow_global<GlobalInfo>(@rena);
        // assert!(smart_table::length(&global_info.table) == 0, 14);
        // assert!(!staker_exists(@0x222), 15);
    }

    // TODO: (if needed) test accumulated time, basic lifecycle already tested
    
}