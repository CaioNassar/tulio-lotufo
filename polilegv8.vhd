library ieee;
use ieee.numeric_bit.all;

entity polilegv8 is
  port(
    clock : in bit;
    reset : in bit
  );
end entity polilegv8;

architecture polilegv8Arch of polilegv8 is

 -- Declaração dos componentes

  component fluxoDados is
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
  end component;

  component unidadeControle is
    port(
      opcode       : in  bit_vector(10 downto 0);
      extendMSB    : out bit_vector(4 downto 0);
      extendLSB    : out bit_vector(4 downto 0);
      reg2Loc      : out bit;
      regWrite     : out bit;
      aluSrc       : out bit;
      alu_control  : out bit_vector(3 downto 0);
      branch       : out bit;
      uncondBranch : out bit;
      memRead      : out bit;
      memWrite     : out bit;
      memToReg     : out bit
    );
  end component;

  -- Unidade de Controle <---> Fluxo de Dados

  signal opcode_s       : bit_vector(10 downto 0);

  signal extendMSB_s    : bit_vector(4 downto 0);
  signal extendLSB_s    : bit_vector(4 downto 0);

  signal reg2Loc_s      : bit;
  signal regWrite_s     : bit;
  signal aluSrc_s       : bit;
  signal alu_control_s  : bit_vector(3 downto 0);

  signal branch_s       : bit;
  signal uncondBranch_s : bit;

  signal memRead_s      : bit;
  signal memWrite_s     : bit;
  signal memToReg_s     : bit;

begin

  -- Fluxo de Dados
  
  u_fluxoDados : fluxoDados
    port map(
      clock        => clock,
      reset        => reset,
      extendMSB    => extendMSB_s,
      extendLSB    => extendLSB_s,
      reg2Loc      => reg2Loc_s,
      regWrite     => regWrite_s,
      aluSrc       => aluSrc_s,
      alu_control  => alu_control_s,
      branch       => branch_s,
      uncondBranch => uncondBranch_s,
      memRead      => memRead_s,
      memWrite     => memWrite_s,
      memToReg     => memToReg_s,
      opcode       => opcode_s
    );

 -- Unidade de Controle
    
  u_unidadeControle : unidadeControle
    port map(
      opcode       => opcode_s,
      extendMSB    => extendMSB_s,
      extendLSB    => extendLSB_s,
      reg2Loc      => reg2Loc_s,
      regWrite     => regWrite_s,
      aluSrc       => aluSrc_s,
      alu_control  => alu_control_s,
      branch       => branch_s,
      uncondBranch => uncondBranch_s,
      memRead      => memRead_s,
      memWrite     => memWrite_s,
      memToReg     => memToReg_s
    );

end architecture polilegv8Arch;
