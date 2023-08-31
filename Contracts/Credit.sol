  // SPDX-License-Identifier: MIT
  pragma solidity 0.8.18;
  import "./owner.sol";
  import "@openzeppelin/contracts/utils/math/SafeMath.sol";
  contract Credit is Ownable{
      using SafeMath for uint;


      address public borrower;
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
      repaymentInstallement=returnAmount.div(_requestRepayment);
      requestedDate=block.timestamp;
      emit LogCreditInitialization(borrower,requestedDate);
      }
      
      mapping(address=>bool) public lenders;
      mapping(address=>uint) lenderInvestedAmount;
      mapping(address=>bool) revokeVoters;
      mapping(address=>bool) fraudVoters;


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
      event LogRepayment(address lender,uint remainingRepayment,uint repaymentInstallement);
      event LogBorrowerChangeReturn(address,uint,uint);
      event LogBorrowerRepaymentInstallment(address,uint,uint);
      event LogBorrowerRepaymentFinished(address,uint);
      event LogLenderWithdraw(address,uint,uint);
      event LogLenderVoteForRevoking(address,uint);
      event LogLenderRefunded(address,uint,uint);
      event LogLenderVoteForFraud(address,uint);
      modifier onlyLender(){
        require(lenders[msg.sender]==true);
        _;
      }
      modifier canAskForInterest(){
        require(state==State.interestReturns);
        require(lenderInvestedAmount[msg.sender]>0);
        _;
      }
      modifier canInvest(){
        require(state==State.investment);
        require(msg.value==returnAmount/requestRepayment);
        _;
      }
      modifier canRepay(){
    require(state==State.investment,"State Failed");
    _;
  }
  modifier canWidthdraw(){
    require(address(this).balance>=requestAmount);
    _;
  }
  modifier isNotFraud(){
    require(state!=State.fraud);
    _;
  }
  modifier isRevokable(){
    require(block.timestamp>=revokeTimeNeeded);
    require(state==State.investment);
    _;
  }
  modifier isRevoked(){
    require(state==State.revoked);
    _;
  }


  modifier onlyBorrower(){
    require(msg.sender==borrower,"you are not borrower");
    _;
  }
  modifier  isActive(){
    require(active==true);
    _;
  }


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
    




    function repay()public payable  onlyBorrower canRepay{
      require(remainingRepayment>0);
      require(msg.value>repaymentInstallement);
      assert(repaidAmount<returnAmount);
      remainingRepayment--;
      lastRepayment=block.timestamp;

      uint extraMoney=0;
      if(msg.value>repaymentInstallement){
        extraMoney=msg.value.sub(repaymentInstallement);
        assert(extraMoney<=msg.value);
        payable(msg.sender).transfer(extraMoney);
        emit LogBorrowerChangeReturn(msg.sender,extraMoney,block.timestamp);
      }
      emit LogBorrowerRepaymentInstallment(msg.sender,msg.value.sub(extraMoney),block.timestamp);
      repaidAmount=repaidAmount.add(msg.value.sub(extraMoney));

      if(repaidAmount==returnAmount){
        emit LogBorrowerRepaymentFinished(msg.sender,block.timestamp);
        state=State.interestReturns;
        emit LogCreditStateChange(state,block.timestamp);
      }
    }

    function widthdraw() public isActive onlyBorrower canWidthdraw isNotFraud {
      state=State.repayment;
      emit LogCreditStateChange(state,block.timestamp);
      payable(borrower).transfer(address(this).balance);
    }

    function requestInterest()public isActive onlyLender canAskForInterest {
      uint lenderReturnAmount=lenderInvestedAmount[msg.sender].mul(returnAmount.div(lenderCount).div(lenderInvestedAmount[msg.sender]));
      assert(address(this).balance>=lenderReturnAmount);
      payable (msg.sender).transfer(lenderReturnAmount);
      emit LogLenderWithdraw(msg.sender,lenderReturnAmount,block.timestamp);
      if(address(this).balance==0){
        active=false;
        emit LogCreditActiveStateChanged(active,block.timestamp);
        state=State.expired;
        emit LogCreditStateChange(state,block.timestamp);
      }
    }

    function getCreditInfo()public view  returns(address,bytes memory,uint,uint,uint,uint,uint,uint,State,bool,uint){
      return(
        borrower,
        description,
        requestAmount,
        requestRepayment,
        repaymentInstallement,
        remainingRepayment,
        interest,
        returnAmount,
        state,
        active,
        address(this).balance
      );
    }

    function revokeVote()public isActive isRevokable onlyLender{
      require(revokeVoters[msg.sender]==false);
      revokeVotes++;
      revokeVoters[msg.sender]==true;
      emit LogLenderVoteForRevoking(msg.sender,block.timestamp);
      if(lenderCount==revokeVotes){
        revoke();
      }
    }
    

    function revoke()internal {
      state=State.revoked;
      emit LogCreditStateChange(state,block.timestamp );
    }


    function refund()public isActive onlyLender isRevoked{
      assert(address(this).balance>=lenderInvestedAmount[msg.sender]);
      payable(msg.sender).transfer(lenderInvestedAmount[msg.sender]);
      emit LogLenderRefunded(msg.sender,lenderInvestedAmount[msg.sender],block.timestamp);
      if(address(this).balance==0){
        active=false;
        emit LogCreditActiveStateChanged(active,block.timestamp);
        emit LogCreditStateChange(state,block.timestamp);
      }
    }

    function fraudVote()public isActive onlyLender{
      require(fraudVoters[msg.sender]==false);
      fraudVotes++;
      fraudVoters[msg.sender]==true;
      emit LogLenderVoteForFraud(msg.sender,block.timestamp);
    }

  }