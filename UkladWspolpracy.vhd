library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UkladWspolpracy is
port
(
	clk : in std_logic;
	ADR : in signed(15 downto 0);
	DO : in signed(15 downto 0);
	Smar, Smbr, WRin, RDin : in std_logic;
--	AD : out signed (15 downto 0);
  DI : out signed(15 downto 0);
  STACKOUT : out signed(15 downto 0);
--	WR, RD : out std_logic
  STACK : in std_logic
);
end entity;

architecture Behavior of UkladWspolpracy is

signal WriteRAM, WriteSTACK : std_logic;
signal ReadRAM, ReadSTACK : std_logic;
signal STACKIN : signed(15 downto 0);

component RAM
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
end component;


signal	D : signed (15 downto 0);

begin	

COMRam: RAM
	PORT MAP(clk,
	STD_LOGIC_VECTOR(DO),
	STD_LOGIC_VECTOR(ADR(7 downto 0)),
	ReadRAM,
	STD_LOGIC_VECTOR(ADR(7 downto 0)), 
	WriteRAM, 
	SIGNED(q) => DI);

COMStos: RAM
	PORT MAP(clk,
	STD_LOGIC_VECTOR(STACKIN), 
	STD_LOGIC_VECTOR(ADR(7 downto 0)),
	ReadSTACK,
	STD_LOGIC_VECTOR(ADR(7 downto 0)), 
	WriteSTACK, 
	SIGNED(q) => STACKOUT);
	
	STACKIN <= DO;
	
process(Smar, ADR, Smbr, DO,
 --D,
 STACK,WRin, RDin)

variable MBRin, MBRout: signed(15 downto 0);
variable MAR : signed(15 downto 0);



begin
	
	
	 if(STACK='1') then
	 ReadSTACK <= RDin;
	 WriteSTACK <= WRin;
	 ReadRAM <= '0';
	 WriteRAM <= '0';
	 end if;
	 
	 if(STACK='0') then
	 ReadSTACK <= '0';
	 WriteSTACK <= '0';
	 ReadRAM <= RDin;
	 WriteRAM <= WRin;
	 end if;
	 
	

	if(Smar='1') then 
		MAR := ADR;	
	end if;
		
	if(Smbr='1') then	
		MBRout := DO; 
	end if;
	
	if(RDin='1') then
		MBRin := D;	 
	end if;
	
	if (WRin='1')	then 
			D <= MBRout;
	else 
			D <= "ZZZZZZZZZZZZZZZZ";
	end if;
	
	DI <= MBRin;
--	AD <= MAR;
--	WR <= WRin;
--	RD <= RDin;
	
end process;

end Behavior; 







