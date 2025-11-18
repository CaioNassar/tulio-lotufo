entity sign_extend is
  generic (
    dataISize       : natural := 32;
    dataOSize       : natural := 64;
    dataMaxPosition : natural := 5 -- sempre fazer log2(dataISize)
  );
  port (
    inData      : in  bit_vector(dataISize-1 downto 0); -- dado de entrada
                  -- com tamanho datalSize
    inDataStart : in  bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit 
                  -- mais significativo do valor util na entrada (bit de sinal)
    inDataEnd   : in  bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit 
                  -- menos significativo do valor util na entrada
    outData     : out bit_vector(dataOSize-1 downto 0)  -- dado de saida 
                  -- com tamanho dataOSize e sinal estendido
  );
end entity sign_extend;