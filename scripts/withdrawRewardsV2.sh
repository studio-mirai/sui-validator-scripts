#!/bin/bash

VALIDATOR_ADDRESS=$(sui client active-address)
RECIPIENT_ADDRESS=$1

getStakedSuiIds() {
    local url='https://sui-mainnet-endpoint.blockvision.org:443'
    local headers='Content-Type: application/json'
    local data='{"jsonrpc": "2.0", "id": 1, "method": "suix_getStakes", "params": ["'"$VALIDATOR_ADDRESS"'"]}'
    curl -X POST -H "$headers" -d "$data" "$url" | jq -r '.result[].stakes[].stakedSuiId'
}

stakedSuiIds=$(getStakedSuiIds)

if [ -z "$stakedSuiIds" ]; then
    echo "No staked Sui IDs found. Exiting script."
    exit 0
fi

sui client ptb \
    --move-call "0x2::balance::zero<0x2::sui::SUI>" \
    --assign balance \
    $(for stakedSuiId in $stakedSuiIds; do
        echo "--move-call 0x3::sui_system::request_withdraw_stake_non_entry @0x5 @$stakedSuiId"
        echo "--assign withdrawnBalance"
        echo "--move-call 0x2::balance::join<0x2::sui::SUI> balance withdrawnBalance"
    done) \
    --move-call "0x2::coin::from_balance<0x2::sui::SUI> balance" \
    --assign coin \
    --transfer-objects [coin] @$RECIPIENT_ADDRESS \
    --gas-budget 1000000000