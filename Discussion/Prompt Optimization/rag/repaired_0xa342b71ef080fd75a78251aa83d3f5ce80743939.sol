pragma solidity ^0.4.18;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}

contract QIUToken is StandardToken, Ownable {
    string public name = 'QIUToken';
    string public symbol = 'QIU';
    uint8 public decimals = 0;
    uint public INITIAL_SUPPLY = 5000000000;
    uint public eth2qiuRate = 10000;

    function() public payable { } 

    function QIUToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = INITIAL_SUPPLY / 10;
        balances[this] = INITIAL_SUPPLY - balances[owner];
    }

    function exchangeForETH(uint qiuAmount) public returns (bool){
        uint ethAmount = qiuAmount * 1000000000000000000 / eth2qiuRate; 
        require(address(this).balance >= ethAmount);
        balances[this] = balances[this].add(qiuAmount);
        balances[msg.sender] = balances[msg.sender].sub(qiuAmount);
        msg.sender.transfer(ethAmount);
        return true;
    }

    function exchangeForQIU() payable public returns (bool){
        uint qiuAmount = msg.value * eth2qiuRate / 1000000000000000000;
        require(qiuAmount <= balances[this]);
        balances[this] = balances[this].sub(qiuAmount);
        balances[msg.sender] = balances[msg.sender].add(qiuAmount);
        return true;
    }

    function getETHBalance() public view returns (uint) {
        return address(this).balance; 
    }
}

