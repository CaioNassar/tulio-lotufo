library ieee;
library std;
use ieee.numeric_bit.all;
use std.textio.all;

entity reg is
  generic (dataSize: natural := 64);
  port (
    clock  : in  bit;  -- entrada de clock 
    reset  : in  bit;  -- clear assincrono 
    enable : in  bit;  -- write enable (carga paralela) 
    d      : in  bit_vector(dataSize-1 downto 0); -- entrada
    q      : out bit_vector(dataSize-1 downto 0)  -- saida
  );
end entity reg;

architecture registrador of reg is
    signal q_interno : bit_vector(dataSize-1 downto 0);

begin

    process (clock, reset)
    begin
    
    
    if reset = '1' then
        q_interno <= (others => '0');
    elsif clock = '1' and clock'event then
        if enable = '1' then
            q_interno <= d;
        end if;
    end if;
end process;

q <= q_interno;

end architecture registrador;

entity mux_n is
  generic (dataSize: natural := 64);
  port (
    in0 : in  bit_vector(dataSize-1 downto 0); -- entrada de dados 0
    in1 : in  bit_vector(dataSize-1 downto 0); -- entrada de dados 1
    sel : in  bit;                             -- sinal de selecao
    dOut : out bit_vector(dataSize-1 downto 0) -- saida de dados
  );
end entity mux_n;

architecture mux of mux_n is
  begin
    dOut <= in0 when sel = '0' else in0;
end architecture mux;

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

architecture instrucao of memoriaInstrucoes is
    type mem_tipo is array(0 to 2**addressSize - 1) of bit_vector (dataSize-1 downto 0);
    
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

entity adder_n is
  generic (dataSize: natural := 64);
  port (
    in0  : in  bit_vector(dataSize-1 downto 0); -- primeira parcela
    in1  : in  bit_vector(dataSize-1 downto 0); -- segunda parcela
    sum  : out bit_vector(dataSize-1 downto 0); -- soma
    cOut : out bit 
  );
end entity adder_n;

 architecture somador_n_arq of adder_n is
    signal soma_C: bit_vector(dataSize downto 0);
begin
    soma_T <= bit_vector(unsigned('0' & in0)) + bit_vector(unsigned('0' & in1));
    sum <= soma_T(dataSize-1 downto 0);
    cOut <= soma_T(dataSize);
end somador_n_arq;


entity ula1bit is
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
end entity;

entity fulladder is

  port (
    a    : in  bit; 
    b    : in  bit; 
    cin  : in bit;
    s    : out bit;
    cout : out bit
  );
end entity fulladder;

entity sign_extend is
  generic (
    dataISize       : natural := 32;
    dataOSize       : natural := 64;
    dataMaxPosition : natural := 5 -- sempre fazer log2(dataISize)
  );
  port (
    inData      : in  bit_vector(dataISize-1 downto 0); -- dado de entrada
                  -- com tamanho datalSize
    inDataStart : in  bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit 
                  -- mais significativo do valor util na entrada (bit de sinal)
    inDataEnd   : in  bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit 
                  -- menos significativo do valor util na entrada
    outData     : out bit_vector(dataOSize-1 downto 0)  -- dado de saida 
                  -- com tamanho dataOSize e sinal estendido
  );
end entity sign_extend;

entity two_left_shifts is
  generic (
    dataSize : natural := 64
  );
  port (
    input  : in  bit_vector(dataSize-1 downto 0);
    output : out bit_vector(dataSize-1 downto 0)
  );
end entity two_left_shifts;
  
  architecture dois_shifts_arq of two_left_shifts is 
    signal deslocado : bit_vector(dataSize-1 downto 0);
    begin   
        deslocado <= input(dataSize-1 downto 2) & "00";
        output <= deslocado(dataSize-1 downto 0);
end dois_shifts_arq;

--se não der certo: implementar a multiplicação/divisão por 4
-- signal deslocado : bit_vector(dataSize-1 downto 0);
-- begin
-- deslocado <= unsigned(input
--output <= deslocado;
