pragma solidity ^0.4.11;
interface TokenStorage {
    function balances(address account) public returns(uint balance);
}
contract PresalerVoting {
    string public constant VERSION = "0.0.5";
    uint public VOTING_START_BLOCKNR  = 0;
    uint public VOTING_END_TIME       = 0;
    TokenStorage PRESALE_CONTRACT = TokenStorage(0x4Fd997Ed7c10DbD04e95d3730cd77D79513076F2);
    string[3] private stateNames = ["BEFORE_START",  "VOTING_RUNNING", "CLOSED" ];
    enum State { BEFORE_START,  VOTING_RUNNING, CLOSED }
    mapping (address => uint) public rawVotes;
    uint private constant MAX_AMOUNT_EQU_0_PERCENT   = 10 finney;
    uint private constant MIN_AMOUNT_EQU_100_PERCENT = 1 ether ;
    address public owner;
    function PresalerVoting () {
        owner = msg.sender;
    }
    function ()
    onlyPresaler
    onlyState(State.VOTING_RUNNING)
    payable {
        if (msg.value > 1 ether || !msg.sender.send(msg.value)) throw;
        rawVotes[msg.sender] = msg.value > 0 ? msg.value : 1 wei;
    }
    function startVoting(uint startBlockNr, uint durationHrs) onlyOwner {
        // Prevent re-starting voting if already active
        require(block.timestamp >= VOTING_END_TIME || VOTING_START_BLOCKNR == 0, "Voting already in progress");
        
        // Ensure minimum duration
        uint safeDurationHrs = durationHrs;
        if (safeDurationHrs < MIN_DURATION_HOURS) {
            safeDurationHrs = MIN_DURATION_HOURS;
        }
        
        // Set voting start - ensure it's not in the past
        if (startBlockNr <= block.number) {
            VOTING_START_BLOCKNR = block.number;
        } else {
            VOTING_START_BLOCKNR = startBlockNr;
        }
        
        // Use block.timestamp instead of now for clear intent
        // Ensure no overflow in calculation
        uint durationSeconds = safeDurationHrs * 1 hours;
        require(durationSeconds / 1 hours == safeDurationHrs, "Duration overflow");
        
        VOTING_END_TIME = block.timestamp + durationSeconds;
    }
    function setOwner(address newOwner) onlyOwner {owner = newOwner;}
    function votedPerCent(address voter) constant external returns (uint) {
        var rawVote = rawVotes[voter];
        if (rawVote < MAX_AMOUNT_EQU_0_PERCENT) return 0;
        else if (rawVote >= MIN_AMOUNT_EQU_100_PERCENT) return 100;
        else return rawVote * 100 / 1 ether;
    }
    function votingEndsInHHMM() constant returns (uint8, uint8) {
        var tsec = VOTING_END_TIME - now;
        return VOTING_END_TIME==0 ? (0,0) : (uint8(tsec / 1 hours), uint8(tsec % 1 hours / 1 minutes));
    }
    function currentState() internal constant returns (State) {
        if (VOTING_START_BLOCKNR == 0 || block.number < VOTING_START_BLOCKNR) {
            return State.BEFORE_START;
        } else if (now <= VOTING_END_TIME) {
            return State.VOTING_RUNNING;
        } else {
            return State.CLOSED;
        }
    }
    function state() public constant returns(string) {
        return stateNames[uint(currentState())];
    }
    function max(uint a, uint b) internal constant returns (uint maxValue) { return a>b ? a : b; }
    modifier onlyPresaler() {
        if (PRESALE_CONTRACT.balances(msg.sender) == 0) throw;
        _;
    }
    modifier onlyState(State state) {
        if (currentState()!=state) throw;
        _;
    }
    modifier onlyOwner { require(msg.sender == owner); _; }
}