-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : tb_ula1bit.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - biblioteca de componentes para construção de um processador
-------------------------------------------------------------------------
-- Descricao : testbench para ula de 1 bit
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     07/11/2025  1.0     Pedro Mendes      versão inicial
--     24/11/2025  1.1     Antonio Vieira    Correção Pass B (imune a
--                                           Binvert)
-------------------------------------------------------------------------

library ieee;

entity tb_ula1bit is
end entity tb_ula1bit;

architecture testbench of tb_ula1bit is
    component ula1bit is
        port(
            a: in bit;
            b: in bit;
            cin: in bit;
            ainvert: in bit;
            binvert: in bit;
            operation: in bit_vector(1 downto 0);
            result: out bit;
            cout: out bit;
            overflow: out bit
        );
    end component;
    
    signal a : bit;
    signal b : bit;
    signal cin : bit;
    signal ainvert : bit;
    signal binvert : bit;
    signal operation : bit_vector(1 downto 0);
    
    signal result : bit;
    signal cout : bit;
    signal overflow : bit;

    signal any_error: bit;

    type test_vector is record
        a, b, cin, ainvert, binvert : bit;
        operation : bit_vector(1 downto 0);
        result_expected, cout_expected, overflow_expected : bit;
    end record;

    type test_array is array (natural range <>) of test_vector;

    -- function to_bstring(s : signed) return string;
    -- Baseado em:
    -- https://stackoverflow.com/questions/26575986/vhdl-coding-conversion-from-integer-to-bit-vector
    -- https://stackoverflow.com/questions/24329155/is-there-a-way-to-print-the-values-of-a-signal-to-a-file-from-a-modelsim-simulat
    function to_bstring(bt : bit) return string is
        variable b_str_v : string(1 to 3);
    begin
        b_str_v := bit'image(bt);
        return "" & b_str_v(2);
    end function;

    function to_bstring(bv : bit_vector) return string is
        alias    bv_norm : bit_vector(1 to bv'length) is bv;
        variable b_str_v : string(1 to 1);
        variable res_v   : string(1 to bv'length);
    begin
        for idx in bv_norm'range loop
            b_str_v := to_bstring(bv_norm(idx));
            res_v(idx) := b_str_v(1);
        end loop;
        return res_v;
    end function;

    constant testes : test_array := (
        -- Operação AND (00)
        ('0','0','0','0','0',"00",'0','0','0'),
        ('0','1','0','0','0',"00",'0','0','0'),
        ('1','0','0','0','0',"00",'0','0','0'),
        ('1','1','0','0','0',"00",'1','0','1'),
        
        -- Com ainvert
        ('0','0','0','1','0',"00",'0','0','0'),
        ('0','1','0','1','0',"00",'1','0','1'),
        ('1','0','0','1','0',"00",'0','0','0'),
        ('1','1','0','1','0',"00",'0','0','0'),
        
        -- Com binvert
        ('0','0','0','0','1',"00",'0','0','0'),
        ('0','1','0','0','1',"00",'0','0','0'),
        ('1','0','0','0','1',"00",'1','0','1'),
        ('1','1','0','0','1',"00",'0','0','0'),
        
        -- Com ambos invertidos
        ('0','0','0','1','1',"00",'1','0','1'),
        ('0','1','0','1','1',"00",'0','0','0'),
        ('1','0','0','1','1',"00",'0','0','0'),
        ('1','1','0','1','1',"00",'0','0','0'),

        -- Operação OR (01)
        ('0','0','0','0','0',"01",'0','0','0'),
        ('0','1','0','0','0',"01",'1','0','0'),
        ('1','0','0','0','0',"01",'1','0','0'),
        ('1','1','0','0','0',"01",'1','0','1'),
        
        -- Com ainvert
        ('0','0','0','1','0',"01",'1','0','0'),
        ('0','1','0','1','0',"01",'1','0','1'),
        ('1','0','0','1','0',"01",'0','0','0'),
        ('1','1','0','1','0',"01",'1','0','0'),
        
        -- Com binvert
        ('0','0','0','0','1',"01",'1','0','0'),
        ('0','1','0','0','1',"01",'0','0','0'),
        ('1','0','0','0','1',"01",'1','0','1'),
        ('1','1','0','0','1',"01",'1','0','0'),
        
        -- Com ambos invertidos
        ('0','0','0','1','1',"01",'1','0','1'),
        ('0','1','0','1','1',"01",'1','0','0'),
        ('1','0','0','1','1',"01",'1','0','0'),
        ('1','1','0','1','1',"01",'0','0','0'),

        -- Operação ADD (10)
        ('0','0','0','0','0',"10",'0','0','0'),
        ('0','0','1','0','0',"10",'1','0','1'),
        ('0','1','0','0','0',"10",'1','0','0'),
        ('0','1','1','0','0',"10",'0','1','0'),
        ('1','0','0','0','0',"10",'1','0','0'),
        ('1','0','1','0','0',"10",'0','1','0'),
        ('1','1','0','0','0',"10",'0','1','1'),
        ('1','1','1','0','0',"10",'1','1','0'),
        
        -- Com ainvert
        ('0','0','0','1','0',"10",'1','0','0'),
        ('0','0','1','1','0',"10",'0','1','0'),
        ('0','1','0','1','0',"10",'0','1','1'),
        ('0','1','1','1','0',"10",'1','1','0'),
        ('1','0','0','1','0',"10",'0','0','0'),
        ('1','0','1','1','0',"10",'1','0','1'),
        ('1','1','0','1','0',"10",'1','0','0'),
        ('1','1','1','1','0',"10",'0','1','0'),
        
        -- Com binvert
        ('0','0','0','0','1',"10",'1','0','0'),
        ('0','0','1','0','1',"10",'0','1','0'),
        ('0','1','0','0','1',"10",'0','0','0'),
        ('0','1','1','0','1',"10",'1','0','1'),
        ('1','0','0','0','1',"10",'0','1','1'),
        ('1','0','1','0','1',"10",'1','1','0'),
        ('1','1','0','0','1',"10",'1','0','0'),
        ('1','1','1','0','1',"10",'0','1','0'),
        
        -- Com ambos invertidos
        ('0','0','0','1','1',"10",'0','1','1'),
        ('0','0','1','1','1',"10",'1','1','0'),
        ('0','1','0','1','1',"10",'1','0','0'),
        ('0','1','1','1','1',"10",'0','1','0'),
        ('1','0','0','1','1',"10",'1','0','0'),
        ('1','0','1','1','1',"10",'0','1','0'),
        ('1','1','0','1','1',"10",'0','0','0'),
        ('1','1','1','1','1',"10",'1','0','1'),

        -- Operação Pass B (11)
        ('0','0','0','0','0',"11",'0','0','0'),
        ('0','1','0','0','0',"11",'1','0','0'),
        ('1','0','0','0','0',"11",'0','0','0'),
        ('1','1','0','0','0',"11",'1','0','1'),
        
        -- Com ainvert
        ('0','0','0','1','0',"11",'0','0','0'),
        ('0','1','0','1','0',"11",'1','0','1'),
        ('1','0','0','1','0',"11",'0','0','0'),
        ('1','1','0','1','0',"11",'1','0','0'),
        
        -- Com binvert
        ('0','0','0','0','1',"11",'0','0','0'),
        ('0','1','0','0','1',"11",'1','0','0'),
        ('1','0','0','0','1',"11",'0','0','1'),
        ('1','1','0','0','1',"11",'1','0','0'),
        
        -- Com ambos invertidos
        ('0','0','0','1','1',"11",'0','0','1'),
        ('0','1','0','1','1',"11",'1','0','0'),
        ('1','0','0','1','1',"11",'0','0','0'),
        ('1','1','0','1','1',"11",'1','0','0')
    );

begin
    UUT: ula1bit port map(
        a => a,
        b => b,
        cin => cin,
        ainvert => ainvert,
        binvert => binvert,
        operation => operation,
        result => result,
        cout => cout,
        overflow => overflow
    );

    processo_estimulo : process
    begin

        report "Iniciando testes da ULA de 1 bit...";
        
        any_error <= '0';
        
        for i in testes'range loop
            
            a <= testes(i).a;
            b <= testes(i).b;
            cin <= testes(i).cin;
            ainvert <= testes(i).ainvert;
            binvert <= testes(i).binvert;
            operation <= testes(i).operation;
            
            wait for 10 ns;
            
            if result /= testes(i).result_expected then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) & 
                       ": Result = " & bit'image(result) & 
                       ", Esperado = " & bit'image(testes(i).result_expected) &
                       " (A=" & bit'image(testes(i).a) & 
                       ", B=" & bit'image(testes(i).b) & 
                       ", Cin=" & bit'image(testes(i).cin) &
                       ", Ainv=" & bit'image(testes(i).ainvert) &
                       ", Binv=" & bit'image(testes(i).binvert) &
                       ", Op=" & to_bstring(testes(i).operation) & ")"
                       severity error;
            end if;
            
            if testes(i).operation = "10" then
                if cout /= testes(i).cout_expected then
                    any_error <= '1';
                    report "Falha no teste " & integer'image(i) & 
                           ": Cout = " & bit'image(cout) & 
                           ", Esperado = " & bit'image(testes(i).cout_expected) &
                           " (A=" & bit'image(testes(i).a) & 
                           ", B=" & bit'image(testes(i).b) & 
                           ", Cin=" & bit'image(testes(i).cin) &
                           ", Ainv=" & bit'image(testes(i).ainvert) &
                           ", Binv=" & bit'image(testes(i).binvert) &
                           ", Op=" & to_bstring(testes(i).operation) & ")"
                           severity error;
                end if;
            end if;
            
            if overflow /= testes(i).overflow_expected then
                any_error <= '1';
                report "Falha no teste " & integer'image(i) & 
                       ": Overflow = " & bit'image(overflow) & 
                       ", Esperado = " & bit'image(testes(i).overflow_expected) &
                       " (A=" & bit'image(testes(i).a) & 
                       ", B=" & bit'image(testes(i).b) & 
                       ", Cin=" & bit'image(testes(i).cin) &
                       ", Ainv=" & bit'image(testes(i).ainvert) &
                       ", Binv=" & bit'image(testes(i).binvert) &
                       ", Op=" & to_bstring(testes(i).operation) & ")"
                       severity error;
            end if;
        end loop;
        
        if any_error = '0' then
            report "Todos os testes passaram!";
        end if;
        report "Simulação concluída!";
        wait;
    end process;

end architecture testbench;
