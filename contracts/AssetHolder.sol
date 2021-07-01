//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AuditResult } from "./shared/Structs.sol";
import "./interfaces/IAssetHolder.sol";
import "./interfaces/IAPXCoordinator.sol";

contract AssetHolder is IAssetHolder, ERC20 {
    using SafeERC20 for IERC20;

    IAPXCoordinator public apxCoordinator;
    uint256 public override id;
    uint256 public override typeId;
    string public info;
    address public override tokenizedAsset;
    address public listedBy;
    string public listingInfo;
    AuditResult public latestAudit;

    modifier onlyApxCoordinator() {
        require(
            msg.sender == address(apxCoordinator),
            "Only Coordinator Contract can execute this call."
        );
        _;
    }

    event AuditPerformed(bool assetVerified);

    constructor(
        address _apxCoordinator,
        address _tokenizedAsset,
        address _listedBy,
        uint256 _id,
        uint256 _typeId,
        string memory _name,
        string memory _ticker,
        string memory _info,
        string memory _listingInfo
    ) ERC20(_name, _ticker) {
        apxCoordinator = IAPXCoordinator(_apxCoordinator);
        id = _id;
        typeId = _typeId;
        info = _info;
        tokenizedAsset = _tokenizedAsset;
        listedBy = _listedBy;
        listingInfo = _listingInfo;
        _mint(address(this), IERC20(tokenizedAsset).totalSupply());   
    }

    function claim() external returns (bool) {
        IERC20 asset = IERC20(tokenizedAsset);
        uint256 allowance = asset.allowance(msg.sender, address(this));
        require(allowance > 0, "Not allowed to spend tokenized asset tokens.");
        asset.safeTransferFrom(msg.sender, address(this), allowance);
        _transfer(address(this), msg.sender, allowance);
        return true;
    }

    function performAudit(bool assetVerified, string memory additionalInfo) external override onlyApxCoordinator {
        latestAudit = AuditResult(assetVerified, additionalInfo, block.timestamp);
        emit AuditPerformed(assetVerified);
    }

    function getLatestAudit() external override view returns (AuditResult memory) {
        return latestAudit;    
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 totalFee = apxCoordinator.calcualteTransferFee(amount);
        uint256 reducedAmount = amount - totalFee;
        super._transfer(sender, recipient, reducedAmount);
        super._transfer(sender, apxCoordinator.protocolFeeBeneficiary(), totalFee);
    }

}
