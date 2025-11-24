library ieee;
use ieee.numeric_bit.all;

entity adder_n is
  generic (dataSize: natural := 64);
  port (
    in0  : in  bit_vector(dataSize-1 downto 0); -- primeira parcela
    in1  : in  bit_vector(dataSize-1 downto 0); -- segunda parcela
    sum  : out bit_vector(dataSize-1 downto 0); -- soma
    cOut : out bit 
  );
end entity adder_n;

 architecture somador_n_arq of adder_n is
    signal soma_C: bit_vector(dataSize downto 0);
begin
    soma_C <= bit_vector(unsigned('0' & in0) + (unsigned('0' & in1)));
    sum <= soma_C(dataSize-1 downto 0);
    cOut <= soma_C(dataSize);
end somador_n_arq;
