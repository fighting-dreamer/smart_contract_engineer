// SPDX-License-Identifier: MIT

// Using structs;
contract OrderAccounting {
    enum OrderStatus {
        PLACED, // Default value, index 0
        CONFIRMED, // 1
        PREPARED, // 2
        ASSIGNED, // 3
        ON_THE_WAY, // 4
        DELIVERED, // 5
        CANCELLED, // 6
        TERMINATED, // 7
        REFUNDED // 8
    }

    struct Item {
        uint256 itemId;
        string itemName;
        uint256 price;
    }

    struct FoodOrder {
        uint256 orderNum;
        Item[] itemList;
        uint256 userId;
        uint256 resturantId;
    }

    mapping(uint256 => mapping(uint256 => FoodOrder)) public userFoodOrderMap; // userID => FoodOrder[], using order-num, get the food-order
    mapping(uint256 => uint256) public userLastOrderNumMap; // user to last order's number;
    mapping(uint256 => mapping(uint256 => OrderStatus)) orderStatusMap;
    constructor() payable {}

    receive() external payable {}

    function _incrementUserOrderCount(
        uint256 _userId
    ) internal returns (uint256) {
        uint256 currentOrderNum = userLastOrderNumMap[_userId];
        userLastOrderNumMap[_userId] = currentOrderNum + 1;
        return currentOrderNum + 1;
    }

    function _setOrderStatus(
        uint256 _userId,
        uint256 _orderNum,
        OrderStatus _status
    ) internal {
        // TODO : check if this order status is one of hte possible next status assignable for given current order status ofr the user.
        orderStatusMap[_userId][_orderNum] = _status;
    }

    function _getItemPrice(
        uint256 _restaurantId,
        uint256 _itemId
    ) internal pure returns (uint256) {
        // sample implementation, retuns in wei
        return _restaurantId * _itemId * 1e9;
    }

    function _processNewFoodOrder(
        uint256 _orderNum,
        FoodOrder memory _foodOrder
    ) internal returns (uint256, FoodOrder memory) {
        // get Item Prices
        uint256 billAmt = 0;
        for (uint i = 0; i < _foodOrder.itemList.length; i++) {
            uint256 price = getItemPrice(
                _foodOrder.resturantId,
                _foodOrder.itemList[i].itemId
            );
            _foodOrder.itemList[i].price = price;
            billAmt += price;
        }
        // update the Order num in the food order struct
        _foodOrder.orderNum = _orderNum;

        return (billAmt, _foodOrder);
    }
    // CRUD
    function addNewOrder(
        uint256 _userId,
        FoodOrder calldata _foodOrder
    ) public payable returns (FoodOrder memory) {
        // update user to order number mapping
        uint256 orderNum = _incrementUserOrderCount(_userId);
        // update user order status
        _setOrderStatus(_userId, orderNum, OrderStatus.PLACED);
        // add foodOrder to user's food order list.
        (
            uint256 billAmt,
            FoodOrder memory processedFoodOrder
        ) = _processNewFoodOrder(orderNum, _foodOrder);

        require(msg.value > billAmt, "user is short on bill");
        userFoodOrderMap[_userId][orderNum] = processedFoodOrder;

        uint256 remainingAmount = msg.value - billAmt;
        // send back remaining amount. // TODO : make it pull based
        bool sent = payable(msg.sender).send(remainingAmount);
        require(sent, "Failed to send back remaining amount");
    }

    function getUserOrderInfo(uint256 _userId, uint256 _orderNum) public view returns(FoodOrder memory) {
        return userFoodOrderMap[_userId][_orderNum];
    }
}
