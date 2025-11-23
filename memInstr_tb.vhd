library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity tb_memoriaInstrucoes is
end entity tb_memoriaInstrucoes;

architecture test_cases of tb-memoriaInstrucoes is

    component memoriaInstrucoes is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memInstr_conteudo.dat"
        );
        port (
            addr : in  bit_vector (addressSize-1 downto 0);
            data : out bit_vector (dataSize-1 downto 0)
        );
    end component memoriaInstrucoes;

    -- Como o arquivo .dat tem 64 linhas, o addressSize deve ser igual a 6 (2^6 = 64).
    -- Tamanho da palavra (8 bits)
    constant T_ADDR : natural := 6; 
    constant T_DATA : natural := 8; 

    -- Sinais
    signal s_addr : bit_vector(T_ADDR-1 downto 0) := (others => '0');
    signal s_data : bit_vector(T_DATA-1 downto 0);

    constant DELAY : time := 10 us;

begin

    dut : memoriaInstrucoes
        generic map (
            addressSize => T_ADDR,  
            dataSize    => T_DATA,
            datFileName => "memInstr_conteudo.dat"
        )
        port map (
            addr => s_addr,
            data => s_data
        );

    gera_estimulos : process
    begin
        wait for DELAY;
        report "Inicio do Testbench para memoriaInstrucoes." severity note;

        -- ==========================================================
        -- Leitura Sequencial
        -- ==========================================================

        for i in 0 to (2**T_ADDR - 1) loop
            -- 1. Coloca o endereço no barramento
            s_addr <= bit_vector(to_unsigned(i, T_ADDR));
            
            -- 2. Aguarda a memória responder
            wait for DELAY;

            -- 3. Reporta o valor lido no console para conferência manual
            report "Addr: " & integer'image(i) & 
                   " | Data Read (Int): " & integer'image(to_integer(unsigned(s_data)));
        end loop;

        report "Fim dos testes." severity note;
        wait; 
    end process gera_estimulos;

end architecture test_cases;