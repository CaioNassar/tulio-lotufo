library ieee;
use ieee.numeric_bit.all;

entity ula1bit is
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
end entity;

entity fulladder is
  port (
    a    : in  bit; 
    b    : in  bit; 
    cin  : in bit;
    s    : out bit;
    cout : out bit
  );
end entity fulladder;

architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s <= axorb xor cin;
  cout <= (axorb and cin) or (a and b);
 end architecture;


architecture ula1bit_arq of ula1bit is
    signal a_sinal, b_sinal : bit;
    component fulladder is
    port(
        a    : in  bit; 
        b    : in  bit; 
        cin  : in bit;
        s    : out bit;
        cout : out bit 
    );
    end component;

begin
    somador : fulladder 
    port map(
        a => a_sinal, 
        b => b_sinal,
        cin => cin,
        s => s,
        cout => cout
    );

    a_sinal <= a when ainvert = '0' else
               NOT(a) when ainvert = '1';  

    b_sinal <= b when binvert = '0' else
               NOT(b) when binvert = '1';  

with operation select
result <= a AND b when "00",
          a OR b when "01",
          s when "10",
          b when "11";

end architecture;
