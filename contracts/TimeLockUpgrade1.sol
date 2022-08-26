// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TimeLock is Ownable {
    enum Status {LOCK, UNLOCK}

    struct User {
        uint256 amountEth;
        uint256 amountToken;
        address token;
        uint256 lockTime;
        uint256 unlockTime;
        Status status;
    }

    uint256 public ownerFee;
    uint256 public ownerAmountEth;
    uint256 public ownerAmountToken;
    uint256 id;
    mapping(address => mapping(uint256 => User)) public locks;

    event Locked(
        address indexed user,
        address indexed token,
        uint256 tokenAmount,
        uint256 ethAmount,
        uint256 lockTime,
        uint256 unlockTime,
        uint256 id
    );

    constructor(uint256 _ownerFee) {
        ownerFee = _ownerFee;
    }

    function lock(
        uint256 _tokenAmount,
        address _token,
        uint256 _lockTime
    ) external payable {
        require(locks[msg.sender][id].status == Status.UNLOCK, "Already Lock once!");

        if (_token != address(0)) {
            require(IERC20(_token).balanceOf(msg.sender) >= _tokenAmount, "Not enough funds!");
            require(IERC20(_token).allowance(msg.sender, address(this)) >= _tokenAmount, "Have no approve!");
            IERC20(_token).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            ); 
        }
        
        locks[msg.sender][id] = User(
            msg.value,
            _tokenAmount,
            _token,
            block.timestamp,
            block.timestamp + _lockTime,
            Status.LOCK
        );

        emit Locked(
            msg.sender,
            _token,
            _tokenAmount,
            msg.value,
            _lockTime,
            block.timestamp + _lockTime,
            id
        );
        id++;
    }


    function unlock(uint256 _id) external {
        // User storage user = locks[msg.sender];
        require(block.timestamp >= locks[msg.sender][_id].unlockTime, "Amount is still locked");
        require(locks[msg.sender][_id].status == Status.LOCK, "Error");
        if (locks[msg.sender][_id].amountEth > 0) {
            ownerAmountEth += locks[msg.sender][_id].amountEth * (100 - ownerFee) / 100;
            payable(msg.sender).transfer(locks[msg.sender][_id].amountEth - ownerAmountEth);
        }
        if (locks[msg.sender][_id].amountToken > 0) {
            ownerAmountToken += locks[msg.sender][_id].amountToken * (100 - ownerFee) / 100;
            IERC20(locks[msg.sender][_id].token).transfer(msg.sender, locks[msg.sender][_id].amountToken - ownerAmountToken);  
        }
        locks[msg.sender][_id] = User (
            0,
            0,
            address(0),
            0,
            0,
            Status.UNLOCK
        );
    }


    function withdraw(uint256 amountEth, uint256 amountToken, address token) external onlyOwner{
        require(amountEth <= ownerAmountEth, "Not enough funds!");
        require(amountToken <= ownerAmountToken, "Not enough funds!");
        if (amountEth > 0 && amountToken == 0) {
            payable(owner()).transfer(amountEth);
            return;
        } else if (amountToken > 0 && amountEth == 0) {
            IERC20(token).transfer(owner(), amountToken);
            return;
        }

        payable(owner()).transfer(amountEth);
        IERC20(token).transfer(owner(), amountToken);
    }

}


// user karana miqani lock ani miangamic
//usery karana miqani token lock ani
//erkusnel miasin 