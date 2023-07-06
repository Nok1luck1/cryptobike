# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npm install --save-dev typescript
npm install --save-dev ts-node
npm i dotenv
npm i solidity-coverage
npm i @typechain/hardhat
npm i @nomiclabs/hardhat-ethers
npm i @nomiclabs/hardhat-waffle
npm i @nomiclabs/hardhat-etherscan
npm i hardhat-gas-reporter
npm i hardhat-contract-sizer
npm i hardhat-abi-exporter
npm i @openzeppelin/hardhat-upgrades
npm i @nomiclabs/hardhat-web3

npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

FreeCollection
setNewFreeItem - в админке будет проходить манипуляция айдишником раздаваемого бесплатного предмета, если захотим новый просто укажем значение на 1 больше от предыдущего

freeMint - Вызов на минт бесплатной нфт в колчестве 1 на один аккаунт, если сменим айди бесплатной раздаеваемой то человек сможет получить новую
