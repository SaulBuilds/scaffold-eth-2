import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy, log } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();

  // Deploy MockUSDC
  const mockUSDCDeployment = await deploy("MockUSDC", {
    from: deployer,
    args: [],
    log: true,
  });

  // Deploy MockChainlinkPriceFeed
  const mockPriceFeedDeployment = await deploy("MockChainlinkPriceFeed", {
    from: deployer,
    args: [3000e8, 8], // Example: setting the initial price to 3000 with 8 decimals
    log: true,
  });

  if (!mockUSDCDeployment.address || !mockPriceFeedDeployment.address) {
    throw new Error("Mock deployments failed");
  }

  // Output the addresses of deployed mocks
  log(`MockUSDC deployed at ${mockUSDCDeployment.address}`);
  log(`MockChainlinkPriceFeed deployed at ${mockPriceFeedDeployment.address}`);

  // Deploy USDC_ETH_Swap with the addresses of the deployed mocks
  const usdcEthSwapDeployment = await deploy("USDC_ETH_Swap", {
    from: deployer,
    args: [mockPriceFeedDeployment.address, mockUSDCDeployment.address],
    log: true,
  });

  // Output the address of deployed USDC_ETH_Swap
  log(`USDC_ETH_Swap deployed at ${usdcEthSwapDeployment.address}`);
};

export default deployContracts;
deployContracts.tags = ["all"];
