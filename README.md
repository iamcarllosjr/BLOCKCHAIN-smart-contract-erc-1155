# BLOCKCHAIN-smart-contract-erc-1155

Aqui temos algumas funções escritas neste contrato :
1 - Função de mint publico (Pagável).
2 - Função de mint privado (Whitelist - Pagável).
3 - Função de saque dos fundos deste contrato.
4 - Função de update de URI (Link para imagens do NFT e metadados).
5 - Função para liberar/fechar tanto mint publico como o privado
6 - Função para adicionar um address e permitir que ele possa chamar a função de mint privado

Também foi utilizado erros customizados ao invés de require

Aqui também definimos algumas coisas como : 
1 - Preços diferentes para mint publico e mint privado.
2 - Supply máximo de NFTs disponíveis.
3 - Um total máximo permitido de mintagem para um único usuário.