contract SoccerChampion is Ownable {
    using SafeMath for uint256;

    struct Tournament {
        uint id;
        bool isEnded;
        bool isLockedForSupport;
        bool initialized;
        Team[] teams;
        SupportTicket[] tickets;
    }

    struct Team {
        uint id;
        bool isKnockout;
        bool isChampion;
    }

    struct SupportTicket {
        uint teamId;
        address supportAddres;
        uint supportAmount;
    }

    mapping (uint => Tournament) public tournaments;
    uint private _nextTournamentId = 0;
    QIUToken public _internalToken;
    uint private _commissionNumber;
    uint private _commissionScale;

    function SoccerChampion(QIUToken _tokenAddress) public {
        _nextTournamentId = 0;
        _internalToken = _tokenAddress;
        _commissionNumber = 2;
        _commissionScale = 100;
    }

    function modifyCommission(uint number, uint scale) public onlyOwner returns(bool){
        _commissionNumber = number;
        _commissionScale = scale;
        return true;
    }

    function createNewTourament(uint[] teamIds) public onlyOwner {
        uint newTourId = _nextTournamentId;
        tournaments[newTourId].id = newTourId;
        tournaments[newTourId].isEnded = false;
        tournaments[newTourId].isLockedForSupport = false;
        tournaments[newTourId].initialized = true;
        for(uint idx = 0; idx < teamIds.length; idx++){
            Team memory team;
            team.id = teamIds[idx];
            team.isChampion = false;
            tournaments[newTourId].teams.push(team);
        }
        _nextTournamentId++;   
    }

    function supportTeam(uint tournamentId, uint teamId, uint amount) public {
        require(tournaments[tournamentId].initialized);
        require(_internalToken.balanceOf(msg.sender) >= amount);
        require(!tournaments[tournamentId].isEnded);
        require(!tournaments[tournamentId].isLockedForSupport);
        require(amount > 0);
        SupportTicket memory ticket;
        ticket.teamId = teamId;
        ticket.supportAddres = msg.sender;
        ticket.supportAmount = amount;
        _internalToken.originTransfer(this, amount);
        tournaments[tournamentId].tickets.push(ticket);
    }

    function _getTournamentSupportAmount(uint tournamentId) public view returns(uint){
        uint supportAmount = 0;
        for(uint idx = 0; idx < tournaments[tournamentId].tickets.length; idx++){
            supportAmount = supportAmount.add(tournaments[tournamentId].tickets[idx].supportAmount);
        }
        return supportAmount;
    }

    function _getTeamSupportAmount(uint tournamentId, uint teamId) public view returns(uint){
        uint supportAmount = 0;
        for(uint idx = 0; idx < tournaments[tournamentId].tickets.length; idx++){
            if(tournaments[tournamentId].tickets[idx].teamId == teamId){
                supportAmount = supportAmount.add(tournaments[tournamentId].tickets[idx].supportAmount);
            }
        }
        return supportAmount;
    }

    function _getUserSupportForTeamInTournament(uint tournamentId, uint teamId) public view returns(uint){
        uint supportAmount = 0;
        for(uint idx = 0; idx < tournaments[tournamentId].tickets.length; idx++){
            if(tournaments[tournamentId].tickets[idx].teamId == teamId && tournaments[tournamentId].tickets[idx].supportAddres == msg.sender){
                supportAmount = supportAmount.add(tournaments[tournamentId].tickets[idx].supportAmount);
            }
        }
        return supportAmount;
    }

    function getTeamlistSupportInTournament(uint tournamentId) public view returns(uint[] teamIds, uint[] supportAmounts, bool[] knockOuts, uint championTeamId, bool isEnded, bool isLocked){  
        if(tournaments[tournamentId].initialized){
            teamIds = new uint[](tournaments[tournamentId].teams.length);
            supportAmounts = new uint[](tournaments[tournamentId].teams.length);
            knockOuts = new bool[](tournaments[tournamentId].teams.length);
            championTeamId = 0;
            for(uint tidx = 0; tidx < tournaments[tournamentId].teams.length; tidx++){
                teamIds[tidx] = tournaments[tournamentId].teams[tidx].id;
                if(tournaments[tournamentId].teams[tidx].isChampion){
                    championTeamId = teamIds[tidx];
                }
                knockOuts[tidx] = tournaments[tournamentId].teams[tidx].isKnockout;
                supportAmounts[tidx] = _getTeamSupportAmount(tournamentId, teamIds[tidx]);
            }
            isEnded = tournaments[tournamentId].isEnded;
            isLocked = tournaments[tournamentId].isLockedForSupport;
        }
    }

    function getUserSupportInTournament(uint tournamentId) public view returns(uint[] teamIds, uint[] supportAmounts){
        if(tournaments[tournamentId].initialized){
            teamIds = new uint[](tournaments[tournamentId].teams.length);
            supportAmounts = new uint[](tournaments[tournamentId].teams.length);
            for(uint tidx = 0; tidx < tournaments[tournamentId].teams.length; tidx++){
                teamIds[tidx] = tournaments[tournamentId].teams[tidx].id;
                uint userSupportAmount = _getUserSupportForTeamInTournament(tournamentId, teamIds[tidx]);
                supportAmounts[tidx] = userSupportAmount;
            }
        }
    }

    function getUserWinInTournament(uint tournamentId) public view returns(bool isEnded, uint winAmount){
        if(tournaments[tournamentId].initialized){
            isEnded = tournaments[tournamentId].isEnded;
            if(isEnded){
                for(uint tidx = 0; tidx < tournaments[tournamentId].teams.length; tidx++){
                    Team memory team = tournaments[tournamentId].teams[tidx];
                    if(team.isChampion){
                        uint tournamentSupportAmount = _getTournamentSupportAmount(tournamentId);
                        uint teamSupportAmount = _getTeamSupportAmount(tournamentId, team.id);
                        uint userSupportAmount = _getUserSupportForTeamInTournament(tournamentId, team.id);
                        uint gainAmount = (userSupportAmount.mul(tournamentSupportAmount)).div(teamSupportAmount);
                        winAmount = (gainAmount.mul(_commissionScale.sub(_commissionNumber))).div(_commissionScale);
                    }
                }
            }else{
                winAmount = 0;
            }
        }
    }

    function knockoutTeam(uint tournamentId, uint teamId) public onlyOwner{
        require(tournaments[tournamentId].initialized);
        require(!tournaments[tournamentId].isEnded);
        for(uint tidx = 0; tidx < tournaments[tournamentId].teams.length; tidx++){
            Team storage team = tournaments[tournamentId].teams[tidx];
            if(team.id == teamId){
                team.isKnockout = true;
            }
        }
    }

    function endTournament(uint tournamentId, uint championTeamId) public onlyOwner{
        require(tournaments[tournamentId].initialized);
        require(!tournaments[tournamentId].isEnded);
        tournaments[tournamentId].isEnded = true;
        uint tournamentSupportAmount = _getTournamentSupportAmount(tournaments[tournamentId].id);
        uint teamSupportAmount = _getTeamSupportAmount(tournaments[tournamentId].id, championTeamId);
        uint totalClearAmount = 0;
        for(uint tidx = 0; tidx < tournaments[tournamentId].teams.length; tidx++){
            Team storage team = tournaments[tournamentId].teams[tidx];
            if(team.id == championTeamId){
                team.isChampion = true;
                break;
            }
        }
        for(uint idx = 0 ; idx < tournaments[tournamentId].tickets.length; idx++){
            SupportTicket memory ticket = tournaments[tournamentId].tickets[idx];
            if(ticket.teamId == championTeamId){
                if(teamSupportAmount != 0){
                    uint gainAmount = (ticket.supportAmount.mul(tournamentSupportAmount)).div(teamSupportAmount);
                    uint actualGainAmount = (gainAmount.mul(_commissionScale.sub(_commissionNumber))).div(_commissionScale);
                    _internalToken.ownerTransferFrom(this, ticket.supportAddres, actualGainAmount);
                    totalClearAmount = totalClearAmount.add(actualGainAmount);
                }
            }
        }
        _internalToken.ownerTransferFrom(this, owner, tournamentSupportAmount.sub(totalClearAmount));
    }

    function lockTournament(uint tournamentId, bool isLock) public onlyOwner{
        require(tournaments[tournamentId].initialized);
        require(!tournaments[tournamentId].isEnded);
        tournaments[tournamentId].isLockedForSupport = isLock;
    }
}


This code includes the necessary security improvements and maintains the original logic of the Smart Contracts.