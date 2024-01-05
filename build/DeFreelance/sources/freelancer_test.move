// This module contains tests for the `defreelance::freelancer` module.
// It's marked with `#[test_only]` to indicate that it should only be compiled and run in test environments.
#[test_only]
module defreelance::freelancer_test {

    // Importing necessary modules and structs from the `sui` and `defreelance::freelancer` namespaces.
    use sui::test_scenario;
    use defreelance::freelancer::{Self, FreelancePlatform, Freelancer};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;




    #[test]
    fun test_create_freelancer() {
        // Define addresses for the owner and two users participating in the test.
        let owner = @0xA;
        let freelancer = @0xB;
        let client = @0xC;

        // Begin a new test scenario with the specified owner.
        // This sets up the initial state and context for the test.
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
        defreelance::freelancer::init_for_testing(test_scenario::ctx(scenario));
        };
    
        

        // Start another transaction in the test scenario as the owner.
        test_scenario::next_tx(scenario, owner);
        {
            let freelancePlatform =test_scenario::take_from_sender<FreelancePlatform>(scenario);
            
            // Create a new freelancer with specified details.
            // This is the core action being tested.
            defreelance::freelancer::createFreelancer(
                b"John Doe", 
                b"Software Engineer", 
                b"https://example.com/image.jpg", 
                5, 
                b"Rust, JavaScript", 
                b"https://github.com/johndoe", 
                b"Experienced software engineer with expertise in Rust and JavaScript.", 
                b"john.doe@example.com", 
                &mut freelancePlatform, 
                test_scenario::ctx(scenario)
            );

            // Assert that the creation of the freelancer did not produce any unexpected results.
            // In this case, checking that no `Freelancer` resource was created for the sender.
            assert!(!test_scenario::has_most_recent_for_sender<Freelancer>(scenario), 0);

            // Return the `FreelancePlatform` resource back to the sender's account after the operation.
            test_scenario::return_to_sender(scenario, freelancePlatform);

        };

        test_scenario::next_tx(scenario, freelancer);
        {
            // Assert that a `Freelancer` resource now exists for `user1`.
            // This checks the post-condition of the freelancer creation.
            assert!(test_scenario::has_most_recent_for_sender<Freelancer>(scenario), 0);
            

        };
    

        // End the test scenario and clean up.
        // This typically involves reverting any changes to the state to avoid affecting other tests.
        test_scenario::end(scenario_val);
    }
}
