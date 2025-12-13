library ieee;
use ieee.numeric_bit.all;

entity fluxoDados is
  port(
    clock        : in  bit;
    reset        : in  bit;
    extendMSB    : in  bit_vector(4 downto 0);
    extendLSB    : in  bit_vector(4 downto 0);
    reg2Loc      : in  bit;
    regWrite     : in  bit;
    aluSrc       : in  bit;
    alu_control  : in  bit_vector(3 downto 0);
    branch       : in  bit;
    uncondBranch : in  bit;
    memRead      : in  bit;
    memWrite     : in  bit;
    memToReg     : in  bit;
    opcode       : out bit_vector(10 downto 0)
  );
end entity fluxoDados;

architecture fluxoDadosArch of fluxoDados is

  constant ZERO64 : bit_vector(63 downto 0) := (others => '0');
  constant FOUR64 : bit_vector(63 downto 0) := x"0000000000000004";

  component reg is
    generic (dataSize : natural := 64);
    port(
      clock  : in  bit;
      reset  : in  bit;
      enable : in  bit;
      d      : in  bit_vector(dataSize-1 downto 0);
      q      : out bit_vector(dataSize-1 downto 0)
    );
  end component;

  component mux_n is
    generic (dataSize : natural := 64);
    port(
      in0  : in  bit_vector(dataSize-1 downto 0);
      in1  : in  bit_vector(dataSize-1 downto 0);
      sel  : in  bit;
      dOut : out bit_vector(dataSize-1 downto 0)
    );
  end component;

  component memoriaInstrucoes is
    generic(
      addressSize : natural := 8;
      dataSize    : natural := 8;
      datFileName : string  := "memInstr_conteudo.dat"
    );
    port(
      addr : in  bit_vector(addressSize-1 downto 0);
      data : out bit_vector(dataSize-1 downto 0)
    );
  end component;

  component memDados is
    generic(
      addressSize : natural := 8;
      dataSize    : natural := 8;
      datFileName : string  := "memDados_conteudo_inicial.dat"
    );
    port(
      clock  : in  bit;
      wr     : in  bit;
      addr   : in  bit_vector(addressSize-1 downto 0);
      data_i : in  bit_vector(dataSize-1 downto 0);
      data_o : out bit_vector(dataSize-1 downto 0)
    );
  end component;

  component regfile is
    port(
      clock    : in  bit;
      reset    : in  bit;
      regWrite : in  bit;
      rr1      : in  bit_vector(4 downto 0);
      rr2      : in  bit_vector(4 downto 0);
      wr       : in  bit_vector(4 downto 0);
      d        : in  bit_vector(63 downto 0);
      q1       : out bit_vector(63 downto 0);
      q2       : out bit_vector(63 downto 0)
    );
  end component;

  component ula is
    port(
      A  : in  bit_vector(63 downto 0);
      B  : in  bit_vector(63 downto 0);
      S  : in  bit_vector(3 downto 0);
      F  : out bit_vector(63 downto 0);
      Z  : out bit;
      Ov : out bit;
      Co : out bit
    );
  end component;

  component sign_extend is
    generic(
      dataISize       : natural := 32;
      dataOSize       : natural := 64;
      dataMaxPosition : natural := 5
    );
    port(
      inData      : in  bit_vector(dataISize-1 downto 0);
      inDataStart : in  bit_vector(dataMaxPosition-1 downto 0);
      inDataEnd   : in  bit_vector(dataMaxPosition-1 downto 0);
      outData     : out bit_vector(dataOSize-1 downto 0)
    );
  end component;

  component adder_n is
    generic(dataSize : natural := 64);
    port(
      in0  : in  bit_vector(dataSize-1 downto 0);
      in1  : in  bit_vector(dataSize-1 downto 0);
      sum  : out bit_vector(dataSize-1 downto 0);
      cOut : out bit
    );
  end component;

  signal pc_q7     : bit_vector(6 downto 0);
  signal pc_d7     : bit_vector(6 downto 0);

  signal pc_q64    : bit_vector(63 downto 0);
  signal pc_next64 : bit_vector(63 downto 0);
  signal pc_plus4  : bit_vector(63 downto 0);
  signal pc_branch : bit_vector(63 downto 0);
  signal pc_src    : bit;

  signal instr     : bit_vector(31 downto 0);

  signal rr1       : bit_vector(4 downto 0);
  signal rr2_a     : bit_vector(4 downto 0);
  signal rr2_b     : bit_vector(4 downto 0);
  signal rr2       : bit_vector(4 downto 0);
  signal wr        : bit_vector(4 downto 0);

  signal q1        : bit_vector(63 downto 0);
  signal q2        : bit_vector(63 downto 0);

  signal imm64     : bit_vector(63 downto 0);
  signal imm64_sl2 : bit_vector(63 downto 0);

  signal alu_b     : bit_vector(63 downto 0);
  signal alu_f     : bit_vector(63 downto 0);
  signal alu_z     : bit;

  signal dmem_addr7 : bit_vector(6 downto 0);
  signal dmem_raw   : bit_vector(63 downto 0);
  signal dmem_rd    : bit_vector(63 downto 0);
  signal wb_data    : bit_vector(63 downto 0);

  signal c_pc4  : bit;
  signal c_br   : bit;

