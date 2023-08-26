// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "./owner.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract Credit is Ownable{
    using SafeMath for uint;


    address borrower;
    uint requestAmount;
    uint returnAmount;
    uint repaidAmount;
    uint interest;
    uint requestRepayment;
    uint remainingRepayment;
    uint repaymentInstallement;
    uint requestedDate;
    uint lastRepayment;
    bool active=true;
    bytes description;
    uint lenderCount=0;
    uint revokeVotes=0;
    uint revokeTimeNeeded=block.timestamp+1 seconds;
    uint fraudVotes=0;
   constructor(uint _requestAmount,uint _requestRepayment,uint _interest,string memory _description){
     requestAmount=_requestAmount;
     requestRepayment=_requestRepayment;
     interest=_interest;
     description=bytes(_description);
     borrower=tx.origin;
     returnAmount=_requestAmount.add(_interest);
     repaymentInstallement=returnAmount.div(requestAmount);
     requestedDate=block.timestamp;
     emit LogCreditInitialization(borrower,requestedDate);
    }
    
    mapping(address=>bool) public lenders;
    mapping(address=>uint) lenderInvestedAmount;
    mapping(address=>bool) revokeVoters;
    mapping(address=>bool) farudVoters;


    enum State{
      investment,
      repayment,
      interestReturns,
      expired,
      revoked,
      fraud
    }
    State state;




    event LogCreditInitialization(address indexed ,uint indexed);
    event LogCreditStateChange(State,uint);
    event LogCreditActiveStateChanged(bool,uint);
    event LogLenderChangeReturned(address,uint,uint);
    event LogLenderInvestement(address,uint,uint);


    function getBalane() public view returns(uint){
        return address(this).balance;
    }

    function changeState(State _state)external onlyOwner{
     state=_state;
     emit LogCreditStateChange(state,block.timestamp);
    }

    function toggleActive() external onlyOwner returns(bool){
        active=!active;
        emit LogCreditActiveStateChanged(active,block.timestamp);
        return active;
    }




    function Invest()public payable canInvest{
      uint extraMoney=0;
      if(address(this).balance>=requestAmount){
        extraMoney=address(this).balance.sub(requestAmount);
        uint subResultOfBal=address(this).balance.sub(extraMoney);
        assert(subResultOfBal==requestAmount);
        assert(extraMoney<=msg.value);
      }
      if(extraMoney>0){
        payable(msg.sender).transfer(extraMoney);
        emit LogLenderChangeReturned(msg.sender,extraMoney,block.timestamp );
      }

      state=State.repayment;
      emit LogCreditStateChange(state,block.timestamp);
      lenders[msg.sender]=true;
      lenderCount++;
      lenderInvestedAmount[msg.sender]=lenderInvestedAmount[msg.sender].add(msg.value.sub(extraMoney));
      emit LogLenderInvestement(msg.sender,msg.value.sub(extraMoney),block.timestamp);
    }


    modifier canInvest(){
      require(state==State.investment);
      _;
    }
}