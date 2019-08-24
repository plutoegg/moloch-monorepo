pragma solidity 0.5.3;

import "./oz/Ownable.sol";
import "./oz/ERC20.sol";
import "./oz/SafeMath.sol";
import "./redeemTokens/IRToken.sol"

contract GuildBank is Ownable {
    using SafeMath for uint256;

    ERC20 public approvedToken; // approved token contract reference
    uint256 public currentHatID;

    event Deposit(uint256 amount);
    event Withdrawal(address indexed receiver, uint256 amount);
    event InterestRecipientsChanged(uint256 rTokenHatID);

    constructor(address approvedTokenAddress) public {
        approvedToken = ERC20(approvedTokenAddress);
    }

    function deposit(uint256 amount) public onlyOwner returns (bool) {
        emit Deposit(amount);
        return approvedToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(address receiver, uint256 shares, uint256 totalShares) public onlyOwner returns (bool) {
        uint256 amount = approvedToken.balanceOf(address(this)).mul(shares).div(totalShares);
        emit Withdrawal(receiver, amount);
        return approvedToken.transfer(receiver, amount);
    }

    function changeInterestRecipients(uint256 rTokenHatID) public onlyOwner returns (bool) {
        if (currentHatID == rTokenHatID) {
          return true;
        }
        emit InterestRecipientsChanged(rTokenHatID);
        currentHatID = rTokenHatID;
        IRToken(address(approvedToken)).changeHat(rTokenHatID);
        return true;
    }
}
