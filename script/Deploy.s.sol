// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "src/LizardToken.sol";
import "src/LizardDistributor.sol";

contract DeployScript is Script {
    function run() public {
        // vm.broadcast();
        // LizardToken lz = new LizardToken();

        vm.broadcast();
        LizardDistributor ld = new LizardDistributor(ILizardToken(0x1A65532D7FFBBb8Bab09F4eeFd87d8518a630c95);
    }
}
