library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.numeric_bit.all;

entity Jednostka is
port(
  clk : in std_logic;
  IR : in signed(15 downto 0);
  reset: in std_logic;
  Salu, Sbb, Sbc, Sba : out signed(3 downto 0);
  Sid : out signed(2 downto 0);
  Sa : out signed(1 downto 0);
  Smar, Smbr, WR, RD : out std_logic;
  STACK : out std_logic
);
end entity;

architecture Behavior of Jednostka is
	type state_type is (
	          START,
            FETCHING, FETCHING2, DECODING,
						ROLRS1, ROLRS2, ROLRS3,
						RORRS1, RORRS2, RORRS3,
						ROLRA1, ROLRA2, ROLRA3, ROLRA4 ,ROLRA5,
						RORRA1, RORRA2, RORRA3, RORRA4 ,RORRA5,
						PUSHR1,
						POPR1, POPR2, POPR3,
						BRS1, BRS2, BRS3, BRS4, BRS5, BRS6,
						MOVRS1, MOVRS2,
						MOVRR1,
						ADDRS1, ADDRS2, ADDRS3, 
					  ADDRR1, 
						SUBRS1, SUBRS2, SUBRS3,
						SUBRR1);
	signal state : state_type := START;
  



begin
  


process (clk, reset)		  
begin


	if reset = '1' then
		state <= FETCHING;
	elsif (clk'event and clk='1') then

		case state is
		  when START=>
		    state <=FETCHING;
			when FETCHING=>
        state <=  FETCHING2;
			when FETCHING2=>
				state <= DECODING;
			when DECODING=>
				case IR(15 downto 13) is
					when "000" =>
						 state <= FETCHING;
					when "001" => -- R
						case IR(12 downto 9) is
							when "0111" => state <= PUSHR1; -- PUSH R
							when "1000" => state <= POPR1; -- POP R(1)
							when others => state <= FETCHING;
						end case;
					when "010" => --S
						case IR(12 downto 9) is
							when "0100" => state <= BRS1; --BR S
							when others => state <= FETCHING;
						end case;
					when "100" => --R, S
						case IR(12 downto 9) is
							when "0101" => state <= ROLRS1; -- ROL R,S
							when "0110" => state <= RORRS1; -- ROR R,S
							when "0001" => state <= MOVRS1; -- MOV R,S
							when "0010" => state <= ADDRS1; -- ADD R,S
							when "0011" => state <= SUBRS1; -- SUB R,S
							when others => state <= FETCHING;
						end case;
					when "101" => --R, A
						case IR(12 downto 9) is
							when "0101" => state <= ROLRA1; -- ROL R,A
							when "0110" => state <= RORRA1; -- ROR R,A
							when others => state <= FETCHING;
						end case;
					when "111" => -- R, R
						case IR(12 downto 9) is
							when "0001" => state <= MOVRR1; -- MOV R,R
							when "0010" => state <= ADDRR1; -- ADD R,R
							when "0011" => state <= SUBRR1; -- SUB R,R 
							when others => state <= FETCHING;
						end case;
					when others =>
						state <= FETCHING;
				end case;

			--Mine next steps
			when MOVRS1 =>
			  state <= MOVRS2;
			  
			when ADDRS1 =>
        state <= ADDRS2;	
   	  when ADDRS2 =>
        state <= ADDRS3;  
           
			when SUBRS1 =>
        state <= SUBRS2;		
     	when SUBRS2 =>
        state <= SUBRS3;
        
 			when ROLRS1 =>
        state <= ROLRS2;		
     	when ROLRS2 =>
        state <= ROLRS3; 
            
			when RORRS1 =>
        state <=RORRS2;		
     	when RORRS2 =>
        state <= RORRS3;
        
  			when BRS1 =>
        state <=BRS2;		
     	when BRS2 =>
        state <= BRS3;
     	when BRS3 =>
        state <= BRS4;      	
     	when BRS4 =>
     	  state <= BRS5;
      when BRS5 =>
     	  state <= BRS6;
     	when BRS6 =>
     	  state <= FETCHING2;   	
            
      when ROLRA1 =>
        state <= ROLRA2;
      when ROLRA2 =>
        state <= ROLRA3;
      when ROLRA3 =>
        state <= ROLRA4;
      when ROLRA4 =>
        state <= ROLRA5;	
         	
      when RORRA1 =>
        state <= RORRA2;
      when RORRA2 =>
        state <= RORRA3;
      when RORRA3 =>
        state <= RORRA4;
      when RORRA4 =>
        state <= RORRA5;	
      
      when POPR1 =>
        state <= POPR2;  	
      when POPR2 =>
        state <= POPR3; 
           	
			when others =>
				state <= FETCHING;
		end case;
	end if;
	
end process;


process (state, IR) 
  variable WRITEDOTOBA : std_logic;
begin
  
	case state is
	  when START =>
	  Sa <= "01"; Sid <="000"; Sba <= "0000"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; STACK<='0';
		Salu <="0001"; 
		
		when FETCHING => -- Increase PC, Dont change BUS, Read data from ram (next adress because increasing PC) 
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; STACK<='0';
		Salu <="0001"; 
			
		when FETCHING2 => -- MOV BUS TO PC
		Sa <= "00"; Sid <="000"; Sba <= "0000"; Sbb <= "1111"; Sbc <="1111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000"; 	  
			
		when DECODING =>
		Sa <= "01"; Sid <="000"; Sba <= "1111"; Sbb <= "1111"; Sbc <="1111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000"; 
		
		-- MOV R, S
    when MOVRS1 => -- (Read data from (next adress) ram)
	  Sa <= "01"; Sid <="001";  Sba <= "1111"; Sbb <= "0000"; Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when MOVRS2 => -- (MOV const to [R_INPUT] from BUS)
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= "1111"; Sbc <="1111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0';  STACK<='0';
		Salu <="0001"; 		
		
		
		--ADD R, S
		when ADDRS1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when ADDRS2 => -- (MOV const to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "1111"; Sbc <="1111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0';  STACK<='0';
		Salu <="0000"; 
		when ADDRS3 => -- (MOV ([R]+[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0010";  
		
		
		-- ADD R, S
		when SUBRS1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when SUBRS2 => -- (MOV const to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when SUBRS3 => -- (MOV ([R]-[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0011";  
		
		
		--ROL R, S	  
		when ROLRS1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when ROLRS2 => -- (MOV const to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when ROLRS3 => -- (MOV ([R]rol[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0101"; 
		
		--ROR R, S	 
		when RORRS1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when RORRS2 => -- (MOV const to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when RORRS3 => -- (MOV ([R]ror[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0110"; 
		
		--BR S
		when BRS1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="000"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 	
		when BRS2 => -- (MOV const to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when BRS3 => -- (MOV ([PC]+[TEMP]) to [PC])
		Sa <= "01"; Sid <="000"; Sba <= "1001"; Sbb <= "1001"; Sbc <="0001";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0010";   
		when BRS4 => -- (Read data From [PC address] ram)
		Sa <= "01"; Sid <="000"; Sba <= "1111"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when BRS5 => -- (Data to [IR])
		Sa <= "01"; Sid <="001"; Sba <= "0000"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 
		when BRS6 => -- (New data to DI ~aka fetch)
		Sa <= "01"; Sid <="000"; Sba <= "1111"; Sbb <= "0000";  Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001";

		
		--MOV R, R
		when MOVRR1 => -- MOV [R2] to [R1]
		Sa <= "01"; Sid <="000"; Sba <= IR(7 downto 4); Sbb <= "0000"; Sbc <= IR(3 downto 0); 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0';  STACK<='0';
		Salu <="0001"; 
		
		
		--ADD R, R
		when ADDRR1 => -- MOV ([R1]+[R2]) to [R1]
		Sa <= "01"; Sid <="000"; Sba <= IR(7 downto 4); Sbb <= IR(7 downto 4); Sbc <= IR(3 downto 0); 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0';  STACK<='0';
		Salu <="0010"; 
		
		
		--SUB R, R
		when SUBRR1 => -- MOV ([R1]-[R2]) to [R1]
		Sa <= "01"; Sid <="000"; Sba <= IR(7 downto 4); Sbb <= IR(7 downto 4); Sbc <= IR(3 downto 0); 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0';  STACK<='0';
		Salu <="0011"; 
			  
		--ROL R, A
		when ROLRA1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="001"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 	
		when ROLRA2 => -- (MOV adr to [ATEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "1011"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when ROLRA3 => -- (Read data from [ATEMP] ram)
		Sa <= "11"; Sid <="000"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 	
		when ROLRA4 => -- (MOV value_from_adr to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "0000"; Sbc<="0000";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0001";  
		when ROLRA5 => -- (MOV ([R]rol[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0101"; 
		
		--ROR R, A
		when RORRA1 => -- (Read data from (next adress) ram)
		Sa <= "01"; Sid <="000"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 	
		when RORRA2 => -- (MOV adr to [ATEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "1011"; Sbb <= "1111"; Sbc<="1111";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0000";  
		when RORRA3 => -- (Read data from [ATEMP] ram)
		Sa <= "11"; Sid <="000"; Sba <= "1111"; Sbb <= "0000"; Sbc <="0000";
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1';  STACK<='0';
		Salu <="0001"; 	
		when RORRA4 => -- (MOV value_from_adr to [TEMP] from bus)
		Sa <= "01"; Sid <="000"; Sba <= "0001"; Sbb <= "0000"; Sbc<="0000";
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0001";  
		when RORRA5 => -- (MOV ([R]rol[TEMP]) to [R])
		Sa <= "01"; Sid <="000"; Sba <= IR(8 downto 5); Sbb <= IR(8 downto 5); Sbc<="0001"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
		Salu <="0110"; 
		
		when PUSHR1 => -- PUSH R
		Sa <= "10"; Sid <="010"; Sba <= "0000"; Sbb <= "0000"; Sbc <=IR(8 downto 5); 
		Smar <='1'; Smbr <= '0'; WR <='1'; RD <='0'; STACK<='1';
		Salu <="0001";
		
		when POPR1 => -- POP R
		Sa <= "10"; Sid <="011"; Sba <= "1111";  Sbb <= "0000"; Sbc <="0000"; 
		Smar <='1'; Smbr <= '0'; WR <='0'; RD <='1'; STACK<='1';
		Salu <="0000"; 
		when POPR2 => 
		Sa <= "10"; Sid <="011"; Sba <= "1111";  Sbb <= "0111"; Sbc <="0111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='1';
		Salu <="0001"; 
		when POPR3 => 
		Sa <= "10"; Sid <="011"; Sba <= IR(8 downto 5);  Sbb <= "0111"; Sbc <="0111"; 
		Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='1';
		Salu <="0001"; 
		
		when others =>
			Sa <= "00"; Sbb <= "0000"; Sba <= "0000"; Sid <="000"; Sbc <="0000"; 
			Smar <='0'; Smbr <= '0'; WR <='0'; RD <='0'; STACK<='0';
			Salu <="0000"; 
		end case;
	end process;
	
end behavior; 