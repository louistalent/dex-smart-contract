// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../lib/utils/Context.sol";
import "../../lib/utils/Ownable.sol";
import "../../lib/interfaces/IERC20.sol";
import "../../lib/utils/Address.sol";
import "../../lib/SafeERC20.sol";
import "./IRandomNumberGenerator.sol";
import "./ILottery.sol";

contract RandomNumberGenerator is IRandomNumberGenerator, Ownable {
    using SafeERC20 for IERC20;

    address public neondexLottery;
    bytes32 public keyHash;
    bytes32 public latestRequestId;
    uint32 public randomResult;
    uint256 public fee;
    uint256 public latestLotteryId;

    /**
     * @notice Request randomness from a user-provided seed
     * @param _seed: seed provided by the NeonDex lottery
     */
    function getRandomNumber(uint256 _seed) external override {
        require(msg.sender == neondexLottery, "Only neondexLottery");
        require(keyHash != bytes32(0), "Must have valid key hash");

        latestRequestId = bytes32(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    blockhash(block.number - 1),
                    _seed
                )
            )
        );
    }

    /**
     * @notice Change the fee
     * @param _fee: new fee (in LINK)
     */
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    /**
     * @notice Change the keyHash
     * @param _keyHash: new keyHash
     */
    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }

    /**
     * @notice Set the address for the neondexLottery
     * @param _neondexLottery: address of the Neondex lottery
     */
    function setLotteryAddress(address _neondexLottery) external onlyOwner {
        neondexLottery = _neondexLottery;
    }

    /**
     * @notice It allows the admin to withdraw tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function withdrawTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
    }

    /**
     * @notice View latestLotteryId
     */
    function viewLatestLotteryId() external view override returns (uint256) {
        return latestLotteryId;
    }

    /**
     * @notice View random result
     */
    function viewRandomResult() external view override returns (uint32) {
        return randomResult;
    }

    /**
     * @notice Callback function used by ChainLink's VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal {
        require(latestRequestId == requestId, "Wrong requestId");
        randomResult = uint32(1000000 + (randomness % 1000000));
        latestLotteryId = ILottery(neondexLottery).viewCurrentLotteryId();
    }
}
