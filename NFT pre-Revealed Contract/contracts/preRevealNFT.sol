// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error  NotEnoughTokens();
error NotvalidAmount();
error NotEnoughAllowance();
error NotAdminMinter();
contract preRevealNFT is ERC721A,Ownable{
    uint256 public price;
    address public tokenAddress;
    string  public baseURI="";
    uint256 public Max_Supply ;
    uint256 public reserveQuantity;
    string public preRevealedURI = "https://www.jsonkeeper.com/b/S00G";
    bool public isRevealed ;
  
    event TokenAddress(address indexed oldAddress,address indexed newAddress);
    event SetPrice(uint indexed oldPrice, uint indexed newPrice);

    constructor(address _tokenAddress,uint _price,uint _Max_Supply,uint256 _reserve) ERC721A("PreRevealToken","PRT") {  
         tokenAddress=_tokenAddress;
         price= _price;
         Max_Supply=_Max_Supply;
         reserveQuantity=_reserve;
         isRevealed = false;
    }

    function setTokenAddress(address  _tokenAddress) public onlyOwner {
        address oldAddress = tokenAddress;
        tokenAddress = _tokenAddress;
        emit TokenAddress(oldAddress, tokenAddress);
    }
 
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        Max_Supply = _maxSupply;
    }

    function setPrice(uint256 _price) public onlyOwner{
        uint oldprice=price;
        price=_price;
        emit SetPrice(oldprice,price);
    }

     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (isRevealed) {
            return super.tokenURI(tokenId);
        }
        return preRevealedURI;
    }

    function setPreRevealedURI(string memory _preRevealedURI) 
        external onlyOwner {
            preRevealedURI = _preRevealedURI;
    }

     function revealAndSetBaseURI(string memory baseURI_) 
        external onlyOwner {
            isRevealed = true;
            baseURI = baseURI_;
    }

    function setreserve(uint256 quantity) public onlyOwner {
        reserveQuantity=quantity;
    }

    function _baseURI()internal view override  returns (string memory){
        return baseURI;
    }

    function reserve(uint256 quantity) public onlyOwner {
        require(quantity <= reserveQuantity, "the quantity exceeds reserve");
        require(totalSupply() + quantity <= Max_Supply, "Not enough tokens left");
        reserveQuantity -= quantity;
        _safeMint(msg.sender, quantity);
    }
   
    function mint(uint256 quantity) public{
        uint256 amount = quantity * price;
        require(totalSupply() + quantity <= Max_Supply, "Not enough tokens left");
        if(IERC20(tokenAddress).balanceOf(msg.sender) < amount){
            revert NotEnoughTokens();
        }
        if(IERC20(tokenAddress).allowance(msg.sender, address(this)) < amount)
        {
            revert NotEnoughAllowance();
        }
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender,quantity );
    }
   function burn(uint256 tokenId) public  {
       
       require(msg.sender == ownerOf(tokenId), "notOwner");
        _burn(tokenId);
        }
   
}