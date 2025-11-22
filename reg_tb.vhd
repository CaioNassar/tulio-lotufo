entity tb_registrador_n is
end entity tb_registrador_n;

architecture testbench of tb_registrador_n is
    component reg is
        generic (dataSize: natural := 64);
        port (
            clock  : in  bit;
            reset  : in  bit;
            enable : in  bit;
            d      : in  bit_vector (dataSize-1 downto 0);
            q      : out bit_vector (dataSize-1 downto 0) 
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    
    signal simulando : bit := '1';
    
    signal clock  : bit;
    signal reset  : bit;
    signal enable : bit;
    
    signal d_16 : bit_vector(15 downto 0);
    signal q_16 : bit_vector(15 downto 0);
    
    signal d_32 : bit_vector(31 downto 0);
    signal q_32 : bit_vector(31 downto 0);
    
    signal d_64 : bit_vector(63 downto 0);
    signal q_64 : bit_vector(63 downto 0);

begin
    UUT_16: reg 
        generic map (dataSize => 16)
        port map (
            clock  => clock,
            reset  => reset,
            enable => enable,
            d      => d_16,
            q      => q_16
        );
    
    UUT_32: reg 
        generic map (dataSize => 32)
        port map (
            clock  => clock,
            reset  => reset,
            enable => enable,
            d      => d_32,
            q      => q_32
        );
    
    UUT_64: reg 
        generic map (dataSize => 64)
        port map (
            clock  => clock,
            reset  => reset,
            enable => enable,
            d      => d_64,
            q      => q_64
        );

    processo_clock : process
    begin
        while simulando = '1' loop
            clock <= '0';
            wait for CLK_PERIOD/2;
            clock <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    processo_estimulo : process
    begin
        -- Inicializar todas as entradas
        reset  <= '0';
        enable <= '0';
        d_16   <= (others => '0');
        d_32   <= (others => '0');
        d_64   <= (others => '0');
        wait for CLK_PERIOD;

        report "Iniciando bateria de testes";

        -- Teste 1: Teste de enable com diferentes dados de entrada
        enable <= '1';
        
        -- Padrão de teste 1: Todos uns
        d_16 <= (others => '1');
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD;
        
        assert q_16 = X"FFFF" report "Teste de apenas uns do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"FFFFFFFF" report "Teste de apenas uns do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Teste de apenas uns do registrador de 64 bits falhou!" severity error;
        
        -- Padrão de teste 2: Todos 0s
        d_16 <= (others => '0');
        d_32 <= (others => '0');
        d_64 <= (others => '0');
        wait for CLK_PERIOD;
        
        assert q_16 = X"0000" report "Teste de apenas zeros do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"00000000" report "Teste de apenas zeros do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"0000000000000000" report "Teste de apenas zeros do registrador de 64 bits falhou!" severity error;

        -- Padrão de teste 3: Bits alternados
        d_16 <= X"AAAA";
        d_32 <= X"AAAAAAAA";
        d_64 <= X"AAAAAAAAAAAAAAAA";
        wait for CLK_PERIOD;
        
        assert q_16 = X"AAAA" report "Teste de bits alternados do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"AAAAAAAA" report "Teste de bits alternados do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Teste de bits alternados do registrador de 64 bits falhou!" severity error;
        

        -- Teste 2: Funcionalidade de desabilitar
        enable <= '0';
        d_16 <= (others => '1');
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD;
        
        assert q_16 = X"AAAA" report "Teste de disable do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"AAAAAAAA" report "Teste de disable do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Teste de disable do registrador de 64 bits falhou!" severity error;
        
        -- Teste 3: Re-habilitar e capturar novos dados
        enable <= '1';
        wait for CLK_PERIOD;
        
        assert q_16 = X"FFFF" report "Teste de re-enable do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"FFFFFFFF" report "Teste de re-enable do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Teste de re-enable do registrador de 64 bits falhou!" severity error;
        
        -- Teste 4: Teste de Reset
        reset <= '1';
        wait for CLK_PERIOD;
        
        assert q_16 = X"0000" report "Reset do registrador de 16 bits falhou!" severity error;
        assert q_32 = X"00000000" report "Reset do registrador de 32 bits falhou!" severity error;
        assert q_64 = X"0000000000000000" report "Reset do registrador de 64 bits falhou!" severity error;
        
        report "Testes finalizados!";
        
        simulando <= '0';
        report "Simulação finalizada" severity note;
        wait;
    end process;

end architecture testbench;