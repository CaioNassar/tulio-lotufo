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

architecture arch_regfile of regfile is

    component reg is
    generic(dataSize: natural);
    port(
        clock  : in  bit;
        reset  : in  bit;
        enable : in  bit;
        d      : in  bit_vector(dataSize-1 downto 0);
        q      : out bit_vector(dataSize-1 downto 0)
    );
    end component;

    component decodificador_5x32 is
    port (
        sel   : in  bit_vector (4 downto 0);
        saida : out bit_vector (31 downto 0)
    );
    end component;

    component mux_32x1_n is
    generic (constant BITS: integer);
    port ( 
        D0    : in  bit_vector (BITS-1 downto 0);
        D1    : in  bit_vector (BITS-1 downto 0);
        D2    : in  bit_vector (BITS-1 downto 0);
        D3    : in  bit_vector (BITS-1 downto 0);
        D4    : in  bit_vector (BITS-1 downto 0);
        D5    : in  bit_vector (BITS-1 downto 0);
        D6    : in  bit_vector (BITS-1 downto 0);
        D7    : in  bit_vector (BITS-1 downto 0);
        D8    : in  bit_vector (BITS-1 downto 0);
        D9    : in  bit_vector (BITS-1 downto 0);
        D10   : in  bit_vector (BITS-1 downto 0);
        D11   : in  bit_vector (BITS-1 downto 0);
        D12   : in  bit_vector (BITS-1 downto 0);
        D13   : in  bit_vector (BITS-1 downto 0);
        D14   : in  bit_vector (BITS-1 downto 0);
        D15   : in  bit_vector (BITS-1 downto 0);
        D16   : in  bit_vector (BITS-1 downto 0);
        D17   : in  bit_vector (BITS-1 downto 0);
        D18   : in  bit_vector (BITS-1 downto 0);
        D19   : in  bit_vector (BITS-1 downto 0);
        D20   : in  bit_vector (BITS-1 downto 0);
        D21   : in  bit_vector (BITS-1 downto 0);
        D22   : in  bit_vector (BITS-1 downto 0);
        D23   : in  bit_vector (BITS-1 downto 0);
        D24   : in  bit_vector (BITS-1 downto 0);
        D25   : in  bit_vector (BITS-1 downto 0);
        D26   : in  bit_vector (BITS-1 downto 0);
        D27   : in  bit_vector (BITS-1 downto 0);
        D28   : in  bit_vector (BITS-1 downto 0);
        D29   : in  bit_vector (BITS-1 downto 0);
        D30   : in  bit_vector (BITS-1 downto 0);
        D31   : in  bit_vector (BITS-1 downto 0);
        SEL   : in  bit_vector (4 downto 0);
        SAIDA : out bit_vector (BITS-1 downto 0)
    );
    end component;

    signal s_decod  : bit_vector(31 downto 0);
    signal s_enable : bit_vector(31 downto 0);
    
    -- saidas dos registradores
    type regfile_tipo is array (0 to 31) of bit_vector(63 downto 0);
    signal s_regs: regfile_tipo;

begin

    -- Gera 31 registradores normais (X0 a X30)
    regs: for i in 0 to 30 generate
        regX: reg generic map (dataSize => 64)
                  port map (
                     clock  => clock,
                     reset  => reset,
                     enable => s_enable(i),
                     d      => d,
                     q      => s_regs(i)
                  );
    end generate;
    
    -- Registrador X31 (XZR) - sempre retorna zero
    s_regs(31) <= (others => '0');

    -- multiplexador 1 - leitura assíncrona do registrador rr1
    mux1: mux_32x1_n generic map (BITS => 64)
                    port map (
                        D0    => s_regs(0),
                        D1    => s_regs(1),
                        D2    => s_regs(2),
                        D3    => s_regs(3),
                        D4    => s_regs(4),
                        D5    => s_regs(5),
                        D6    => s_regs(6),
                        D7    => s_regs(7),
                        D8    => s_regs(8),
                        D9    => s_regs(9),
                        D10   => s_regs(10),
                        D11   => s_regs(11),
                        D12   => s_regs(12),
                        D13   => s_regs(13),
                        D14   => s_regs(14),
                        D15   => s_regs(15),
                        D16   => s_regs(16),
                        D17   => s_regs(17),
                        D18   => s_regs(18),
                        D19   => s_regs(19),
                        D20   => s_regs(20),
                        D21   => s_regs(21),
                        D22   => s_regs(22),
                        D23   => s_regs(23),
                        D24   => s_regs(24),
                        D25   => s_regs(25),
                        D26   => s_regs(26),
                        D27   => s_regs(27),
                        D28   => s_regs(28),
                        D29   => s_regs(29),
                        D30   => s_regs(30),
                        D31   => s_regs(31),
                        SEL   => rr1,
                        SAIDA => q1
                    );
    
    -- multiplexador 2 - leitura assíncrona do registrador rr2
    mux2: mux_32x1_n generic map (BITS => 64)
                    port map (
                        D0    => s_regs(0),
                        D1    => s_regs(1),
                        D2    => s_regs(2),
                        D3    => s_regs(3),
                        D4    => s_regs(4),
                        D5    => s_regs(5),
                        D6    => s_regs(6),
                        D7    => s_regs(7),
                        D8    => s_regs(8),
                        D9    => s_regs(9),
                        D10   => s_regs(10),
                        D11   => s_regs(11),
                        D12   => s_regs(12),
                        D13   => s_regs(13),
                        D14   => s_regs(14),
                        D15   => s_regs(15),
                        D16   => s_regs(16),
                        D17   => s_regs(17),
                        D18   => s_regs(18),
                        D19   => s_regs(19),
                        D20   => s_regs(20),
                        D21   => s_regs(21),
                        D22   => s_regs(22),
                        D23   => s_regs(23),
                        D24   => s_regs(24),
                        D25   => s_regs(25),
                        D26   => s_regs(26),
                        D27   => s_regs(27),
                        D28   => s_regs(28),
                        D29   => s_regs(29),
                        D30   => s_regs(30),
                        D31   => s_regs(31),
                        SEL   => rr2,
                        SAIDA => q2
                    );

    -- decodificador para endereço de escrita
    decod: decodificador_5x32 port map (
               sel   => wr,
               saida => s_decod
           );

    -- controle de habilitação de escrita (X31 nunca é habilitado)
    write_control: process(regWrite, s_decod)
    begin
        s_enable <= (others => '0');
        if regWrite = '1' then
            for i in 0 to 30 loop
                s_enable(i) <= s_decod(i);
            end loop;
            -- s_enable(31) permanece '0' (X31 nunca escrito)
        end if;
    end process;
    
end architecture arch_regfile;
