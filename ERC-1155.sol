// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply {

    //Erros customizados
    error MaxSupplyExceeded(uint256 quantity);
    error ValueNotEnough(uint256 value);
    error MaxPerWalletReached(uint256 max);
    error FailedTranfer();
    error URIQueryForNonExistentToken();
    error AllowListClosed();
    error PublicMintClosed();
    error YouAreNotOnTheList();
    
    //Evento para rastrear wallet e valor de um possível saque
    event Withdraw (address indexed owner, uint256 balance);

    uint256 public constant publicPrice = 0.05 ether;
    uint256 public constant allowListPrice = 0.02 ether;
    uint256 public constant maxSupply = 5;
    uint256 public constant maxPerWallet = 2;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = true;

    mapping (address => bool) allowListAddress;

    mapping (address => uint8) public walletMinted;

    constructor(address initialOwner) ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/") Ownable(initialOwner) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    
    //Função para adicionar e retornar o json na URL do metadados IPFS.
    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        if(!exists(_tokenId)) revert URIQueryForNonExistentToken(); 
        return string(abi.encodePacked(super.uri(_tokenId), Strings.toString(_tokenId), ".json"));    
    }


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function publicMint( uint256 id, uint256 _quantity) public payable whenNotPaused {
        if(allowListMintOpen) {
            revert PublicMintClosed();
        }

         if(msg.value < publicPrice * _quantity){
            revert ValueNotEnough(msg.value);
         } 

         mint(id, _quantity);  
    }
    
    //Função de mint privado
    function allowListMint(uint256 id, uint256 _quantity) public payable whenNotPaused {
        if(!allowListAddress[msg.sender]) {
            revert YouAreNotOnTheList();
        }

        if(publicMintOpen) {
            revert AllowListClosed();
        }

        if(msg.value < allowListPrice * _quantity) {
            revert ValueNotEnough(msg.value);
        }

        mint(id, _quantity);
    }
    

    //Função criada para fazer um Clean Up Code em publicMint e allowListMint
    function mint (uint256 id, uint256 _quantity) internal {
         if(walletMinted[msg.sender] >= maxPerWallet){
            revert MaxPerWalletReached(maxPerWallet);
         }

         if (totalSupply(id) + _quantity > maxSupply){
             revert MaxSupplyExceeded(_quantity);
         }

        _mint(msg.sender, id, _quantity, "" );
        walletMinted[msg.sender] += 1;
    }
    
    //Função de mint windows para ativar/desativar o Mint público e de lista de permissões
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //Salvar endereços na lista de permissões
    function setAllowList (address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) 
        {
            allowListAddress[addresses[i]] = true;
        }
    }
    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    //Função de saque dos fundos do contrato
    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        (bool sucess, ) = (msg.sender).call{ value: balance }("");
        if(!sucess){
            revert FailedTranfer();
        }
        
        //Emitindo evento contendo wallet e valor de quem fez o saque dos fundos
        emit Withdraw(msg.sender, balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}