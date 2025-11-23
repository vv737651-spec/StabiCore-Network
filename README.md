# StabiCore Network

## Project Description

StabiCore Network is a decentralized stability protocol built on blockchain technology that enables users to stake assets, participate in governance, and earn rewards while contributing to network stability. The platform combines staking mechanisms with democratic governance, allowing stakeholders to propose and vote on network decisions based on their staked positions.

The smart contract implements a comprehensive ecosystem where users can:
- Stake their tokens to earn passive rewards calculated at a configurable Annual Percentage Rate (APR)
- Participate in decentralized governance through proposal creation and voting
- Contribute to a stability fund that supports the network's long-term sustainability
- Manage their stakes with flexible unstaking options

### Reward Mechanism

StabiCore Network uses a time-based reward calculation system:
- **Reward Formula**: `rewards = (stakedAmount × rewardRate × stakingDuration) / (365 days × 100)`
- **Configurable APR**: Set during deployment and adjustable through governance
- **Recommended Rate**: 12% APR (balanced and sustainable)
- **Real-time Calculation**: Rewards accumulate continuously based on staking duration

**Example**: Staking 1 ETH at 12% APR yields:
- 1 month: ~0.01 ETH (1%)
- 3 months: ~0.03 ETH (3%)
- 1 year: ~0.12 ETH (12%)

## Project Vision

Our vision is to create a self-sustaining, community-governed decentralized network that prioritizes stability, transparency, and equitable participation. StabiCore Network aims to:

1. **Democratize Finance**: Enable anyone to participate in network governance proportional to their stake
2. **Ensure Stability**: Build a robust stability fund mechanism that protects the network during market volatility
3. **Reward Participation**: Provide fair and transparent rewards to stakeholders who contribute to network security
4. **Foster Community**: Create a platform where decisions are made collectively by the community
5. **Promote Sustainability**: Develop a long-term sustainable model that balances growth with stability

## Key Features

### 1. **Staking Mechanism**
- Stake native tokens to participate in the network
- Earn rewards based on staking duration and amount
- Flexible unstaking with calculated rewards distribution

### 2. **Rewards System**
- Automatic reward calculation based on stake amount and duration
- Configurable reward rates managed by governance (default: 12% APR)
- Real-time reward tracking and claiming functionality
- Formula: `(stakedAmount × rewardRate × duration) / (365 days × 100)`
- Rewards accumulate continuously and can be claimed anytime

### 3. **Decentralized Governance**
- Proposal creation system for network improvements
- Voting power proportional to staked amounts
- Time-bound voting periods with democratic execution
- Full transparency of proposals and voting results

### 4. **Stability Fund**
- Community-funded stability reserve
- Accepts deposits from any participant
- Designed to support network stability during market stress
- Transparent fund management

### 5. **Security Features**
- Owner-controlled emergency pause functionality
- Protected administrative functions
- Safe fund withdrawal mechanisms
- Comprehensive event logging for transparency

### 6. **Stakeholder Management**
- Track all active stakeholders
- Detailed stakeholder information queries
- Historical tracking of staking activities

### 7. **Proposal Management**
- Create detailed proposals with descriptions
- Track voting statistics in real-time
- Execute approved proposals automatically
- Prevent double voting and manipulation

### 8. **Flexible Configuration**
- Adjustable reward rates through governance
- Customizable voting periods
- Emergency controls for critical situations

### 9. **Transparent Reporting**
- Query individual stakeholder information
- View proposal details and voting results
- Monitor total network statistics
- Real-time contract state visibility

### 10. **Efficient Resource Management**
- Optimized gas usage
- Scalable architecture
- Event-driven updates for off-chain indexing

## Future Scope

### Phase 1: Enhanced Governance
- Implement delegation mechanisms for voting power
- Add proposal categories and specialized voting tracks
- Introduce time-locked governance for critical changes
- Develop a reputation system for active participants

