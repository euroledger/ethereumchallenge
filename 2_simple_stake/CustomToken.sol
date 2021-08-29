// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Extension of {ERC20} that adds staking mechanism.
 */
contract CustomToken is Ownable, Initializable, ERC20 { 
    using SafeMath for uint64;

    uint256 internal _minTotalSupply;
    uint256 internal _maxTotalSupply;
    uint256 internal _stakeStartTime;
    uint256 internal _stakeMinAge;
    uint256 internal _stakeMaxAge;
    uint256 internal _maxInterestRate;
    uint256 internal _stakeMinAmount;
    uint256 internal _stakePrecision;

    struct StakeStruct {
        int256 amount;
        uint256 time;
    }

    mapping(address => StakeStruct[]) internal _stakes;
    
    struct Balance {
        uint256 amount;
    }
    
    mapping (address => Balance) internal _balances;


    // constructor(
    //     string memory name,
    //     string memory symbol,
    //     uint256 minTotalSupply, 
    //     uint256 maxTotalSupply, 
    //     uint64 stakeMinAge, 
    //     uint64 stakeMaxAge,
    //     uint8 stakePrecision
    // ) ERC20(name, symbol) {
    //     initialize(msg.sender, minTotalSupply, maxTotalSupply, stakeMinAge, stakeMaxAge, stakePrecision);
    // }
    
    
    constructor(
    ) ERC20("Custom Token", "CTK") {
        initialize(msg.sender, 10 ** 18, 10 ** 18, 1, 5, 2);
    }
    
    function initialize(
        address sender, uint256 minTotalSupply, uint256 maxTotalSupply, uint64 stakeMinAge, uint64 stakeMaxAge,
        uint8 stakePrecision
    ) public initializer onlyOwner
    {
        _minTotalSupply = minTotalSupply;
        _maxTotalSupply = maxTotalSupply;
        _mint(sender, minTotalSupply);
        _stakePrecision = uint256(stakePrecision);

        _stakeStartTime = block.timestamp;
        _stakeMinAge = uint256(stakeMinAge);
        _stakeMaxAge = uint256(stakeMaxAge);

        _maxInterestRate = uint256(10**17); // 10% annual interest
        _stakeMinAmount = uint256(10**18);  // min stake of 1 token
    }
    
     function stakeOf(address account) public view returns (uint256) {
        if (_stakes[account].length <= 0) return 0;
        uint256 stake = 0;

        for (uint i = 0; i < _stakes[account].length; i++) {
            stake += uint256(_stakes[account][i].amount);
        }
        return stake;
    }

    function stakeAll() public returns (bool) {
        _stake(_msgSender(), uint256(balanceOf(_msgSender())));
        return true;
    }
    
      function unstakeAll() public returns (bool) {
        _unstake(_msgSender());
        return true;
    }

    function reward() public returns (bool) {
        _reward(_msgSender());
        return true;
    }
    
 
    // This method should allow adding on to user's stake.
    // Any required constrains and checks should be coded as well.  
    function _stake(address sender, uint256 amount) internal {
        require (_balances[sender].amount >= amount, "Insufficient Funds for Stake!");
        _burn(msg.sender, uint256(amount));
        _balances[sender].amount -= amount;
        StakeStruct memory newStake = StakeStruct(int256(amount), block.timestamp); 
        _stakes[msg.sender].push(newStake);
    }
    
    // This method should allow withdrawing staked funds
    // Any required constrains and checks should be coded as well.
    function _unstake(address sender) internal {
        uint256 unstakeAmount = stakeOf(sender);
        
        int256 negativeAmount = - int256(unstakeAmount);
        StakeStruct memory newStake = StakeStruct( negativeAmount, block.timestamp); 
        _balances[sender].amount += unstakeAmount;
        _stakes[msg.sender].push(newStake);
       _mint(msg.sender, uint256(unstakeAmount));    
    }

    // This method should allow withdrawing cumulated reward for all staked funds of the user's.
    // Any required constrains and checks should be coded as well.
    // Important! Withdrawing reward should not decrease the stake, stake should be rolled over for the future automatically.
    function _reward(address sender) internal {
        uint256 posReward = uint256(_getProofOfStakeReward(sender));
        increaseBalance(sender, posReward);
    }
    
    function _getProofOfStakeReward(address _address) internal view returns (uint256) {
        require((block.timestamp >= _stakeStartTime) && (_stakeStartTime > 0));

        uint256 _now = block.timestamp;
        uint256 _coinAge = _getCoinAge(_address, _now);
        if (_coinAge <= 0) return 0;

        uint256 interest = _getAnnualInterest();
        uint256 rewarded = (_coinAge * interest) / (365 * 10**_stakePrecision);

        return rewarded;
    }

    function _getCoinAge(address _address, uint256 _now) internal view returns (uint256) {
        if (_stakes[_address].length <= 0) return 0;
        uint256 _coinAge = 0;

        for (uint i = 0; i < _stakes[_address].length; i++) {
            if (_now < uint256(_stakes[_address][i].time) + _stakeMinAge) continue;

            uint256 nCoinSeconds = _now - uint256(_stakes[_address][i].time);
            if (nCoinSeconds > _stakeMaxAge) nCoinSeconds = _stakeMaxAge;

            _coinAge = _coinAge + uint256(_stakes[_address][i].amount) * nCoinSeconds / (1 days);
        }

        return _coinAge;
    }
    
    function _getAnnualInterest() internal view returns(uint256) {
        return _maxInterestRate;
    }
    
    function increaseBalance(address account, uint256 amount) public {
        require(account != address(0), "Balance increase from the zero address");
        _balances[account].amount += amount;
    }

    function decreaseBalance(address account, uint256 amount) public {
        require(account != address(0), "Balance decrease from the zero address");
        require(_balances[account].amount >= amount, "Balance decrease amount exceeds balance");
        _balances[account].amount -= amount;
    }
}
 