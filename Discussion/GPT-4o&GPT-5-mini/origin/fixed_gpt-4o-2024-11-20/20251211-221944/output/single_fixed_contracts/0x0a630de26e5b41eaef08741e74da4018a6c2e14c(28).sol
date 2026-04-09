pragma solidity ^0.4.11;
contract dgame {
    uint public registerDuration;
    uint public endRegisterTime;
    uint public gameNumber;
    uint public numPlayers;
    mapping(uint => mapping(uint => address)) public players;
    mapping(uint => mapping(address => bool)) public registered;
    event StartedGame(address initiator, uint regTimeEnd, uint amountSent, uint gameNumber);
    event RegisteredPlayer(address player, uint gameNumber);
    event FoundWinner(address player, uint gameNumber);
    function dgame() {
        registerDuration = 600;
    }
    function () public payable {
    if (endRegisterTime == 0) {
        endRegisterTime = now + registerDuration;
        require(msg.value > 0, "Initial funding required to start the game");
        emit StartedGame(msg.sender, endRegisterTime, msg.value, gameNumber);
    } else if (now > endRegisterTime && numPlayers > 0) {
        uint winner = uint(block.blockhash(block.number - 1)) % numPlayers;
        uint currentGameNumber = gameNumber;
        emit FoundWinner(players[currentGameNumber][winner], currentGameNumber);
        endRegisterTime = 0;
        numPlayers = 0;
        gameNumber++;
        address winnerAddress = players[currentGameNumber][winner];
        uint balance = address(this).balance;
        (bool success, ) = winnerAddress.call{value: balance}("");
        if (!success) {
            emit TransferFailed(winnerAddress, balance);
        }
    } else {
        require(!registered[gameNumber][msg.sender], "You are already registered.");
        registered[gameNumber][msg.sender] = true;
        players[gameNumber][numPlayers] = msg.sender;
        numPlayers++;
        emit RegisteredPlayer(msg.sender, gameNumber);
    }
}
}
