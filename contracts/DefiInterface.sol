// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface DefiInterface {

    function deposit() 
        external payable;

    function withdraw(address _user)
        external payable;

    function getContractBalance()
        external view
        returns (uint256);
 
}