// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title StabiCore Network
 * @notice Collateral-backed stablecoin system
 *         - Mint/burn stablecoins
 *         - Deposit ERC20 collateral
 *         - Stability fees / interest
 *         - Governance-controlled parameters
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
}

contract StabiCoreNetwork {
    address public owner;
    IERC20 public stablecoin; // The network stablecoin

    uint256 public stabilityFee = 5; // 5% annual, simple model
    uint256 public constant BLOCKS_PER_YEAR = 2102400;

    struct Collateral {
        address token;
        uint256 amount;
    }

    struct Position {
        address owner;
        Collateral[] collaterals;
        uint256 debt; // stablecoins minted
        uint256 lastUpdateBlock;
        bool active;
    }

    uint256 public positionCount;
    mapping(uint256 => Position) public positions;
    mapping(address => uint256[]) public userPositions;

    event PositionOpened(uint256 indexed id, address indexed owner);
    event CollateralDeposited(uint256 indexed id, address token, uint256 amount);
    event StablecoinMinted(uint256 indexed id, uint256 amount);
    event StablecoinBurned(uint256 indexed id, uint256 amount);
    event StabilityFeeUpdated(uint256 newFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validPosition(uint256 id) {
        require(positions[id].active, "Invalid position");
        _;
    }

    constructor(address _stablecoin) {
        owner = msg.sender;
        stablecoin = IERC20(_stablecoin);
    }

    // ------------------------------------------------
    // POSITION FUNCTIONS
    // ------------------------------------------------
    function openPosition() external returns (uint256) {
        positionCount++;
        positions[positionCount] = Position({
            owner: msg.sender,
            collaterals: new Collateral ,
            debt: 0,
            lastUpdateBlock: block.number,
            active: true
        });

        userPositions[msg.sender].push(positionCount);
        emit PositionOpened(positionCount, msg.sender);
        return positionCount;
    }

    function depositCollateral(uint256 positionId, address token, uint256 amount) external validPosition(positionId) {
        Position storage pos = positions[positionId];
        require(pos.owner == msg.sender, "Not owner");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        pos.collaterals.push(Collateral({token: token, amount: amount}));

        emit CollateralDeposited(positionId, token, amount);
    }

    function mintStablecoin(uint256 positionId, uint256 amount) external validPosition(positionId) {
        Position storage pos = positions[positionId];
        require(pos.owner == msg.sender, "Not owner");
        _accrueStabilityFee(pos);

        // Check simple collateralization: total collateral value > debt (simplified)
        uint256 totalCollateral = _totalCollateralValue(pos);
        require(totalCollateral >= pos.debt + amount, "Undercollateralized");

        pos.debt += amount;
        stablecoin.transfer(msg.sender, amount);
        pos.lastUpdateBlock = block.number;

        emit StablecoinMinted(positionId, amount);
    }

    function burnStablecoin(uint256 positionId, uint256 amount) external validPosition(positionId) {
        Position storage pos = positions[positionId];
        require(pos.owner == msg.sender, "Not owner");
        _accrueStabilityFee(pos);

        require(amount <= pos.debt, "Exceeds debt");
        stablecoin.transferFrom(msg.sender, address(this), amount);
        pos.debt -= amount;
        pos.lastUpdateBlock = block.number;

        emit StablecoinBurned(positionId, amount);
    }

    // ------------------------------------------------
    // INTERNAL HELPERS
    // ------------------------------------------------
    function _accrueStabilityFee(Position storage pos) internal {
        uint256 blocksPassed = block.number - pos.lastUpdateBlock;
        if (blocksPassed == 0 || pos.debt == 0) return;

        uint256 fee = pos.debt * stabilityFee * blocksPassed / (100 * BLOCKS_PER_YEAR);
        pos.debt += fee;
    }

    function _totalCollateralValue(Position storage pos) internal view returns (uint256 total) {
        for (uint256 i = 0; i < pos.collaterals.length; i++) {
            total += pos.collaterals[i].amount; // Simplified: 1:1 token value
        }
    }

    // ------------------------------------------------
    // VIEWERS
    // ------------------------------------------------
    function getUserPositions(address user) external view returns (uint256[] memory) {
        return userPositions[user];
    }

    function getPositionDebt(uint256 positionId) external view returns (uint256) {
        Position storage pos = positions[positionId];
        uint256 blocksPassed = block.number - pos.lastUpdateBlock;
        uint256 fee = pos.debt * stabilityFee * blocksPassed / (100 * BLOCKS_PER_YEAR);
        return pos.debt + fee;
    }

    // ------------------------------------------------
    // ADMIN
    // ------------------------------------------------
    function updateStabilityFee(uint256 newFee) external onlyOwner {
        stabilityFee = newFee;
        emit StabilityFeeUpdated(newFee);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
