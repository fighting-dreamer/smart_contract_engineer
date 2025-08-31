// SPDX-License-Identifier: MIT
import "hardhat/console.sol";

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
        Item[] itemList; // UnimplementedFeatureError: Copying of type struct OrderAccounting.Item memory[] memory to storage not yet supported.
        uint256 userId;
        uint256 resturantId;
    }

    mapping(uint256 => mapping(uint256 => FoodOrder)) public userFoodOrderMap; // userID => FoodOrder[], using order-num, get the food-order
    mapping(uint256 => uint256) public userLastOrderNumMap; // user to last order's number;
    mapping(uint256 => mapping(uint256 => OrderStatus)) public orderStatusMap;
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
    ) internal pure returns (uint256, FoodOrder memory) {
        // get Item Prices
        uint256 billAmt = 0;
        for (uint i = 0; i < _foodOrder.itemList.length; i++) {
            uint256 price = _getItemPrice(
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

    function copyFoodOrderFromMemtoStorage(
        FoodOrder memory _fo,
        FoodOrder storage newOrder
    ) internal returns (FoodOrder storage) {
        newOrder.orderNum = _fo.orderNum;
        newOrder.resturantId = _fo.resturantId;
        newOrder.userId = _fo.userId;
        for (uint i = 0; i < _fo.itemList.length; i++) {
            newOrder.itemList.push(_fo.itemList[i]);
        }

        return newOrder;
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
        copyFoodOrderFromMemtoStorage(
            processedFoodOrder,
            userFoodOrderMap[_userId][orderNum]
        );

        uint256 remainingAmount = msg.value - billAmt;
        // send back remaining amount. // TODO : make it pull based
        bool sent = payable(msg.sender).send(remainingAmount);
        require(sent, "Failed to send back remaining amount");
        // console.log(newOrder.itemList.length);
        console.log(userFoodOrderMap[_userId][orderNum].itemList.length);
        console.log(
            "Order Num , ",
            userFoodOrderMap[_userId][orderNum].orderNum
        );
        console.log("User ID , ", userFoodOrderMap[_userId][orderNum].userId);

        return userFoodOrderMap[_userId][orderNum];
    }

    function getUserOrderInfo(
        uint256 _userId,
        uint256 _orderNum
    ) public view returns (FoodOrder memory) {
        return userFoodOrderMap[_userId][_orderNum];
    }
}
