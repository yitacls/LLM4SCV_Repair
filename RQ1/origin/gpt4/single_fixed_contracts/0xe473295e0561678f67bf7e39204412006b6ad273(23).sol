pragma solidity^0.4.17;
contract BountyEscrow {
  address public admin;
  function BountyEscrow() public {
    admin = msg.sender;
  }
  event Payout(
    address indexed sender,
    address indexed recipient,
    uint256 indexed sequenceNum,
    uint256 amount,
    bool success
  );
  function payout(address[] recipients, uint256[] amounts) public {
    require(admin == msg.sender);
    require(recipients.length == amounts.length);

    for (uint i = 0; i < recipients.length; i++) {
        require(recipients[i] != address(0));
        recipients[i].transfer(amounts[i]);
        
        Payout(
            msg.sender,
            recipients[i],
            i + 1,
            amounts[i]
        );
    }
}

  function () public payable { }
}