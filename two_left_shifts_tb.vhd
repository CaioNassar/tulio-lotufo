entity testbench_tls is
generic (dataSize: natural := 64);
end testbench_tls;

architecture deslocadorEsqDois of testbench_tls is
component two_left_shifts is
    port (
        input : in bit_vector(dataSize-1 downto 0);
        output : out bit_vector(dataSize-1 downto 0)  
    );
end component;

    signal a_in, b_out : bit_vector(dataSize-1 downto 0);

    begin

    DUT: two_left_shifts port map (input => a_in, output => b_out);

deslocador: process
begin

    a_in <= "0000000000000000000000000000000000000000000000000000000000000001";
    wait for 1 ns;
    assert(b_out = "0000000000000000000000000000000000000000000000000000000000000100") report "Fail zerar" severity error;

    a_in <= "0000000000000000000000000000000000000000000000000000000000001010";
    wait for 1 ns;
    assert(b_out = "0000000000000000000000000000000000000000000000000000000000101000") report "Fail empurrar final" severity error;
    
    a_in <= "1000000000000000000000000000000000000000000000000000000000000001";
    wait for 1 ns;
    assert(b_out = "0000000000000000000000000000000000000000000000000000000000000100") report "Fail zerar inicio" severity error;



assert false report "Test done." severity note;
wait;

end process;

end deslocadorEsqDois;
