// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "hardhat/console.sol";

contract Operations {
    // hardhat console
    // conditionals
    // loops
    // array operations
    // mapping operations
    // enum poerations

    uint256 public myNumber = 123;
    address public myAddress = msg.sender;
    uint256[] public myArray; // A dynamic array
    mapping(uint256 => uint256) public myMapping;

    constructor() {
        // Let's add some initial data for demonstration
        myArray.push(10);
        myArray.push(20);
        myMapping[1] = 100;
    }

    function addToArray(uint256 _value) external {
        myArray.push(_value);
    }

    function addToMapping(uint256 _key, uint256 _value) external {
        myMapping[_key] = _value;
    }

    function printGivenArray(uint256[] memory _myArray) internal pure {
        console.log("--- Logging Array Contents ---");
        for (uint i = 0; i < _myArray.length; i++) {
            // Log each element with its index
            console.log("myArray[%d]:", i, _myArray[i]);
        }
    }

    function printArray() internal view {
        printGivenArray(myArray);
    }

    function print() public view {
        console.log("--- Logging from Solidity ---");
        console.log("myNumber:", myNumber);
        console.log("myAddress:", myAddress);
        // console.log("myArray : ", myArray); // does not
        printArray();
        // To log from a mapping, you must access a specific key.
        console.log("myMapping[1]:", myMapping[1]);
    }

    function simpleIfElse() internal view {
        if (myNumber > 10) {
            console.log("myNumber is greater than 10");
        } else {
            console.log("my number is less than or equal 10");
        }
    }

    function terneryConditional() internal view returns (string memory) {
        return myNumber > 100 ? "Yes" : "No";
    }

    function checkConditionals() public view returns (string memory) {
        simpleIfElse();
        string memory res = terneryConditional();
        console.log("res : ", res);
        return res;
    }

    function simpleForLoop(uint8 _num) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint8 i = 0; i < _num; i++) {
            sum += i;
        }
        return sum;
    }

    function simpleWhileLoop(uint8 _num) internal pure returns (uint256) {
        uint256 sum = 0;
        uint i = 0;
        while (i < _num) {
            sum += i;
            i++;
        }
        return sum;
    }

    function checkLoops(uint8 _num) public pure returns (uint256, bool) {
        uint256 forSum = simpleForLoop(_num);
        uint256 whilesum = simpleWhileLoop(_num);
        bool isEqual = forSum == whilesum;

        return (forSum, isEqual);
    }

    // This function removes an element from an array by swapping it with the last element
    // and then popping. This is a gas-efficient O(1) operation, but it does not preserve
    // the order of the elements in the array.
    function removeAt(uint256[] storage _array, uint256 _index) internal {
        require(_index < _array.length, "index given is out of bound of array");
        // _array[_index] = _array[_array.length - 1];
        for (uint i = _index; i < _array.length - 1; i++) {
            _array[i] = _array[i + 1];
        }
        _array.pop();
    }

    function removeAtMemory(
        uint256[] memory _array,
        uint256 _index
    ) internal pure returns (uint256[] memory) {
        require(_index < _array.length, "index given is out of bound of array");
        // Create a new array to hold the result
        uint256[] memory newArray = new uint256[](_array.length - 1);
        uint256 j = 0;
        for (uint i = 0; i < _array.length; i++) {
            if (i != _index) {
                newArray[j] = _array[i];
                j++;
            }
        }
        return newArray;
    }

    function removeAtMyArray(uint256 _index) internal {
        removeAt(myArray, _index);
    }

    // This does not WORK
    function copyArrayByref(uint256[] memory _cpyArray) internal view {
        _cpyArray = myArray;
    }

    function copyArrayByValueMemory() internal view returns (uint256[] memory) {
        return myArray;
    }

    function copyArrayByValueStorage() internal view returns (uint256[] storage) {
        return myArray;
    }

    function doSomeInArray(uint256[] storage _myArray) internal {
        _myArray.pop();
    }

    // Learning :
    // 1. cant remove at certain index of my choice
    // 2. the removal will require what kind of storage we are using, is it storage or memory, in case of memory, you can't pop
    // 3. the view, pure etc related :
    //   => // view : if you are not changing any storage or reading from storage
    //   => // pure function promises not to modify the state AND not to read from the state.
    // copy happens in way we see in golang append or sorts, you cant do any work of reference if its not storage as state of contract (ie storage is type storage)
    // copy by ref not works
    // if you copyinging value to a new variable, it is a new copy in case of memory.
    function checkArrayOperations(uint256 _num) public {
        // check push;
        console.log("----------push-----------------");
        for (uint256 i = 0; i < _num; i++) {
            myArray.push(i * 2);
        }
        printArray();

        // check removal
        console.log("----------removal-----------------");
        myArray.pop();
        printArray();

        // removal at certain index
        uint256 index = 2;
        console.log(
            "----------removal at index : ",
            index,
            "----------------- "
        );
        removeAtMyArray(2); // it checks also if array got effected then it relfects on the state.
        printArray();

        // copyArray by Ref
        console.log(
            "------------copyArray by Ref------------------ : Does NOT WORK"
        );
        uint256[] memory cpyArray;
        copyArrayByref(cpyArray);
        console.log("Length of copied array", cpyArray.length);
        printGivenArray(cpyArray);
        // removeAtMemory(cpyArray,2); // since copied array is not actually copied, removal like this will give error.
        printGivenArray(cpyArray);

        // copyArray by value
        console.log(
            "------------ copyArray by value Memory ------------------"
        );
        printArray();
        uint256[] memory cpyArray2 = copyArrayByValueMemory();
        console.log("Length of copied array", cpyArray2.length);
        printGivenArray(cpyArray2);
        myArray.pop(); // are they referring to same array or different : the returned array is different copied seperate array.
        console.log("After some element removal from original array");
        console.log("Length of copied array", cpyArray2.length);
        console.log(
            "Both length are same => the coied array is a new seperate array copy of original"
        );
        printGivenArray(cpyArray2);

        console.log("---------copy by storage --------------");
        printArray();
        uint256[] storage cpyArray3 = copyArrayByValueStorage();
        console.log("Length of copied array", cpyArray3.length);
        printGivenArray(cpyArray3);
        myArray.pop();
        console.log("Length of copied array", cpyArray3.length);
        printGivenArray(cpyArray3);
        console.log("effect of original array change happens on the copied array");
    }


    // ------------------------------------------- //

    // Mapping related functions
    // adding element : done
    // getting value for a key : done
    // removing element for a key : done
    // listing KV : not directly possible.
    function removeKV(uint256 _key) public {
        delete myMapping[_key];
    }

    function getMappingValue(uint256 _key)  public view returns (uint256) {
        return myMapping[_key];
    }
    

}
