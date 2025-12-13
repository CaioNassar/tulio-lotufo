library ieee;
use ieee.numeric_bit.all;

entity tb_sign_extend is
end entity;

architecture tb of tb_sign_extend is
constant I : natural := 32;
constant O : natural := 64;
constant P : natural := 5;

signal inData      : bit_vector(I-1 downto 0) := (others => '0');
signal inDataStart : bit_vector(P-1 downto 0) := (others => '0');
signal inDataEnd   : bit_vector(P-1 downto 0) := (others => '0');
signal outData     : bit_vector(O-1 downto 0);

function bv(n : natural) return bit_vector is
begin
return bit_vector(to_unsigned(n, P));
end function;

function exp(v : bit_vector; bits : natural; s : bit) return bit_vector is
variable r : bit_vector(O-1 downto 0);
variable i : integer;
begin
  r := (others => s);
  for i in 0 to integer(bits)-1 loop
    r(i) := v(i);
  end loop;
  return r;
  end function;

begin
  dut: entity work.sign_extend(se)
    generic map(dataISize => I, dataOSize => O, dataMaxPosition => P)
    port map(inData => inData, inDataStart => inDataStart, inDataEnd => inDataEnd, outData => outData);

  process
  begin
    inData <= (others => '0'); inData(3 downto 0) <= "0101";
    inDataStart <= bv(3); inDataEnd <= bv(0); wait for 1 ns;
    assert outData = exp("0101", 4, '0') severity error;

    inData <= (others => '0'); inData(3 downto 0) <= "1001";
    inDataStart <= bv(3); inDataEnd <= bv(0); wait for 1 ns;
    assert outData = exp("1001", 4, '1') severity error;

    inData <= (others => '0'); inData(20 downto 12) <= "001101011";
    inDataStart <= bv(20); inDataEnd <= bv(12); wait for 1 ns;
    assert outData = exp("001101011", 9, '0') severity error;

    inData <= (others => '0'); inData(23) <= '1';
    inDataStart <= bv(23); inDataEnd <= bv(5); wait for 1 ns;
    assert outData = (others => '1') severity error;

    inData <= (others => '0'); inData(5) <= '0';
    inDataStart <= bv(5); inDataEnd <= bv(5); wait for 1 ns;
    assert outData = (others => '0') severity error;

    inData <= (others => '0'); inData(5) <= '1';
    inDataStart <= bv(5); inDataEnd <= bv(5); wait for 1 ns;
    assert outData = (others => '1') severity error;

    wait;
  end process;

end architecture;
