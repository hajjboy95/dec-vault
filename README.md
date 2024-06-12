Vault contract

Creates a Mock of the WETH contract and uses it in the tests.

This contract prevents depositing to the fallback method of the contract and reverts to prevent user from performing
a transfer by accident to the contract.
