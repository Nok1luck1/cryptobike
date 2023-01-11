pragma solidity 0.8.17;
import "./AccountPLayer.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract AccountFactory is
    ReentrancyGuard,
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for IERC20;

    function createPlayer(uint256 _id) public {
        address createdAccount;
        bytes memory bytecodeAccount = type(AccountPlayer).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(address(this), address(msg.sender), _id)
        );
        assembly {
            {
                createdAccount := create2(
                    0,
                    add(bytecodeAccount, 0x20),
                    mload(bytecodeAccount),
                    salt
                )
            }
        }
        require(createdAccount != address(0), "Create2: Failed on deploy");
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
