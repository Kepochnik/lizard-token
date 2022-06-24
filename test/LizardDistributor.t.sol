// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "src/LizardToken.sol";
import "src/LizardDistributor.sol";

contract LizardDistributorTest is Test {
    LizardToken internal token;
    LizardDistributor internal distributor;
    address internal lizard = address(1);
    address internal lizard2 = address(2);
    address internal lizard3 = address(3);

    function setUp() public {
        token = new LizardToken();
        distributor = new LizardDistributor(ILizardToken(address(token)));

        vm.deal(lizard, 100 ether);
        vm.deal(lizard2, 100 ether);
        vm.deal(lizard3, 100 ether);

        token.setCanMint(address(distributor));
    }

    function testCanDistribute() public {
        address[] memory rxs = new address[](3);
        rxs[0] = lizard;
        rxs[1] = lizard2;
        rxs[2] = lizard3;

        uint256[] memory amts = new uint256[](3);
        amts[0] = 100 ether;
        amts[1] = 14 ether;
        amts[2] = 4500 ether;

        distributor.distribute(rxs, amts);

        assertEq(token.balanceOf(lizard), 100 ether);
        assertEq(token.balanceOf(lizard2), 14 ether);
        assertEq(token.balanceOf(lizard3), 4500 ether);
    }
}
