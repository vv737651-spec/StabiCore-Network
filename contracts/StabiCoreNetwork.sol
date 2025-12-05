// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title StabiCore Network
 * @notice A reserve-backed stable asset protocol allowing users to mint stable tokens
 *         by depositing collateral and redeem tokens for collateral at any time.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StabiCoreNetwork {
    // ================================
    // ERC20 TOKEN IMPLEMENTATION
    // ================================
    string public constant name = "StabiCore USD";
    string public constant symbol = "SCUSD";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    IERC20 public collateralAsset; // token used as collateral (USDT/USDC/DAI etc.)
    address public owner;
    uint256 public collateralRatio; // basis points (e.g. 15000 = 150%)

    event Minted(address indexed user, uint256 collateralAmount, uint256 mintedSCUSD);
    event Redeemed(address indexed user, uint256 burnedSCUSD, uint256 collateralReturned);
    event CollateralRatioUpdated(uint256 newRatio);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _collateralAsset, uint256 _collateralRatio) {
        require(_collateralAsset != address(0), "Invalid collateral token");
        collateralAsset = IERC20(_collateralAsset);
        collateralRatio = _collateralRatio;
        owner = msg.sender;
    }

    // ================================
    // INTERNAL ERC20 FUNCTIONS
    // ================================

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Not allowed");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    // ================================
    // CORE STABLE PROTOCOL FUNCTIONS
    // ================================

    /** Mint SCUSD by depositing collateral */
    function mint(uint256 collateralAmount) external {
        require(collateralAmount > 0, "Collateral > 0");

        // Transfer collateral
        collateralAsset.transferFrom(msg.sender, address(this), collateralAmount);

        // Calculate mintable SCUSD
        uint256 mintAmount = collateralAmount * 10000 / collateralRatio; // maintains overcollateralization
        _mint(msg.sender, mintAmount);

        emit Minted(msg.sender, collateralAmount, mintAmount);
    }

    /** Redeem SCUSD to withdraw collateral */
    function redeem(uint256 scusdAmount) external {
        require(balanceOf[msg.sender] >= scusdAmount, "Not enough SCUSD");

        uint256 collateralReturn = scusdAmount * collateralRatio / 10000;
        require(collateralAsset.balanceOf(address(this)) >= collateralReturn, "Vault low liquidity");

        _burn(msg.sender, scusdAmount);
        collateralAsset.transfer(msg.sender, collateralReturn);

        emit Redeemed(msg.sender, scusdAmount, collateralReturn);
    }

    /** Update collateral ratio — handled by protocol owner */
    function setCollateralRatio(uint256 newRatio) external onlyOwner {
        require(newRatio >= 10000, "Min 100% collateral");
        collateralRatio = newRatio;
        emit CollateralRatioUpdated(newRatio);
    }

    /** View total collateral backing the system */
    function totalCollateral() external view returns (uint256) {
        return collateralAsset.balanceOf(address(this));
    }

    /** Change ownership */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}
