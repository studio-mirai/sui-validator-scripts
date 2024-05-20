#!/bin/bash
#
# Merge SUI coins to a single coin.

# Create a list of all Sui coins excluding the gas coin (index 0) and format them for merging.
formattedSuiCoins=$(sui client gas --json | jq -r '.[1:] | .[].gasCoinId' | sed 's/^/@/; s/ /, @/g')

# Check if exactly one Sui coin is found
if [ -z "$formattedSuiCoins" ]; then
    echo "Only one Sui coin found. Exiting script."
    exit 0
fi

# Merge coins into a single Sui coin.
sui client ptb \
    --merge-coins gas [$formattedSuiCoins] \
    --gas-budget 10000000
