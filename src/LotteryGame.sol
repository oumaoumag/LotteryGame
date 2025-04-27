// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title LotteryGame
 * @dev A simple Ethereum-based lottery game where players can:
 * - Register by paying 0.02 ETH
 * - Make up to 2 guesses between 1-9
 * - Win prizes if they guess correctly
 */
contract LotteryGame {
    /// @dev Struct to store player information
    struct Player {
        uint8 attempts;    // Number of guesses made
        bool active;       // Whether player is registered
    }

    // Constants
    uint256 public constant REGISTRATION_FEE = 0.02 ether;
    uint8 public constant MAX_ATTEMPTS = 2;
    uint8 public constant MAX_NUMBER = 9;
    
    // State Variables
    mapping(address => Player) public players;
    address[] public activePlayers;
    address[] public winners;
    uint256 public totalPrizePool;  // Renamed from prizePool
    bool private _distributing;

    // Events
    event PlayerRegistered(address indexed player);
    event GuessSubmitted(address indexed player, uint256 guess);
    event WinnerSelected(address indexed winner, uint256 prize);
    event GameReset();

    /**
     * @dev Register a new player in the game
     * @notice Players must send exactly 0.02 ETH to register
     * Requirements:
     * - Exact registration fee must be paid
     * - Player must not be already registered
     */
    function register() external payable {
        require(msg.value == REGISTRATION_FEE, "Please stake 0.02 ETH");
        require(!players[msg.sender].active, "Already registered");
        
        players[msg.sender] = Player(0, true);
        activePlayers.push(msg.sender);
        totalPrizePool += msg.value;
        
        emit PlayerRegistered(msg.sender);
    }

    /**
     * @dev Submit a guess for the lottery
     * @param guess The number guessed by the player (1-9)
     * Requirements:
     * - Player must be registered
     * - Player must have attempts remaining
     * - Guess must be within valid range
     */
    function guessNumber(uint256 guess) external {
        Player storage player = players[msg.sender];
        
        require(player.active, "Player is not active");
        require(player.attempts < MAX_ATTEMPTS, "Player has already made 2 attempts");
        require(guess >= 1 && guess <= MAX_NUMBER, "Number must be between 1 and 9");

        uint256 winningNumber = _generateRandomNumber();
        if (guess == winningNumber) {
            winners.push(msg.sender);
        }

        player.attempts++;
        
        emit GuessSubmitted(msg.sender, guess);
    }

    /**
     * @dev Distribute prizes to winners and reset the game
     * Requirements:
     * - Must have at least one winner
     * - Distribution must not be in progress
     */
    function distributePrizes() external {
        require(!_distributing, "Distribution in progress");
        require(winners.length > 0, "No winners to distribute prizes to");
        _distributing = true;

        uint256 currentPrize = address(this).balance;
        uint256 prizePerWinner = currentPrize / winners.length;
        
        address[] memory winnersToReceive = winners;
        _resetGame();

        for (uint256 i = 0; i < winnersToReceive.length; i++) {
            address winner = winnersToReceive[i];
            (bool success, ) = winner.call{value: prizePerWinner}("");
            require(success, "Prize transfer failed");
            emit WinnerSelected(winner, prizePerWinner);
        }

        _distributing = false;
    }

    /**
     * @dev Get list of previous winners
     * @return Array of winner addresses
     */
    function getPrevWinners() external view returns (address[] memory) {
        return winners;
    }

    /**
     * @dev Get total prize pool amount
     * @return Current balance of the contract
     */
    function totalPrize() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Generate a pseudo-random number between 1 and 9
     * @return Random number
     * @notice Not secure for production use - uses block data for randomness
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 9 + 1;
    }
    
    /**
     * @dev Check if all registered players have used their attempts
     * @return bool indicating if all players have finished
     */
    function _allPlayersFinished() internal view returns (bool) {
        for (uint256 i = 0; i < activePlayers.length; i++) {
            if (players[activePlayers[i]].attempts < MAX_ATTEMPTS) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Reset game state for next round
     * @notice Clears all players, winners, and prize pool
     */
    function _resetGame() internal {
        totalPrizePool = 0;
        
        for (uint256 i = 0; i < activePlayers.length; i++) {
            delete players[activePlayers[i]];
        }
        
        delete activePlayers;
        delete winners;
        
        emit GameReset();
    }
}
