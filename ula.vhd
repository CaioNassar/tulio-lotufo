library ieee;
use ieee.numeric_bit.all;

entity ula is
port (
A : in bit_vector(63 downto 0); -- e n t r a d a A
B : in bit_vector(63 downto 0); -- e n t r a d a B
S : in bit_vector (3 downto 0); -- s e l e c i o n a o p e r a c a o
F : out bit_vector (63 downto 0); -- s a i d a
Z : out bit; -- f l a g z e r o
Ov : out bit ; -- f l a g o v e r f l o w
Co : out bit -- f l a g c a r r y out
);
end entity alu ;


architecture aluula of ula is

   component ula1bit is
   port (
    a         : in  bit;
    b         : in  bit;
    cin       : in  bit;
    ainvert   : in  bit;
    binvert   : in  bit;
    operation : in  bit_vector(1 downto 0);
    result    : out bit;
    cout      : out bit;
    overflow  : out bit
  );
  end component;
   
  signal carry  : bit_vector(63 downto 0); 

begin 
ulagrande: for i in 63 downto 0 generate
   ulas: ula1bit port map(A(i), B(i), cin, S(3), S(2), S(1 downto 0), F(i));
end generate ulagrande;
 end architecture;
