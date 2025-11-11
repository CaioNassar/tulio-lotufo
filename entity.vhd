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

entity mux_n is
  generic (dataSize: natural := 64);
  port (
    in0 : in  bit_vector(dataSize-1 downto 0); -- entrada de dados 0
    in1 : in  bit_vector(dataSize-1 downto 0); -- entrada de dados 1
    sel : in  bit;                             -- sinal de selecao
    dOut : out bit_vector(dataSize-1 downto 0) -- saida de dados
  );
end entity mux_n;

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