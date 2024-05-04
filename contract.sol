
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint value) external returns (bool success);
    function approve(address spender, uint value) external returns (bool success);
    function balanceOf(address account) external view returns (uint);
}

contract DecentralizedExchange {
    mapping (address => mapping (address => uint)) public balances;
    mapping (address => mapping (address => uint)) public allowed;
    mapping (address => uint) public totalSupply;
    mapping (address => address) public ownerOf;
    mapping (address => bool) public isToken;
    address[] public tokens;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Swap(address indexed token, address indexed from, address indexed to, uint value);

    constructor() public {
        isToken[msg.sender] = true;
        ownerOf[msg.sender] = msg.sender;
        totalSupply[msg.sender] = 1000000;
        tokens.push(msg.sender);
    }

    function transfer(address to, uint value) public {
        require(isToken[msg.sender], "Not a token");
        require(totalSupply[msg.sender] >= value, "Insufficient balance");
        require(balances[msg.sender][msg.sender] >= value, "Insufficient balance");
        require(to != msg.sender, "Cannot transfer to self");

        balances[msg.sender][msg.sender] -= value;
        balances[msg.sender][to] += value;
        totalSupply[msg.sender] -= value;

        emit Transfer(msg.sender, to, value);
    }

    function approve(address spender, uint value) public {
        require(isToken[msg.sender], "Not a token");
        require(spender != msg.sender, "Cannot approve self");

        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint value) public {
        require(isToken[from], "Not a token");
        require(totalSupply[from] >= value, "Insufficient balance");
        require(balances[from][from] >= value, "Insufficient balance");
        require(allowed[from][msg.sender] >= value, "Insufficient allowance");
        require(to != from, "Cannot transfer to self");

        balances[from][from] -= value;
        balances[from][to] += value;
        totalSupply[from] -= value;

        emit Transfer(from, to, value);
    }

    function swap(address token, uint value) public {
        require(isToken[token], "Not a token");
        require(totalSupply[token] >= value, "Insufficient balance");
        require(balances[token][msg.sender] >= value, "Insufficient balance");

        balances[token][msg.sender] -= value;
        balances[token][address(this)] += value;

        IERC20(token).transferFrom(address(this), msg.sender, value);

        emit Swap(token, msg.sender, address(this), value);
    }

    function addToken(address token) public {
        require(!isToken[token], "Token already exists");

        isToken[token] = true;
        ownerOf[token] = msg.sender;
        totalSupply[token] = 1000000;
        tokens.push(token);
    }
}














