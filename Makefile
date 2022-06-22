# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

.PHONY: all test

# deps
update:; forge update

# Build & Test
build 	:; forge build
test 		:; forge test -vv
watch 	:; forge test -vv --watch
deploy  :; forge script script/Deploy.s.sol:DeployScript \
	--rpc-url ${ARBITRUM_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
