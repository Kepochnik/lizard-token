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

    function testUserCanClaim() public {
        address owner = vm.addr(123456789);

        distributor.transferOwnership(owner);

        uint256 amount = 100 ether;
        bytes32 hash = keccak256(abi.encodePacked(lizard, amount, "abc123"));
        console.logBytes32(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(123456789, hash);

        vm.prank(lizard);
        distributor.claim(amount, "abc123", v, r, s);

        assertEq(token.balanceOf(lizard), 100 ether);

        vm.expectRevert(
            abi.encodeWithSelector(
                LizardDistributor.AlreadyClaimed.selector,
                "abc123"
            )
        );
        vm.prank(lizard);
        distributor.claim(amount, "abc123", v, r, s);

        hash = keccak256(abi.encodePacked(lizard, amount, "def456"));
        (v, r, s) = vm.sign(987654321, hash);
        vm.expectRevert(
            abi.encodeWithSelector(LizardDistributor.Unauthorized.selector)
        );
        vm.prank(lizard);
        distributor.claim(amount, "def456", v, r, s);
    }
}
