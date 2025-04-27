// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LotteryGame} from "../src/LotteryGame.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

    LotteryGame lottery = new LotteryGame();
    console.log("LotteryGame deployed to:", address(lottery));

    vm.stopBroadcast();
    }
}