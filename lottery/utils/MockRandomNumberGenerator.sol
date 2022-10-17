//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "../../lib/utils/Ownable.sol";
import "./IRandomNumberGenerator.sol";
import "./ILottery.sol";

contract MockRandomNumberGenerator is IRandomNumberGenerator, Ownable {
    address public neondexLottery;
    uint32 public randomResult;
    uint256 public nextRandomResult;
    uint256 public latestLotteryId;

    /**
     * @notice Constructor
     * @dev MockRandomNumberGenerator must be deployed before the lottery.
     */
    constructor() {}

    /**
     * @notice Set the address for the neondexLottery
     * @param _neondexLottery: address of the PancakeSwap lottery
     */
    function setLotteryAddress(address _neondexLottery) external onlyOwner {
        neondexLottery = _neondexLottery;
    }

    /**
     * @notice Set the address for the neondexLottery
     * @param _nextRandomResult: next random result
     */
    function setNextRandomResult(uint256 _nextRandomResult) external onlyOwner {
        nextRandomResult = _nextRandomResult;
    }

    /**
     * @notice Request randomness from a user-provided seed
     * @param _seed: seed provided by the PancakeSwap lottery
     */
    function getRandomNumber(uint256 _seed) external override {
        require(msg.sender == neondexLottery, "Only neondexLottery");
        fulfillRandomness(0, nextRandomResult);
    }

    /**
     * @notice Change latest lotteryId to currentLotteryId
     */
    function changeLatestLotteryId() external {
        latestLotteryId = ILottery(neondexLottery).viewCurrentLotteryId();
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
        randomResult = uint32(1000000 + (randomness % 1000000));
    }
}
