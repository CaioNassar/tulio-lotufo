library ieee;
use ieee.numeric_bit.all;

entity unidadeControle is
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
end entity unidadeControle;

architecture comb of unidadeControle is
begin

  process(opcode)
  begin
    -- Defaults (evita latch e resolve os "X" da tabela)
    extendMSB    <= "00000";
    extendLSB    <= "00000";

    reg2Loc      <= '0';
    regWrite     <= '0';
    aluSrc       <= '0';
    alu_control  <= "0000";

    branch       <= '0';
    uncondBranch <= '0';

    memRead      <= '0';
    memWrite     <= '0';
    memToReg     <= '0';

    -- Decodificação por opcode (11 MSBs da instrução)
    if opcode = "10001011000" then            -- ADD
      regWrite    <= '1';
      alu_control <= "0010";

    elsif opcode = "11001011000" then         -- SUB
      regWrite    <= '1';
      alu_control <= "0110";

    elsif opcode = "10001010000" then         -- AND
      regWrite    <= '1';
      alu_control <= "0000";

    elsif opcode = "10101010000" then         -- ORR
      regWrite    <= '1';
      alu_control <= "0001";

    elsif opcode = "11111000010" then         -- LDUR
      aluSrc      <= '1';
      memToReg    <= '1';
      regWrite    <= '1';
      memRead     <= '1';
      alu_control <= "0010";
      extendMSB   <= "10100";                 -- 20
      extendLSB   <= "01100";                 -- 12

    elsif opcode = "11111000000" then         -- STUR
      reg2Loc     <= '1';
      aluSrc      <= '1';
      memWrite    <= '1';
      alu_control <= "0010";
      extendMSB   <= "10100";                 -- 20
      extendLSB   <= "01100";                 -- 12

    elsif opcode(10 downto 3) = "10110100" then -- CBZ (bits [2:0] = don't care)
      reg2Loc     <= '1';
      branch      <= '1';
      alu_control <= "0011";                  -- "xx11" (escolhido como 0011)
      extendMSB   <= "10111";                 -- 23
      extendLSB   <= "00101";                 -- 5

    elsif opcode(10 downto 5) = "000101" then  -- B (bits [4:0] = don't care)
      uncondBranch <= '1';
      extendMSB    <= "11001";                -- 25
      extendLSB    <= "00000";                -- 0

    else
      -- permanece nos defaults
      null;
    end if;

  end process;

end architecture comb;
