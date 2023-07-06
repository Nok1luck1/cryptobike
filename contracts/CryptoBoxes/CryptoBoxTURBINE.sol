//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../interface/PartsLibrary.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "../interface/ICryptoBoxFactory.sol";

contract CryptoBoxTURBINE is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    ICryptoBoxFactory public factory;
    mapping(address => uint) public countOfOpenV1;
    mapping(address => uint) public countOfOpenV2;
    mapping(address => uint) public countOfOpenV3;

    event MaterialDroped(
        PartsLibrary.Materials,
        uint count,
        PartsLibrary.Rarity
    );

    constructor(address owner) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function openLootBoxV1(
        uint[] memory randomNumber,
        address receiver
    ) public {
        bool itemsDroped;
        bool mtcbDroped;
        if (countOfOpenV1[receiver] == 30) {
            //first case
            if (randomNumber[0] < 70) {
                //Every 30 open
                ICryptoBoxFactory(factory).mint(44, receiver); //common type3
            } else if (randomNumber[0] > 70 && randomNumber[0] < 95) {
                ICryptoBoxFactory(factory).mint(40, receiver); //uncommon type 2
            } else if (randomNumber[0] > 95) {
                ICryptoBoxFactory(factory).mint(8, receiver); //rare type 1
            }
        } else if (randomNumber[0] < 5) {
            //second case
            //Items 5% chance
            if (randomNumber[1] < 60) {
                //common
                if (randomNumber[2] < 34) {
                    ICryptoBoxFactory(factory).mint(6, receiver);
                    itemsDroped = true;
                }
                if (randomNumber[2] > 34 && randomNumber[2] < 68) {
                    ICryptoBoxFactory(factory).mint(39, receiver);
                    itemsDroped = true;
                }
                if (randomNumber[2] > 68) {
                    ICryptoBoxFactory(factory).mint(44, receiver);
                    itemsDroped = true;
                }
            } else if (randomNumber[1] > 60 && randomNumber[1] < 90) {
                //uncommon
                if (randomNumber[2] < 51) {
                    ICryptoBoxFactory(factory).mint(7, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 51) {
                    ICryptoBoxFactory(factory).mint(40, receiver);
                    itemsDroped = true;
                }
            } else {
                ICryptoBoxFactory(factory).mint(8, receiver);
                itemsDroped = true;
            }
        } else if (
            (itemsDroped =
                false ||
                (randomNumber[1] > 5 && randomNumber[1] < 41))
        ) {
            ////////////////////////block with 2 materials drop and MTCB
            if (randomNumber[3] < 50) {
                ICryptoBoxFactory(factory).transferMTCB(
                    11 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 50 && randomNumber[3] < 71) {
                ICryptoBoxFactory(factory).transferMTCB(
                    22 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 71 && randomNumber[3] < 86) {
                ICryptoBoxFactory(factory).transferMTCB(
                    33 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 86 && randomNumber[3] < 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    44 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    55 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            }
            /////first material choose
            if (randomNumber[5] < 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            /////second material choose
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
        }
        //////////////////////block with 3 materials drop
        else if ((mtcbDroped = false) || (itemsDroped = false)) {
            //MaterialsDrop first time of 3
            if (randomNumber[5] < 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            //MaterialsDrop second time of 3
            if (randomNumber[7] < 51) {
                if (randomNumber[8] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[8] > 60 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            if (randomNumber[7] > 51) {
                if (randomNumber[8] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[8] > 60 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            //MaterialsDrop third time of 3
            if (randomNumber[9] < 51) {
                if (randomNumber[10] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[10] > 60 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            if (randomNumber[9] > 51) {
                if (randomNumber[10] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Common
                    );
                } else if (randomNumber[10] > 60 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
        }
        countOfOpenV1[receiver]++;
    }

    ////////////////////////////////////////////////
    ////////////////////////////////////////////////
    function openLootBoxV2(
        uint[] memory randomNumber,
        address receiver
    ) public {
        bool itemsDroped;
        bool mtcbDroped;
        if (countOfOpenV2[receiver] == 20) {
            //first case
            if (randomNumber[0] < 70) {
                //Every 30 open
                ICryptoBoxFactory(factory).mint(45, receiver); //type 3 uncommon
            } else if (randomNumber[0] > 70 && randomNumber[0] < 95) {
                ICryptoBoxFactory(factory).mint(41, receiver); //type 2 rare
            } else if (randomNumber[0] > 95) {
                ICryptoBoxFactory(factory).mint(9, receiver); //type 1 epic
            }
        } else if (randomNumber[0] < 5) {
            //second case
            //Items 5% chance
            if (randomNumber[1] < 60) {
                if (randomNumber[2] < 34) {
                    ICryptoBoxFactory(factory).mint(7, receiver); //type 1 uncommon
                    itemsDroped = true;
                }
                if (randomNumber[2] > 34 && randomNumber[2] < 68) {
                    //type 2 uncommon
                    ICryptoBoxFactory(factory).mint(40, receiver);
                    itemsDroped = true;
                }
                if (randomNumber[2] > 68) {
                    ICryptoBoxFactory(factory).mint(45, receiver); //type 3 uncommon
                    itemsDroped = true;
                }
            } else if (randomNumber[1] > 60 && randomNumber[1] < 90) {
                if (randomNumber[2] < 51) {
                    ICryptoBoxFactory(factory).mint(8, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 51) {
                    ICryptoBoxFactory(factory).mint(41, receiver);
                    itemsDroped = true;
                }
            } else {
                if (randomNumber[2] < 51) {
                    ICryptoBoxFactory(factory).mint(9, receiver);
                    itemsDroped = true;
                } else {
                    ICryptoBoxFactory(factory).mint(42, receiver);
                    itemsDroped = true;
                }
            }
        } else if (
            (itemsDroped =
                false ||
                (randomNumber[1] > 5 && randomNumber[1] < 41))
        ) {
            ////////////////////////block with 2 materials drop and MTCB
            if (randomNumber[3] < 50) {
                ICryptoBoxFactory(factory).transferMTCB(
                    55 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 50 && randomNumber[3] < 71) {
                ICryptoBoxFactory(factory).transferMTCB(
                    111 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 71 && randomNumber[3] < 86) {
                ICryptoBoxFactory(factory).transferMTCB(
                    166 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 86 && randomNumber[3] < 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    222 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    277 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            }
            /////first material choose
            if (randomNumber[5] < 51) {
                if (randomNumber[6] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 50 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
            /////second material choose
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 50 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
        }
        //////////////////////block with 3 materials drop
        else if ((mtcbDroped = false) || (itemsDroped = false)) {
            //MaterialsDrop first time of 3
            if (randomNumber[5] < 51) {
                if (randomNumber[6] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 50 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 50 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                }
            }
            //MaterialsDrop second time of 3
            if (randomNumber[7] < 51) {
                if (randomNumber[8] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[8] > 50 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
            if (randomNumber[7] > 51) {
                if (randomNumber[8] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[8] > 50 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
            //MaterialsDrop third time of 3
            if (randomNumber[9] < 51) {
                if (randomNumber[10] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[10] > 50 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
            if (randomNumber[9] > 51) {
                if (randomNumber[10] < 50) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[10] > 50 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Uncommon
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                }
            }
        }
        countOfOpenV2[receiver]++;
    }

    ////////////////////////////////////////////////
    ////////////////////////////////////////////////
    function openLootBoxV3(
        uint[] memory randomNumber,
        address receiver
    ) public {
        bool itemsDroped;
        bool mtcbDroped;
        if (countOfOpenV3[receiver] == 20) {
            //first case
            if (randomNumber[0] < 70) {
                //Every 30 open
                ICryptoBoxFactory(factory).mint(47, receiver);
            } else if (randomNumber[0] > 70 && randomNumber[0] < 95) {
                ICryptoBoxFactory(factory).mint(41, receiver);
            } else if (randomNumber[0] > 95) {
                ICryptoBoxFactory(factory).mint(10, receiver);
            }
        } else if (randomNumber[0] < 5) {
            //second case
            //Items 5% chance
            if (randomNumber[1] < 60) {
                if (randomNumber[2] < 34) {
                    ICryptoBoxFactory(factory).mint(9, receiver);
                    itemsDroped = true;
                }
                if (randomNumber[2] > 34 && randomNumber[2] < 68) {
                    ICryptoBoxFactory(factory).mint(42, receiver);
                    itemsDroped = true;
                }
                if (randomNumber[2] > 68) {
                    ICryptoBoxFactory(factory).mint(47, receiver);
                    itemsDroped = true;
                }
            } else if (randomNumber[1] > 60 && randomNumber[1] < 90) {
                if (randomNumber[2] < 51) {
                    ICryptoBoxFactory(factory).mint(41, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 51 && randomNumber[2] < 70) {
                    ICryptoBoxFactory(factory).mint(8, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 70) {
                    ICryptoBoxFactory(factory).mint(46, receiver);
                    itemsDroped = true;
                }
            } else {
                if (randomNumber[2] < 51) {
                    ICryptoBoxFactory(factory).mint(10, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 51 && randomNumber[2] < 70) {
                    ICryptoBoxFactory(factory).mint(48, receiver);
                    itemsDroped = true;
                } else if (randomNumber[2] > 70) {
                    ICryptoBoxFactory(factory).mint(43, receiver);
                    itemsDroped = true;
                }
            }
        } else if (
            (itemsDroped =
                false ||
                (randomNumber[1] > 5 && randomNumber[1] < 41))
        ) {
            ////////////////////////block with 2 materials drop and MTCB
            if (randomNumber[3] < 50) {
                ICryptoBoxFactory(factory).transferMTCB(
                    416 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 50 && randomNumber[3] < 71) {
                ICryptoBoxFactory(factory).transferMTCB(
                    333 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 71 && randomNumber[3] < 86) {
                ICryptoBoxFactory(factory).transferMTCB(
                    250 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 86 && randomNumber[3] < 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    176 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            } else if (randomNumber[3] > 96) {
                ICryptoBoxFactory(factory).transferMTCB(
                    83 * 10 ** 18,
                    receiver
                );
                mtcbDroped = true;
            }
            /////first material choose
            if (randomNumber[5] < 60) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            /////second material choose
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
        }
        //////////////////////block with 3 materials drop
        else if ((mtcbDroped = false) || (itemsDroped = false)) {
            //MaterialsDrop first time of 3
            if (randomNumber[5] < 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            if (randomNumber[5] > 51) {
                if (randomNumber[6] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[6] > 60 && randomNumber[6] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[6] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            //MaterialsDrop second time of 3
            if (randomNumber[7] < 51) {
                if (randomNumber[8] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[8] > 60 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            if (randomNumber[7] > 51) {
                if (randomNumber[8] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[8] > 60 && randomNumber[8] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[8] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            //MaterialsDrop third time of 3
            if (randomNumber[9] < 51) {
                if (randomNumber[10] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[10] > 60 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.TURBINE,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
            if (randomNumber[9] > 51) {
                if (randomNumber[10] < 60) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Epic
                    );
                } else if (randomNumber[10] > 60 && randomNumber[10] < 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Rare
                    );
                } else if (randomNumber[10] > 90) {
                    emit MaterialDroped(
                        PartsLibrary.Materials.MATERIAL_BOX,
                        15,
                        PartsLibrary.Rarity.Legendary
                    );
                }
            }
        }
        countOfOpenV3[receiver]++;
    }

    receive() external payable {}

    fallback() external payable {}
}
