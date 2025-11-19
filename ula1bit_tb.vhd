entity testbench_ula is
end testbench_ula;

architecture ula1bittb of testbench_ula is
component ula1bit is
    port (
    a         : in  bit;
    b         : in  bit;
    cin       : in  bit;
    ainvert   : in  bit;
    binvert   : in  bit;
    operation : in  bit_vector(1 downto 0);
    result    : out bit;
    cout      : out bit;
    overflow  : out bit
    );
end component;

    signal a_in, b_in, c_cin, a_inv, b_inv, operacao, r, c_cout, ofw : bit;

    begin

    DUT: ula1bit port map (
        a => a_in, 
        b => b_in,
        cin => c_cin,
        ainvert => a_inv,
        binvert => b_inv,
        operation => operacao,
        result => r,
        cout => c_cout,
        overflow => ofw
    );

testeULA: process
begin


    assert false report "Test done." severity note;	
    wait;

end process;

end ula1bittb;
