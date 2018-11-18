library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

entity ALU is
port(
	Clk : in std_logic; 
	A,B : in signed(15 downto 0);
	Operation : in signed(3 downto 0);
	Y : out signed(15 downto 0);
	Z,S,P,C : out std_logic
);

end entity;

architecture Behavior of ALU is

signal Reg1,Reg2,Reg3 : signed(15 downto 0) := (others => '0');

begin
  
Reg1 <= A;
Reg2 <= B;
Y <= Reg3 (15 downto 0);

process(Clk,A,B,Operation)
  variable AA, BB, CC : signed(16 downto 0);
  variable CF,ZF,SF,PF : std_logic := '0';
begin
  

AA(15 downto 0) := A;
BB(15 downto 0) := B;
CC(16 downto 0) := "00000000000000000"; 

        case Operation is
         			when "0000" =>	--NULL Operation
          		null;
          		
            when "0001" => --MOV
            Reg3 <= Reg2;  
            
            when "0010" => --ADD 
            
            AA(16) := '0'; BB(16) := '0';
            CC := AA+BB;
            Reg3 <= Reg1 + Reg2;	
           	-- Flaga Przeniesienia
	         	CF := CC(16);

            
            when "0011" => --SUB
            CC := AA-BB;
            Reg3 <= Reg1 - Reg2;  
            -- Flaga Przeniesienia
            if (BB>AA) then
  	         	CF := '1';
	         	else
	         	  CF := '0';
	         	end if;
            
            when "0101" => --ROL
            Reg3 <= Reg1 rol to_integer(Reg2);
             -- Reg3 <= Reg1;  
     		  			 -- for i in 0 to 1 loop
           		--			Temp <= Reg3(0);
						 --   for x in 0 to 14 loop
						 --     Reg3(x) <= Reg3(x+1);
        					--	  end loop;	
        					--	  Reg3(15) <= Temp;
						 -- end loop;
						 
            when "0110" => --ROR
            Reg3 <= Reg1 ror to_integer(Reg2);
             --  Reg3 <= Reg1;  
					   --  for i in 0 to 1 loop
					   --     Temp <= Reg3(15);
						 --     for x in 0 to 14 loop
						 --       Reg3(15-x) <= Reg3(15-x-1);
						 --     end loop;	
      					  --     Reg3(0) <= Temp;
						 --  end loop;	
						 
            when others =>
                NULL;
        end case;      
   
  Z <= ZF;
  S <= SF;
  C <= CF; 
  P <= PF;

  PF := '1';
  if (clk'event and clk='1') then
		if (Reg3 = "00000000000000000") then  -- Flaga Zera
			ZF:='1';
		else 
			ZF:='0';
		end if;
			
		if (Reg3(15)='1') then -- Flaga Znaku
			SF:='1'; 
		else 
			SF:='0';
		end if;
		
		for i in 0 to 15 loop  -- Flaga Parzystosci
			if (Reg3(i)='1') then
				PF := NOT(PF);
			end if;			
		end loop;	
		
  end if;	
	
end process;   

end Behavior;

