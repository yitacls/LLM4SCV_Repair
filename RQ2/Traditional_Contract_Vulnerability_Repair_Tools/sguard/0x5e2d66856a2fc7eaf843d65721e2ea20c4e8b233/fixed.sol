pragma solidity ^0.4.21;
contract Ownable {
    address public owner;
    event OwnershipTransferred(address previousOwner, address newOwner);
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
contract StorageBase is Ownable {
    function withdrawBalance() external onlyOwner returns (bool) {
        bool res = msg.sender.send(address(this).balance);  // fault line
        return res;
    }
}
contract CryptoStorage is StorageBase {
    struct Monster {
        uint32 matronId;
        uint32 sireId;
        uint32 siringWithId;
        uint16 cooldownIndex;
        uint16 generation;
        uint64 cooldownEndBlock;
        uint64 birthTime;
        uint16 monsterId;
        uint32 monsterNum;
        bytes properties;
    }
    Monster[] internal monsters;
    uint256 public promoCreatedCount;
    uint256 public systemCreatedCount;
    uint256 public pregnantMonsters;
    mapping (uint256 => uint32) public monsterCurrentNumber;
    mapping (uint256 => address) public monsterIndexToOwner;
    mapping (address => uint256) public ownershipTokenCount;
    mapping (uint256 => address) public monsterIndexToApproved;
    function CryptoStorage() public {
        createMonster(0, 0, 0, 0, 0, "");
    }
    function createMonster(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _birthTime,
        uint256 _monsterId,
        bytes _properties
    ) 
        public 
        onlyOwner
        returns (uint256)
    {
        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint16(_generation)));
        require(_birthTime == uint256(uint64(_birthTime)));
        require(_monsterId == uint256(uint16(_monsterId)));
        monsterCurrentNumber[_monsterId]++;
        Monster memory monster = Monster({
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: 0,
            generation: uint16(_generation),
            cooldownEndBlock: 0,
            birthTime: uint64(_birthTime),
            monsterId: uint16(_monsterId),
            monsterNum: monsterCurrentNumber[_monsterId],
            properties: _properties
        });
        uint256 tokenId = monsters.push(monster) - 1;
        require(tokenId == uint256(uint32(tokenId)));
        return tokenId;
    }
    function getMonster(uint256 _tokenId)
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint16 cooldownIndex,
            uint64 nextActionAt,
            uint32 siringWithId,
            uint32 matronId,
            uint32 sireId,
            uint64 cooldownEndBlock,
            uint16 generation,
            uint64 birthTime,
            uint32 monsterNum,
            uint16 monsterId,
            bytes properties
        ) 
    {
        Monster storage monster = monsters[_tokenId];
        isGestating = (monster.siringWithId != 0);
        isReady = (monster.cooldownEndBlock <= block.number);
        cooldownIndex = monster.cooldownIndex;
        nextActionAt = monster.cooldownEndBlock;
        siringWithId = monster.siringWithId;
        matronId = monster.matronId;
        sireId = monster.sireId;
        cooldownEndBlock = monster.cooldownEndBlock;
        generation = monster.generation;
        birthTime = monster.birthTime;
        monsterNum = monster.monsterNum;
        monsterId = monster.monsterId;
        properties = monster.properties;
    }
    function getMonsterCount() external view returns (uint256) {
        return monsters.length - 1;
    }
    function getMatronId(uint256 _tokenId) external view returns (uint32) {
        return monsters[_tokenId].matronId;
    }
    function getSireId(uint256 _tokenId) external view returns (uint32) {
        return monsters[_tokenId].sireId;
    }
    function getSiringWithId(uint256 _tokenId) external view returns (uint32) {
        return monsters[_tokenId].siringWithId;
    }
    function setSiringWithId(uint256 _tokenId, uint32 _siringWithId) external onlyOwner {
        monsters[_tokenId].siringWithId = _siringWithId;
    }
    function deleteSiringWithId(uint256 _tokenId) external onlyOwner {
        delete monsters[_tokenId].siringWithId;
    }
    function getCooldownIndex(uint256 _tokenId) external view returns (uint16) {
        return monsters[_tokenId].cooldownIndex;
    }
    function setCooldownIndex(uint256 _tokenId) external onlyOwner {
        monsters[_tokenId].cooldownIndex += 1;
    }
    function getGeneration(uint256 _tokenId) external view returns (uint16) {
        return monsters[_tokenId].generation;
    }
    function getCooldownEndBlock(uint256 _tokenId) external view returns (uint64) {
        return monsters[_tokenId].cooldownEndBlock;
    }
    function setCooldownEndBlock(uint256 _tokenId, uint64 _cooldownEndBlock) external onlyOwner {
        monsters[_tokenId].cooldownEndBlock = _cooldownEndBlock;
    }
    function getBirthTime(uint256 _tokenId) external view returns (uint64) {
        return monsters[_tokenId].birthTime;
    }
    function getMonsterId(uint256 _tokenId) external view returns (uint16) {
        return monsters[_tokenId].monsterId;
    }
    function getMonsterNum(uint256 _tokenId) external view returns (uint32) {
        return monsters[_tokenId].monsterNum;
    }
    function getProperties(uint256 _tokenId) external view returns (bytes) {
        return monsters[_tokenId].properties;
    }
    function updateProperties(uint256 _tokenId, bytes _properties) external onlyOwner {
        monsters[_tokenId].properties = _properties;
    }
    function setMonsterIndexToOwner(uint256 _tokenId, address _owner) external onlyOwner {
        monsterIndexToOwner[_tokenId] = _owner;
    }
    function increaseOwnershipTokenCount(address _owner) external onlyOwner {
        ownershipTokenCount[_owner]++;
    }
    function decreaseOwnershipTokenCount(address _owner) external onlyOwner {
        ownershipTokenCount[_owner]--;
    }
    function setMonsterIndexToApproved(uint256 _tokenId, address _approved) external onlyOwner {
        monsterIndexToApproved[_tokenId] = _approved;
    }
    function deleteMonsterIndexToApproved(uint256 _tokenId) external onlyOwner {
        delete monsterIndexToApproved[_tokenId];
    }
    function increasePromoCreatedCount() external onlyOwner {
        promoCreatedCount++;
    }
    function increaseSystemCreatedCount() external onlyOwner {
        systemCreatedCount++;
    }
    function increasePregnantCounter() external onlyOwner {
        pregnantMonsters++;
    }
    function decreasePregnantCounter() external onlyOwner {
        pregnantMonsters--;
    }
}