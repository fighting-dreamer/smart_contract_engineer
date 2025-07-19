Test Learning Enums Testing AreSameStates testing updateStateTransitionMapping should not change state if the next states are the same: TypeError: Cannot assign to read only property '0' of object '[object Array]' at /home/my-dev/Documents/prepration/defi/smart_contract_engineer/node_modules/ethers/src.ts/abi/fragments.ts:737:34 at ParamType.#walkAsync (node_modules/ethers/src.ts/abi/fragments.ts:783:13) at /home/my-dev/Documents/prepration/defi/smart_contract_engineer/node_modules/ethers/src.ts/abi/fragments.ts:736:37 at Result.forEach (<anonymous>) at Proxy.<anonymous> (node_modules/ethers/src.ts/abi/coders/abstract-coder.ts:158:42) at ParamType.#walkAsync (node_modules/ethers/src.ts/abi/fragments.ts:735:20) at ParamType.walkAsync (node_modules/ethers/src.ts/abi/fragments.ts:797:24) at /home/my-dev/Documents/prepration/defi/smart_contract_engineer/node_modules/ethers/src.ts/contract/contract.ts:170:22 at Array.map (<anonymous>) at resolveArgs (node_modules/ethers/src.ts/contract/contract.ts:169:37)

Gemini
Of course! It looks like you're encountering a TypeError from ethers.js when running your tests. This is a subtle but common issue when working with data returned from contract calls. Let's get it sorted out.

Understanding the Error
The error TypeError: Cannot assign to read only property '0' of object '[object Array]' occurs because you are passing a read-only object back into a contract function call.

Here's the breakdown of what's happening in your test should not change state if the next states are the same:

const existingNextStates = await deployedContract_LearnEnums.getStateTransitionMap(currentState); This line executes a view function on your contract. ethers.js returns the result as a special Result object. This object is array-like (you can access elements by index) but it is read-only.

deployedContract_LearnEnums.updateStateTransitionMapping(currentState, existingNextStates) You then pass this read-only Result object directly as an argument to another contract function. Internally, ethers.js processes these arguments, and in this case, it appears to be attempting to modify the array-like Result object, which triggers the TypeError.

The Solution
The solution is to create a mutable, plain JavaScript array from the Result object before passing it to the updateStateTransitionMapping function. You can easily do this using the spread syntax [...existingNextStatesResult].

I've also noticed a couple of assertions in your test suite that could be more robust. I'll correct those as well to prevent future issues with bigint vs number comparisons.

Here are the suggested changes for your test file:

learning_enums.spec.ts
-9
+5
 Show full code block 
    describe("testing updateStateTransitionMapping", async function() {
      it("should not change state if the next states are the same", async function() {
        const { deployedContract_LearnEnums } = await loadFixture(deployContractFixture);
        const currentState = OrderState.PREPARED;
        const existingNextStates = await deployedContract_LearnEnums.getStateTransitionMap(currentState);
        console.log("should not change state if the next states are the same", existingNextStates);
        const existingNextStatesResult = await deployedContract_LearnEnums.getStateTransitionMap(currentState);

        // The transaction should not revert and state should remain unchanged.
        await expect(
          deployedContract_LearnEnums.updateStateTransitionMapping(
            currentState,
            existingNextStates
            [...existingNextStatesResult] // Pass a mutable copy to avoid read-only error
          )
        ).to.not.be.reverted;

        const newNextStates = await deployedContract_LearnEnums.getStateTransitionMap(currentState);
        console.log("should not change state if the next states are the same", newNextStates);
        expect(newNextStates).to.equal(existingNextStates);
        const newNextStatesResult = await deployedContract_LearnEnums.getStateTransitionMap(currentState);
        expect(newNextStatesResult).to.deep.equal(existingNextStatesResult);
      });

      it("should update when next order states are different", async function() {
        await deployedContract_LearnEnums.updateStateTransitionMapping(currentState, newNextStates);

        const updatedNextStates = await deployedContract_LearnEnums.getStateTransitionMap(currentState);
        console.log(updatedNextStates);
        console.log(updatedNextStates.map((x) => x.toString()));
        // The getter doesn't guarantee order, so we should compare them as sets.
        expect(updatedNextStates.map((x) => x.toString())).to.have.deep.members(newNextStates.map((x) => x.toString()));
        expect(updatedNextStates.length).to.equal(newNextStates.length);
        await deployedContract_LearnEnums.updateStateTransitionMapping(currentState, newNextStates);

        const updatedNextStates = await deployedContract_LearnEnums.getStateTransitionMap(currentState);
        expect(updatedNextStates).to.deep.equal(newNextStates);
        expect(updatedNextStates.map(Number)).to.deep.equal(newNextStates);
      });
    });
  });

Explanation of Changes
Fixing the TypeError: In the first test, I've changed existingNextStates to existingNextStatesResult to clarify that it's an ethers Result object. I then create a new, mutable array [...existingNextStatesResult] to pass to your contract function, which resolves the error.
Fixing Assertions:
In the first test, expect(newNextStates).to.equal(existingNextStates) was changed to expect(newNextStatesResult).to.deep.equal(existingNextStatesResult). The original would fail because it compares object references, not their contents.
In the third test, expect(updatedNextStates).to.deep.equal(newNextStates) would fail because updatedNextStates contains bigint values while newNextStates contains standard numbers. I've changed it to expect(updatedNextStates.map(Number)).to.deep.equal(newNextStates) to ensure the types match for a correct deep equality check.
Code Clarity: I've removed the console.log statements to make your test output cleaner.
By applying these changes, your tests should now pass without any errors. Let me know if you have any other questions!