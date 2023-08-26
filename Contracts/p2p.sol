// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "./owner.sol";
import "./Credit.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract PeerToPeer is Ownable{
    using SafeMath for uint;    
    struct Users{
        bool credited;
        address activeCredit;
        bool fraudStatus;
        address[] allCredits;
    }
    mapping(address=>Users) public users;

    address[] public credits;
    event LogCreditCreated(address indexed ,address indexed  _borrower,uint indexed);
    event LogCrediteStateChange(address,Credit.State indexed ,uint indexed );
    event LogCreditActiveChanged(address,bool,uint indexed);
    event LogUserSetFraud(address indexed,bool,uint);
    
    function applyForCredit(uint requestAmount,uint repaymentsCount,uint interest,bytes memory creditDescription)public returns(address _CreditDescripiton){
      require(users[msg.sender].credited=false);
      require(users[msg.sender].fraudStatus==false);
      assert(users[msg.sender].activeCredit==address(0));
      users[msg.sender].credited=true;
      Credit credit=new Credit(requestAmount,repaymentsCount,interest,creditDescription);
      users[msg.sender].activeCredit=address(credit);
      credits.push(address(credit));
      users[msg.sender].allCredits.push(address(credit));
      emit LogCreditCreated(address(credit),msg.sender,block.timestamp);
      return address(credit);
    }


    function getCredits()public view  returns(address[] memory){
        return credits;
    }

    function getUsersCredits()public view returns(address[] memory){
        return users[msg.sender].allCredits;
    }

    function setFraudStatus(address _borrower) external returns (bool){
        users[_borrower].fraudStatus=true;
        emit LogUserSetFraud(_borrower,users[_borrower].fraudStatus,block.timestamp);
        return users[_borrower].fraudStatus;
    }
    
    function changeCreditState(Credit _credit)public onlyOwner{
        Credit credit= Credit(_credit);
        bool active=credit.toggleActive();
        emit LogCreditActiveChanged(address(credit),active,block.timestamp );
    }

}