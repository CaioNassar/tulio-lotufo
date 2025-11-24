entity regfile is
  port(
    clock        : in bit;                      -- entrada de clock
    reset        : in bit;                      -- entrada de reset
    regWrite     : in bit;                      -- entrada de carga do registrador wr
    rr1          : in bit_vector(4 downto 0);   -- entrada define registrador 1
    rr2          : in bit_vector(4 downto 0);   -- entrada define registrador 2
    wr           : in bit_vector(4 downto 0);   -- entrada define registrador de escrita
    d            : in bit_vector(63 downto 0);  -- entrada de dado para carga pararela
    q1           : out bit_vector(63 downto 0); -- saida do registrador rr1
    q2           : out bit_vector(63 downto 0)  -- saida do registrador rr2
  );
end entity regfile;
