entity testbench_ad is
generic (dataSize: natural := 64);
end testbench_ad;

architecture adder_nbits_tb of testbench_ad is
component adder_n is
    port (
        in0 : in bit_vector(dataSize-1 downto 0);
        in1 : in bit_vector(dataSize-1 downto 0);
        sum : out bit_vector(dataSize-1 downto 0);
        Cout : out bit
    );
end component;
    signal a_in0, b_in1, soma_out : bit_vector(dataSize-1 downto 0);
    signal c_out : bit;

    begin

    DUT: adder_n port map (in0 => a_in0, in1 => b_in1, sum => soma_out, Cout => c_out);

somador: process
begin
    --soma básica
    a_in0 <= "0000000000000000000000000000000000000000000000000000000000000001";
    b_in1 <= "0000000000000000000000000000000000000000000000000000000000000010";
    wait for 1 ns;
    assert (c_out & soma_out = "00000000000000000000000000000000000000000000000000000000000000011") report "Fail 1+2" severity error;

    -- soma 64+64
    a_in0 <= "0000000000000000000000000000000000000000000000000000000001000000";
    b_in1 <= "0000000000000000000000000000000000000000000000000000000001000000";
    wait for 1 ns;
    assert (c_out & soma_out = "00000000000000000000000000000000000000000000000000000000010000000") report "Fail 64+64" severity error;

    --soma testando unsigned
    a_in0 <= "1000000000000000000000000000000000000000000000000000000000001000";
    b_in1 <= "1000000000000000000000000000000000000000000000000000000000000001";
    wait for 1 ns;
    assert (c_out & soma_out = "10000000000000000000000000000000000000000000000000000000000001001") report "Fail números grandes" severity error;

    assert false report "Test done." severity note;	
    wait;
end process;

end  adder_nbits_tb;
