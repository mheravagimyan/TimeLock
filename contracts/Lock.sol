// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract Lock is Ownable {
    enum Status {LOCK, UNLOCK}
    
    struct User {
        address tokenAddress;
        uint256 amountToken;
        uint256 amountEther;
        // uint256 lockTime;
        uint256 unLockTime;
        Status status;
    }

    uint256 public ownerFee;
    uint256 public ownerAmountToken;
    uint256 public ownerAmountEther;

    mapping(address => User) public locks;

    event Locked();

    event UnLocked();

    event Withdraw();

    constructor(uint256 _ownerFee) {

        ownerFee = _ownerFee;
    }

    function lock(uint256 _tokenAmount, uint256 _lockTime, address _token) external payable {
        require(_token == address(0) && msg.value == 0, "Not enough funds");
        require(locks[msg.sender].status == Status.UNLOCK, "Already Lock once!");
        if(_token != address(0) && msg.value == 0){
            require(IERC20(_token).allowance(msg.sender, address(this)) >= _tokenAmount, "Have no approve!");
            require(IERC20(_token).balanceOf(msg.sender) >= _tokenAmount, "Not enough funds!");
            IERC20(_token).transferFrom(msg.sender, address(this), _tokenAmount);
            locks[msg.sender] = User(
                _token,
                _tokenAmount,
                0,
                block.timestamp + _lockTime,
                Status.LOCK
            );
        } else if(_token == address(0) && msg.value > 0){
            payable(address(this)).transfer(msg.value);
            locks[msg.sender] = User(
                address(0),
                0,
                msg.value,
                block.timestamp + _lockTime,
                Status.LOCK
            );
        } else {
            require(IERC20(_token).allowance(msg.sender, address(this)) >= _tokenAmount, "Have no approve!");
            require(IERC20(_token).balanceOf(msg.sender) >= _tokenAmount, "Not enough funds!");
            IERC20(_token).transferFrom(msg.sender, address(this), _tokenAmount);
            payable(address(this)).transfer(msg.value);
            locks[msg.sender] = User(
                _token,
                _tokenAmount,
                msg.value,
                block.timestamp + _lockTime,
                Status.LOCK
            );
        }
    }
    

    function unLock() external payable {
        require(locks[msg.sender].unLockTime <= block.timestamp, "Wait some minute!");
        require(locks[msg.sender].status == Status.LOCK, "Cant unLock!");

        if(msg.value > 0) {
            ownerAmountEther += msg.value * ownerFee / 100;      
            payable(msg.sender).transfer(msg.value - ownerAmountEther);
        }
        if(locks[msg.sender].tokenAddress != address(0)) {
            ownerAmountToken += locks[msg.sender].amountToken * ownerFee / 100;
            IERC20(locks[msg.sender].tokenAddress).transfer(msg.sender, locks[msg.sender].amountToken - ownerAmountToken);
        }

    }

    function withdraw(uint256 _amount) external onlyOwner payable{
        require(address(this).balance >= _amount, "");
        IERC20(locks[msg.sender].tokenAddress).transfer(owner(), _amount);

    }


}