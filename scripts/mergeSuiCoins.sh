#!/bin/bash
#
# Merge SUI coins to a single coin.


# Create a list of all Sui coins.
# Output array starts at index 1 ([1:]) because index 0 is gas coin.
suiCoins=$(sui client gas --json | jq -r '.[1:] | .[].gasCoinId')

# Convert Sui coins into an array
suiCoinArray=($suiCoins)

# Check if exactly one Sui coin is found
if [ ${#suiCoinArray[@]} -eq 1 ]; then
    echo "Only one Sui coin found. Exiting script."
    exit 0
fi

# Format Sui coins for merging
formattedSuiCoins=$(echo "${suiCoinArray[@]}" | awk '{ printf "@%s, ", $0 }' | tr -d '\n' | sed 's/, $/\n/')

# Merge coins into a single Sui coin.
sui client ptb \
    --merge-coins gas [$formattedSuiCoins] \
    --gas-budget 10000000
