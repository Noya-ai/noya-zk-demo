// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract ERC4626Modified is ERC20 {
    using Math for uint256;
    uint256 public expectedValue;

    event LogWithdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares, uint256 expectedValue);
    event LogDeposit(address indexed caller, address indexed receiver, uint256 assets, uint256 shares, uint256 expectedValue);


    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol)  {
    }

    function convertToShares(uint256 assets) public view virtual returns (uint256 shares) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256 assets) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Down);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Up);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Up);
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    function _depositAssets(uint256 assets, address receiver) internal virtual returns (uint256) {
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    function _mintShares(uint256 shares, address receiver) internal virtual returns (uint256) {
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    function _withdrawAssets(
        uint256 assets,
        address receiver,
        address owner
    ) internal virtual returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }


    function _redeemShares(
        uint256 shares,
        address receiver,
        address owner
    ) internal virtual returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256 shares) {
        uint256 supply = totalSupply();
        return
        (assets == 0 || supply == 0)
        ? _initialConvertToShares(assets, rounding)
        : assets.mulDiv(supply, expectedValue, rounding);
    }

    function _initialConvertToShares(
        uint256 assets,
        Math.Rounding /*rounding*/
    ) internal view virtual returns (uint256 shares) {
        return assets;
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256 assets) {
        uint256 supply = totalSupply();
        return
        (supply == 0) ? _initialConvertToAssets(shares, rounding) : shares.mulDiv(expectedValue, supply, rounding);
    }

    function _initialConvertToAssets(
        uint256 shares,
        Math.Rounding /*rounding*/
    ) internal view virtual returns (uint256 assets) {
        return shares;
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) private  {
        expectedValue += assets;
        _mint(receiver, shares);

        emit LogDeposit(caller, receiver, assets, shares, expectedValue);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) private  {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        _burn(owner, shares);
        expectedValue -= assets;
        // TODO: send assets to receiver

        emit LogWithdraw(caller, receiver, owner, assets, shares, expectedValue);
    }

    function _isVaultCollateralized() private view returns (bool) {
        return expectedValue > 0 || totalSupply() == 0;
    }
}
