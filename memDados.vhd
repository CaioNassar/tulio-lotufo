library ieee;
library std;
use ieee.numeric_bit.all;
use std.textio.all;

entity memDados is
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
end entity memDados;

architecture dados of memDados is
  type mem_tipo is array(0 to (2**addressSize) - 1) of bit_vector(7 downto 0);

  impure function init_mem return mem_tipo is
    file     arquivo  : text open read_mode is datFileName;
    variable linha    : line;
    variable mem_cont : mem_tipo;
    variable temp_bv  : bit_vector(7 downto 0);
    variable i        : integer := 0;

  begin

    for j in mem_cont'range loop
      mem_cont(j) := (others => '0');
    end loop;

    while not endfile(arquivo) loop
      readline(arquivo, linha);
      read(linha, temp_bv);
      mem_cont(i) := temp_bv;
      i := i + 1;
    end loop;

    return mem_cont;
  end function;

  signal mem : mem_tipo := init_mem;

  begin
    write_process: process(clock)
    begin
      if clock'event and clock = '1' then
        if wr = '1' then
          mem(to_integer(unsigned(addr))+7) <= data_i(63 downto 56);
          mem(to_integer(unsigned(addr))+6) <= data_i(55 downto 48);
          mem(to_integer(unsigned(addr))+5) <= data_i(47 downto 40);
          mem(to_integer(unsigned(addr))+4) <= data_i(39 downto 32);
          mem(to_integer(unsigned(addr))+3) <= data_i(31 downto 24);
          mem(to_integer(unsigned(addr))+2) <= data_i(23 downto 16);
          mem(to_integer(unsigned(addr))+1) <= data_i(15 downto 8);
          mem(to_integer(unsigned(addr)))   <= data_i(7 downto 0);
        end if;
      end if;
    end process write_process;

  data_o <= mem(to_integer(unsigned(addr))) & mem(to_integer(unsigned(addr))+1) & mem(to_integer(unsigned(addr))+2) & mem(to_integer(unsigned(addr))+3) & mem(to_integer(unsigned(addr))+4) & mem(to_integer(unsigned(addr))+5) & mem(to_integer(unsigned(addr))+6) & mem(to_integer(unsigned(addr))+7);

end architecture dados;
