library ieee;
use ieee.numeric_bit.to_unsigned;
use ieee.numeric_bit.unsigned;

entity two_left_shifts is
  generic (
    dataSize : natural := 64
  );
  port (
    input  : in  bit_vector(dataSize-1 downto 0);
    output : out bit_vector(dataSize-1 downto 0)
  );
end entity two_left_shifts;

architecture dois_shifts_arq of two_left_shifts is 
    signal deslocado : bit_vector(dataSize-1 downto 0);
    begin   
        deslocado <= input(dataSize-3 downto 0) & "00";
        output <= deslocado(dataSize-1 downto 0);
end dois_shifts_arq;


