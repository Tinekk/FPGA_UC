library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CPU is

	 port (
        clk  : in    std_logic;
        reset  : in    std_logic; 
        MemoryReading  : out   bit;  -- aktywny w stanie 0
        MemoryWriting  : out   bit  -- aktywny w stanie 0
			);
end CPU;

architecture Behavior of CPU is



component Jednostka 
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
end component;

component ALU
  port(
	Clk : in std_logic; 
	A,B : in signed(15 downto 0);
	Operation : in signed(3 downto 0);
	Y : out signed(15 downto 0);
	Z,S,P,C : out std_logic);
end component;

component Rejestr
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
end component;

component UkladWspolpracy 
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
end component;

--Jednostka	
		signal Jednostka_Salu : signed(3 downto 0); 
		signal Jednostka_Sbb : signed(3 downto 0);
		signal Jednostka_Sbc : signed(3 downto 0);
		signal Jednostka_Sba : signed(3 downto 0);
		signal Jednostka_Sid : signed(2 downto 0);
		signal Jednostka_Sa : signed(1 downto 0);
		signal Jednostka_Smar : std_logic;
		signal Jednostka_Smbr : std_logic;
		signal Jednostka_WR : std_logic;
		signal Jednostka_RD : std_logic;
		signal Jednostka_STACK : std_logic;
		
--alu		
		signal Alu_Y :signed(15 downto 0);
		signal Alu_C :std_logic;
		signal Alu_S :std_logic;
		signal Alu_Z :std_logic;
		signal Alu_P :std_logic;
		
--rejestry		
		signal Rejestry_BB :signed (15 downto 0);
		signal Rejestry_BC :signed (15 downto 0);		
		signal Rejestry_ADR :signed (15 downto 0);
		signal Rejestry_IRout:signed (15 downto 0);
		
--uwp		
		signal UkladWspolpracy_DI :signed(15 downto 0);
	  signal UkladWspolpracy_STACKOUT :signed(15 downto 0);
			
begin
  
    
COMJednostka: Jednostka
PORT MAP(
		 clk=>clk,
  		 IR=>Rejestry_IRout,
		 reset=>reset,
		 Salu=>Jednostka_Salu,
		 Sbb=>Jednostka_Sbb,
		 Sbc=>Jednostka_Sbc, 
		 Sba=>Jednostka_Sba, 
		 Sid=>Jednostka_Sid, 
		 Sa=>Jednostka_Sa,
		 Smar=>Jednostka_Smar,
		 Smbr=>Jednostka_Smbr,
		 WR=>Jednostka_WR,
		 RD=>Jednostka_RD,
		 STACK=>Jednostka_STACK);
		 
COMAlu: ALU
		PORT MAP(
    Clk=>clk,
    A=>Rejestry_BB,
    B=>Rejestry_BC,
    Operation=>Jednostka_Salu,
    Y=>Alu_Y,
    Z=>Alu_Z,
    S=>Alu_S,
    P=>Alu_P,
    C=>Alu_C);
    
COMRejestry: Rejestr
		PORT MAP(
    clk=>clk,
    DI=>UkladWspolpracy_DI,
    BA=>Alu_Y,
    Sbb=>Jednostka_Sbb,
    Sbc=>Jednostka_Sbc,
    Sba=>Jednostka_Sba,
    Sid=>Jednostka_Sid,
    Sa=>Jednostka_Sa,
    BB=>Rejestry_BB,
    BC=>Rejestry_BC,
    ADR=>Rejestry_ADR,
    IROUT=>Rejestry_IRout,
    STACKIN=>UkladWspolpracy_STACKOUT);
    
COMUklad: UkladWspolpracy
	PORT MAP(
    clk=>clk,
    ADR=>Rejestry_ADR,
    DO=>Alu_Y,
    Smar=>Jednostka_Smar,
    Smbr=>Jednostka_Smbr,
    WRin=>Jednostka_WR,
    RDin=>Jednostka_RD,
    DI=>UkladWspolpracy_DI,
    STACK=>Jednostka_STACK,
    STACKOUT=>UkladWspolpracy_STACKOUT
    
  --  AD=>Address,
  --    D=>Data
  --  WR=>MemoryWriting,
  --  RD=>MemoryReading
   );

		
end Behavior;