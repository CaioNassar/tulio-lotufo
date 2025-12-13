library ieee;
use ieee.numeric_bit.all;

entity regfile_tb is
end entity regfile_tb;

architecture dataflow of regfile_tb is

  component regfile is
    port(
      clock    : in  bit;
      reset    : in  bit;
      regWrite : in  bit;
      rr1      : in  bit_vector(4 downto 0);
      rr2      : in  bit_vector(4 downto 0);
      wr       : in  bit_vector(4 downto 0);
      d        : in  bit_vector(63 downto 0);
      q1       : out bit_vector(63 downto 0);
      q2       : out bit_vector(63 downto 0)
    );
  end component;

  constant clkPeriod : time := 10 ns;

  signal simulando : bit := '0';
  signal clk       : bit := '0';
  signal rt        : bit := '0'; -- reset
  signal ld        : bit := '0'; -- regWrite

  signal rr1, rr2, wr : bit_vector(4 downto 0) := (others => '0');
  signal d            : bit_vector(63 downto 0) := (others => '0');
  signal q1, q2        : bit_vector(63 downto 0);

  signal caso : natural := 0;

begin

  -- geração de clock (oscila enquanto simulando='1')
  clk <= (simulando and (not clk)) after clkPeriod/2;

  -- DUT
  dut : regfile
    port map(
      clock    => clk,
      reset    => rt,
      regWrite => ld,
      rr1      => rr1,
      rr2      => rr2,
      wr       => wr,
      d        => d,
      q1       => q1,
      q2       => q2
    );

  stim : process
    type test_pattern_array is array (natural range <>) of bit_vector(63 downto 0);

    constant test_patterns : test_pattern_array :=
    (
      x"0000000000000000",  -- idx=0 (usado como referência)
      x"FFFFFFFFFFFFFFFF",
      x"FEDCBA9876543210",
      x"0F0F0F0F0F0F0F0F",
      x"123456789ABCDEF0"
    );

    variable ri  : integer;
    variable idx : integer;
  begin
    report "Inicio do testbench do regfile PoliLEGv8";
    simulando <= '1';

    ----------------------------------------------------------------------
    -- 1) Reset
    ----------------------------------------------------------------------
    caso <= 1;
    rr1 <= "00000"; rr2 <= "00000"; wr <= "00000"; ld <= '0';
    d <= x"FFFFFFFFFFFFFFFF";

    rt <= '1';
    wait for 10 ns;
    rt <= '0';
    wait for 1 ns;

    -- após reset, todos devem ser 0; X31 (11111) deve ser sempre 0
    for ri in 0 to 31 loop
      rr1 <= bit_vector(to_unsigned(ri, 5));
      rr2 <= bit_vector(to_unsigned(ri, 5));
      wait for 1 ns;

      assert (q1 = x"0000000000000000" and q2 = x"0000000000000000")
        report "Falha no reset: registrador " & integer'image(ri) & " nao esta zerado"
        severity error;
    end loop;

    report "Fim do teste de reset";

    ----------------------------------------------------------------------
    -- 2) Escrita e leitura: escreve padroes em varios regs e verifica leitura
    ----------------------------------------------------------------------
    caso <= 2;

    for idx in 1 to test_patterns'length-1 loop
      d <= test_patterns(idx);

      for ri in 0 to 31 loop
        wr  <= bit_vector(to_unsigned(ri, 5));
        rr1 <= bit_vector(to_unsigned(ri, 5));
        rr2 <= bit_vector(to_unsigned(ri, 5));

        wait for 1 ns;

        -- pulso de escrita (1 ciclo)
        ld <= '1';
        wait until (clk'event and clk = '1');
        ld <= '0';
        wait for 1 ns;

        if ri = 31 then
          -- X31 deve permanecer 0
          assert (q1 = x"0000000000000000" and q2 = x"0000000000000000")
            report "Falha: X31 (XZR) aceitou escrita (deveria ficar 0)"
            severity error;
        else
          -- regs normais devem refletir o valor escrito
          assert (q1 = test_patterns(idx) and q2 = test_patterns(idx))
            report "Falha: escrita/leitura no registrador " & integer'image(ri)
            severity error;
        end if;

      end loop;
    end loop;

    report "Fim do teste de escrita/leitura";

    ----------------------------------------------------------------------
    -- 3) Leitura simultanea de dois regs diferentes
    ----------------------------------------------------------------------
    caso <= 3;

    -- escreve valores distintos em alguns regs
    d  <= x"1111111111111111"; wr <= "00001"; ld <= '1'; wait until (clk'event and clk='1'); ld <= '0';
    d  <= x"2222222222222222"; wr <= "00010"; ld <= '1'; wait until (clk'event and clk='1'); ld <= '0';
    d  <= x"3333333333333333"; wr <= "00011"; ld <= '1'; wait until (clk'event and clk='1'); ld <= '0';
    d  <= x"4444444444444444"; wr <= "11111"; ld <= '1'; wait until (clk'event and clk='1'); ld <= '0'; -- tentativa X31

    wait for 1 ns;

    -- lê X1 e X2 ao mesmo tempo
    rr1 <= "00001";
    rr2 <= "00010";
    wait for 1 ns;

    assert (q1 = x"1111111111111111" and q2 = x"2222222222222222")
      report "Falha: leitura simultanea X1/X2"
      severity error;

    -- lê X31 e X3 ao mesmo tempo (X31 deve ser 0)
    rr1 <= "11111";
    rr2 <= "00011";
    wait for 1 ns;

    assert (q1 = x"0000000000000000" and q2 = x"3333333333333333")
      report "Falha: leitura de X31 e X3"
      severity error;

    report "Fim do testbench - TODOS OS TESTES PASSARAM!";
    simulando <= '0';
    wait;
  end process;

end architecture dataflow;

