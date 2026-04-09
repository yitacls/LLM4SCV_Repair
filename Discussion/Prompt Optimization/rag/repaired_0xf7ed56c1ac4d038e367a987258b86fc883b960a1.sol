pragma solidity ^0.4.19;

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract EjectableOwnable is Ownable {
  function removeOwnership() onlyOwner public {
    owner = 0x0;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract PullPayment {
  using SafeMath for uint256;
  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];
    require(payment != 0);
    require(this.balance >= payment);
    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;
    assert(payee.send(payment));
  }

  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }
}

contract Destructible is Ownable {
  function Destructible() public payable { }

  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract EDStructs {
  struct Dungeon {
    uint32 creationTime;
    uint8 status;
    uint8 difficulty;
    uint16 capacity;
    uint32 floorNumber;
    uint32 floorCreationTime;
    uint128 rewards;
    uint seedGenes;
    uint floorGenes;
  }

  struct Hero {
    uint64 creationTime;
    uint64 cooldownStartTime;
    uint32 cooldownIndex;
    uint genes;
  }
}

contract ERC721 {
  event Transfer(address indexed from, address indexed to, uint indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

  function totalSupply() public view returns (uint);
  function balanceOf(address _owner) public view returns (uint);
  function ownerOf(uint _tokenId) external view returns (address);
  function transfer(address _to, uint _tokenId) external;
  function approve(address _to, uint _tokenId) external;
  function approvedFor(uint _tokenId) external view returns (address);
  function transferFrom(address _from, address _to, uint _tokenId) external;

  mapping(address => uint[]) public ownerTokens;
}

contract DungeonTokenInterface is ERC721, EDStructs {
  uint public constant DUNGEON_CREATION_LIMIT = 1024;
  string public constant name = "Dungeon";
  string public constant symbol = "DUNG";
  Dungeon[] public dungeons;

  function createDungeon(uint _difficulty, uint _capacity, uint _floorNumber, uint _seedGenes, uint _floorGenes, address _owner) external returns (uint);
  function setDungeonStatus(uint _id, uint _newStatus) external;
  function addDungeonRewards(uint _id, uint _additionalRewards) external;
  function addDungeonNewFloor(uint _id, uint _newRewards, uint _newFloorGenes) external;
}

contract HeroTokenInterface is ERC721, EDStructs {
  string public constant name = "Hero";
  string public constant symbol = "HERO";
  Hero[] public heroes;

  function createHero(uint _genes, address _owner) external returns (uint);
  function setHeroGenes(uint _id, uint _newGenes) external;
  function triggerCooldown(uint _id) external;
}

contract ChallengeFormulaInterface {
  function calculateResult(uint _floorGenes, uint _seedGenes) external returns (uint);
}

contract TrainingFormulaInterface {
  function calculateResult(uint _heroGenes, uint _floorGenes, uint _equipmentId) external returns (uint);
}

contract EDBase is EjectableOwnable, Pausable, PullPayment, EDStructs {
  DungeonTokenInterface public dungeonTokenContract;
  HeroTokenInterface public heroTokenContract;
  ChallengeFormulaInterface challengeFormulaContract;
  TrainingFormulaInterface trainingFormulaContract;
  uint public constant SUPER_HERO_MULTIPLIER = 32;
  uint public constant ULTRA_HERO_MULTIPLIER = 64;
  uint public constant MEGA_HERO_MULTIPLIER = 96;
  uint public recruitHeroFee = 2 finney;
  uint public transportationFeeMultiplier = 250 szabo;
  uint public noviceDungeonId = 31;
  uint public consolationRewardsRequiredFaith = 100;
  uint public consolationRewardsClaimPercent = 50;
  uint public constant challengeFeeMultiplier = 1 finney;
  uint public constant challengeRewardsPercent = 45;
  uint public constant masterRewardsPercent = 8;
  uint public consolationRewardsPercent = 2;
  uint public dungeonPreparationTime = 60 minutes;
  uint public constant rushTimeChallengeRewardsPercent = 22;
  uint public constant rushTimeFloorCount = 30;
  uint public trainingFeeMultiplier = 2 finney;
  uint public equipmentTrainingFeeMultiplier = 8 finney;
  uint public constant preparationPeriodTrainingFeeMultiplier = 1600 szabo;
  uint public constant preparationPeriodEquipmentTrainingFeeMultiplier = 6400 szabo;
  mapping(address => uint) playerToLastActionBlockNumber;
  uint tempSuccessTrainingHeroId;
  uint tempSuccessTrainingNewHeroGenes = 1;
  uint public grandConsolationRewards = 168203010964693559;
  mapping(address => uint) playerToDungeonID;
  mapping(address => uint) playerToFaith;
  mapping(address => bool) playerToFirstHeroRecruited;
  mapping(uint => uint) dungeonIdToPlayerCount;

  event PlayerTransported(uint timestamp, address indexed playerAddress, uint indexed originDungeonId, uint indexed destinationDungeonId);
  event DungeonChallenged(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint indexed heroId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newFloorGenes, uint successRewards, uint masterRewards);
  event ConsolationRewardsClaimed(uint timestamp, address indexed playerAddress, uint consolationRewards);
  event HeroTrained(uint timestamp, address indexed playerAddress, uint indexed dungeonId, uint indexed heroId, uint heroGenes, uint floorNumber, uint floorGenes, bool success, uint newHeroGenes);

  function getHeroAttributes(uint _genes) public pure returns (uint[]) {
    uint[] memory attributes = new uint[](12);
    for (uint i = 0; i < 12; i++) {
      attributes[11 - i] = _genes % 32;
      _genes /= 32 ** 4;
    }
    return attributes;
  }

  function getHeroPower(uint _genes, uint _dungeonDifficulty) public pure returns (
    uint totalPower,
    uint equipmentPower,
    uint statsPower,
    bool isSuper,
    uint superRank,
    uint superBoost
  ) {
    uint16[32] memory EQUIPMENT_POWERS = [
      1, 2, 4, 5, 16, 17, 32, 33,
      8, 16, 16, 32, 32, 48, 64, 96,
      4, 16, 32, 64,
      32, 48, 80, 128,
      32, 96,
      80, 192,
      192,
      288,
      384,
      512
    ];
    uint[] memory attributes = getHeroAttributes(_genes);
    superRank = attributes[0];
    for (uint i = 0; i < 8; i++) {
      uint equipment = attributes[i];
      equipmentPower += EQUIPMENT_POWERS[equipment];
      if (superRank != equipment) {
        superRank = 0;
      }
    }
    for (uint j = 8; j < 12; j++) {
      statsPower += attributes[j] + 1;
    }
    isSuper = superRank >= 16;
    if (superRank >= 28) {
      superBoost = (_dungeonDifficulty - 1) * MEGA_HERO_MULTIPLIER;
    } else if (superRank >= 24) {
      superBoost = (_dungeonDifficulty - 1) * ULTRA_HERO_MULTIPLIER;
    } else if (superRank >= 16) {
      superBoost = (_dungeonDifficulty - 1) * SUPER_HERO_MULTIPLIER;
    }
    totalPower = statsPower + equipmentPower + superBoost;
  }

  function getDungeonPower(uint _genes) public pure returns (uint) {
    uint16[32] memory EQUIPMENT_POWERS = [
      1, 2, 4, 5, 16, 17, 32, 33,
      8, 16, 16, 32, 32, 48, 64, 96,
      4, 16, 32, 64,
      32, 48, 80, 128,
      32, 96,
      80, 192,
      192,
      288,
      384,
      512
    ];
    uint dungeonPower;
    for (uint j = 0; j < 12; j++) {
      dungeonPower += EQUIPMENT_POWERS[_genes % 32];
      _genes /= 32 ** 4;
    }
    return dungeonPower;
  }

  function setTempHeroPower() onlyOwner public {
    _setTempHeroPower();
  }

  function setDungeonTokenContract(address _newDungeonTokenContract) onlyOwner external {
    dungeonTokenContract = DungeonTokenInterface(_newDungeonTokenContract);
  }

  function setHeroTokenContract(address _newHeroTokenContract) onlyOwner external {
    heroTokenContract = HeroTokenInterface(_newHeroTokenContract);
  }

  function setChallengeFormulaContract(address _newChallengeFormulaAddress) onlyOwner external {
    challengeFormulaContract = ChallengeFormulaInterface(_newChallengeFormulaAddress);
  }

  function setTrainingFormulaContract(address _newTrainingFormulaAddress) onlyOwner external {
    trainingFormulaContract = TrainingFormulaInterface(_newTrainingFormulaAddress);
  }

  function setRecruitHeroFee(uint _newRecruitHeroFee) onlyOwner external {
    recruitHeroFee = _newRecruitHeroFee;
  }

  function setTransportationFeeMultiplier(uint _newTransportationFeeMultiplier) onlyOwner external {
    transportationFeeMultiplier = _newTransportationFeeMultiplier;
  }

  function setNoviceDungeonId(uint _newNoviceDungeonId) onlyOwner external {
    noviceDungeonId = _newNoviceDungeonId;
  }

  function setConsolationRewardsRequiredFaith(uint _newConsolationRewardsRequiredFaith) onlyOwner external {
    consolationRewardsRequiredFaith = _newConsolationRewardsRequiredFaith;
  }

  function setConsolationRewardsClaimPercent(uint _newConsolationRewardsClaimPercent) onlyOwner external {
    consolationRewardsClaimPercent = _newConsolationRewardsClaimPercent;
  }

  function setConsolationRewardsPercent(uint _newConsolationRewardsPercent) onlyOwner external {
    consolationRewardsPercent = _newConsolationRewardsPercent;
  }

  function setDungeonPreparationTime(uint _newDungeonPreparationTime) onlyOwner external {
    dungeonPreparationTime = _newDungeonPreparationTime;
  }

  function setTrainingFeeMultiplier(uint _newTrainingFeeMultiplier) onlyOwner external {
    trainingFeeMultiplier = _newTrainingFeeMultiplier;
  }

  function setEquipmentTrainingFeeMultiplier(uint _newEquipmentTrainingFeeMultiplier) onlyOwner external {
    equipmentTrainingFeeMultiplier = _newEquipmentTrainingFeeMultiplier;
  }

  function _setTempHeroPower() internal {
    if (tempSuccessTrainingNewHeroGenes != 1) {
      heroTokenContract.setHeroGenes(tempSuccessTrainingHeroId, tempSuccessTrainingNewHeroGenes);
      tempSuccessTrainingNewHeroGenes = 1;
    }
  }

  modifier dungeonExists(uint _dungeonId) {
    require(_dungeonId < dungeonTokenContract.totalSupply());
    _;
  }
}

contract EDTransportation is EDBase {
  function recruitHero() whenNotPaused external payable returns (uint) {
    require(playerToDungeonID[msg.sender] == noviceDungeonId || !playerToFirstHeroRecruited[msg.sender]);
    require(msg.value >= recruitHeroFee);
    dungeonTokenContract.addDungeonRewards(noviceDungeonId, recruitHeroFee);
    asyncSend(msg.sender, msg.value - recruitHeroFee);
    if (!playerToFirstHeroRecruited[msg.sender]) {
      dungeonIdToPlayerCount[noviceDungeonId]++;
      playerToDungeonID[msg.sender] = noviceDungeonId;
      playerToFirstHeroRecruited[msg.sender] = true;
    }
    return heroTokenContract.createHero(0, msg.sender);
  }

  function transport(uint _destinationDungeonId) whenNotPaused dungeonCanTransport(_destinationDungeonId) playerAllowedToTransport() external payable {
    uint originDungeonId = playerToDungeonID[msg.sender];
    require(_destinationDungeonId != originDungeonId);
    uint difficulty;
    (,, difficulty,,,,,,) = dungeonTokenContract.dungeons(_destinationDungeonId);
    uint top5HeroesPower = calculateTop5HeroesPower(msg.sender, _destinationDungeonId);
    require(top5HeroesPower >= difficulty * 12);
    uint baseFee = difficulty * transportationFeeMultiplier;
    uint additionalFee = top5HeroesPower / 64 * transportationFeeMultiplier;
    uint requiredFee = baseFee + additionalFee;
    require(msg.value >= requiredFee);
    dungeonTokenContract.addDungeonRewards(originDungeonId, requiredFee);
    asyncSend(msg.sender, msg.value - requiredFee);
    _transport(originDungeonId, _destinationDungeonId);
  }

  function _transport(uint _originDungeonId, uint _destinationDungeonId) internal {
    if (dungeonIdToPlayerCount[_originDungeonId] > 0) {
      dungeonIdToPlayerCount[_originDungeonId]--;
    }
    dungeonIdToPlayerCount[_destinationDungeonId]++;
    playerToDungeonID[msg.sender] = _destinationDungeonId;
    PlayerTransported(now, msg.sender, _originDungeonId, _destinationDungeonId);
  }

  modifier dungeonCanTransport(uint _destinationDungeonId) {
    require(_destinationDungeonId < dungeonTokenContract.totalSupply());
    uint status;
    uint capacity;
    (, status,, capacity,,,,,) = dungeonTokenContract.dungeons(_destinationDungeonId);
    require(status == 0 || status == 1);
    require(capacity == 0 || dungeonIdToPlayerCount[_destinationDungeonId] < capacity);
    _;
  }

  modifier playerAllowedToTransport() {
    require(playerToFirstHeroRecruited[msg.sender]);
    _;
  }
}

contract EDChallenge is EDTransportation {
  function challenge(uint _dungeonId, uint _heroId) whenNotPaused dungeonCanChallenge(_dungeonId) heroAllowedToChallenge(_heroId) external payable {
    playerToLastActionBlockNumber[msg.sender] = block.number;
    _setTempHeroPower();
    uint difficulty;
    uint seedGenes;
    (,, difficulty,,,,, seedGenes,) = dungeonTokenContract.dungeons(_dungeonId);
    uint requiredFee = difficulty * challengeFeeMultiplier;
    require(msg.value >= requiredFee);
    dungeonTokenContract.addDungeonRewards(_dungeonId, requiredFee);
    asyncSend(msg.sender, msg.value - requiredFee);
    _challengePart2(_dungeonId, difficulty, _heroId);
  }

  function _computeCooldownRemainingTime(uint _heroId) internal view returns (uint) {
    uint cooldownStartTime;
    uint cooldownIndex;
    (, cooldownStartTime, cooldownIndex,) = heroTokenContract.heroes(_heroId);
    uint cooldownPeriod = (cooldownIndex / 2) ** 2 * 1 minutes;
    if (cooldownPeriod > 100 minutes) {
      cooldownPeriod = 100 minutes;
    }
    uint cooldownEndTime = cooldownStartTime + cooldownPeriod;
    if (cooldownEndTime <= now) {
      return 0;
    } else {
      return cooldownEndTime - now;
    }
  }

  function _challengePart2(uint _dungeonId, uint _dungeonDifficulty, uint _heroId) private {
    uint floorNumber;
    uint rewards;
    uint floorGenes;
    (,,,, floorNumber,, rewards,, floorGenes) = dungeonTokenContract.dungeons(_dungeonId);
    uint heroGenes;
    (,,, heroGenes) = heroTokenContract.heroes(_heroId);
    bool success = _getChallengeSuccess(heroGenes, _dungeonDifficulty, floorGenes);
    uint newFloorGenes;
    uint masterRewards;
    uint consolationRewards;
    uint successRewards;
    uint newRewards;
    if (success) {
      newFloorGenes = _getNewFloorGene(_dungeonId);
      masterRewards = rewards * masterRewardsPercent / 100;
      consolationRewards = rewards * consolationRewardsPercent / 100;
      if (floorNumber < rushTimeFloorCount) {
        successRewards = rewards * rushTimeChallengeRewardsPercent / 100;
        newRewards = rewards * (100 - rushTimeChallengeRewardsPercent - masterRewardsPercent - consolationRewardsPercent) / 100;
      } else {
        successRewards = rewards * challengeRewardsPercent / 100;
        newRewards = rewards * (100 -