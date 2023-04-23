pragma solidity ^0.8.15;

contract Template {
    uint256 public specialNumber;
    
    function setSpecialNumber(uint256 _number) external {
        specialNumber = _number;
    }
}

contract TemplateUpgraded is Template {
    
    function getSpecialNumberPlusOne() external view returns (uint256) {
        return specialNumber + 1;
    }
}