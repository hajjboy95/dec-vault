require('@nomicfoundation/hardhat-toolbox')
require('@nomicfoundation/hardhat-chai-matchers')
require('@nomiclabs/hardhat-ethers')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {version: '0.8.25'},
      {version: '0.4.18'}
    ]
  }
}
