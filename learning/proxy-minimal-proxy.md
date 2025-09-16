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
