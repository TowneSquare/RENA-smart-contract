/*
    Simple presale module for RENA

    TODO:
        - Presale can only happen once?
*/

module rena_multisig::presale {

    use aptos_framework::aptos_account;
    use aptos_framework::aptos_coin::{AptosCoin as APT};
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use aptos_std::math64;
    use aptos_std::simple_map;
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_std::type_info;
    use std::signer;
    use std::string::String;
    use std::vector;
    use rena::core::{RenegadeCoin as RENA};

    // ---------
    // Constants
    // ---------

    // ------
    // Errors
    // ------

    /// The signer is not the RENA treasury
    const ENOT_rena: u64 = 1;
    /// The supply is invalid
    const EINVALID_SUPPLY: u64 = 2;
    /// The start time is invalid
    const EINVALID_START_TIME: u64 = 3;
    /// The end time is invalid
    const EINVALID_END_TIME: u64 = 4;
    /// The presale is active
    const EPRESALE_ACTIVE: u64 = 5;
    /// The presale is not active
    const EPRESALE_NOT_ACTIVE: u64 = 6;
    /// The signer has insufficient funds
    const EINSUFFICIENT_FUNDS: u64 = 7;
    /// The minimum contribution amount is 1 APT
    const EMIN_CONTRIBUTION_AMOUNT_IS_1_APT: u64 = 8;

    // ---------
    // Resources
    // ---------

    /// Global storage for the presale
    struct Info has key {
        treasury: address, // Address to send funds to
        start: u64, // Start time of the presale
        end: u64, // End time of the presale
        contributors: SmartTable<address, u64>, // Map of contributors and their contributions
        raised_funds: coin::Coin<APT>, // Amount of funds raised
        sale_supply: coin::Coin<RENA>, // Amount of RENA tokens for sale
        is_completed: bool
    }

    // ------
    // Events
    // ------

    #[event]
    struct PresaleInitialized has drop, store {
        treasury: address,
        start: u64,
        end: u64,
        sale_cointype: String,
        funds_cointype: String,
        sale_supply: u64
    }

    #[event]
    struct Contributed has drop, store {
        contributor: address,
        amount: u64
    }

    #[event]
    struct ContributionUpdated has drop, store {
        contributor: address,
        updated_amount: u64
    }

    #[event]
    struct ShareDistributed has drop, store {
        cointype: String,
        contributor: address,
        amount: u64
    }

    #[event]
    struct PresaleFinalized has drop, store {
        treasury: address,
        raised_funds: u64
    }

    // ---------------
    // Entry Functions
    // ---------------

    // TODO: delete tag for mainnet
    #[deprecated]
    /// Initialize/schedule the presale
    entry fun init(signer_ref: &signer, treasury_addr: address, start: u64, end: u64, sale_supply: u64) acquires Info {
        let signer_addr = signer::address_of(signer_ref);
        // assert signer is RENA treasury
        assert!(signer_addr == @rena, ENOT_rena);
        // assert there is enough RENA supply
        assert!(sale_supply > 0, EINVALID_SUPPLY);
        assert!(coin::balance<RENA>(signer_addr) >= sale_supply, EINSUFFICIENT_FUNDS);
        // ensure the start time is in the future
        assert!(timestamp::now_seconds() <= start, EINVALID_START_TIME);
        // ensure the end time is after the start time
        assert!(end > start, EINVALID_END_TIME);
        move_to(
            signer_ref,
            Info {
                treasury: treasury_addr,
                start,
                end,
                contributors: smart_table::new(),
                raised_funds: coin::zero<APT>(),
                sale_supply: coin::zero<RENA>(),
                is_completed: false
            }
        );
        // send the RENA tokens to the presale
        let sale_coins = coin::withdraw(signer_ref, sale_supply);
        let info = borrow_global_mut<Info>(@rena);
        coin::merge<RENA>(&mut info.sale_supply, sale_coins);
        // emit event
        event::emit(
            PresaleInitialized {
                treasury: treasury_addr,
                start,
                end,
                sale_cointype: type_info::type_name<RENA>(),
                funds_cointype: type_info::type_name<APT>(),
                sale_supply,
            }
        )
    }

