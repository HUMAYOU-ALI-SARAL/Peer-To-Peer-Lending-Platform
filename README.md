# Peer-To-Peer-Lending-Platform

![P2P SOL](https://github.com/HUMAYOU-ALI-SARAL/Peer-To-Peer-Lending-Platform/assets/78782252/c483828f-aaea-4077-bb1a-2d433a03cf13)

Introduction

Welcome to the Peer-to-Peer Lending Platform built on the Ethereum blockchain network.
This modular project aims to revolutionize the lending industry by introducing transparency,
fairness, and efficiency through decentralized technology.
Unlike traditional banking systems, our focus, by efficiently utilizing the knowledge we have
gained about smart contracts, is on empowering both borrowers and investors, ensuring
mutually beneficial interactions without hidden fees or unfair practices.1.

Overview

Problem Statement
The traditional banking industry is often criticized for prioritizing profit over customer welfare.
Borrowers face exorbitant interest rates, while investors experience subpar returns.
Additionally, hidden fees erode the trust between banks and their customers.
Solution Overview
Our Peer-to-Peer Lending Platform leverages the Ethereum blockchain to create a transparent,
equitable, and community-oriented lending environment.
By embracing blockchain's immutable ledger and smart contracts, we aim to revolutionize
lending by enabling:
➔ Borrowers to request funding with fair interest rates.
➔ Lenders to invest in projects/credits with improved returns.
➔ Voting mechanisms for contract revocation and fraud detection.

Features

#Borrowing Funds

Requesting Funding
Borrowers can create funding requests, specifying the amount required, purpose, and proposed
interest rate. This request is then verified and added to the platform.
Providing Funding Details

Lenders can review the funding requests and associated details provided by borrowers.
Transparent information allows lenders to make informed decisions about investing.
Withdrawal of Funding
Once a funding request reaches its goal, the borrower can withdraw the funds. Smart contracts
ensure that funds are released only upon successful completion of the funding goal.
Repayment Installments

Borrowers are required to adhere to a predefined repayment schedule. The platform facilitates
automated repayment installments, enhancing convenience for both borrowers and lenders.b) Lending Funds
Investing in Project/Credit
Lenders can invest in various funding requests based on their preferences. By diversifying their
investments across multiple projects, lenders can manage risk effectively.
Voting for Contract Revocation

The community of lenders holds the power to vote for the revocation of a contract in case of
suspected fraudulent activities or violations. This democratic approach ensures platform
integrity.


Project Structure

The modular project we are going to build is upon a well-structured architecture that
leverages various smart contracts to ensure security, modularity, and efficient functionality.
Below is a brief overview of the project's structure:

Libraries

SafeMath.sol

The SafeMath library is a foundational component of the project, responsible for preventing
integer overflow and underflow vulnerabilities in arithmetic operations.
It provides secure mathematical operations for integers, safeguarding the project against
potential vulnerabilities.

Contracts

Ownable.sol

The Ownable contract establishes a basic access control mechanism, ensuring that certain
actions or functions within the system can only be executed by the owner of the contract.
This is a common pattern in Ethereum smart contracts to manage permissions and
administrative actions.Credit.sol

The Credit contract extends the functionality of the ‘Ownable’ contract. It represents a credit
request made by a borrower on the platform.
The contract defines details about the credit, including the requested amount, repayment
plan, and any collateral offered.

By inheriting from ‘Ownable’, the contract can manage ownership and access control for credit-
related actions.

PeerToPeerLending.sol

The PeerToPeerLending contract is the core component of the platform. It inherits from the
‘Ownable’ contract and serves as the bridge between borrowers and investors.

This contract contains essential functions for borrowing funds, investing in projects/credit, voting
on contract revocation, and refunding investments.
It creates instances of the ‘Credit’ contract to facilitate individual credit requests and maintain
the lending ecosystem.

Interactions

‘Credit.sol’ and ‘PeerToPeerLending.sol’ both inherit from ‘Ownable.sol’, which means they
share the ownership management logic. The ‘Ownable’ contract's functions enable only
authorized parties to perform administrative tasks.
‘PeerToPeerLending.sol’ creates instances of the ‘Credit’ contract, enabling the creation and
management of individual credit requests.
This contract also provides functions for investing in projects/credit and voting on contract-
related actions.

