library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Rejestr is

port
(
  clk : in std_logic;
  DI : in signed (15 downto 0);
  BA : in signed (15 downto 0);
  Sbb : in signed (3 downto 0);
  Sbc : in signed (3 downto 0);
  Sba : in signed (3 downto 0);
  Sid : in signed (2 downto 0);
  Sa : in signed (1 downto 0);
  BB : out signed (15 downto 0);
  BC : out signed (15 downto 0);
  ADR : out signed (15 downto 0);
  IRout : out signed (15 downto 0);
  STACKIN : in signed (15 downto 0)
);
end entity;

architecture Behavior of Rejestr is
begin

process (clk, Sbb, Sbc, Sba, Sid, Sa, DI)
variable IR, TMP, A, B, C, D, E, F: signed (15 downto 0);
variable AD, PC, SP, ATMP : signed (15 downto 0) := "0000000000000000";
begin

if (clk'event and clk='1') then	
		case Sid is
			when "001" => -- 1
				PC := PC + 1;
			when "010" => -- 2
				SP := SP + 1;
			when "011" => -- 3
				SP := SP - 1;
			when "100" => -- 4
 				AD := AD + 1;
			when "101" => -- 5
				AD := AD - 1;
			when others =>
				null;
		end case;

		case Sba is
			when "0000" => IR := BA; 
			when "0001" => TMP := BA;
			when "0010" => A := BA;
			when "0011" => B := BA;
			when "0100" => C := BA;
  			when "0101" => D := BA;
   			when "0110" => E := BA;
 		--	when "0111" => F := BA;
   			when "1000" => AD(15 downto 0) := BA;
   			when "1001" => PC(15 downto 0) := BA;
   			when "1010" => SP(15 downto 0) := BA;
   			when "1011" => ATMP(15 downto 0) := BA;
  			when "1111"  => null;
			when others =>
				null;
		end case;
end if;

		case Sbb is
			when "0000" => BB <= DI;
			when "0001" => BB <= TMP;
			when "0010" => BB <= A;
			when "0011" => BB <= B;
			when "0100" => BB <= C;
  			when "0101" => BB <= D;
   			when "0110" => BB <= E;
   			when "0111" => BB <= STACKIN;
   			when "1000" => BB <= AD(15 downto 0);
   			when "1001" => BB <= PC(15 downto 0);
   			when "1010" => BB <= SP(15 downto 0);
   			when "1011" => BB <= ATMP(15 downto 0);
 			when "1111"  => null;
			when others =>
				null;
		end case;
		
		case Sbc is
			when "0000" => BC <= DI;
			when "0001" => BC <= TMP;
			when "0010" => BC <= A;
			when "0011" => BC <= B;
			when "0100" => BC <= C;
  			when "0101" => BC <= D;
   			when "0110" => BC <= E;
   			when "0111" => BC <= STACKIN;
   			when "1000" => BC <= AD(15 downto 0);
   			when "1001" => BC <= PC(15 downto 0);
   			when "1010" => BC <= SP(15 downto 0);
   			when "1011" => BC <= ATMP(15 downto 0); 	
   			when "1111"  => null;
		  when others =>
				null;
		end case;
		
		case Sa is
			when "00" => ADR <= AD;
			when "01" => ADR <= PC;
			when "10" => ADR <= SP;
			when "11" => ADR <= ATMP;
			when others =>
				null;
		end case;
				
		IRout <= IR;

end process;
end Behavior; 
