library ieee;
use ieee.numeric_bit.all;

entity tb_polilegv8 is
end entity;

architecture sim of tb_polilegv8 is

  signal clock : bit := '0';
  signal reset : bit := '1';

  constant TCLK : time := 10 ns; -- 100 MHz (ajuste se quiser)

begin

  -- DUT
  dut : entity work.polilegv8
    port map(
      clock => clock,
      reset => reset
    );

  -- Clock generator
  p_clk : process
  begin
    while true loop
      clock <= '0';
      wait for TCLK/2;
      clock <= '1';
      wait for TCLK/2;
    end loop;
  end process;

  -- Reset + tempo de simulação
  p_stim : process
  begin
    -- reset assíncrono ativo no início
    reset <= '1';
    wait for 3*TCLK;      -- segura alguns ciclos

    reset <= '0';         -- libera
    -- roda ciclos suficientes para executar o programa e entrar em loop
    -- (ajuste se sua memória/programa tiver mais/menos instruções)
    wait for 200*TCLK;

    -- encerra simulação
    assert false report "Fim da simulacao (TB)" severity failure;
  end process;

end architecture;
