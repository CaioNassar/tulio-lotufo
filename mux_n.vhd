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
    dOut <= in0 when sel = '0' else in1;
end architecture mux;
