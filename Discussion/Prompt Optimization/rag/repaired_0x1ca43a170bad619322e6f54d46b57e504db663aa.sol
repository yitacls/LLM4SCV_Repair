pragma solidity ^0.4.25;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;
        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);
            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);
    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}

contract DSTokenBase is ERC20, DSMath {
    uint256 private _supply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }

    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }

    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }
}

contract DSToken is DSTokenBase(0) {
    bytes32 public symbol;
    uint256 public decimals = 18;

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }

    function burn(uint wad) public {
        burn(msg.sender, wad);
    }

    function mint(address guy, uint wad) public {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit Mint(guy, wad);
    }

    function burn(address guy, uint wad) public {
        if (guy != msg.sender) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Burn(guy, wad);
    }

    bytes32 public name = "";

    function setName(bytes32 name_) public {
        name = name_;
    }
}

contract AKC is DSToken("AKC") {
    constructor() {
        setName("ARTWOOK Coin");
    }
}