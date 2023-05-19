// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract StrategyExecutor is Ownable, Pausable {
    address public manager;
    address public dexHandler;
    address public strategyOwnerFeeRecipient;
    address public NoyaFeeRecipient;
    
    constructor(
        address _manager,
        address _strategyOwnerFeeRecipient,
        address _dexHandler,
        address _NoyaFeeRecipient
    ) public {
        manager = _manager;
        strategyOwnerFeeRecipient = _strategyOwnerFeeRecipient;
        dexHandler = _dexHandler;
        NoyaFeeRecipient = _NoyaFeeRecipient;
    }

    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == manager, "!manager");
        _;
    }
    
    function setManager(address _manager) external onlyOwner {
        manager = _manager;
    }
    
    function setStrategyOwnerFeeRecipient(address _strategyOwnerFeeRecipient) external onlyOwner {
        strategyOwnerFeeRecipient = _strategyOwnerFeeRecipient;
    }
    
    function setDexHandler(address _dexHandler) external onlyOwner {
        dexHandler = _dexHandler;
    }
    
    function setNoyaFeeRecipient(address _NoyaFeeRecipient) external onlyOwner {
        NoyaFeeRecipient = _NoyaFeeRecipient;
    }
    
    function beforeDeposit() external virtual {}
}
