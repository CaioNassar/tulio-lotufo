library ieee;
use ieee.numeric_bit.all;

entity ula is
port (
A : in bit_vector(63 downto 0); -- e n t r a d a A
B :  in bit_vector(63 downto 0); -- e n t r a d a B
S : in bit_vector (3 downto 0); -- s e l e c i o n a o p e r a c a o
F : out bit_vector (63 downto 0); -- s a i d a
Z : out bit; -- f l a g z e r o
Ov : out bit ; -- f l a g o v e r f l o w
Co : out bit -- f l a g c a r r y out
);
end entity alu ;


architecture aluula of ula is
   signal carry  : bit_vector(63 downto 0) 

