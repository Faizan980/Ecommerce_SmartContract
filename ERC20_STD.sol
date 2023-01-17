// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC20_STD{
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);


    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// Whoever launches the token will set the ownership of the token. It is very important while make
// contract for client side.
contract Ownership {
    // who launches the supply will be the owner of complete supply
    address public contractOwner;
    // the new Owner who receives token after launch
    address public newOwner;

    event TransferOwnerShip(address indexed _from, address indexed _to);

    constructor() {
        contractOwner = msg.sender;
    }

    function changeOwner(address _to) public {
        require(msg.sender == contractOwner, "Only owner of the contract call it");
        newOwner = _to;
    }
    function acceptOwner() public {
        require(msg.sender == newOwner, "Only new assigned owner can call it");
        emit TransferOwnerShip (contractOwner, newOwner);
        contractOwner = newOwner;
        newOwner = address(0);
    }
}

contract MyERC20 is ERC20_STD,Ownership {

    string public _name;
    string public _symbol;
    uint8 public _decimal;
    uint256 public _totalSupply; // Necessary to provide supply first

    address public _minter; // It create/mint address create digital currency   

    mapping (address => uint256) TotalBalances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor (address minter_) {
        _name = "TechHub Coin";
        _symbol = "TCH";
        _totalSupply = 10000000;
        _minter = minter_;

        TotalBalances[_minter] = _totalSupply; // Number of coins mint to addressess is equal to total supply
    }


    function name() public view override returns (string memory){
        return _name;
    }
    function symbol() public view override returns (string memory){
        return _symbol;
    }
    function decimals() public view override returns (uint8){
        return _decimal;
    }
    function totalSupply() public view override returns (uint256){
        return _totalSupply;
    }

    // Shows the balance of each token holder
    function balanceOf(address _owner) public view override returns (uint256 balance){
        return TotalBalances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success){
        require(TotalBalances[msg.sender] <= _value, "Insufficient Token"); // Check token transfer value is sufficient or not
        TotalBalances[msg.sender] -= _value;
        TotalBalances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;

    }
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        uint256 allowedBal = allowed[_from][msg.sender];
        require( allowedBal >= _value, "Insufficient Balance");
        TotalBalances[_from] -= _value;
        TotalBalances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(TotalBalances[msg.sender] >= _value, "Insufficient Balance");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256 remaining){
        return allowed[_owner][_spender]; // It provide a cap, justify how much _spender spend tokens
    }
}