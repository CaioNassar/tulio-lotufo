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