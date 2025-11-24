entity mux_32x1_n is
    generic (constant BITS: integer);
    port ( 
        D0    : in  bit_vector (BITS-1 downto 0);
        D1    : in  bit_vector (BITS-1 downto 0);
        D2    : in  bit_vector (BITS-1 downto 0);
        D3    : in  bit_vector (BITS-1 downto 0);
        D4    : in  bit_vector (BITS-1 downto 0);
        D5    : in  bit_vector (BITS-1 downto 0);
        D6    : in  bit_vector (BITS-1 downto 0);
        D7    : in  bit_vector (BITS-1 downto 0);
        D8    : in  bit_vector (BITS-1 downto 0);
        D9    : in  bit_vector (BITS-1 downto 0);
        D10   : in  bit_vector (BITS-1 downto 0);
        D11   : in  bit_vector (BITS-1 downto 0);
        D12   : in  bit_vector (BITS-1 downto 0);
        D13   : in  bit_vector (BITS-1 downto 0);
        D14   : in  bit_vector (BITS-1 downto 0);
        D15   : in  bit_vector (BITS-1 downto 0);
        D16   : in  bit_vector (BITS-1 downto 0);
        D17   : in  bit_vector (BITS-1 downto 0);
        D18   : in  bit_vector (BITS-1 downto 0);
        D19   : in  bit_vector (BITS-1 downto 0);
        D20   : in  bit_vector (BITS-1 downto 0);
        D21   : in  bit_vector (BITS-1 downto 0);
        D22   : in  bit_vector (BITS-1 downto 0);
        D23   : in  bit_vector (BITS-1 downto 0);
        D24   : in  bit_vector (BITS-1 downto 0);
        D25   : in  bit_vector (BITS-1 downto 0);
        D26   : in  bit_vector (BITS-1 downto 0);
        D27   : in  bit_vector (BITS-1 downto 0);
        D28   : in  bit_vector (BITS-1 downto 0);
        D29   : in  bit_vector (BITS-1 downto 0);
        D30   : in  bit_vector (BITS-1 downto 0);
        D31   : in  bit_vector (BITS-1 downto 0);
        SEL   : in  bit_vector (4 downto 0);
        SAIDA : out bit_vector (BITS-1 downto 0)
    );
end entity mux_32x1_n;

architecture behavioral of mux_32x1_n is
begin
    with SEL select SAIDA <=
        D0  when "00000",
        D1  when "00001",
        D2  when "00010",
        D3  when "00011",
        D4  when "00100",
        D5  when "00101",
        D6  when "00110",
        D7  when "00111",
        D8  when "01000",
        D9  when "01001",
        D10 when "01010",
        D11 when "01011",
        D12 when "01100",
        D13 when "01101",
        D14 when "01110",
        D15 when "01111",
        D16 when "10000",
        D17 when "10001",
        D18 when "10010",
        D19 when "10011",
        D20 when "10100",
        D21 when "10101",
        D22 when "10110",
        D23 when "10111",
        D24 when "11000",
        D25 when "11001",
        D26 when "11010",
        D27 when "11011",
        D28 when "11100",
        D29 when "11101",
        D30 when "11110",
        D31 when "11111",
        (others => '0') when others;
end architecture behavioral;
