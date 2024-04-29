#!/bin/bash
#
# Withdraw all validator rewards.

VALIDATOR_ADDRESS=$(sui client active-address)

getStakedSuiIds() {
  	local url='https://sui-mainnet-endpoint.blockvision.org:443'
  	local headers='Content-Type: application/json'
  	local data='{"jsonrpc": "2.0", "id": 1, "method": "suix_getStakes", "params": ["'"$VALIDATOR_ADDRESS"'"]}'
  	curl -X POST -H "$headers" -d "$data" "$url" | jq -r '.result[].stakes[].stakedSuiId'
}

stakeSuiIds=$(getStakedSuiIds)

# Exit script if no staked Sui IDs are found
if [ -z "$stakeSuiIds" ]; then
    echo "No staked Sui IDs found. Exiting script."
    exit 0
fi

# Call request_withdraw_stake for each Staked SUI object.
# This will be improved later on by calling request_withdraw_stake_non_entry
# within a PTB instead.
for stakedSuiId in $stakeSuiIds; do
	sui client call \
		--package 0x3 \
		--module sui_system \
		--function request_withdraw_stake \
		--args 0x5 $stakedSuiId \
		--gas-budget 100000000 \
		--json
done