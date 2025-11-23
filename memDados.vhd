library ieee;
library std;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaDados is
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
end entity memoriaDados;

architecture dados of memoriaDados is
  type mem_tipo is array(0 to 2**addressSize - 1) of bit_vector(dataSize - 1 downto 0);

  impure function init_mem return mem_tipo is
    file     arquivo  : text open read_mode is datFileName;
    variable linha    : line;
    variable mem_cont : mem_tipo;
    variable temp_bv  : bit_vector(dataSize-1 downto 0);
    variable i        : integer := 0;

  begin

    for j in mem_cont'range loop
      mem_cont(j) := (others => '0');
    end loop;

    while not endfile(arquivo) and i < mem_cont'length loop
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
          mem(to_integer(unsigned(addr))) <= data_i;
        end if;
      end if;
    end process write_process;

  data_o <= mem(to_integer(unsigned(addr)));

end architecture dados;
