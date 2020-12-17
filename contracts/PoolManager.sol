pragma solidity =0.7.5;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.1-solc-0.7/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.1-solc-0.7/contracts/access/Ownable.sol";
import "./Pool.sol";

contract PoolManager is Ownable{
    using SafeMath for uint256;

    mapping(Pool => bool) approvedPools;
    address regionOwner;
    string regionName;




    constructor(address regOwn, string memory regName) public {
        regionName = regName;
        regionOwner = regOwn;
    }


    /*
    should be safe for people because nobody has to invest into new pool we launch without looking at it
    does not give us ability to modify or fuck with existing pools in any way, just add new ones
    */
    function approvePool(address newPool) external onlyOwner{
        Pool np = Pool(newPool);
        approvedPools[np] = true;
    }

    /*
    @todo think about how this works, with modular yield/vault deployment for regions
    */
    function deployPool() external{
        //make this take paramaters and stuff to deploy a custom pool, then add it to approved pools
    }

    function depositToPool(address p, uint256 amount ) external{ //p stands for pool
        Pool pool = Pool(p); //cast address to pool
        require(approvedPools[pool]); //make sure pool is approved in out system

        IERC20 pToken = pool.getToken(); //get the contract of the pools staking token, and make it work like an erc20
        bool success = pToken.transferFrom(msg.sender, p, amount); //transfer tokens from the user to the pool
        require(success, "Failed to transfer token, needs approval"); //throw a fit if the transfer doesnt happen
        pool.deposit(msg.sender, amount); //have the pool deposit the tokens into the strategy
    }

    function withdrawFromPool(address p, uint256 amount) external{
        Pool pool = Pool(p); //cast address to pool
        require(approvedPools[pool]); //make sure pool is approved in out system

        pool.withdraw(msg.sender, amount);

    }


    function getRegionOwner() public view returns(address){
        return regionOwner;
    }

    function getRegionName() external view returns(string memory){
        return regionName;
    }



}