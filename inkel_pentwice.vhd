LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.UTILS.ALL;

ENTITY inkel_pentwice IS
	PORT(
		clk    : IN STD_LOGIC;
		reset  : IN STD_LOGIC
	);
END inkel_pentwice;

ARCHITECTURE structure OF inkel_pentwice IS
	COMPONENT inkel_pentiun IS
		PORT (
			clk        : IN    STD_LOGIC;
			reset      : IN    STD_LOGIC;
			debug_dump : IN    STD_LOGIC;
			i_arb_req  : OUT   STD_LOGIC;
			d_arb_req  : OUT   STD_LOGIC;
			i_arb_ack  : IN    STD_LOGIC;
			d_arb_ack  : IN    STD_LOGIC;
			mem_req    : OUT   STD_LOGIC;
			mem_we     : OUT   STD_LOGIC;
			mem_addr   : OUT   STD_LOGIC_VECTOR(31  DOWNTO 0);
			mem_done   : IN    STD_LOGIC;
			mem_data   : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			pc_out     : OUT   STD_LOGIC_VECTOR(31  DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memory IS
		PORT (
			clk        : IN    STD_LOGIC;
			reset      : IN    STD_LOGIC;
			debug_dump : IN    STD_LOGIC;
			req        : IN    STD_LOGIC;
			we         : IN    STD_LOGIC;
			done       : OUT   STD_LOGIC;
			addr       : IN    STD_LOGIC_VECTOR(31  DOWNTO 0);
			data       : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT arbiter IS
		PORT (
			clk       : IN  STD_LOGIC;
			reset     : IN  STD_LOGIC;
			mem_done  : IN  STD_LOGIC;
			req_one_i : IN  STD_LOGIC;
			req_two_i : IN  STD_LOGIC;
			req_one_d : IN  STD_LOGIC;
			req_two_d : IN  STD_LOGIC;
			ack_one_i : OUT STD_LOGIC;
			ack_two_i : OUT STD_LOGIC;
			ack_one_d : OUT STD_LOGIC;
			ack_two_d : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL i_req_MEM : STD_LOGIC;
	SIGNAL d_req_MEM : STD_LOGIC;
	SIGNAL d_we_MEM   : STD_LOGIC;
	SIGNAL i_done_MEM : STD_LOGIC;
	SIGNAL d_done_MEM : STD_LOGIC;
	SIGNAL i_addr_MEM : STD_LOGIC_VECTOR(31  DOWNTO 0);
	SIGNAL d_addr_MEM : STD_LOGIC_VECTOR(31  DOWNTO 0);
	SIGNAL i_data_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL d_data_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);

	SIGNAL req_MEM  : STD_LOGIC;
	SIGNAL we_MEM   : STD_LOGIC;
	SIGNAL addr_MEM : STD_LOGIC_VECTOR(31  DOWNTO 0);
	SIGNAL done_MEM : STD_LOGIC;
	SIGNAL data_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
	
	SIGNAL req_one_i_ARB : STD_LOGIC;
	SIGNAL req_one_d_ARB : STD_LOGIC;
	SIGNAL ack_one_i_ARB : STD_LOGIC;
	SIGNAL ack_one_d_ARB : STD_LOGIC;
-- 	SIGNAL req_two_i_ARB : STD_LOGIC; --Unused until we use 2 pentiuns
-- 	SIGNAL req_two_d_ARB : STD_LOGIC;
 	SIGNAL ack_two_i_ARB : STD_LOGIC;
 	SIGNAL ack_two_d_ARB : STD_LOGIC;

	SIGNAL debug_dump : STD_LOGIC;
	
	BEGIN
		mem : memory PORT MAP (
			clk        => clk,
			reset      => reset,
			debug_dump => debug_dump,
			req        => req_MEM,
			we         => we_MEM,
			done       => done_MEM,
			addr       => addr_MEM,
			data       => data_MEM
		);

		arb : arbiter PORT MAP (
			clk       => clk,
			reset     => reset,
			mem_done  => done_MEM,
			req_one_i => req_one_i_ARB,
			req_one_d => req_one_d_ARB,
			ack_one_i => ack_one_i_ARB,
			ack_one_d => ack_one_d_ARB,
			req_two_i => '0',
			req_two_d => '0',
			ack_two_i => ack_two_i_ARB,
			ack_two_d => ack_two_d_ARB
		);

		proc : inkel_pentiun PORT MAP (
			clk        => clk,
			reset      => reset,
			debug_dump => debug_dump,
			i_arb_req  => req_one_i_ARB,
			d_arb_req  => req_one_d_ARB,
			i_arb_ack  => ack_one_i_ARB,
			d_arb_ack  => ack_one_d_ARB,
			mem_req    => req_MEM,
			mem_we     => we_MEM,
			mem_addr   => addr_MEM,
			mem_done   => done_MEM,
			mem_data   => data_MEM,
			pc_out     => OPEN
		);
		
		debug_dump <= '0';
		
END structure;