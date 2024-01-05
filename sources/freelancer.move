module defreelance::freelancer{

    use std::string::{Self, String};

    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::object_table::{Self, ObjectTable};
    use sui::event;

    const EINSUFFICIENT_FUNDS: u64 = 0;
    const ENOACCESS: u64 = 1;
    const ENOTENOUGHPAYMENT: u64 = 2;
    const ETASKCOMPLETED: u64 = 4;
    const MIN_PUBLISH_PAYMENT: u64 = 3;


    struct Task has key, store{
        id: UID,
        title: String,
        description: String,
        deadline: u64, // unix time
        client: address,
        payment: u64,
        completed: bool,
    }


    struct Freelancer has key, store{
        id: UID,
        name: String,
        owner: address,
        title: String,
        img_url: Url,
        description: String,
        years_of_exp: u8,
        technologies: String,
        portfolio: String,
        contact: String,
    }


    struct FreelancePlatform has key {
        id: UID,
        owner: address,
        taskCounter: u64,
        freelancerCounter: u64,
        tasks: ObjectTable<u64, Task>,
        freelancers: ObjectTable<u64, Freelancer>,
    
    }

    struct FreelancerMembershipCreated has copy, drop {
        id: ID,
        name: String,
        owner: address,
        title: String,
        contact: String
    }

    struct TaskCreated has copy, drop {
        id: ID,
        title: String,
        client: address
    }

    fun init(ctx: &mut TxContext){
        transfer::share_object(
            FreelancePlatform {
                id: object::new(ctx),
                owner: tx_context::sender(ctx),
                taskCounter: 0,
                freelancerCounter: 0,
                tasks: object_table::new(ctx),
                freelancers: object_table::new(ctx),
            }
        );
    }


    public entry fun createFreelancer(
        name: vector<u8>,
        title: vector<u8>,
        img_url: vector<u8>,
        years_of_exp: u8,
        technologies: vector<u8>,
        portfolio: vector<u8>,
        description: vector<u8>,
        contact: vector<u8>,
        freelancerPlatform: &mut FreelancePlatform,
        ctx: &mut TxContext
    ) {
        freelancerPlatform.freelancerCounter = freelancerPlatform.freelancerCounter + 1;
        let id = object::new(ctx);

        event::emit(
            FreelancerMembershipCreated {
                id: object::uid_to_inner(&id), 
                name: string::utf8(name), 
                owner: tx_context::sender(ctx), 
                title: string::utf8(title), 
                contact: string::utf8(contact) 
            }
        );


        let freelancer = Freelancer {
            id: id,
            name: string::utf8(name),
            owner: tx_context::sender(ctx),
            title: string::utf8(title),
            img_url: url::new_unsafe_from_bytes(img_url),
            description: string::utf8(description),
            years_of_exp: years_of_exp,
            technologies: string::utf8(technologies),
            portfolio: string::utf8(portfolio),
            contact: string::utf8(contact),
        };

        object_table::add(&mut freelancerPlatform.freelancers, freelancerPlatform.freelancerCounter, freelancer)

    }


    public entry fun createTask(
    title: vector<u8>,
    description: vector<u8>,
    deadline: u64,
    taskPublishPayment: Coin<SUI>,
    freelancePlatform: &mut FreelancePlatform,
    ctx: &mut TxContext
    ) {

        let value = coin::value(&taskPublishPayment);
    
        assert!(value >= MIN_PUBLISH_PAYMENT, EINSUFFICIENT_FUNDS);
    
       
        freelancePlatform.taskCounter = freelancePlatform.taskCounter + 1;

        transfer::public_transfer(taskPublishPayment, freelancePlatform.owner);
       
        let taskId = object::new(ctx);

        event::emit(
            TaskCreated {
                id: object::uid_to_inner(&taskId),
                title: string::utf8(title),
                client: tx_context::sender(ctx),
            },
        );

        let task = Task {
            id: taskId,
            title: string::utf8(title),
            description: string::utf8(description),
            deadline: deadline,
            client: tx_context::sender(ctx),
            payment: value,
            completed: false 
        };


        object_table::add(&mut freelancePlatform.tasks, freelancePlatform.taskCounter, task);
        
    }


    public entry fun completeTask(
    taskId: u64,
    freelancerAddress: address,
    coinPayment: Coin<SUI>,
    freelancePlatform: &mut FreelancePlatform,
    ctx: &mut TxContext
) {

    let task = object_table::borrow_mut(&mut freelancePlatform.tasks, taskId);

    assert!(task.completed == false, ETASKCOMPLETED);
    assert!(tx_context::sender(ctx) == task.client, ENOACCESS);

    let value =  coin::value(&coinPayment);

    assert!(value >= task.payment, ENOTENOUGHPAYMENT);

    transfer::public_transfer(coinPayment, freelancerAddress);


    // Remove the completed task from the object table
    task.completed = true;
   
}

  #[test_only]
    // Not public by default

    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);

}



}