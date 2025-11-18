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