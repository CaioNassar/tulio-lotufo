library ieee;
library std;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
  generic (
    addressSize : natural := 8;
    dataSize    : natural := 8;
    datFileName : string  := "memInstr_conteudo.dat"
  );
  port (
    addr : in  bit_vector (addressSize-1 downto 0);
    data : out bit_vector (dataSize-1 downto 0)
  );
end entity memoriaInstrucoes;
-------------------------------------------------------
architecture instrucao of memoriaInstrucoes is
    type mem_tipo is array(0 to 2**addressSize - 1) of bit_vector(dataSize-1 downto 0);
    
    impure function init_mem(nome_do_arquivo : in string) return mem_tipo is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem_tipo;
    begin
        for i in mem_tipo'range loop
            readline(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end function init_mem;

    signal mem : mem_tipo := init_mem("memInstr_conteudo.dat");

begin
    data <= mem(to_integer(unsigned(addr)));
    

end architecture instrucao;