### Phase 2: Advanced Staking
- Multiple staking pools with different risk/reward profiles
- Lock-up periods with bonus rewards
- Auto-compounding reward options
- Staking derivatives and liquid staking tokens

### Phase 3: Stability Mechanisms
- Automated stability algorithms using oracles
- Dynamic reward rate adjustments based on network health
- Insurance mechanisms for stakeholder protection
- Integration with external DeFi protocols for yield optimization

### Phase 4: Cross-Chain Integration
- Bridge functionality to other blockchain networks
- Multi-chain staking and governance
- Cross-chain asset stability mechanisms
- Interoperability with major DeFi ecosystems

### Phase 5: Advanced Features
- NFT-based governance memberships
- DAO treasury management
- Grants and funding programs for ecosystem growth
- Analytics dashboard and mobile application
- Integration with decentralized identity solutions

### Phase 6: Enterprise Solutions
- White-label solutions for organizations
- Compliance and regulatory frameworks
- Institutional-grade security audits
- Professional support and SLA guarantees

### Long-term Vision
- Become a foundational layer for decentralized stability
- Support multiple asset types and stablecoins
- Create a network of interconnected stability pools
- Establish partnerships with major DeFi protocols
- Build a sustainable ecosystem with real-world utility

## Deployment Guide

### Initial Setup

**Deploy the contract with recommended parameters:**

```solidity
// Constructor parameter
rewardRate: 12  // 12% Annual Percentage Rate (APR)
```

### Testing the Contract

**1. Deploy Contract:**
```javascript
const StabiCoreNetwork = await ethers.getContractFactory("StabiCoreNetwork");
const contract = await StabiCoreNetwork.deploy(12); // 12% APR
await contract.deployed();
```

**2. Stake Tokens:**
```javascript
// Stake 1 ETH
await contract.stake({ value: ethers.utils.parseEther("1.0") });
```

**3. Expected Rewards (at 12% APR):**

| Staked Amount | Time Period | Expected Rewards |
|---------------|-------------|------------------|
| 1 ETH | 1 day | ~0.000329 ETH |
| 1 ETH | 7 days | ~0.0023 ETH |
| 1 ETH | 30 days | ~0.00986 ETH (~1% monthly) |
| 1 ETH | 90 days | ~0.0296 ETH (~3% quarterly) |
| 1 ETH | 365 days | ~0.12 ETH (12% annually) |

**4. Test Governance:**
```javascript
// Create a proposal (7-day voting period)
await contract.createProposal("Increase reward rate to 15%", 604800);

// Vote on proposal (ID: 1)
await contract.vote(1, true); // Vote 'yes'

// Execute after voting period ends
await contract.executeProposal(1);
```

**5. Test Stability Fund:**
```javascript
// Deposit to stability fund
await contract.depositStabilityFund({ value: ethers.utils.parseEther("0.5") });
```

**6. Claim Rewards:**
```javascript
// Check pending rewards
const rewards = await contract.calculateRewards(userAddress);

// Claim all rewards
await contract.claimRewards();
```

**7. Update Reward Rate (Owner only):**
```javascript
// Change to 15% APR
await contract.updateRewardRate(15);
```

### Recommended Configuration Values

- **Reward Rate**: 
  - Conservative: 5-8% APR
  - Moderate: 10-15% APR (Recommended: **12%**)
  - Aggressive: 20-30% APR
  - Maximum: 100% APR (contract limit)

- **Voting Period**: 
  - Short: 3 days (259200 seconds)
  - Standard: 7 days (604800 seconds)
  - Extended: 14 days (1209600 seconds)

- **Minimum Stake**: No minimum enforced (consider adding if needed)

### Security Notes

- Always audit the contract before mainnet deployment
- Ensure sufficient balance for reward payouts
- Monitor stability fund levels regularly
- Use multisig wallet for owner functions
- Test thoroughly on testnet before production

## Contract Details:

Transaction id: 0x443D3cE07AAD6E67602d6f2e7d99BEea0B99ceF6
![image](image.png)