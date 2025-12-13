library ieee;
use ieee.numeric_bit.all;


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

  architecture se of sign_extend is 
begin
  recortador: process(inData, inDataStart, inDataEnd)
    variable comeco      : integer;
    variable fim         : integer;
    variable tamanho     : integer;
    variable bitExtensor : bit;
    variable recorte     : bit_vector(dataOSize-1 downto 0);
    variable i           : integer;
  begin
    
    comeco := to_integer(unsigned(inDataStart));
    fim    := to_integer(unsigned(inDataEnd));
    tamanho := comeco - fim + 1;
    bitExtensor := inData(comeco);

    i := 0;
    while i < tamanho loop
      recorte(i) := inData(fim + i);
      i := i + 1;
    end loop;

    while i < dataOSize loop
      recorte(i) := bitExtensor;
      i := i + 1;
    end loop;

    outData <= recorte;
  end process recortador;
end architecture se;
    
