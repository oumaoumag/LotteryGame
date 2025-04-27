# Lisk Bootcamp Task 1: LotteryGame Smart Contract

## Overview

This project implements a simple Ethereum-based lottery game where players can register, make guesses, and potentially win ETH prizes. The LotteryGame smart contract demonstrates Solidity development fundamentals including:

- State variables and data structures
- Function implementation
- Event handling
- Basic randomness generation
- Testing with Foundry

## Project Structure

```
Lisk-BootCamp-Task1/
├── src/
│   └── LotteryGame.sol       # Main contract implementation
├── test/
│   └── LotteryGame.t.sol     # Foundry tests
└── script/
    └── LotteryGame.s.sol     # Deployment script
```

## Contract Details

The `LotteryGame` contract implements a lottery system with the following features:

### Game Rules

1. Players must stake exactly 0.02 ETH to register
2. Each player can make up to 2 guesses
3. Valid guesses are numbers between 1 and 9
4. Players who guess correctly are added to the winners list
5. Prizes are distributed equally among all winners
6. After distribution, the game state is reset for a new round

### Key Functions

- `register()`: Allows players to join the game by staking 0.02 ETH
- `guessNumber(uint256 guess)`: Allows registered players to make guesses
- `distributePrizes()`: Distributes prizes to winners and resets the game
- `getPrevWinners()`: Returns a list of previous winners
- `totalPrize()`: Returns the current prize pool amount

### Events

- `PlayerRegistered`: Emitted when a player registers
- `GuessSubmitted`: Emitted when a player submits a guess
- `WinnerSelected`: Emitted when a winner receives a prize
- `GameReset`: Emitted when the game state is reset

## Deployment Information

The contract has been deployed to the Lisk Sepolia testnet at:

```
Contract Address: 0x2825394600414ff582f89ff5791ecc2361b2c613
```

You can interact with the contract through the Lisk Sepolia RPC endpoint:
```
https://rpc.sepolia-api.lisk.com
```

## How to Interact with the Contract

### Using Foundry

You can interact with the deployed contract using Foundry's `cast` command:

```bash
# Register as a player
cast send 0x2825394600414ff582f89ff5791ecc2361b2c613 "register()" --value 0.02ether --rpc-url https://rpc.sepolia-api.lisk.com --private-key YOUR_PRIVATE_KEY

# Make a guess (e.g., guessing the number 5)
cast send 0x2825394600414ff582f89ff5791ecc2361b2c613 "guessNumber(uint256)" 5 --rpc-url https://rpc.sepolia-api.lisk.com --private-key YOUR_PRIVATE_KEY

# Distribute prizes
cast send 0x2825394600414ff582f89ff5791ecc2361b2c613 "distributePrizes()" --rpc-url https://rpc.sepolia-api.lisk.com --private-key YOUR_PRIVATE_KEY

# View previous winners
cast call 0x2825394600414ff582f89ff5791ecc2361b2c613 "getPrevWinners()" --rpc-url https://rpc.sepolia-api.lisk.com
```

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/oumaoumag/LotteryGame.git
   cd LotteryGame
   ```

2. Install dependencies:
   ```bash
   forge install
   ```

### Testing

Run the tests using Foundry:

```bash
forge test
```

The tests verify that:
1. Players can register with the correct amount
2. Registration fails with incorrect amounts
3. Guesses work within valid ranges
4. Unregistered players cannot make guesses
5. Players are limited to two attempts
6. Prizes cannot be distributed when there are no winners

### Deployment

To deploy the contract to a network:

1. Create a `.env` file with your private key:
   ```
   PRIVATE_KEY=your_private_key_here
   ```

2. Run the deployment script:
   ```bash
   forge script script/LotteryGame.s.sol:DeployScript --rpc-url https://rpc.sepolia-api.lisk.com --broadcast --verify
   ```

## Security Considerations

- The contract uses a simplified random number generator based on block properties, which is not secure for production use
- For a production environment, a more secure random number generator (like Chainlink VRF) would be required
- The contract does not have an owner or admin role, so there's no way to pause or upgrade it

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.