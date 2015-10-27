
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library uart_lib;


entity ram_to_uart_pwm is

  generic (
    UART_CHANNELS : integer := 2;
    PWM_CHANNELS  : integer := 16);

  port (
    clk_fpga : in std_logic;            -- sampling clock
    rst      : in std_logic;            -- active high

    CLK_FSMC : in  std_logic;                       -- memory clock
    A_IN     : in  std_logic_vector (8 downto 0);   -- memory address
    D_IN     : in  std_logic_vector (15 downto 0);  -- memory data in
    D_OUT    : out std_logic_vector (15 downto 0);  -- memory data out
    EN_IN    : in  std_logic;                       -- memory enable
    WE_IN    : in  std_logic;                       -- memory write enable

    UART_RX  : in  std_logic_vector (UART_CHANNELS-1 downto 0);
    UART_CTS : in  std_logic_vector (UART_CHANNELS-1 downto 0);
    UART_TX  : out std_logic_vector (UART_CHANNELS-1 downto 0);
    UART_RTS : out std_logic_vector (UART_CHANNELS-1 downto 0);

    PWM_DATA_IN  : in  std_logic_vector (15 downto 0);
    PWM_EN_IN    : in  std_logic;
    PWM_DATA_OUT : out std_logic_vector (15 downto 0);
    PWM_EN_OUT   : out std_logic);

end entity ram_to_uart_pwm;

architecture rtl of ram_to_uart_pwm is

  -- Memory space
  type t_pwm_ram is array (0 to PWM_CHANNELS-1) of std_logic_vector (15 downto 0);
  signal pwm_from_mcu : t_pwm_ram;
  signal pwm_to_mcu   : t_pwm_ram;

  signal clk_fsmc_i   : std_logic;
  signal clk_fsmc_d_i : std_logic;      -- previous value
  signal a_i          : std_logic_vector (8 downto 0);
  signal d_i          : std_logic_vector (15 downto 0);
  signal en_i         : std_logic;
  signal we_i         : std_logic;

  signal bank_num_i : integer;
  signal uart_num_i : integer;
  signal pwm_num_i  : integer;

  signal fsmc_wr : std_logic;
  signal fsmc_rd : std_logic;

  signal uart_wr_i   : std_logic;
  signal uart_rd_i   : std_logic;
  signal uart_cs_i   : std_logic_vector (UART_CHANNELS-1 downto 0);
  signal uart_addr_i : std_logic_vector (2 downto 0);

  signal uart_16x_baudclk : std_logic_vector (UART_CHANNELS-1 downto 0);

  -- FSMC data out sources
  signal pwm_ram_do : std_logic_vector (15 downto 0);
  type t_uart_do is array (0 to UART_CHANNELS-1) of std_logic_vector (7 downto 0);
  signal uart_do    : t_uart_do;
  signal uart_ints  : std_logic_vector (UART_CHANNELS-1 downto 0);  -- interrupts

begin

  -- input sampling
  process (clk_fpga) is
  begin
    if rising_edge(clk_fpga) then
      clk_fsmc_i   <= CLK_FSMC;
      clk_fsmc_d_i <= clk_fsmc_i;
      a_i          <= A_IN;
      d_i          <= D_IN;
      en_i         <= EN_IN;
      we_i         <= WE_IN;
    end if;
  end process;

  -- address decode for uarts

  bank_num_i <= to_integer(unsigned(a_i(8 downto 3)));
  --bank 0-1  pwm read   --addr 0-15
  --bank 2-3  pwm write  --addr 16-31
  --bank 4-19 uarts      --addr 32-159
  --bank 20   interrupts --addr 160

  uart_num_i <= bank_num_i - PWM_CHANNELS/4;
  pwm_num_i  <= to_integer(unsigned(a_i(3 downto 0)));

  fsmc_rd <= '1' when clk_fsmc_d_i = '0' and clk_fsmc_i = '1' and en_i = '1' and we_i = '0'
             else '0';
  fsmc_wr <= '1' when clk_fsmc_d_i = '0' and clk_fsmc_i = '1' and en_i = '1' and we_i = '1'
             else '0';

  process (clk_fsmc_i, fsmc_rd, fsmc_wr) is               -- combinatorial
  begin
    uart_rd_i      <= '0';
    uart_wr_i      <= '0';
    uart_cs_i      <= (others => '0');
    if (uart_num_i <= UART_CHANNELS-1 and uart_num_i >= 0) then  -- address range check
      if fsmc_rd = '1' then
        uart_cs_i (uart_num_i) <= '1';
        uart_rd_i              <= '1';
      elsif fsmc_wr = '1' then
        uart_cs_i (uart_num_i) <= '1';
        uart_wr_i              <= '1';
      end if;
    end if;
  end process;

  uart_addr_i <= a_i (2 downto 0);      -- uart register address

  -- pwm memory
  process (clk_fpga) is
  begin
    if rising_edge(clk_fpga) then
      if (bank_num_i >= 0 and bank_num_i <= PWM_CHANNELS/4-1) then  -- address range check
        if fsmc_rd = '1' then
          pwm_ram_do <= pwm_to_mcu (pwm_num_i);
        elsif fsmc_wr = '1' then
          pwm_from_mcu (pwm_num_i) <= d_i;
        end if;
      end if;
    end if;
  end process;

  uarts : for i in 0 to UART_CHANNELS-1 generate  -------------------------------
    uart_16750_i : entity uart_lib.uart_16750
      port map (
        CLK      => clk_fpga,
        RST      => rst,
        BAUDCE   => '1',
        CS       => uart_cs_i (i),
        WR       => uart_wr_i,
        RD       => uart_rd_i,
        A        => uart_addr_i,
        DIN      => d_i (7 downto 0),
        DOUT     => open,               --------------------
        DDIS     => open,
        INT      => uart_ints (i),
        OUT1N    => open,
        OUT2N    => open,
        RCLK     => uart_16x_baudclk (i),
        BAUDOUTN => uart_16x_baudclk (i),
        RTSN     => UART_RTS (i),
        DTRN     => open,
        CTSN     => UART_CTS (i),
        DSRN     => '1',
        DCDN     => '1',
        RIN      => '1',
        SIN      => UART_RX (i),
        SOUT     => UART_TX (i));
  end generate uarts;
  
end architecture rtl;
