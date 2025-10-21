// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

contract TaskListApp {
    enum State {
        TODO,
        IN_PROGRESS,
        COMPLETED
    }

    struct Task {
        string message;
        State status;
        uint256 createdOn; // the blocknumber
    }

    mapping(address => Task[]) private tasksByUser;
    uint256 private uniqueUserCount;

    function addTask(string calldata _message) public returns (uint256) {
        Task memory task = Task({message: _message, status: State.TODO, createdOn: block.number});

        tasksByUser[msg.sender].push(task);
        uint256 len = tasksByUser[msg.sender].length;
        if (len == 1) {
            uniqueUserCount = uniqueUserCount + 1;
        }
        return len - 1;
    }

    function getTasks() public view returns (Task[] memory) {
        return tasksByUser[msg.sender];
    }

    // function updateTaskMessage(uint256 _index, string memory message) public returns (bool) {
    //     Task storage task = tasksByUser[msg.sender][_index];

    // }

    // function updateTaskSatus(uint256 _index, State status) public returns (bool) {

    // }
}
