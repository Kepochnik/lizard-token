// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "src/LizardToken.sol";

contract LizardTokenTest is Test {
    LizardToken internal token;
    address internal lizard = address(1);
    address internal lizard2 = address(2);

    function setUp() public {
        token = new LizardToken();

        vm.deal(lizard, 100 ether);
        vm.deal(lizard2, 100 ether);
    }

    function testCanDeployToken() public {
        assertEq(token.name(), "Lizard Token");
        assertEq(token.symbol(), "LZRD");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 0);
    }

    function testCanMint() public {
        token.awardTokens(lizard, 100 ether);
        assertEq(token.balanceOf(lizard), 100 ether);
        assertEq(token.totalSupply(), 100 ether);
    }

    function testFailToMintMoreThan20Mil() public {
        token.awardTokens(lizard, 20_000_000 ether);
        token.awardTokens(lizard2, 1 ether);
    }

    function testCanBurn() public {
        token.awardTokens(lizard, 100 ether);
        token.burnTokens(lizard, 100 ether);
        assertEq(token.balanceOf(lizard), 0);
        assertEq(token.totalSupply(), 0);
    }

    function testCanSetPermissions() public {
        token.setCanMint(lizard);
        token.setCanBurn(lizard);

        vm.startPrank(lizard);
        token.awardTokens(lizard2, 100 ether);
        token.burnTokens(lizard2, 100 ether);
        vm.stopPrank();
        uint8 perm = token.permissions(lizard);
        assert(perm & token.CAN_MINT() == token.CAN_MINT());
        assert(perm & token.CAN_BURN() == token.CAN_BURN());
    }

    function testCanTransferOwnership() public {
        token.transferOwnership(lizard);
        assertEq(token.owner(), lizard);
    }

    function testCanUnsetPermissions() public {
        token.setCanMint(lizard);
        token.unsetCanMint(lizard);
        token.setCanBurn(lizard);
        token.unsetCanBurn(lizard);
        uint8 perm = token.permissions(lizard);
        assert(perm & token.CAN_MINT() != token.CAN_MINT());
        assert(perm & token.CAN_BURN() != token.CAN_BURN());
    }

    function testFailToMintWithoutPermission() public {
        vm.prank(lizard);
        token.awardTokens(lizard2, 100 ether);
    }

    function testFailToBurnWithoutPermission() public {
        token.awardTokens(lizard2, 100 ether);
        vm.prank(lizard);
        token.burnTokens(lizard2, 100 ether);
    }

    function testFailToTransfer() public {
        token.awardTokens(lizard, 100 ether);
        vm.startPrank(lizard);
        token.transfer(lizard2, 10 ether);
    }

    function testFailToApprove() public {
        token.awardTokens(lizard, 100 ether);
        vm.startPrank(lizard);
        token.approve(lizard2, 10 ether);
    }
}
