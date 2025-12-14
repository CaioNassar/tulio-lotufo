library ieee;
use ieee.numeric_bit.all;

entity ula_tb is
end entity;

architecture ula_tbArch of ula_tb is
  signal A  : bit_vector(63 downto 0);
  signal B  : bit_vector(63 downto 0);
  signal S  : bit_vector(3 downto 0);
  signal F  : bit_vector(63 downto 0);
  signal Z  : bit;
  signal Ov : bit;
  signal Co : bit;
begin

  dut : entity work.ula
    port map(
      A  => A,
      B  => B,
      S  => S,
      F  => F,
      Z  => Z,
      Ov => Ov,
      Co => Co
    );

  process
  begin
    ------------------------------------------------------------------------
    -- AND: S=0000
    ------------------------------------------------------------------------
    A <= x"F0F0F0F0F0F0F0F0";
    B <= x"0FF00FF00FF00FF0";
    S <= "0000";
    wait for 1 ns;
    assert F = (A and B) report "ERRO AND" severity failure;
    assert Z = '0' report "ERRO Z no AND" severity failure;

    ------------------------------------------------------------------------
    -- OR: S=0001
    ------------------------------------------------------------------------
    A <= x"F0F0F0F0F0F0F0F0";
    B <= x"0FF00FF00FF00FF0";
    S <= "0001";
    wait for 1 ns;
    assert F = (A or B) report "ERRO OR" severity failure;
    assert Z = '0' report "ERRO Z no OR" severity failure;

    ------------------------------------------------------------------------
    -- ADD: S=0010
    ------------------------------------------------------------------------
    A <= x"0000000000000008";
    B <= x"0000000000000005";
    S <= "0010";
    wait for 1 ns;
    assert F = x"000000000000000D" report "ERRO ADD 8+5" severity failure;
    assert Z = '0' report "ERRO Z no ADD" severity failure;

    ------------------------------------------------------------------------
    -- SUB: S=0110  (A - B)
    ------------------------------------------------------------------------
    A <= x"0000000000000008";
    B <= x"0000000000000005";
    S <= "0110";
    wait for 1 ns;
    assert F = x"0000000000000003" report "ERRO SUB 8-5" severity failure;
    assert Z = '0' report "ERRO Z no SUB" severity failure;

    ------------------------------------------------------------------------
    -- SUB: 5 - 8 = -3 (2's complement)
    ------------------------------------------------------------------------
    A <= x"0000000000000005";
    B <= x"0000000000000008";
    S <= "0110";
    wait for 1 ns;
    assert F = x"FFFFFFFFFFFFFFFD" report "ERRO SUB 5-8 (-3)" severity failure;
    assert Z = '0' report "ERRO Z no SUB 5-8" severity failure;

    ------------------------------------------------------------------------
    -- PASSA B: S=0011  (operation="11" e binvert=0, cin=0)
    ------------------------------------------------------------------------
    A <= x"AAAAAAAAAAAAAAAA";
    B <= x"0123456789ABCDEF";
    S <= "0011";
    wait for 1 ns;
    assert F = B report "ERRO PASSA B (S=0011)" severity failure;
    assert Z = '0' report "ERRO Z no PASSA B" severity failure;

    ------------------------------------------------------------------------
    -- PASSA B com B=0 => Z deve ser 1
    ------------------------------------------------------------------------
    A <= x"FFFFFFFFFFFFFFFF";
    B <= x"0000000000000000";
    S <= "0011";
    wait for 1 ns;
    assert F = x"0000000000000000" report "ERRO PASSA B com B=0" severity failure;
    assert Z = '1' report "ERRO Z no PASSA B com B=0" severity failure;

    ------------------------------------------------------------------------
    -- AND gerando zero => Z deve ser 1
    ------------------------------------------------------------------------
    A <= x"0000000000000000";
    B <= x"FFFFFFFFFFFFFFFF";
    S <= "0000";
    wait for 1 ns;
    assert F = x"0000000000000000" report "ERRO AND zero" severity failure;
    assert Z = '1' report "ERRO Z no AND zero" severity failure;

    report "ULA TB: Ok";
    wait;
  end process;

end architecture;
