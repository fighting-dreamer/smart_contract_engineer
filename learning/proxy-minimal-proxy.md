## Minimal proxy pattern

- Idea is we use a contract that just calls the implementation contract using delegate call and returns the data to the caller.

- We are not considering any kind of upgradability, its just some contract that sits before other contract and it takes cares of the calls.

- you have address of contract that is to be proxied.
- this proxy contract is going to behave same as the implementation as it is just going to do everything using the logic of implementation

### how it works : 

- the proxy contract have only the fallback function inside it.
- when caller calles any function of implementation contract on proxy address, the proxy contract recieves the calldata but does not find any matching function inside the proxy itself.
- then the fallback of proxy contract is executed, inside the fallback of proxy, we have logic that simply calls the implementation contract using the same calldata using "delegatecall()"
- this calldata itself contains the function of implementation contract to be executed.
- as it is delegate call, the storage is still from the proxy contract.
- the data associated with proxy is used/updated, only logic of implementation contract is used.
- even if you call a function that is not implemented by implementation contract, the relevant fallback of of implementation contract gets triggered using same idea ie the storage of proxy is updated or used while hte logic of fallback from implementation is used.

### How you create such proxy : 

#### approach 1 : MinimalProxyOne

- in this, you have an implementation address, it can be hardcodede as constant or a value at time of deployment from constructor.
- when you call some function on proxy, it goes to fallback.
- the fallbacak delegatecall() to implementation address
- the proxy's storage or balance info etc is used as if it is the implementation contract.
    - even if user sends the ether to proxy, those ether remain in proxy contract, only the msg.value of the delegatecall have same value for calling.
- what ever the result be, that is given back to the user, if it was not success, we are reverting.
- NOTE : we could also check the success and accordingly get the revert reason to ensure better debugging (it will use some assembly)

### approach 2 : using some assembly gymnastics and knowledge of how contracts are encoded.

- in this, we are cloning a contract, but we are not literally cloning it, its more like you are doing exactly what we did in alst implementation but in a more optimised way. we put in the address of contract we want to clone and the clonefactory will create and deploy a contract that is a proxy contract.
- we can use that contract in what ever way we wanted to use hte implementation contract.

### what is clonefactory doing : 

- we are trying to create code of contract to be stored on chain.
- a smart contract at time of creation have two main components : 
    - creation code : this code is executed by EVM and it puts hte runtime code on the chain.
    - runtime code : the active code that one interacts with.
- in this case, the creation code is to be created on the fly in the clonefactory's clone method.
- In this case, the creation code , is also called the bytecode is made of three sections : 
    1. prefix
    2. address
    3. suffix.
- the prefix contains some part creation code and some part runtime code
    - creation code part : `3d602d80600a3d3981f3`, btw, this is the complete creation code here in this case.
    - runtime code part : `363d3d373d3d3d363d73`
- address : its a 20 bytes long string
- suffix : this is runtime code hta delegate th call : `5af43d82803e903d91602b57fd5bf3`

- creation code is : `3d602d80600a3d3981f3`, it copies hte runtime code on hte chain
- runtime code : `363d3d373d3d3d363d73 {address} 5af43d82803e903d91602b57fd5bf3`.

- now the clone funcition is to work for every address supplied to it.
- to make it work, it needs a way to concat strings
- concating string in solidity is not stright forward.
- we put hte data pieices at specific memory locations and then read them in one go, htats how we concatinate here.
- where to start : we need a memory pointer location where it is not disturbing or over-writing any existing data peice : in solidity, the 0x40 slot in memory is special: it contains the "free memory pointer" which points to the end of the currently allocated memory.

- we put hte `prefix` starting at `the free memory pointer`. then we paste `the address` in form of bytes, then the `suffix` section.
- after that, we know that the lendth of our code is fixed 55 bytes, the first 10 bytes from creation code, the 45 bytes from runtime code.
- `creation code` and prefix are not same, `prefix` contains the creation code and some part of runtime code.
- we then call the create method.

