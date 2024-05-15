// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

error InsufficientFunds(address user, uint256 amount);
error FailedToSendEth();
error FailedToSendWEth();
error InvalidAmount();

contract Vault is ReentrancyGuard {
    event VaultDepositEth(address indexed user, uint256 amount);
    event VaultWithdrawEth(address indexed user, uint256 amount);
    event VaultWrapEthToWEth(address indexed user, uint256 amount);
    event VaultUnwrapWethToEth(address indexed user, uint256 amount);
    event VaultDepositERC20(address indexed user, address token, uint256 amount);
    event VaultWithdrawERC20(address indexed user, address token, uint256 amount);

    using SafeERC20 for IERC20;

    IWETH public immutable weth;
    mapping(address user => uint256 ethBalance) public ethBalances;
    mapping(address tokenAddr => mapping(address user => uint256 tokenBalance)) public tokenBalances;

    constructor(address _wethAddr) {
        weth = IWETH(_wethAddr);
    }

    receive() external payable {
        revert("Call depositEth() to deposit eth");
    }

    function depositEth() external payable {
        ethBalances[msg.sender] += msg.value;
        emit VaultDepositEth(msg.sender, msg.value);
    }

    function withdrawEth(uint256 amount) external nonReentrant {
        if (ethBalances[msg.sender] < amount) revert InsufficientFunds(msg.sender, amount);

        ethBalances[msg.sender] -= amount;
        // async call, mark method with nonRentrant to prevent exploits
        (bool sent, ) = msg.sender.call{value: amount}("");

        if (sent == false) revert FailedToSendEth();

        emit VaultWithdrawEth(msg.sender, amount);
    }

    function wrapEthToWEth(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();
        if (ethBalances[msg.sender] < amount) revert InsufficientFunds(msg.sender, amount);

        ethBalances[msg.sender] -= amount;
        weth.deposit{value: amount}();
        weth.transfer(msg.sender, amount);
        
        tokenBalances[address(weth)][msg.sender] += amount;
        emit VaultWrapEthToWEth(msg.sender, amount);
    }

    function unwrapWEthToEth(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();
        if (tokenBalances[address(weth)][msg.sender] < amount) revert InsufficientFunds(msg.sender, amount);

        weth.transferFrom(msg.sender, address(this), amount);
        weth.withdraw(amount);

        (bool sent, ) = msg.sender.call{value: amount}("");

        if (sent == false) revert FailedToSendWEth();
        emit VaultUnwrapWethToEth(msg.sender, amount);
    }
   
    function depositToken(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[token][msg.sender] += amount;
        emit VaultDepositERC20(msg.sender, token, amount);
    }

    function withdrawToken(address token, uint256 amount) external nonReentrant {
        if (tokenBalances[token][msg.sender] < amount) revert InsufficientFunds(msg.sender, amount);
        tokenBalances[token][msg.sender] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);
        emit VaultWithdrawERC20(msg.sender, token, amount);
    }


}