    // // TODO: delete function for mainnet
    // /// Initialize/schedule the presale
    // entry fun re_init(signer_ref: &signer, treasury_addr: address, start: u64, end: u64, sale_supply: u64) acquires Info {
    //     let signer_addr = signer::address_of(signer_ref);
    //     // assert signer is RENA treasury
    //     assert!(signer_addr == @rena, ENOT_rena);
    //     // assert there is enough RENA supply
    //     assert!(sale_supply > 0, EINVALID_SUPPLY);
    //     assert!(coin::balance<RENA>(signer_addr) >= sale_supply, EINSUFFICIENT_FUNDS);
    //     // ensure the start time is in the future
    //     assert!(timestamp::now_seconds() <= start, EINVALID_START_TIME);
    //     // ensure the end time is after the start time
    //     assert!(end > start, EINVALID_END_TIME);
    //     // TODO: to remove after testing?
    //     // ==================================================================
    //     // check if Info resrouce already exists
    //     if (exists<Info>(@rena)) {
    //         // assert is not completed
    //         let info = borrow_global_mut<Info>(@rena);
    //         assert!(info.is_completed, EPRESALE_ACTIVE);
    //         // set the new values
    //         info.treasury = treasury_addr;
    //         info.start = start;
    //         info.end = end;
    //         smart_table::destroy(info.contributors);
    //         info.contributors = smart_table::new();
    //         info.is_completed = false;
    //     } else {
    //     // ==================================================================
    //         move_to(
    //             signer_ref,
    //             Info {
    //                 treasury: treasury_addr,
    //                 start,
    //                 end,
    //                 contributors: smart_table::new(),
    //                 raised_funds: coin::zero<APT>(),
    //                 sale_supply: coin::zero<RENA>(),
    //                 is_completed: false
    //             }
    //         );
    //     };
    //     // send the RENA tokens to the presale
    //     let sale_coins = coin::withdraw(signer_ref, sale_supply);
    //     let info = borrow_global_mut<Info>(@rena);
    //     coin::merge<RENA>(&mut info.sale_supply, sale_coins);
    //     // emit event
    //     event::emit(
    //         PresaleInitialized {
    //             treasury: treasury_addr,
    //             start,
    //             end,
    //             sale_cointype: type_info::type_name<RENA>(),
    //             funds_cointype: type_info::type_name<APT>(),
    //             sale_supply,
    //         }
    //     )
    // }
    
    /// Contribute to the presale
    entry fun contribute(signer_ref: &signer, amount: u64) acquires Info {
        // assert amount is greater than 1 APT
        assert!(amount >= 1 * math64::pow(10, 8), EMIN_CONTRIBUTION_AMOUNT_IS_1_APT);
        let signer_addr = signer::address_of(signer_ref);
        // ensure the presale is not completed
        let info = borrow_global<Info>(@rena);
        assert!(!info.is_completed, EPRESALE_NOT_ACTIVE);
        // ensure the presale is active
        assert!(
            info.start <= timestamp::now_seconds() && timestamp::now_seconds() <= info.end,
            EPRESALE_NOT_ACTIVE
        );
        // assert signer has enough funds
        assert!(coin::balance<APT>(signer_addr) >= amount, EINSUFFICIENT_FUNDS);
        // if signer is already a contributor, update their contribution, else add them to the contributors
        if (smart_table::contains(&info.contributors, signer_addr)) {
            update_contribution(signer_ref, amount);
        } else {
            let info_mut = borrow_global_mut<Info>(@rena);
            // send the funds to raised_funds storage
            let contribution_coin = coin::withdraw(signer_ref, amount);
            coin::merge<APT>(&mut info_mut.raised_funds, contribution_coin);
            // add the signer to the contributors map
            smart_table::add(&mut info_mut.contributors, signer_addr, amount);
            // emit event
            event::emit( Contributed { contributor: signer_addr, amount } );
        }

    }

