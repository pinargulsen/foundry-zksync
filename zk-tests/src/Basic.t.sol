// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

contract BlockEnv {
    uint256 public number;
    uint256 public timestamp;

    constructor() {
        number = block.number;
        timestamp = block.timestamp;
    }
}

contract ZkBasicTest is Test {
    uint256 constant ERA_FORK_BLOCK = 19579636;
    uint256 constant ERA_FORK_BLOCK_TS = 1700601590;

    uint256 constant ETH_FORK_BLOCK = 19225195;
    uint256 constant ETH_FORK_BLOCK_TS = 1707901427;

    address constant TEST_ADDRESS = 0x6Eb28604685b1F182dAB800A1Bfa4BaFdBA8a79a;

    uint256 forkEra;
    uint256 forkEth;

    function setUp() public {
        forkEra = vm.createFork("mainnet", ERA_FORK_BLOCK);
        forkEth = vm.createFork("https://eth-mainnet.alchemyapi.io/v2/Lc7oIGYeL_QvInzI0Wiu_pOZZDEKBrdf", ETH_FORK_BLOCK);
    }

    function testZkBasicBlockNumber() public {
        vm.selectFork(forkEra);
        require(block.number == ERA_FORK_BLOCK, "era block number mismatch");

        vm.selectFork(forkEth);
        require(block.number == ETH_FORK_BLOCK, "eth block number mismatch");
    }

    function testZkBasicBlockTimestamp() public {
        vm.selectFork(forkEra);
        require(block.timestamp == ERA_FORK_BLOCK_TS, "era block timestamp mismatch");

        vm.selectFork(forkEth);
        require(block.timestamp == ETH_FORK_BLOCK_TS, "eth block timestamp mismatch");
    }

    function testZkBasicAddressBalance() public {
        vm.makePersistent(TEST_ADDRESS);
        vm.deal(TEST_ADDRESS, 100);

        vm.selectFork(forkEra);
        require(TEST_ADDRESS.balance == 100, "era balance mismatch");

        vm.selectFork(forkEth);
        require(TEST_ADDRESS.balance == 100, "eth balance mismatch");
    }

    function testZkPropagatedBlockEnv() public {
        BlockEnv be = new BlockEnv();
        require(be.number() == block.number, "propagated block number is the same as current");
        require(be.timestamp() == block.timestamp, "propagated block timestamp is the same as current");

        be = new BlockEnv();
        require(be.number() == block.number, "propagated block number stays constant");
        require(be.timestamp() == block.timestamp, "propagated block timestamp stays constant");

        vm.roll(42);
        vm.warp(42);

        be = new BlockEnv();
        require(be.number() == block.number, "propagated block number rolls");
        require(be.timestamp() == block.timestamp, "propagated block timestamp warps");
    }
}
