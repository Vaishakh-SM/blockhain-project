// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./1_Company.sol";

contract Market {
    CompanyContract companyContract;

    constructor(address _cAddress) {
        companyContract = CompanyContract(_cAddress);
    }

    uint256 OrderId = 0;

    struct Order {
        address seller;
        uint256 companyID;
        uint256 numberOfStocks;
        uint256 rate;
        uint256 orderId;
    }

    mapping(address => mapping(uint256 => uint256)) stockOwnership;
    mapping(address => mapping(uint256 => uint256)) listedStockOwnership;
    mapping(address => uint256) balance;
    mapping(uint256 => Order) listedStocks;

    function produceStocks(uint256 companyID, uint256 amount) public {
        if (companyContract.isOfficial(msg.sender, companyID)) {
            companyContract.addStocks(companyID, amount);
            stockOwnership[msg.sender][companyID] += amount;
        }
    }

    function sell(
        uint256 companyID,
        uint256 rate,
        uint256 amount
    ) public {
        if (amount <= stockOwnership[msg.sender][companyID]) {
            stockOwnership[msg.sender][companyID] -= amount;
            listedStockOwnership[msg.sender][companyID] += amount;
            Order storage newOrder = listedStocks[OrderId];
            OrderId += 1;
            newOrder.seller = msg.sender;
            newOrder.companyID = companyID;
            newOrder.numberOfStocks = amount;
            newOrder.rate = rate;
        }
    }

    function buyCoins() public payable {
        balance[msg.sender] += msg.value;
    }

    function sellCoins(uint256 amount) public payable {
        if (balance[msg.sender] >= amount) {
            address payable payAddress = payable(msg.sender);
            payAddress.transfer(amount);
        }
    }

    function buy(uint256 orderId, uint256 amount) public {
        if (
            listedStocks[orderId].numberOfStocks >= amount &&
            balance[msg.sender] >= amount * listedStocks[orderId].rate
        ) {
            balance[msg.sender] -= amount * listedStocks[orderId].rate;
            balance[listedStocks[orderId].seller] +=
                amount *
                listedStocks[orderId].rate;
            stockOwnership[msg.sender][
                listedStocks[orderId].companyID
            ] += amount;
            listedStocks[orderId].numberOfStocks -= amount;
        }
    }

    function unlist(uint256 orderId, uint256 amount) public {
        if (
            listedStocks[orderId].numberOfStocks >= amount &&
            listedStocks[orderId].seller == msg.sender
        ) {
            stockOwnership[msg.sender][
                listedStocks[orderId].companyID
            ] += amount;
            listedStocks[orderId].numberOfStocks -= amount;
        }
    }

    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function getOwnedStocks()
        public
        view
        returns (uint256[] memory _numberOwned)
    {
        uint256[] memory numberOwned = new uint256[](
            companyContract.companyID()
        );
        for (uint256 i = 0; i < companyContract.companyID(); i++) {
            numberOwned[i] = stockOwnership[msg.sender][i];
        }

        return numberOwned;
    }
}