    /// Finalize the presale
    entry fun finalize(signer_ref: &signer) acquires Info {
        // assert signer is RENA treasury
        assert!(signer::address_of(signer_ref) == @rena, ENOT_rena);
        let info = borrow_global<Info>(@rena);
        let treasury_addr = info.treasury;
        // ensure the presale is not already completed
        assert!(!info.is_completed, EPRESALE_NOT_ACTIVE);
        // ensure the presale is over
        assert!(timestamp::now_seconds() > info.end, EPRESALE_ACTIVE);
        let raised_funds = coin::value<APT>(&info.raised_funds);
        let sale_supply = coin::value<RENA>(&info.sale_supply);
        let contributors_map = smart_table::to_simple_map(&info.contributors);
        let (contributors_vec, contributions_vec) = simple_map::to_vec_pair(contributors_map);
        for (i in 0..vector::length(&contributors_vec)) {
            let contributor = vector::borrow(&contributors_vec, i);
            let contribution = vector::borrow(&contributions_vec, i);
            let share_amount = calculate_share(*contribution, sale_supply, raised_funds);
            distribute_share(*contributor, share_amount);
            // emit event
            event::emit( ShareDistributed { cointype: type_info::type_name<RENA>(), contributor: *contributor, amount: share_amount } );
        };
        // send the raised funds to the treasury
        let info_mut = borrow_global_mut<Info>(@rena);
        let raised_funds_coins = coin::extract<APT>(&mut info_mut.raised_funds, raised_funds);
        aptos_account::deposit_coins(treasury_addr, raised_funds_coins);
        // mark the presale as completed
        info_mut.is_completed = true;
        // emit event
        event::emit( PresaleFinalized { treasury: treasury_addr, raised_funds } );
    }

    // -------
    // Helpers
    // -------

    /// Calculate the share of the contributor
    inline fun calculate_share(contribution: u64, sale_supply: u64, raised_funds: u64): u64 {
        // share = (contribution * sale_supply) / raised_funds
        math64::mul_div(contribution, sale_supply, raised_funds)
    }

    /// Distribute the share of the contributor
    inline fun distribute_share(contributor: address, share_amount: u64) {
        let info_mut = borrow_global_mut<Info>(@rena);
        let share_coins = coin::extract<RENA>(&mut info_mut.sale_supply, share_amount);
        aptos_account::deposit_coins<RENA>(contributor, share_coins);
    }

    // --------
    // Mutators
    // --------

    /// Update contribution
    inline fun update_contribution(signer_ref: &signer, amount: u64) acquires Info {
        // update the contribution of the signer
        let info_mut = borrow_global_mut<Info>(@rena);
        let signer_addr = signer::address_of(signer_ref);
        let contribution_coins = coin::withdraw(signer_ref, amount);
        coin::merge<APT>(&mut info_mut.raised_funds, contribution_coins);
        // update the value corresponding to the signer key in the contributors map
        let old_amount = smart_table::borrow(&info_mut.contributors, signer_addr);
        let new_amount = *old_amount + amount;
        smart_table::upsert(&mut info_mut.contributors, signer_addr, *old_amount + amount);
        // emit event
        event::emit( ContributionUpdated { contributor: signer_addr, updated_amount: new_amount } );
    }
    
    // --------------
    // View functions
    // --------------   

    #[view]
    /// Get the treasury address
    public fun treasury_address(): address acquires Info {
        borrow_global<Info>(@rena).treasury
    }

    #[view]
    /// Get the start time of the presale
    public fun start_time(): u64 acquires Info {
        borrow_global<Info>(@rena).start
    }
    
    #[view]
    /// Get the end time of the presale
    public fun end_time(): u64 acquires Info {
        borrow_global<Info>(@rena).end
    }

    #[view]
    /// Get the remaining time of the presale
    public fun remaining_time(): u64 acquires Info {
        let info = borrow_global<Info>(@rena);
        if (info.is_completed) { 0 } else {
        if (timestamp::now_seconds() > info.end || timestamp::now_seconds() < info.start) { 0 } else {
                info.end - timestamp::now_seconds()
            }
        }
    }

    #[view]
    /// Check if the presale is completed
    public fun is_completed(): bool acquires Info {
        borrow_global<Info>(@rena).is_completed
    }
    
    #[view]
    /// Get the amount of funds raised
    /// TODO: duplicate function, remove before mainnet deployment
    public fun raised_funds(): u64 acquires Info {
        coin::value<APT>(&borrow_global<Info>(@rena).raised_funds)
    }
    
    #[view]
    /// Get the total number of contributors
    public fun total_contributors(): u64 acquires Info {
        let info = borrow_global<Info>(@rena);
        vector::length(&simple_map::keys(&smart_table::to_simple_map(&info.contributors)))
    }

