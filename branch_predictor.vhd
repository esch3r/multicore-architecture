LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.utils.ALL;

ENTITY branch_predictor IS
	PORT(
		clk	      : IN  STD_LOGIC;
		reset     : IN  STD_LOGIC;
		pc_F      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		next_pc_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		taken_F   : OUT STD_LOGIC;
		info_F    : OUT STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0);
		branch_A  : IN  STD_LOGIC;
		taken_A   : IN  STD_LOGIC;
		pc_A      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		next_pc_A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		info_A    : IN  STD_LOGIC_VECTOR(BP_INFO_BITS-1 DOWNTO 0)
	);
END branch_predictor;

ARCHITECTURE branch_predictor_behaviour OF branch_predictor IS
	CONSTANT ENTRIES : INTEGER := 2 ** BP_INDEX_BITS;

	TYPE pc_fields_t      IS ARRAY(ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
	TYPE taken_fields_t   IS ARRAY(ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR( 1 DOWNTO 0);
	TYPE next_pc_fields_t IS ARRAY(ENTRIES-1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL history : STD_LOGIC_VECTOR(BP_HISTORY_BITS-1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL pc      : pc_fields_t;
	SIGNAL taken   : taken_fields_t;
	SIGNAL next_pc : next_pc_fields_t;

	SIGNAL entry_F   : INTEGER RANGE 0 TO ENTRIES-1 := 0;
	SIGNAL entry_A   : INTEGER RANGE 0 TO ENTRIES-1 := 0;
	SIGNAL entry_F_v : STD_LOGIC_VECTOR(BP_INDEX_BITS-1 DOWNTO 0);
	SIGNAL entry_A_v : STD_LOGIC_VECTOR(BP_INDEX_BITS-1 DOWNTO 0);
BEGIN
	execution_process : PROCESS(clk, reset)
	BEGIN
		IF rising_edge(clk) AND reset = '1' THEN
			FOR i IN 0 TO ENTRIES-1 LOOP
				pc(i) <= (OTHERS => '0');
				taken(i) <= (OTHERS => '0');
			END LOOP;
			history <= (OTHERS => '0');
		ELSIF falling_edge(clk) AND reset = '0' THEN
			IF (branch_A = '1') THEN
				IF (pc(entry_A) = pc_A(31 DOWNTO 8)) THEN
					IF (taken_A = '1' AND taken(entry_A) /= "11") THEN
						taken(entry_A) <= taken(entry_A) + "01";
					ELSIF (taken_A = '0' AND taken(entry_A) /= "00") THEN
						taken(entry_A) <= taken(entry_A) - "01";
					END IF;
				ELSE
					pc(entry_A) <= pc_A(31 DOWNTO 8);
					next_pc(entry_A) <= next_pc_A;
					taken(entry_A)(1) <= '0';
					taken(entry_A)(0) <= taken_A;
				END IF;

				history <= to_stdlogicvector(to_bitvector(history) SLL 1);
				history(0) <= taken_A;
			END IF;
		END IF;
	END PROCESS execution_process;

	entry_F_v <= history(BP_HISTORY_BITS-1 DOWNTO 0) & pc_F(7 DOWNTO 2);
	entry_F <= to_integer(unsigned(entry_F_v));
	entry_A <= to_integer(unsigned(info_A));

	info_F <= std_logic_vector(to_unsigned(entry_F, info_F'length));
	taken_F <= '1' WHEN (taken(entry_F) = "10" OR taken(entry_F) = "11") AND pc(entry_F) = pc_F(31 DOWNTO 8) ELSE '0';
	next_pc_F <= next_pc(entry_F);
END branch_predictor_behaviour;