library ieee;
use ieee.numeric_bit.all;

entity tb_memDados is
end entity tb_memDados;

architecture test_cases of tb_memDados is

    component memDados is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memDados_conteudo_inicial.dat"
        );
        port (
            clock  : in  bit;
            wr     : in  bit;
            addr   : in  bit_vector (addressSize-1 downto 0);
            data_i : in  bit_vector (dataSize-1 downto 0);
            data_o : out bit_vector (dataSize-1 downto 0)
        );
    end component memDados;

    -- Configurações
    constant T_ADDR : natural := 4; -- Vamos testar com 4 bits (16 posições)
    constant T_DATA : natural := 4;

    -- Sinais (Tudo BIT agora)
    signal s_clock   : bit := '0';
    signal s_wr      : bit := '0'; -- Write Enable (Ativo Alto na sua implementação)
    signal s_addr    : bit_vector(T_ADDR-1 downto 0) := (others => '0');
    signal s_data_i  : bit_vector(T_DATA-1 downto 0) := (others => '0');
    signal s_data_o  : bit_vector(T_DATA-1 downto 0);

    constant CLK_PERIOD    : time := 10 us;
    signal keep_simulating : bit := '0';

begin

   
    s_clock <= not(s_clock) and keep_simulating after CLK_PERIOD/2;

    dut : memDados
        generic map (
            addressSize => T_ADDR,
            dataSize    => T_DATA,
            datFileName => "preenche_tb.dat"
        )
        port map (
            clock  => s_clock,
            wr     => s_wr, 
            addr   => s_addr,
            data_i => s_data_i,
            data_o => s_data_o
        );

    gera_estimulos : process
        variable expected : bit_vector(T_DATA-1 downto 0);
    begin
        keep_simulating <= '1';
        wait for CLK_PERIOD;
        report "Inicio do Testbench para memDados." severity note;

        -- ==========================================================
        -- FASE 1: Escrita (Escreve 15-i no endereço i)
        -- ==========================================================
        report "Fase de Escrita..." severity note;
        s_wr     <= '1';
        wait until s_clock = '1';

        for i in 0 to 15 loop
            s_addr   <= bit_vector(to_unsigned(i, T_ADDR));
            s_data_i <= bit_vector(to_unsigned(15 - i, T_DATA));
            wait until s_clock = '1';
        end loop;


        -- ==========================================================
        -- FASE 2: Leitura e Verificação
        -- ==========================================================
        report "Fase de Leitura..." severity note;
        s_wr <= '0';
        wait until s_clock = '1';

        for i in 0 to 15 loop
            -- Seleciona Endereço
            s_addr <= bit_vector(to_unsigned(i, T_ADDR));
            
            -- Espera até que o dado seja lido e propagado para a saida (assíncrono)
            wait for CLK_PERIOD;

            expected := bit_vector(to_unsigned(15 - i, T_DATA));

            assert s_data_o = expected
                report "Caso de Teste " & integer'image(i) &
                " NOK: esperado " & integer'image(to_integer(unsigned(expected))) & 
                " mas foi lido " & integer'image(to_integer(unsigned(s_data_o)))
                severity error;
        end loop;

        keep_simulating <= '0';
        report "Fim dos testes." severity note;
        wait;
    end process gera_estimulos;

end architecture test_cases;