    #[view]
    /// Get the total raised funds
    public fun total_raised_funds(): u64 acquires Info {
        coin::value<APT>(&borrow_global<Info>(@rena).raised_funds)
    }
    
    #[view]
    /// Get the contributed amount of the signer
    /// TODO: should get address as input
    public fun contributed_amount(signer_ref: &signer): u64 acquires Info {
        let info = borrow_global<Info>(@rena);
        let signer_addr = signer::address_of(signer_ref);
        if (smart_table::contains(&info.contributors, signer_addr)) {
            *smart_table::borrow(&info.contributors, signer_addr)
        } else {
            0
        }
    }

    #[view]
    /// Get the contributed amount of the signer
    public fun contributed_amount_from_address(contributor_addr: address): u64 acquires Info {
        let info = borrow_global<Info>(@rena);
        if (smart_table::contains(&info.contributors, contributor_addr)) {
            *smart_table::borrow(&info.contributors, contributor_addr)
        } else {
            0
        }
    }

    // ----------
    // Unit tests
    // ----------

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::aptos_coin;
    #[test_only]
    use aptos_framework::managed_coin;
    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_std::math64::pow;
    #[test_only]
    use std::features;

    #[test_only]
    public fun setup_test(aptos_framework: signer, rena: &signer, rena_treasury: &signer, alice: &signer, bob: &signer, charlie: &signer, eve: &signer) {
        let (aptos_coin_burn_cap, aptos_coin_mint_cap) = aptos_coin::initialize_for_test(&aptos_framework);
        features::change_feature_flags(&aptos_framework, vector[26], vector[]);
        // account::create_account_for_test(signer::address_of(admin));

        account::create_account_for_test(signer::address_of(rena));
        account::create_account_for_test(signer::address_of(rena_treasury));
        account::create_account_for_test(signer::address_of(alice));
        account::create_account_for_test(signer::address_of(bob));
        account::create_account_for_test(signer::address_of(charlie));
        account::create_account_for_test(signer::address_of(eve));

        managed_coin::register<APT>(rena);
        managed_coin::register<APT>(rena_treasury);
        managed_coin::register<APT>(alice);
        managed_coin::register<APT>(bob);
        managed_coin::register<APT>(charlie);
        managed_coin::register<APT>(eve);
        
        // mint some APT
        aptos_coin::mint(&aptos_framework, signer::address_of(rena), 10000 * pow(10, 8));
        aptos_coin::mint(&aptos_framework, signer::address_of(alice), 10000 * pow(10, 8));
        aptos_coin::mint(&aptos_framework, signer::address_of(bob), 10000 * pow(10, 8));
        aptos_coin::mint(&aptos_framework, signer::address_of(charlie), 10000 * pow(10, 8));
        aptos_coin::mint(&aptos_framework, signer::address_of(eve), 10000 * pow(10, 8));
        // destroy APT mint and burn caps
        coin::destroy_mint_cap<APT>(aptos_coin_mint_cap);
        coin::destroy_burn_cap<APT>(aptos_coin_burn_cap);

        managed_coin::initialize<RENA>(rena, b"Rena Coin", b"RENA", 8, true);
        coin::register<RENA>(rena);
        managed_coin::mint<RENA>(rena, signer::address_of(rena), 5000 * pow(10, 8));

        // timestamps
        timestamp::set_time_has_started_for_testing(&aptos_framework);
    }

