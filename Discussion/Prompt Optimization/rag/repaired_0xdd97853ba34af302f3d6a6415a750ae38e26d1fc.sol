// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.6.0;

contract betContractUP is usingOraclize {
    event UpSuccess(string status, address indexed EtherSentBy);
    event UpPlayerResult(string result, address indexed player, uint query1Result, uint query2Result, uint time);
    event UpStats(uint indexed totalBets, uint indexed total_amount_won, uint indexed total_bets_won, uint win_rate);

    uint public UP_totalBets;
    uint public UP_etherWin;
    uint public UP_winBets;
    uint public UP_winRate;
    uint public min_bet = 10000000000000000;
    uint public max_bet = 50000000000000000;

    struct Player {
        address playerAddress;
        uint playerbetvalue;
        bytes32 queryid1;
        bytes32 queryid2;
        uint queryResult1;
        uint queryResult2;
    }

    mapping(bytes32 => Player) Players;

    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function createBet() payable {
        require(msg.value >= min_bet && msg.value <= max_bet, "Invalid payment amount");
        
        bytes32 rngId1 = oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD).USD");

        Players[rngId1].playerAddress = msg.sender;
        Players[rngId1].playerbetvalue = msg.value;
        Players[rngId1].queryid1 = rngId1;
        Players[rngId1].queryid2 = 0;
    }

    function betContractUP() payable {
        owner = msg.sender;
    }

    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress(), "Unauthorized callback");

        if (Players[myid].queryid1 == myid && Players[myid].queryid2 == 0) {
            Players[myid].queryResult1 = stringToUint(result);
            bytes32 rngId2 = oraclize_query(120, "URL", "json(https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD).USD");

            Players[myid].queryid1 = 0;
            Players[rngId2].queryid1 = 0;
            Players[rngId2].playerAddress = Players[myid].playerAddress;
            Players[rngId2].playerbetvalue = Players[myid].playerbetvalue;
            Players[rngId2].queryResult1 = Players[myid].queryResult1;
            Players[rngId2].queryid2 = rngId2;
        } else if (Players[myid].queryid2 == myid && Players[myid].queryid1 == 0) {
            Players[myid].queryResult2 = stringToUint(result);

            if (Players[myid].queryResult1 < Players[myid].queryResult2) {
                UP_totalBets++;
                UP_winBets++;
                UP_winRate = UP_winBets * 10000 / UP_totalBets;
                UP_etherWin = UP_etherWin + ((Players[myid].playerbetvalue * 75) / 100);
                UpPlayerResult("WIN", Players[myid].playerAddress, Players[myid].queryResult1, Players[myid].queryResult2, now);
                winnerReward(Players[myid].playerAddress, Players[myid].playerbetvalue);
            } else if (Players[myid].queryResult1 > Players[myid].queryResult2) {
                UP_totalBets++;
                UP_winRate = UP_winBets * 10000 / UP_totalBets;
                UpPlayerResult("LOSE", Players[myid].playerAddress, Players[myid].queryResult1, Players[myid].queryResult2, now);
                loser(Players[myid].playerAddress);
            } else if (Players[myid].queryResult1 == Players[myid].queryResult2) {
                UP_totalBets++;
                UP_winRate = UP_winBets * 10000 / UP_totalBets;
                UpPlayerResult("DRAW", Players[myid].playerAddress, Players[myid].queryResult1, Players[myid].queryResult2, now);
                draw(Players[myid].playerAddress, Players[myid].playerbetvalue);