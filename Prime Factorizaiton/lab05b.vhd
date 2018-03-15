library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity lab05b is
port(
	clk: in    std_logic;
  	ra1: in    std_logic;
  	rc1: in    std_logic;
  	rc3: in    std_logic;
  	rb:  inout std_logic_vector(7 downto 0);
  	but: in    std_logic;
  	led: out   std_logic
 );
end lab05b;

architecture arch of lab05b is

	component lab05_gui
	port(
   		clk:      in    std_logic;
   		ra1:      in    std_logic;
   		rc1:      in    std_logic;
  		rc3:      in    std_logic;
   		rb:       inout std_logic_vector(7 downto 0);
   		data_in:  in    std_logic_vector(47 downto 0);
   		data_out: out   std_logic_vector(47 downto 0)
		);
	end component;
 
	signal data_in:  std_logic_vector(47 downto 0);
	signal data_out: std_logic_vector(47 downto 0);
	signal factor:   unsigned(23 downto 0);
	signal count:    unsigned(5 downto 0);
	signal start,sym,sym0: std_logic:='0';
	shared variable temp: unsigned(70 downto 0);
	shared variable temp_new: unsigned(70 downto 0);
	signal square:	unsigned(47 downto 0);
	 
	attribute INIT: string;
	attribute INIT of factor: signal is b"11111111_11111111_11111111";
	attribute INIT of count: signal is b"110000";
	
	begin
 	gui: lab05_gui port map(clk=>clk,ra1=>ra1,rc1=>rc1,rc3=>rc3,rb=>rb,
  	data_in=>data_in,data_out=>data_out);
 
 	start<=not but;
 	process(clk)
 	begin
  		if rising_edge(clk) then
   	   		case count is
    			when b"110000" => --which is 48
     		   		if (factor=b"11111111_11111111_11111111") then
						if (start='1') then
				 		-- Start of new factorization
				 	   		led<='1';
				 		   	factor<=b"00000000_00000000_00000010";
				 		   	square<=b"00000000_00000000_00000000_00000000_00000000_00000100";
				 		   	count<=b"000000";
				 		   	data_in<=std_logic_vector(to_unsigned(1,48));
				 		   	temp:=unsigned("00000000000000000000000" & data_out);
				 		   	temp_new:=b"00000000_00000000_0000001000000000000000000000000000000000000000000000000";
				 		   	sym0<='0';
				 		   	sym<='0';
						else
							led<='0';
							if sym='0' then
								data_in<=data_out;
							else
								null;
							end if;
		   			 	end if;
     			    else
				    -- Increment factor
				    	factor<=factor+1;
				    	square<=square+2*factor+1;
				    	temp_new:=unsigned(std_logic_vector(factor) & "00000000000000000000000000000000000000000000000");
				    	count<=b"000000";
				   		temp:=unsigned("00000000000000000000000" & data_out);
				    	if square >= unsigned(temp)	then
				   			factor <= b"11111111_11111111_11111111";
				    	end if;
     			   	end if;
    			when b"101111" =>--which is 47
     		    -- Check for zero remainder
     
     		   		if temp=0  and sym0='0' then
						sym<='1';
						sym0<='1';
						if unsigned(factor) > 2 then
							data_in<=std_logic_vector("000000000000000000000000" & std_logic_vector(factor-1));
						else
							data_in<=std_logic_vector("000000000000000000000000" & std_logic_vector(factor));
						end if;
						factor <= b"11111111_11111111_11111111";
     			    else
					   null;
     			  	end if;
	  			  	count<=count+1;
    			when others =>
     		   	-- Shift and subtract
     		   		count<=count+1;
     			   	temp_new:=shift_right(temp_new,1);
     			   	if temp>=temp_new then
						temp:=temp-temp_new;
     			   	else
						null;
     			   	end if;
   			 	end case;
  		  	end if;
 	   end process;
end arch;
