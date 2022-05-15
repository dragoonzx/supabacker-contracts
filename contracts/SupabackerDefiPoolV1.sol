// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./DefiInterface.sol";

/**
  *  @title Smart-contract that plays the role of a DeFi protocol where backers can deposit and earn interests
*/
contract SupabackerDefiPoolV1 is DefiInterface {

    /**
     * @dev Balance of each user address
     */
    mapping(address => uint256) public userBalance;

    /**
     * @dev Start date of each user deposit
     */
    mapping(address => uint256) public depositStart;

    /**
     * @dev Time spent in user deposit
     */
    mapping(address => uint256) public depositTime;

    /**
     * @dev Interests earn per user
     */
    mapping(address => uint256) public interests;

    /**
     * @dev Event triggered once an address deposited in the contract
     */
    event Deposit(
        address indexed user,
        uint256         amount,
        uint256         timeStart
    );

    /**
      * @notice Moves `_amount` tokens from `_sender` to this contract
      */
    function deposit() public override payable {
        require(msg.value > 0,  "SB: ZERO VALUE");

        userBalance[msg.sender] = userBalance[msg.sender] + msg.value;

        depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Withdraw all amount deposited by a user
     * @param _user address of the user
     */
    function withdraw(address _user) public override payable {
        uint time;
        depositTime[_user] = block.timestamp - depositStart[_user];
        time = depositTime[_user];

        uint256 interestPerSecond =
            31577600 * uint256(userBalance[_user] / 1e8);

        interests[_user] = interestPerSecond * time;
        uint initialUserBalance = userBalance[_user];
        userBalance[_user] = userBalance[_user] + interests[msg.sender];
        (payable(_user)).transfer(userBalance[_user]);
        userBalance[_user] = userBalance[_user] - initialUserBalance;
    }

    function getContractBalance()
        public view override
        returns (uint256)
    {
        return address(this).balance;
    }
}