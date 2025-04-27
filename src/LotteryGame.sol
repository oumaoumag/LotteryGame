// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title LotteryGame
 * @dev A simple number guessing game where players can win ETH prizes
 */
contract LotteryGame {

    struct Player {
        uint256 attempts;
        bool active;
    }

    event PlayerRegistered(address player, uint256 amount);
    event GuessResult(address player, uint256 guess, bool correct);
    event PrizeDistributed(address[] winners, uint256 prizePerWinner);

    // This mapping connects Ethereum addresses to Player information
    mapping(address => Player) public players;

    // Keep track of all player addresses that have registerd 
    address[] public playerAddresses;

    // Keeps track of total ETH in the prize pool
    uint256 public totalPrize;

    // Array of addresses that won in the current round
    address[] public currentWinners;

    // Historical record of winners from previous rounds
    address[] public previousWinners;
    
    /**
     * @dev Register to play the game
     * Players must stake exactly 0.02 ETH to participate
     */
    function register() public payable {
        // Required amount check
        uint256 requiredAmount = 0.02 ether;
        require(msg.value == requiredAmount, "Please stake 0.02 ETH");

        // Double registration check
        require(!players[msg.sender].active, "Player already registered");

        // creating player record if new
        players[msg.sender] = Player({
            attempts: 0,
            active: true
        });

        // Tracking players
        playerAddresses.push(msg.sender);

        // Prize pool update
        totalPrize += msg.value;

        // event emission
        emit PlayerRegistered(msg.sender, msg.value);
    }                  

    /**
     * @dev Make a guess between 1 and 9
     * @param guess The player's guess
     */
    function guessNumber(uint256 guess) public {
        // Get player.s current state
        Player storage player = players[msg.sender];

        // Validate player is registered
        require(player.active, "Player is not active");

        // Check if player has attempts remaining
        require(player.attempts < 2, "Player has already made 2 attempts");

        // Validate guess is with within range
        require(guess >= 1 && guess <= 9, "Number must be between 1 and 9");

        // Generate winning number and compare
        uint256 winningNumber = _generateRandomNumber();
        bool hasWon = (guess == winningNumber);

        // Increment attempts
        player.attempts += 1;

        // If player won, add to winners list
        if (hasWon && !_isPlayerInWinners(msg.sender)) {
            currentWinners.push(msg.sender);
        }

        // emit result
        emit GuessResult(msg.sender, guess, hasWon);
    }

    /**
     * @dev Internal helper to check if player is already in winners list
     * @param playerAddress Address to check
     * @return boll True if player is already in winners list
     */
    function _isPlayerInWinners(address playerAddress) internal view returns (bool) {
        for (uint256 i = 0; i < currentWinners.length; i++) {
            if (currentWinners[i] == playerAddress) {
            return true;
            } 
        }
        return false;
    } 

    /**
     * @dev Distribute prizes to winners
     */
    function distributePrizes() public {     
        // Check if we have any winners
        require(currentWinners.length > 0, "No winners to distribute prizes to");

        // Calculate prize per winner
        uint256 prizePerWinner = totalPrize / currentWinners.length;

        // Store current winners for event emission
        address[] memory winners = currentWinners;
        
        // Transfer prizes and handler failures
        for (uint256 i = 0; i < currentWinners.length; i++) {
            address winner = currentWinners[i];

            // Reset player state 
            players[winner].attempts = 0;
            players[winner].active = false;

            // Transfer prize using call
            (bool success,) = winner.call{value: prizePerWinner}("");
            require(success, "Prize transfer failed");
        }

        // Update game state
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            delete players[playerAddresses[i]];
        }

        // Store winners in history
        for (uint256 i = 0; i < currentWinners.length; i++) {
            previousWinners.push(currentWinners[i]);
        }

        // Reset game state
        delete playerAddresses;
        delete currentWinners;
        totalPrize = 0;

        // Emit event
        emit PrizeDistributed(winners, prizePerWinner);
    }

    /**
     * @dev View function to get previous winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() public view returns (address[] memory) {
        return previousWinners;
    }

    /**
     * @dev Helper function to generate a "random" number
     * @return A uint between 1 and 9
     * NOTE: This is not secure for production use!
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 9 + 1;
    }
}
