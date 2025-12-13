library ieee;
use ieee.numeric_bit.all;

entity regfile_tb is
end regfile_tb;

architecture dataflow of regfile_tb is

  component regfile
    port(
        clock    : in  bit;                     --! entrada de clock
        reset    : in  bit;                     --! entrada de reset
        regWrite : in  bit;                     --! entrada de carga do registrador wr
        rr1      : in  bit_vector(4 downto 0);  --! entrada define registrador 1
        rr2      : in  bit_vector(4 downto 0);  --! entrada define registrador 2
        wr       : in  bit_vector(4 downto 0);  --! entrada define registrador de escrita
        d        : in  bit_vector(63 downto 0); --! entrada de dado para carga paralela
        q1       : out bit_vector(63 downto 0); --! saida do registrador rr1
        q2       : out bit_vector(63 downto 0)  --! saida do registrador rr2
    );
  end component regfile;

  constant clkPeriod : time := 1 ns;
  signal simulando : bit := '0';
  signal clk, rt, ld : bit := '0';
  signal rr1, rr2, wr: bit_vector(4 downto 0);
  signal d, q1, q2: bit_vector(63 downto 0);

  signal caso : natural := 0;  -- caso de teste

begin
  -- geracao de clock
  clk <= (simulando and (not clk)) after clkPeriod/2;

  --! DUT = Design Under Test
  dut: regfile
      port map (
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

  -- processo para geracao de estimulos do testbench
  stim: process

      -- vetor de teste com padroes de dados para escrita nos registradores
      type test_pattern_array is array (natural range <>) of bit_vector(63 downto 0);
      constant test_patterns: test_pattern_array :=
      (
        (X"0000000000000000"), -- usado para verificacao do reset (nao mudar)
        (X"FFFFFFFFFFFFFFFF"),
        (X"F0F0F0F0F0F0F0F0"),
        (X"0F0F0F0F0F0F0F0F"),
        (X"123456789ABCDEF0")
      );

  begin
    report "Inicio do testbench do regfile PoliLEGv8";
    simulando <= '1';
    
    -- 1. Verificacao do Reset
    caso <= 1;
    -- valores iniciais
    rr1 <= "00000"; rr2 <= "00000"; wr <= "00000"; ld <= '0';
    d <= X"FFFFFFFFFFFFFFFF";
    -- gera pulso de reset
    rt <= '1';
    wait for 10 ns;
    rt <= '0';
    -- verifica se saidas dos registradores eh zero (exceto X31 que SEMPRE deve ser zero)
    for ri in 0 to 31 loop
        rr1 <= bit_vector(to_unsigned(ri,5));
        rr2 <= bit_vector(to_unsigned(ri,5));
        wait for 1 ns;
        if ri = 31 then
            -- X31 deve SEMPRE retornar zero
            assert (q1 = X"0000000000000000" and q2 = X"0000000000000000")
                report "X31 (XZR) nao retorna zero apos reset"
                severity error;
        else
            -- Demais registradores devem ser zero apos reset
            assert (q1 = X"0000000000000000" and q2 = X"0000000000000000")
                report "Saidas apos reset nao sao zero para o registrador X" &
                       integer'image(ri)
                severity error;
        end if;
    end loop;
    report "Fim do teste de reset";

    -- 2. Verificacao de escrita dos padroes de dados
    caso <= 2;
    -- testa conjunto de padroes de dados
    for idx in test_patterns'range loop
        if idx > 0 then  -- pula o padrao 0 (usado apenas para reset)
            report "Teste de padrao #" & integer'image(idx) & " d=" & to_bstring(test_patterns(idx));
            d <= test_patterns(idx);
            
            for ri in 0 to 31 loop
                wr  <= bit_vector(to_unsigned(ri,5));
                rr1 <= bit_vector(to_unsigned(ri,5));
                rr2 <= bit_vector(to_unsigned(ri,5));
                wait for 1 ns;
                
                -- 2.a) testa valores dos registradores antes da escrita
                if ri = 31 then
                    -- X31 deve SEMPRE retornar zero, independente da escrita anterior
                    assert (q1 = X"0000000000000000" and q2 = X"0000000000000000")
                        report "X31 (XZR) nao retorna zero antes da escrita"
                        severity error;
                else
                    -- Para registradores normais, verifica valor anterior
                    if idx > 1 then
                        assert (q1 = test_patterns(idx-1) and q2 = test_patterns(idx-1))
                            report "Saida anterior invalida para o registrador X" &
                                   integer'image(ri) & " antes da escrita" & LF &
                                   " esperado:" & to_bstring(test_patterns(idx-1)) & LF &
                                   " saida q1: " & to_bstring(q1) & LF &
                                   " saida q2: " & to_bstring(q2)
                            severity error;
                    end if;
                end if;

                -- 2.b) execucao da escrita de registradores
                ld <= '1';
                wait until rising_edge(clk);
                ld <= '0';
                wait for 1 ns;

                -- 2.c) testa valor escrito nos registradores
                if ri = 31 then
                    -- X31 deve IGNORAR escrita e SEMPRE retornar zero
                    assert (q1 = X"0000000000000000" and q2 = X"0000000000000000")
                        report "X31 (XZR) aceitou escrita - deveria permanecer zero" & LF &
                               " tentou escrever: " & to_bstring(d) & LF &
                               " mas retornou: " & to_bstring(q1)
                        severity error;
                else
                    -- Para registradores normais, verifica se valor foi escrito
                    assert (q1 = test_patterns(idx) and q2 = test_patterns(idx))
                        report "Saida invalida no registrador X" &
                               integer'image(ri) & " apos a escrita" & LF &
                               " esperado:" & to_bstring(test_patterns(idx)) & LF &
                               " saida q1: " & to_bstring(q1) & LF &
                               " saida q2: " & to_bstring(q2)
                        severity error;
                end if;
            end loop;
        end if;
    end loop;

    -- 3. Teste de leitura simultanea de registradores diferentes
    caso <= 3;
    report "Teste de leitura simultanea de registradores diferentes";
    
    -- Escreve valores distintos em alguns registradores
    d <= X"1111111111111111"; wr <= "00001"; ld <= '1'; wait until rising_edge(clk); ld <= '0';
    d <= X"2222222222222222"; wr <= "00010"; ld <= '1'; wait until rising_edge(clk); ld <= '0';
    d <= X"3333333333333333"; wr <= "00011"; ld <= '1'; wait until rising_edge(clk); ld <= '0';
    d <= X"4444444444444444"; wr <= "11111"; ld <= '1'; wait until rising_edge(clk); ld <= '0'; -- Tentativa de escrita no X31
    
    wait for 1 ns;
    
    -- Testa leitura simultanea
    rr1 <= "00001"; rr2 <= "00010";
    wait for 1 ns;
    assert (q1 = X"1111111111111111" and q2 = X"2222222222222222")
        report "Leitura simultanea falhou" & LF &
               " q1 esperado: " & to_bstring(X"1111111111111111") & " obtido: " & to_bstring(q1) & LF &
               " q2 esperado: " & to_bstring(X"2222222222222222") & " obtido: " & to_bstring(q2)
        severity error;
    
    -- Testa leitura do X31 simultaneamente com outro registrador
    rr1 <= "11111"; rr2 <= "00011";
    wait for 1 ns;
    assert (q1 = X"0000000000000000" and q2 = X"3333333333333333")
        report "Leitura do X31 com outro registrador falhou" & LF &
               " X31 deveria ser zero, mas q1 = " & to_bstring(q1) & LF &
               " q2 esperado: " & to_bstring(X"3333333333333333") & " obtido: " & to_bstring(q2)
        severity error;

    report "Fim do testbench - TODOS OS TESTES PASSARAM!";
    simulando <= '0';
    wait;
  end process;

end architecture;
