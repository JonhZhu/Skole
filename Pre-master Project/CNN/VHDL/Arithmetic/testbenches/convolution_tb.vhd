library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
  
ENTITY convolution_tb IS
	generic 	(
		IMAGE_DIM	: integer := 5;
		KERNEL_DIM 	: integer := 3;
		INT_WIDTH	: integer := 8;
		FRAC_WIDTH	: integer := 8
	);
END convolution_tb;

ARCHITECTURE behavior OF convolution_tb IS 

-- Component Declaration
	COMPONENT convolution
		generic 	(
			IMAGE_DIM	: integer := IMAGE_DIM;
			KERNEL_DIM 	: integer := KERNEL_DIM;
			INT_WIDTH	: integer := INT_WIDTH;
			FRAC_WIDTH	: integer := FRAC_WIDTH
		);
		port ( 
			clk					: in std_logic;
			reset					: in std_logic;
			conv_en				: in std_logic;
			weight_we			: in std_logic;
			weight_data 		: in ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
			pixel_in 			: in ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
			output_valid		: out std_logic; 
			pixel_out 			: out ufixed(INT_WIDTH-1 downto -FRAC_WIDTH)
		);
	END COMPONENT;

	constant zero 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000000000000000";
	constant one 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000000100000000";
	constant two 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000001000000000";
	constant three : ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000001100000000";
	constant four 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000010000000000";
	constant five 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := "0000010100000000";
	
	constant result0 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(73, 7, -8);
	constant result1 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(79, 7, -8);
	constant result2 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(38, 7, -8);
	constant result3 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(44, 7, -8);
	constant result4 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(61, 7, -8);
	constant result5 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(47, 7, -8);
	constant result6 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(42, 7, -8);
	constant result7 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(79, 7, -8);
	constant result8 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH) := to_ufixed(71, 7, -8);
	
	
	type img_array is array (24 downto 0) of ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	type kernel_array is array (9 downto 0) of ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	type conv_array is array (8 downto 0) of ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	
	signal image 	: img_array := (
		three,	three,	two,	 	three, 	one,
		three,	five,		three, 	three, 	one,
		two, 		three,	zero,		two, 		zero,
		zero, 	two,		five, 	four, 	one,
		zero, 	two,		five, 	one, 		three);
	
	signal kernel 	: kernel_array := (
		zero, 	zero, 	five,
		four, 	four, 	five,
		five,		two, 		one,
		one -- bias
		);
		
	signal result : conv_array := (
		result0, result1, result2,
		result3, result4, result5,
		result6, result7, result8);
		 

	signal clk				: std_logic;
	signal reset			: std_logic;
	signal conv_en			: std_logic;
	signal weight_we		: std_logic;
	signal weight_data 	: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	signal pixel_in 		: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	signal output_valid	: std_logic; 
	signal pixel_out 		: ufixed(INT_WIDTH-1 downto -FRAC_WIDTH);
	
	constant clk_period : time := 1 ns;

BEGIN

	convolution_test : convolution port map(
		clk => clk,
		reset => reset,
		conv_en => conv_en,
		weight_we => weight_we,
		weight_data => weight_data,
		pixel_in => pixel_in,
		output_valid => output_valid,
		pixel_out => pixel_out
	);
	
	clock : process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;


	load_weights : process
	begin
		reset <= '1';
		weight_we <= '0';
		wait for clk_period;
		reset <= '0';
		weight_we <= '1';
		for i in 0 to 9 loop
			weight_data <= kernel(i);
			wait for clk_period;
		end loop;
		
		weight_we <= '0';
		wait;
		
	end process;
	
	
	create_input : PROCESS
	BEGIN
		wait for clk_period*(KERNEL_DIM*KERNEL_DIM+2); -- wait until weights are loaded. 
		conv_en <= '1';
		for i in 0 to ((IMAGE_DIM*IMAGE_DIM)-1) loop
			pixel_in <= image(IMAGE_DIM*IMAGE_DIM-1-i);
			wait for clk_period;
		end loop;
		conv_en <= '0';
		
		wait; -- will wait forever
	END PROCESS;
	
--	assert_output : process(clk)
--
--	begin
--		if rising_edge(clk) then
--			if (output_valid ='1') then
--				nof_outputs := nof_outputs + 1;
--			end if;
--		end if;
--	end process;
--  End Test Bench 

END;
