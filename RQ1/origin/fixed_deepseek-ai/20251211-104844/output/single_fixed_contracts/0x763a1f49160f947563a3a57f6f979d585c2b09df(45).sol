pragma solidity ^0.4.24;
interface FoMo3DlongInterface {
      function getBuyPrice()
        public
        view
        returns(uint256)
    ;
  function getTimeLeft()
        public
        view
        returns(uint256)
    ;
  function withdraw() external;
}
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
contract PwnFoMo3D is Owned {
    FoMo3DlongInterface fomo3d;
  constructor() public payable {
     fomo3d  = FoMo3DlongInterface(0x0aD3227eB47597b566EC138b3AfD78cFEA752de5);
  }
  function gotake() public {
    if (fomo3d.getTimeLeft() > 50) {
        revert();
    }
    
    uint256 buyPrice = fomo3d.getBuyPrice();
    uint256 amountToSend = buyPrice * 2;
    
    require(address(this).balance >= amountToSend, "Insufficient contract balance");
    
    // Use transfer() instead of call.value() for safer ether transfer
    address(fomo3d).transfer(amountToSend);
    
    fomo3d.withdraw();
}
    function withdrawOwner(uint256 a)  public onlyOwner {
        msg.sender.transfer(a);    
    }
}