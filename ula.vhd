library ieee;
use ieee.numeric_bit.all;

entity ula is
   port (
      A  : in bit_vector(63 downto 0);   -- entrada A
      B  : in bit_vector(63 downto 0);   -- entrada B
      S  : in bit_vector (3 downto 0);   -- seleciona operacao
      F  : out bit_vector (63 downto 0); -- saida
      Z  : out bit;                      -- flag zero
      Ov : out bit;                      -- flag overflow
      Co : out bit                       -- flag carry out
   );
end entity ula;


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
   
   signal carry : bit_vector(63 downto 0);
   signal F_int : bit_vector(63 downto 0);
   signal Ov_int : bit_vector(63 downto 0);

   begin 
      ulagrande: for i in 63 downto 1 generate
         ulas_x: ula1bit port map(A(i), B(i), carry(i-1), S(3), S(2), S(1 downto 0), F_int(i), carry(i), Ov_int(i));
      end generate ulagrande;
      ulas_0: ula1bit port map(A(0), B(0), S(2), S(3), S(2), S(1 downto 0), F_int(0), carry(0), Ov_int(0));

      process(F_int)
         variable um : bit;
      begin
         um := '0';

         for i in 0 to 63 loop
            if NOT(F_int(i)) = '0' then um := '1';
            end if;
         end loop;

         Z <= NOT um;
      end process;

      F <= F_int;
      Co <= carry(63);
      Ov <= Ov_int(63);

end architecture;
