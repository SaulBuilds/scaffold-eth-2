// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "mUSDC") {
        _mint(msg.sender, 1000000 * 10**decimals()); // Mint 1 million mUSDC for the deployer
    }

    function decimals() public view virtual override returns (uint8) {
        return 6; // USDC typically uses 6 decimal places
    }
}
