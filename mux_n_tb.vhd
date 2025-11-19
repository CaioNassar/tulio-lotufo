-- Testbench para mux_n
entity mux_n_tb is
end entity mux_n_tb;

architecture testbench of mux_n_tb is
    -- Constante
    constant dataSize : natural := 64;

    -- Sinais de teste
    signal in0 : bit_vector(dataSize-1 downto 0);
    signal in1 : bit_vector(dataSize-1 downto 0);
    signal sel : bit;
    signal dOut : bit_vector(dataSize-1 downto 0);
    
    -- Componente a ser testado (com correção)
    component mux_n is
        generic (dataSize: natural := 64);
        port (
            in0 : in bit_vector(dataSize-1 downto 0);
            in1 : in bit_vector(dataSize-1 downto 0);
            sel : in bit;
            dOut : out bit_vector(dataSize-1 downto 0)
        );
    end component mux_n;
    
begin
    -- Instância do DUT (Device Under Test)
    DUT: mux_n
        generic map (dataSize => dataSize)
        port map (
            in0 => in0,
            in1 => in1,
            sel => sel,
            dOut => dOut
        );
    
    -- Processo de estímulo
    stimulus: process
    begin
        -- Valores de teste
        in0 <= X"AAAAAAAAAAAAAAAA";  -- Padrão AAAA...
        in1 <= X"5555555555555555";  -- Padrão 5555...
        
        -- Teste 1: sel = '0' -> saída deve ser in0
        sel <= '0';
        wait for 10 ns;
        assert dOut = in0
            report "Erro: sel='0' mas saída não é in0"
            severity error;
        
        -- Teste 2: sel = '1' -> saída deve ser in1
        sel <= '1';
        wait for 10 ns;
        assert dOut = in1
            report "Erro: sel='1' mas saída não é in1"
            severity error;
        
        -- Teste 3: sel = '0' novamente
        sel <= '0';
        wait for 10 ns;
        assert dOut = in0
            report "Erro: sel='0' mas saída não é in0"
            severity error;
        
        -- Teste com outros valores
        in0 <= X"FFFFFFFFFFFFFFFF";  -- Todos 1s
        in1 <= X"0000000000000000";  -- Todos 0s
        
        wait for 10 ns;
        
        sel <= '1';
        wait for 10 ns;
        assert dOut = in1
            report "Erro: sel='1' mas saída não é in1 (teste com novos valores)"
            severity error;
        
        sel <= '0';
        wait for 10 ns;
        assert dOut = in0
            report "Erro: sel='0' mas saída não é in0 (teste com novos valores)"
            severity error;
        
        -- Finalização do teste
        report "Testbench concluído!" severity note;
        wait;
    end process stimulus;

end architecture testbench;
