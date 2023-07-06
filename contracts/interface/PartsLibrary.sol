// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PartsLibrary {
    enum Materials {
        ENGINE,
        TRANSMISSION,
        TURBINE,
        FUEL_TANK,
        WHEEL,
        NITRO,
        MATERIAL_BOX
    }
    enum Rarity {
        Common,
        Uncommon,
        Rare,
        Epic,
        Legendary
    }
}