    #[test(aptos_framework = @0x1, rena = @rena, rena_treasury = @rena_treasury, alice = @0x123, bob = @0x456, charlie = @0x789, eve = @0xabc)]
    fun test_e2e(aptos_framework: signer, rena: &signer, rena_treasury: &signer, alice: &signer, bob: &signer, charlie: &signer, eve: &signer) acquires Info {
        setup_test(aptos_framework, rena, rena_treasury, alice, bob, charlie, eve);
        // initialize the presale
        let start_time = timestamp::now_seconds() + 10;
        let end_time = timestamp::now_seconds() + 360;
        init(rena, @rena_treasury, start_time, end_time, 2500 * pow(10, 8));
        assert!(treasury_address() == @rena_treasury, 1);
        assert!(!coin::is_account_registered<RENA>(signer::address_of(alice)), 1);
        assert!(!coin::is_account_registered<RENA>(signer::address_of(bob)), 1);
        assert!(!coin::is_account_registered<RENA>(signer::address_of(charlie)), 1);
        assert!(!coin::is_account_registered<RENA>(signer::address_of(eve)), 1);
        // assert the presale is not active yet
        assert!(start_time() > timestamp::now_seconds(), 1);

        // forward to the start time
        timestamp::fast_forward_seconds(10);
        // assert the presale is active
        assert!(!is_completed(), 1);
        assert!(start_time() == timestamp::now_seconds(), 2);
        assert!(remaining_time() == (end_time() - start_time()), 3);
        // contribute to the presale
        contribute(alice, 100 * pow(10, 8));
        assert!(total_contributors() == 1, 1);
        assert!(contributed_amount(alice) == 100 * pow(10, 8), 1);
        assert!(raised_funds() == 100 * pow(10, 8), 2);

        // forward 60 seconds
        timestamp::fast_forward_seconds(60);
        assert!(remaining_time() == (end_time() - timestamp::now_seconds()), 4);
        contribute(bob, 200 * pow(10, 8));
        assert!(total_contributors() == 2, 1);
        assert!(contributed_amount(bob) == 200 * pow(10, 8), 1);
        assert!(raised_funds() == 300 * pow(10, 8), 2);

        // forward 60 seconds
        timestamp::fast_forward_seconds(60);
        assert!(remaining_time() == (end_time() - timestamp::now_seconds()), 5);
        contribute(charlie, 300 * pow(10, 8));
        assert!(total_contributors() == 3, 1);
        assert!(contributed_amount(charlie) == 300 * pow(10, 8), 1);
        assert!(raised_funds() == 600 * pow(10, 8), 2);

        // forward 60 seconds
        timestamp::fast_forward_seconds(60);
        assert!(remaining_time() == (end_time() - timestamp::now_seconds()), 6);
        contribute(eve, 200 * pow(10, 8));
        assert!(total_contributors() == 4, 1);
        assert!(contributed_amount(eve) == 200 * pow(10, 8), 1);
        assert!(raised_funds() == 800 * pow(10, 8), 2);
        contribute(eve, 200 * pow(10, 8));
        assert!(total_contributors() == 4, 1);
        assert!(contributed_amount(eve) == 400 * pow(10, 8), 1);
        assert!(raised_funds() == 1000 * pow(10, 8), 2);

        // forward to the end time
        timestamp::fast_forward_seconds(end_time);
        assert!(remaining_time() == 0, 5);
        assert!(!is_completed(), 3);    // completed only when finalized
        assert!(total_contributors() == 4, 1);
        assert!(raised_funds() == 1000 * pow(10, 8), 2);
        let info = borrow_global<Info>(@rena);
        assert!(coin::value<RENA>(&info.sale_supply) == 2500 * pow(10, 8), 1);
        assert!(coin::value<APT>(&info.raised_funds) == 1000 * pow(10, 8), 2);
        // finalize the presale
        let treasury_before_finalize = coin::balance<APT>(@rena_treasury);
        let expected_treasury_balance = raised_funds();
        finalize(rena);
        assert!(coin::balance<RENA>(@rena) == 2500 * pow(10, 8), 1);
        assert!(coin::balance<APT>(@rena_treasury) == expected_treasury_balance + treasury_before_finalize, 2);
        assert!(is_completed(), 4);
        // alice should receive 100 * 2500 / 1000 = 250 RENA
        assert!(coin::balance<RENA>(signer::address_of(alice)) == 250 * pow(10, 8), 1);
        // bob should receive 200 * 2500 / 1000 = 500 RENA
        debug::print<u64>(&coin::balance<RENA>(signer::address_of(bob)));
        debug::print<u64>(&coin::balance<RENA>(signer::address_of(charlie)));
        debug::print<u64>(&coin::balance<RENA>(signer::address_of(eve)));
        assert!(coin::balance<RENA>(signer::address_of(bob)) == 500 * pow(10, 8), 2);
        // charlie should receive 300 * 2500 / 1000 = 750 RENA
        assert!(coin::balance<RENA>(signer::address_of(charlie)) == 750 * pow(10, 8), 3);
        // eve should receive 400 * 2500 / 1000 = 1000 RENA
        assert!(coin::balance<RENA>(signer::address_of(eve)) == 1000 * pow(10, 8), 4);
    }

}