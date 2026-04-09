pragma solidity ^0.4.18;
contract KittyCoreInterface {
    function cooAddress() public returns(address);
}
contract GeneScience {
    bool public isGeneScience = true;
    uint256 internal constant maskLast8Bits = uint256(0xff);
    uint256 internal constant maskFirst248Bits = uint256(~0xff);
    address internal _privilegedBirther;
    uint256 public privilegedBirtherWindowSize = 5;
    KittyCoreInterface _kittyCore;
    function GeneScience(address _privilegedBirtherAddress, address _kittyCoreAddress) public {
        require(_kittyCoreAddress != address(0));
        _kittyCore = KittyCoreInterface(_kittyCoreAddress);
        _privilegedBirther = _privilegedBirtherAddress;
    }
    function setPrivilegedBirther(address _birtherAddress) public {
        require(msg.sender == _kittyCore.cooAddress());
        _privilegedBirther = _birtherAddress;
    }
    function _ascend(uint8 trait1, uint8 trait2, uint256 rand) internal pure returns(uint8 ascension) {
        ascension = 0;
        uint8 smallT = trait1;
        uint8 bigT = trait2;
        if (smallT > bigT) {
            bigT = trait1;
            smallT = trait2;
        }
        if ((bigT - smallT == 1) && smallT % 2 == 0) {
            uint256 maxRand;
            if (smallT < 23) maxRand = 1;
            else maxRand = 0;
            if (rand <= maxRand ) {
                ascension = (smallT / 2) + 16;
            }
        }
    }
    function _sliceNumber(uint256 _n, uint256 _nbits, uint256 _offset) private pure returns (uint256) {
        uint256 mask = uint256((2**_nbits) - 1) << _offset;
        return uint256((_n & mask) >> _offset);
    }
    function _get5Bits(uint256 _input, uint256 _slot) internal pure returns(uint8) {
        return uint8(_sliceNumber(_input, uint256(5), _slot * 5));
    }
    function decode(uint256 _genes) public pure returns(uint8[]) {
        uint8[] memory traits = new uint8[](48);
        uint256 i;
        for(i = 0; i < 48; i++) {
            traits[i] = _get5Bits(_genes, i);
        }
        return traits;
    }
    function encode(uint8[] _traits) public pure returns (uint256 _genes) {
        _genes = 0;
        for(uint256 i = 0; i < 48; i++) {
            _genes = _genes << 5;
            _genes = _genes | _traits[47 - i];
        }
        return _genes;
    }
    function expressingTraits(uint256 _genes) public pure returns(uint8[12]) {
        uint8[12] memory express;
        for(uint256 i = 0; i < 12; i++) {
            express[i] = _get5Bits(_genes, i * 4);
        }
        return express;
    }
    function mixGenes(uint256 _genes1, uint256 _genes2, uint256 _targetBlock) public returns (uint256) {
    if (_privilegedBirther == address(0) || msg.sender == _privilegedBirther) {
        require(block.number > _targetBlock);
    } else {
        require(block.number > _targetBlock + privilegedBirtherWindowSize);
    }
    // Rest of the function remains the same...
}
}