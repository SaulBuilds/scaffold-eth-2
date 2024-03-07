// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC_ETH_Swap is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    AggregatorV3Interface internal priceFeed;
    IERC20 public usdcToken;

    uint256 private constant PRICE_FEED_DECIMALS = 1e8;
    uint256 private constant USDC_DECIMALS = 1e6;

    mapping(address => uint256) public ethBalances;
    mapping(address => uint256) public usdcBalances;

    event DepositETH(address indexed user, uint256 amount);
    event DepositUSDC(address indexed user, uint256 amount);
    event SwapUSDCForETH(address indexed user, uint256 usdcAmount, uint256 ethAmount);
    event SwapETHForUSDC(address indexed user, uint256 ethAmount, uint256 usdcAmount);

    constructor(address _priceFeed, address _usdcToken) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        usdcToken = IERC20(_usdcToken);
    }

    function getLatestPrice() public view returns (int) {
        (, int price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return price;
    }

    function depositETH() external payable nonReentrant {
        require(msg.value > 0, "Cannot deposit 0 ETH");
        ethBalances[msg.sender] += msg.value;
        emit DepositETH(msg.sender, msg.value);
    }

    function depositUSDC(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot deposit 0 USDC");
        usdcBalances[msg.sender] += amount;
        usdcToken.safeTransferFrom(msg.sender, address(this), amount);
        emit DepositUSDC(msg.sender, amount);
    }

    function swapUSDCForETH(uint256 usdcAmount) external nonReentrant {
        require(usdcBalances[msg.sender] >= usdcAmount, "Insufficient USDC balance");
        int price = getLatestPrice();
        uint256 ethAmount = (uint256(price) * usdcAmount / PRICE_FEED_DECIMALS) / USDC_DECIMALS;
        require(address(this).balance >= ethAmount, "Insufficient ETH balance in contract");

        usdcBalances[msg.sender] -= usdcAmount;
        ethBalances[msg.sender] += ethAmount;
        usdcToken.safeTransferFrom(msg.sender, address(this), usdcAmount);
        payable(msg.sender).transfer(ethAmount);

        emit SwapUSDCForETH(msg.sender, usdcAmount, ethAmount);
    }

    function swapETHForUSDC(uint256 ethAmount) external payable nonReentrant {
        require(msg.value == ethAmount, "ETH amount mismatch");
        int price = getLatestPrice();
        uint256 usdcAmount = ethAmount * uint256(price) / PRICE_FEED_DECIMALS * USDC_DECIMALS;
        require(usdcBalances[address(this)] >= usdcAmount, "Insufficient USDC balance in contract");

        ethBalances[msg.sender] += ethAmount;
        usdcBalances[address(this)] -= usdcAmount;
        usdcToken.safeTransfer(msg.sender, usdcAmount);

        emit SwapETHForUSDC(msg.sender, ethAmount, usdcAmount);
    }

    function withdrawUSDC(uint256 _amount) external onlyOwner nonReentrant {
        require(usdcBalances[address(this)] >= _amount, "Insufficient USDC balance");
        usdcBalances[address(this)] -= _amount;
        usdcToken.safeTransfer(msg.sender, _amount);
    }

    function withdrawETH(uint256 _amount) external onlyOwner nonReentrant {
        require(ethBalances[address(this)] >= _amount, "Insufficient ETH balance");
        ethBalances[address(this)] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}