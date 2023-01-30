// // SPDX-License-Identifier: GPL-2.0-or-later
// pragma solidity ^0.8.0;


// import './interfaces/INonfungiblePositionManager.sol';
// import './interfaces/INonfungibleTokenPositionDescriptor.sol';
// import './libraries/PositionKey.sol';
// import './libraries/PoolAddress.sol';
// import './base/LiquidityManagement.sol';
// import './base/PeripheryImmutableState.sol';
// import './base/Multicall.sol';
// import './base/ERC721Permit.sol';
// import './base/PeripheryValidation.sol';
// import './base/SelfPermit.sol';
// import './base/PoolInitializer.sol';

// /// @title NFT positions
// /// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
// contract NonfungiblePositionManager is
//     INonfungiblePositionManager,
//     Multicall,
//     ERC721Permit,
//     PeripheryImmutableState,
//     PoolInitializer,
//     LiquidityManagement,
//     PeripheryValidation,
//     SelfPermit
// {
//     // details about the uniswap position
//     struct Position {
//         // the nonce for permits
//         uint96 nonce;
//         // the address that is approved for spending this token
//         address operator;
//         // the ID of the pool with which this token is connected
//         uint80 poolId;
//         // the tick range of the position
//         int24 tickLower;
//         int24 tickUpper;
//         // the liquidity of the position
//         uint128 liquidity;
//         // the fee growth of the aggregate position as of the last action on the individual position
//         uint256 feeGrowthInside0LastX128;
//         uint256 feeGrowthInside1LastX128;
//         // how many uncollected tokens are owed to the position, as of the last computation
//         uint128 tokensOwed0;
//         uint128 tokensOwed1;
//     }
//     struct UserInfo{
        
//     }

//     /// @dev IDs of pools assigned by this contract
//     mapping(address => uint80) private _poolIds;

//     /// @dev Pool keys by pool ID, to save on SSTOREs for position data
//     mapping(uint80 => PoolAddress.PoolKey) private _poolIdToPoolKey;

//     /// @dev The token ID position data
//     mapping(uint256 => Position) private _positions;

//     /// @dev The ID of the next token that will be minted. Skips 0
//     uint176 private _nextId = 1;
//     /// @dev The ID of the next pool that is used for the first time. Skips 0
//     uint80 private _nextPoolId = 1;

//     /// @dev The address of the token descriptor contract, which handles generating token URIs for position tokens
//     address private immutable _tokenDescriptor;

//     constructor(
//         address _factory,
//         address _WETH9,
//         address _tokenDescriptor_
//     ) ERC721Permit('Uniswap V3 Positions NFT-V1', 'UNI-V3-POS', '1') PeripheryImmutableState(_factory, _WETH9) {
//         _tokenDescriptor = _tokenDescriptor_;
//     }

    

    

//     /// @inheritdoc INonfungiblePositionManager
//     function mint(MintParams calldata params)
//         external
//         payable
//         override
//         checkDeadline(params.deadline)
//         returns (
//             uint256 tokenId,
//             uint128 liquidity,
//             uint256 amount0,
//             uint256 amount1
//         )
//     {
//         IUniswapV3Pool pool;
//         (liquidity, amount0, amount1, pool) = addLiquidity(
//             AddLiquidityParams({
//                 token0: params.token0,
//                 token1: params.token1,
//                 fee: params.fee,
//                 recipient: address(this),
//                 tickLower: params.tickLower,
//                 tickUpper: params.tickUpper,
//                 amount0Desired: params.amount0Desired,
//                 amount1Desired: params.amount1Desired,
//                 amount0Min: params.amount0Min,
//                 amount1Min: params.amount1Min
//             })
//         );

//         _mint(params.recipient, (tokenId = _nextId++));

//         bytes32 positionKey = PositionKey.compute(address(this), params.tickLower, params.tickUpper);
//         (, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = pool.positions(positionKey);

//         // idempotent set
//         uint80 poolId =
//             cachePoolKey(
//                 address(pool),
//                 PoolAddress.PoolKey({token0: params.token0, token1: params.token1, fee: params.fee})
//             );

//         _positions[tokenId] = Position({
//             nonce: 0,
//             operator: address(0),
//             poolId: poolId,
//             tickLower: params.tickLower,
//             tickUpper: params.tickUpper,
//             liquidity: liquidity,
//             feeGrowthInside0LastX128: feeGrowthInside0LastX128,
//             feeGrowthInside1LastX128: feeGrowthInside1LastX128,
//             tokensOwed0: 0,
//             tokensOwed1: 0
//         });

//         emit IncreaseLiquidity(tokenId, liquidity, amount0, amount1);
//     }

//     modifier isAuthorizedForToken(uint256 tokenId) {
//         require(_isApprovedOrOwner(msg.sender, tokenId), 'Not approved');
//         _;
//     }

//     function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
//         require(_exists(tokenId));
//         return INonfungibleTokenPositionDescriptor(_tokenDescriptor).tokenURI(this, tokenId);
//     }

//     // save bytecode by removing implementation of unused method
//     function baseURI() public pure override returns (string memory) {}

    

    

//     /// @inheritdoc INonfungiblePositionManager
//     function burn(uint256 tokenId) external payable override isAuthorizedForToken(tokenId) {
//         Position storage position = _positions[tokenId];
//         require(position.liquidity == 0 && position.tokensOwed0 == 0 && position.tokensOwed1 == 0, 'Not cleared');
//         delete _positions[tokenId];
//         _burn(tokenId);
//     }

//     function _getAndIncrementNonce(uint256 tokenId) internal override returns (uint256) {
//         return uint256(_positions[tokenId].nonce++);
//     }

//     /// @inheritdoc IERC721
//     function getApproved(uint256 tokenId) public view override(ERC721, IERC721) returns (address) {
//         require(_exists(tokenId), 'ERC721: approved query for nonexistent token');

//         return _positions[tokenId].operator;
//     }

//     /// @dev Overrides _approve to use the operator in the position, which is packed with the position permit nonce
//     function _approve(address to, uint256 tokenId) internal override(ERC721) {
//         _positions[tokenId].operator = to;
//         emit Approval(ownerOf(tokenId), to, tokenId);
//     }
// }

