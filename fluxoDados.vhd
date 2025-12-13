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
  constant QUATRO64 : bit_vector(63 downto 0) := x"0000000000000004";

 -- Declaração dos Componentes

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

 -- Declaração dos Sinais

  signal pc_q7     : bit_vector(6 downto 0);  -- Conteúdo atual do PC (endereço da instrução atual, em bytes), armazenado no registrador PC
  signal pc_d7     : bit_vector(6 downto 0);  -- Próximo valor a ser carregado no PC no próximo clock (PC+4 ou alvo de branch), truncado para 7 bits

  signal pc_q64    : bit_vector(63 downto 0); -- PC atual zero-extendido para 64 bits, para permitir somas em 64 bits (adder_n é 64 bits)
  signal pc_next64 : bit_vector(63 downto 0); -- Próximo PC calculado em 64 bits (saída do mux de PC), antes do truncamento para pc_d7
  signal pc_plus4  : bit_vector(63 downto 0); -- Resultado de PC + 4 (incremento de 4 bytes por instrução) — endereço sequencial
  signal pc_branch : bit_vector(63 downto 0); -- Endereço alvo de desvio: (PC+4) + (imediato << 2)
  signal pc_src    : bit;                     -- Seleção do próximo PC: 0 => pc_plus4; 1 => pc_branch. Implementa branch/uncondBranch

  signal instr     : bit_vector(31 downto 0); -- Instrução de 32 bits lida da memória de instruções no endereço pc_q7

  signal rr1       : bit_vector(4 downto 0);  -- Índice do registrador fonte 1 (Rn) extraído da instrução (instr[9:5])
  signal rr2_a     : bit_vector(4 downto 0);  -- Índice candidato p/ registrador fonte 2 (Rm) (instr[20:16]) — usado em R-type
  signal rr2_b     : bit_vector(4 downto 0);  -- Índice candidato p/ registrador fonte 2 (Rt) (instr[4:0]) — usado em D-type/CBZ
  signal rr2       : bit_vector(4 downto 0);  -- Índice final do registrador fonte 2, após mux reg2Loc (rr2_a vs rr2_b)
  signal wr        : bit_vector(4 downto 0);  -- Índice do registrador destino de escrita (Rd/Rt), aqui usando instr[4:0]

  signal q1        : bit_vector(63 downto 0); -- Dado lido do banco de registradores no endereço rr1 (saída q1 do regfile)
  signal q2        : bit_vector(63 downto 0); -- Dado lido do banco de registradores no endereço rr2 (saída q2 do regfile)

  signal imm64     : bit_vector(63 downto 0); -- Imediato extraído da instrução e sign-extendido para 64 bits (saída do sign_extend)
  signal imm64_sl2 : bit_vector(63 downto 0); -- Imediato deslocado 2 à esquerda (<<2), usado para calcular alvo de branch (multiplica por 4)

  signal alu_b     : bit_vector(63 downto 0); -- Operando B efetivo da ALU (saída do mux aluSrc): q2 (registrador) ou imm64 (imediato)
  signal alu_f     : bit_vector(63 downto 0); -- Resultado da ALU (saída F), usado como resultado aritmético/lógico e também como endereço p/ memDados
  signal alu_z     : bit;                     -- Flag zero da ALU (Z=1 quando alu_f == 0). Usada para branch condicional (CBZ)

  signal dmem_addr7 : bit_vector(6 downto 0); -- Endereço (7 bits) aplicado na memória de dados: aqui é alu_f(6 downto 0) (byte address truncado)
  signal dmem_raw   : bit_vector(63 downto 0); -- Saída direta da memDados (dado lido). Como memDados não tem memRead, ela sempre fornece algo
  signal dmem_rd    : bit_vector(63 downto 0); -- Dado de leitura “validado” por memRead: se memRead=1, dmem_raw; senão, ZERO64 (via mux)
  signal wb_data    : bit_vector(63 downto 0); -- Dado final de write-back no regfile: selecionado por memToReg (ALU vs memória)

  signal c_pc4  : bit;                        -- Carry-out do adder PC+4 (não utilizado no datapath, mas exigido pela porta do adder_n)
  signal c_br   : bit;                        -- Carry-out do adder do branch target (não utilizado no datapath)

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
      in1  => QUATRO64,
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
