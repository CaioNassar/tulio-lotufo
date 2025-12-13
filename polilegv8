library ieee;
use ieee.numeric_bit.all;

entity polilegv8 is
  port(
    clock : in bit;
    reset : in bit
  );
end entity polilegv8;

architecture estrutural of polilegv8 is

  -- Interligação UC <-> Fluxo de Dados
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

  --------------------------------------------------------------------------
  -- Fluxo de Dados (datapath)
  --------------------------------------------------------------------------
  u_fluxoDados : entity work.fluxoDados
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

  --------------------------------------------------------------------------
  -- Unidade de Controle
  --------------------------------------------------------------------------
  u_unidadeControle : entity work.unidadeControle
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

end architecture estrutural;
