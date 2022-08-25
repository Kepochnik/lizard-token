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
    bytes32 internal constant MERKLE_ROOT1 =
        0x2bdb488e2a77d740ad346e6c4a64c8a825d9fed6b4650e8857bba5f5cf90831f;
    bytes32 internal constant MERKLE_ROOT2 =
        0x3df8f0ee76e00c0d83e0166282ee8c4f5c4b0f634dfb14908d6cee93dbc97144;

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

    function testUserCanClaim() public {
        distributor.setMerkleRoot(MERKLE_ROOT1);

        // lizard - 10 LZRD
        bytes32[] memory proof1 = new bytes32[](1);
        proof1[
            0
        ] = 0x68d6943699773c5eac94d110209046ecf39062e98800a490f2106c064b8ac3d8;

        vm.prank(lizard);
        distributor.claim(10 ether, "ODYSEE", proof1);

        assertEq(token.balanceOf(lizard), 10 ether);

        vm.expectRevert(LizardDistributor.AlreadyClaimed.selector);
        vm.prank(lizard);
        distributor.claim(10 ether, "ODYSEE", proof1);

        vm.expectRevert(LizardDistributor.Unauthorized.selector);
        vm.prank(lizard2);
        distributor.claim(100 ether, "ODYSEE", proof1);

        // Update Merkle Root to include new claims
        distributor.setMerkleRoot(MERKLE_ROOT2);

        // lizard2 - 35 LZRD
        bytes32[] memory proof2 = new bytes32[](2);
        proof2[
            0
        ] = 0xdf1f757cf17111591f40aaf3fa1ed46c0f3ce76c427d15c5ebab10ad64c922fa;
        proof2[
            1
        ] = 0x5158bbcef4ec6db4683fed303fb8ad41af1fc3150f0e9484029f03bd76769b09;

        vm.prank(lizard2);
        distributor.claim(35 ether, "ODYSEE", proof2);

        // lizard3 - 42 LZRD
        bytes32[] memory proof3 = new bytes32[](1);
        proof3[
            0
        ] = 0x2bdb488e2a77d740ad346e6c4a64c8a825d9fed6b4650e8857bba5f5cf90831f;

        assertEq(token.balanceOf(lizard2), 35 ether);

        vm.prank(lizard3);
        distributor.claim(42 ether, "NEWSERIES", proof3);

        assertEq(token.balanceOf(lizard3), 42 ether);
    }
}