begin

  pc_q64 <= (63 downto 7 => '0') & pc_q7;

  opcode <= instr(31 downto 21);

  rr1   <= instr(9 downto 5);
  rr2_a <= instr(20 downto 16);
  rr2_b <= instr(4 downto 0);
  wr    <= instr(4 downto 0);

  dmem_addr7 <= alu_f(6 downto 0);

  pc_src <= (uncondBranch) or (branch and alu_z);

  imm64_sl2 <= imm64(61 downto 0) & "00";

  u_pc : reg
    generic map(dataSize => 7)
    port map(
      clock  => clock,
      reset  => reset,
      enable => '1',
      d      => pc_d7,
      q      => pc_q7
    );

  u_imem : memoriaInstrucoes
    generic map(
      addressSize => 7,
      dataSize    => 32,
      datFileName => "memInstrPolilegV8.dat"
    )
    port map(
      addr => pc_q7,
      data => instr
    );
    
  u_mux_rr2 : mux_n
    generic map(dataSize => 5)
    port map(
      in0  => rr2_a,
      in1  => rr2_b,
      sel  => reg2Loc,
      dOut => rr2
    );

  u_regfile : regfile
    port map(
      clock    => clock,
      reset    => reset,
      regWrite => regWrite,
      rr1      => rr1,
      rr2      => rr2,
      wr       => wr,
      d        => wb_data,
      q1       => q1,
      q2       => q2
    );

  u_sext : sign_extend
    generic map(
      dataISize       => 32,
      dataOSize       => 64,
      dataMaxPosition => 5
    )
    port map(
      inData      => instr,
      inDataStart => extendMSB,
      inDataEnd   => extendLSB,
      outData     => imm64
    );

  u_mux_alub : mux_n
    generic map(dataSize => 64)
    port map(
      in0  => q2,
      in1  => imm64,
      sel  => aluSrc,
      dOut => alu_b
    );

  u_alu : ula
    port map(
      A  => q1,
      B  => alu_b,
      S  => alu_control,
      F  => alu_f,
      Z  => alu_z,
      Ov => open,
      Co => open
    );

  u_dmem : memDados
    generic map(
      addressSize => 7,
      dataSize    => 64,
      datFileName => "memDadosInicialPolilegV8.dat"
    )
    port map(
      clock  => clock,
      wr     => memWrite,
      addr   => dmem_addr7,
      data_i => q2,
      data_o => dmem_raw
    );

  u_mux_memread : mux_n
    generic map(dataSize => 64)
    port map(
      in0  => ZERO64,
      in1  => dmem_raw,
      sel  => memRead,
      dOut => dmem_rd
    );

  u_mux_wb : mux_n
    generic map(dataSize => 64)
    port map(
      in0  => alu_f,
      in1  => dmem_rd,
      sel  => memToReg,
      dOut => wb_data
    );

  u_add_pc4 : adder_n
    generic map(dataSize => 64)
    port map(
      in0  => pc_q64,
      in1  => FOUR64,
      sum  => pc_plus4,
      cOut => c_pc4
    );

  u_add_branch : adder_n
    generic map(dataSize => 64)
    port map(
      in0  => pc_plus4,
      in1  => imm64_sl2,
      sum  => pc_branch,
      cOut => c_br
    );

  u_mux_pc : mux_n
    generic map(dataSize => 64)
    port map(
      in0  => pc_plus4,
      in1  => pc_branch,
      sel  => pc_src,
      dOut => pc_next64
    );

  pc_d7 <= pc_next64(6 downto 0);

end architecture fluxoDadosArch;

