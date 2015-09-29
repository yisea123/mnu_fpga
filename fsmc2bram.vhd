----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:43:03 07/21/2015 
-- Design Name: 
-- Module Name:    fsmc_glue - A_fsmc_glue 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsmc2bram is
  Generic (
    BW : positive; -- block width
    BS : positive; -- block select
    DW : positive; -- data witdth
    AW : positive  -- total address width
  );
	Port (
    fsmc_clk : in std_logic; -- extenal clock generated by FSMC bus

    A : in STD_LOGIC_VECTOR (AW-1 downto 0);
    D : inout STD_LOGIC_VECTOR (DW-1 downto 0);
    NWE : in STD_LOGIC;
    NOE : in STD_LOGIC;
    NCE : in STD_LOGIC;
    NBL : in std_logic_vector (1 downto 0);

    bram0_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram0_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram0_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram0_en  : out STD_LOGIC;
    bram0_we  : out std_logic_vector (1 downto 0);
    bram0_clk : out std_logic;
    
    bram1_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram1_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram1_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram1_en  : out STD_LOGIC;
    bram1_we  : out std_logic_vector (1 downto 0);
    bram1_clk : out std_logic;
    
    bram2_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram2_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram2_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram2_en  : out STD_LOGIC;
    bram2_we  : out std_logic_vector (1 downto 0);
    bram2_clk : out std_logic;
    
    bram3_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram3_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram3_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram3_en  : out STD_LOGIC;
    bram3_we  : out std_logic_vector (1 downto 0);
    bram3_clk : out std_logic;
    
    bram4_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram4_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram4_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram4_en  : out STD_LOGIC;
    bram4_we  : out std_logic_vector (1 downto 0);
    bram4_clk : out std_logic;
    
    bram5_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram5_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram5_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram5_en  : out STD_LOGIC;
    bram5_we  : out std_logic_vector (1 downto 0);
    bram5_clk : out std_logic;
    
    bram6_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram6_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram6_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram6_en  : out STD_LOGIC;
    bram6_we  : out std_logic_vector (1 downto 0);
    bram6_clk : out std_logic;
    
    bram7_a   : out STD_LOGIC_VECTOR (BW-1 downto 0);
    bram7_di  : in  STD_LOGIC_VECTOR (DW-1 downto 0);
    bram7_do  : out STD_LOGIC_VECTOR (DW-1 downto 0);
    bram7_en  : out STD_LOGIC;
    bram7_we  : out std_logic_vector (1 downto 0);
    bram7_clk : out std_logic
  );
  
  function address2en(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
  begin
    return A(AW-1 downto BW);
  end address2en;
  
  function address2cnt(A : in std_logic_vector(AW-1 downto 0)) return std_logic_vector is
  begin
    return A(BW-1 downto 0);
  end address2cnt;

end fsmc2bram;

-------------------------
architecture beh of fsmc2bram is

type state_t is (IDLE, ADDR, WRITE1, READ1);
signal state : state_t := IDLE;

signal a_cnt : STD_LOGIC_VECTOR (BW-1 downto 0) := (others => '0');

signal do_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal di_common : STD_LOGIC_VECTOR (DW-1 downto 0) := (others => '0');
signal we_common : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
signal en_common : STD_LOGIC := '0';
signal blk_select : STD_LOGIC_VECTOR (BS-1 downto 0);

begin

  bram0_a <= a_cnt;
  bram1_a <= a_cnt;
  bram2_a <= a_cnt;
  bram3_a <= a_cnt;
  bram4_a <= a_cnt;
  bram5_a <= a_cnt;
  bram6_a <= a_cnt;
  bram7_a <= a_cnt;
  
  bram0_clk <= fsmc_clk;
  bram1_clk <= fsmc_clk;
  bram2_clk <= fsmc_clk;
  bram3_clk <= fsmc_clk;
  bram4_clk <= fsmc_clk;
  bram5_clk <= fsmc_clk;
  bram6_clk <= fsmc_clk;
  bram7_clk <= fsmc_clk;
  
  bram0_we <= we_common;
  bram1_we <= we_common;
  bram2_we <= we_common;
  bram3_we <= we_common;
  bram4_we <= we_common;
  bram5_we <= we_common;
  bram6_we <= we_common;
  bram7_we <= we_common;
  
  bram0_do <= do_common;
  bram1_do <= do_common;
  bram2_do <= do_common;
  bram3_do <= do_common;
  bram4_do <= do_common;
  bram5_do <= do_common;
  bram6_do <= do_common;
  bram7_do <= do_common;
  
  en_decoder : entity work.fsmc_3to8_en
  PORT MAP (
    A  => blk_select,
    en => en_common,
    
    sel(0) => bram0_en,
    sel(1) => bram1_en,
    sel(2) => bram2_en,
    sel(3) => bram3_en,
    sel(4) => bram4_en,
    sel(5) => bram5_en,
    sel(6) => bram6_en,
    sel(7) => bram7_en
  );

  di_decoder : entity work.fsmc_3to8_di
  PORT MAP (
    A  => blk_select,

    i0 => bram0_di,
    i1 => bram1_di,
    i2 => bram2_di,
    i3 => bram3_di,
    i4 => bram4_di,
    i5 => bram5_di,
    i6 => bram6_di,
    i7 => bram7_di,
    
    o  => di_common
  );

  D <= di_common when (NCE = '0' and NOE = '0') else (others => 'Z');
  do_common <= D;
  
  process(fsmc_clk, NCE) begin
    if (NCE = '1') then
      en_common <= '0';
      we_common <= "00";
      state <= IDLE;
      
    elsif rising_edge(fsmc_clk) then
      case state is
      
      when IDLE =>
        if (NCE = '0') then 
          a_cnt <= address2cnt(A);
          blk_select <= address2en(A);
          state <= ADDR;
        end if;
        
      when ADDR =>
        if (NWE = '0') then
          state <= WRITE1;
        else
          state <= READ1;
          en_common <= '1';
          a_cnt <= a_cnt + 1;
        end if;

      when WRITE1 =>
        en_common <= '1';
        we_common <= not NBL;
        a_cnt <= a_cnt + 1;

      when READ1 =>
        a_cnt <= a_cnt + 1;

      end case;
    end if;
  end process;
end beh;




