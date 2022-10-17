// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "../lib/ERC20.sol";
import "../lib/SafeMath.sol";
import "../lib/utils/Ownable.sol";

// CakeToken with Governance.
contract BEP20Token is ERC20("BINANCE PEG", "BUSD"), Ownable {
    using SafeMath for uint256;

    constructor() {
        mint(msg.sender, 31000000000000000000000000);
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}
