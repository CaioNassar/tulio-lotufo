library ieee;
use ieee.numeric_bit.all;

entity tb_polilegv8 is
end entity;

architecture tb_polilegv8Arch of tb_polilegv8 is

  signal clock : bit := '0';
  signal reset : bit := '1';

  constant TCLK : time := 10 ns;

begin

  dut : entity work.polilegv8
    port map(
      clock => clock,
      reset => reset
    );

  p_clk : process
  begin
    while true loop
      clock <= '0';
      wait for TCLK/2;
      clock <= '1';
      wait for TCLK/2;
    end loop;
  end process;

  p_stim : process
  begin
    
    reset <= '1';
    wait for 3*TCLK;    

    reset <= '0';        
    wait for 200*TCLK;

    assert false report "Fim da simulacao (TB)" severity failure;
  end process;

end architecture;
