State variables
    address public owner;
    uint256 public totalStaked;
    uint256 public rewardRate;
    uint256 public stabilityFund;
    bool public paused;
    
    struct StakeHolder {
        uint256 stakedAmount;
        uint256 stakingTimestamp;
        uint256 rewardsEarned;
        bool isActive;
    }
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
        address proposer;
    }
    
    mapping(address => StakeHolder) public stakeHolders;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    
    uint256 public proposalCount;
    address[] public stakeHolderList;
    
    Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    constructor(uint256 _rewardRate) {
        owner = msg.sender;
        rewardRate = _rewardRate;
        paused = false;
    }
    
    /**
     * @dev Function 1: Stake tokens into the network
     */
    function stake() external payable whenNotPaused {
        require(msg.value > 0, "Cannot stake 0");
        
        StakeHolder storage holder = stakeHolders[msg.sender];
        
        if (!holder.isActive) {
            stakeHolderList.push(msg.sender);
            holder.isActive = true;
        }
        
        if (holder.stakedAmount > 0) {
            holder.rewardsEarned += calculateRewards(msg.sender);
        }
        
        holder.stakedAmount += msg.value;
        holder.stakingTimestamp = block.timestamp;
        totalStaked += msg.value;
        
        emit Staked(msg.sender, msg.value);
    }
    
    /**
     * @dev Function 2: Unstake tokens from the network
     */
    function unstake(uint256 _amount) external whenNotPaused {
        StakeHolder storage holder = stakeHolders[msg.sender];
        require(holder.stakedAmount >= _amount, "Insufficient staked amount");
        
        holder.rewardsEarned += calculateRewards(msg.sender);
        holder.stakedAmount -= _amount;
        holder.stakingTimestamp = block.timestamp;
        totalStaked -= _amount;
        
        payable(msg.sender).transfer(_amount);
        
        emit Unstaked(msg.sender, _amount);
    }
    
    /**
     * @dev Function 3: Calculate rewards for a stakeholder
     */
    function calculateRewards(address _staker) public view returns (uint256) {
        StakeHolder memory holder = stakeHolders[_staker];
        if (holder.stakedAmount == 0) return 0;
        
        uint256 stakingDuration = block.timestamp - holder.stakingTimestamp;
        uint256 rewards = (holder.stakedAmount * rewardRate * stakingDuration) / (365 days * 100);
        
        return rewards;
    }
    
    /**
     * @dev Function 4: Claim accumulated rewards
     */
    function claimRewards() external whenNotPaused {
        StakeHolder storage holder = stakeHolders[msg.sender];
        
        uint256 rewards = calculateRewards(msg.sender) + holder.rewardsEarned;
        require(rewards > 0, "No rewards to claim");
        require(address(this).balance >= rewards, "Insufficient contract balance");
        
        holder.rewardsEarned = 0;
        holder.stakingTimestamp = block.timestamp;
        
        payable(msg.sender).transfer(rewards);
        
        emit RewardsClaimed(msg.sender, rewards);
    }
    
    /**
     * @dev Function 5: Create a governance proposal
     */
    function createProposal(string memory _description, uint256 _votingPeriod) external {
        require(stakeHolders[msg.sender].stakedAmount > 0, "Must be a stakeholder");
        
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + _votingPeriod;
        newProposal.proposer = msg.sender;
        
        emit ProposalCreated(proposalCount, msg.sender, _description);
    }
    
    /**
     * @dev Function 6: Vote on a proposal
     */
    function vote(uint256 _proposalId, bool _support) external {
        require(stakeHolders[msg.sender].stakedAmount > 0, "Must be a stakeholder");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting period ended");
        require(!proposal.executed, "Proposal already executed");
        
        uint256 votingPower = stakeHolders[msg.sender].stakedAmount;
        
        if (_support) {
            proposal.votesFor += votingPower;
        } else {
            proposal.votesAgainst += votingPower;
        }
        
        hasVoted[msg.sender][_proposalId] = true;
        
        emit Voted(_proposalId, msg.sender, _support);
    }
    
    /**
     * @dev Function 7: Execute a proposal after voting period
     */
    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");
        
        proposal.executed = true;
        
        emit ProposalExecuted(_proposalId);
    }
    
    /**
     * @dev Function 8: Deposit funds into stability fund
     */
    function depositStabilityFund() external payable {
        require(msg.value > 0, "Cannot deposit 0");
        stabilityFund += msg.value;
        
        emit StabilityFundDeposited(msg.sender, msg.value);
    }
    
    /**
     * @dev Function 9: Update reward rate (only owner)
     */
    function updateRewardRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0 && _newRate <= 100, "Invalid reward rate");
        rewardRate = _newRate;
    }
    
    /**
     * @dev Function 10: Emergency pause/unpause contract (only owner)
     */
    function togglePause() external onlyOwner {
        paused = !paused;
    }
    
    /**
     * @dev Get stakeholder information
     */
    function getStakeHolderInfo(address _staker) external view returns (
        uint256 stakedAmount,
        uint256 stakingTimestamp,
        uint256 rewardsEarned,
        uint256 pendingRewards,
        bool isActive
    ) {
        StakeHolder memory holder = stakeHolders[_staker];
        return (
            holder.stakedAmount,
            holder.stakingTimestamp,
            holder.rewardsEarned,
            calculateRewards(_staker),
            holder.isActive
        );
    }
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 _proposalId) external view returns (
        uint256 id,
        string memory description,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 deadline,
        bool executed,
        address proposer
    ) {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.deadline,
            proposal.executed,
            proposal.proposer
        );
    }
    
    /**
     * @dev Get total number of stakeholders
     */
    function getTotalStakeHolders() external view returns (uint256) {
        return stakeHolderList.length;
    }
    
    End
End
// 
// 
End
// 
