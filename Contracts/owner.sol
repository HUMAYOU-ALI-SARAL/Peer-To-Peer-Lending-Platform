// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract Ownable{
address public immutable owner;

constructor(){
owner=msg.sender;
}
    function changeCreditState()public onlyOwner{
     
    }


modifier onlyOwner(){
    require(msg.sender==owner,"Not Owner");
    _;
}



}