entity regfile is
  port(
    clock        : in bit;
    reset        : in bit;
    regWrite     : in bit;
    rr1          : in bit_vector(4 downto 0);
    rr2          : in bit_vector(4 downto 0);
    wr           : in bit_vector(4 downto 0);
    d            : in bit_vector(63 downto 0);
    q1           : out bit_vector(63 downto 0);
    q2           : out bit_vector(63 downto 0);
    
