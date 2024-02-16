`define RC4
`define KEY_SIZE 16

module rc4_tb;

	reg clk = 1'b0;	
	integer clkcount = 0;
	integer j = 0;
	always #5 clk = !clk;
	always @(posedge clk)
		begin
		clkcount = clkcount + 1;
	end
	reg rst_n = 1'b0;
	event reset_deassertion, change_key;
	
	initial begin
		#12.8 rst_n = 1'b1;
		-> reset_deassertion;
	end

	reg [7:0] key[0:`KEY_SIZE-1];
	reg [7:0] pt[0:11];
	reg [7:0] ct[0:11];
	wire [7:0] Key_stream;
	reg  [7:0] din;
	reg din_valid;
	reg key_valid;
	wire [7:0] dout;
	wire key_stream_valid;
	wire dout_ready;
	reg [7:0] key_input; 

/* rc4 module implementation */
rc4 rc4mod(
	.clk(clk),
	.rst_n(rst_n),
	.key_input(key_input),
	.key_valid(key_valid),
	.din(din),
	.din_valid(din_valid),
    .dout_ready(dout_ready),
    .key_stream_valid(key_stream_valid),
	.dout(dout)
);
always @(posedge clk) begin
	if(dout_ready == 1) begin
		$display("clkcount = %0d pt_txt = %x ct_gen = %x ct_text = %x. The result is: %-7s",clkcount, din, dout, ct[j], ct[j] === dout ? "CORRECT" : "WRONG");
		j = j + 1;
	end
end

initial begin
	@(reset_deassertion);
	din_valid = 1'b0;
	key_valid = 1'b0;
	din = 8'b0;
	@(posedge clk);

//KEY [hex] := cc28bec716a9d4ad4d677f36c051f8f6
	key[0] = 8'hcc;
	key[1] = 8'h28; //
	key[2] = 8'hbe; // 
	key[3] = 8'hc7; // 
	key[4] = 8'h16; // 
	key[5] = 8'ha9; // 
	key[6] = 8'hd4; // 
	key[7] = 8'had; //
	key[8] = 8'h4d; // 
	key[9] = 8'h67; // 
	key[10] = 8'h7f; // 
	key[11] = 8'h36; // 
	key[12] = 8'hc0; // 
	key[13] = 8'h51; //
	key[14] = 8'hf8; // 
	key[15] = 8'hf6; // 

//PLAINTEXT [hex] := 1b565f6bce1bde2f9e5363c7
	pt[0] = 8'h1b;
	pt[1] = 8'h56;
	pt[2] = 8'h5f;
	pt[3] = 8'h6b;
	pt[4] = 8'hce;
	pt[5] = 8'h1b;
	pt[6] = 8'hde;
	pt[7] = 8'h2f;
	pt[8] = 8'h9e;
	pt[9] = 8'h53;
	pt[10] = 8'h63;
	pt[11] = 8'hc7;

//CIPHERTEX [hex] := 090cd8c0ac12f5eb6d7b38de
	ct[0] = 8'h09;
	ct[1] = 8'h0c;
	ct[2] = 8'hd8;
	ct[3] = 8'hc0;
	ct[4] = 8'hac;
	ct[5] = 8'h12;
	ct[6] = 8'hf5;
	ct[7] = 8'heb;
	ct[8] = 8'h6d;
	ct[9] = 8'h7b;
	ct[10] = 8'h38;
	ct[11] = 8'hde;
	$write("Reading key...\n");
	key_valid = 1;
	@(posedge clk);
	key_valid = 0;

	for(integer i = 0; i < `KEY_SIZE; i++) begin
		key_input = key[i];
		$display("key[%0d] = %x", i, key_input);
		@(posedge clk);
	end
	@(posedge key_stream_valid);
	$write("Encrypting plaintext and check... \n");
	
	for(integer i = 0; i < 12; i++) begin
		din = pt[i];
		if(i == 5) begin
			din_valid = 0;
			$display("Waiting 3 clock cycles...");
			@(posedge clk);
			@(posedge clk);
		end
		din_valid = 1;
		@(posedge clk);
	end
 -> change_key;
end
initial begin
	@(change_key)
	$display("Changing key and plaintext ...");
	j = 0;
	din_valid = 0;
	key_valid = 0;
	@(posedge clk);

//KEY       [hex] := 0a1caebce6db3327122618832fc53f3d
	key[0] = 8'h0a;
	key[1] = 8'h1c; //
	key[2] = 8'hae; // 
	key[3] = 8'hbc; // 
	key[4] = 8'he6; // 
	key[5] = 8'hdb; // 
	key[6] = 8'h33; // 
	key[7] = 8'h27; //
	key[8] = 8'h12; // 
	key[9] = 8'h26; // 
	key[10] = 8'h18; // 
	key[11] = 8'h83; // 
	key[12] = 8'h2f; // 
	key[13] = 8'hc5; //
	key[14] = 8'h3f; // 
	key[15] = 8'h3d; // 

//PLAINTEXT [hex] := 4c91f0e5a68cd7c643148267
	pt[0] = 8'h4c;
	pt[1] = 8'h91;
	pt[2] = 8'hf0;
	pt[3] = 8'he5;
	pt[4] = 8'ha6;
	pt[5] = 8'h8c;
	pt[6] = 8'hd7;
	pt[7] = 8'hc6;
	pt[8] = 8'h43;
	pt[9] = 8'h14;
	pt[10] = 8'h82;
	pt[11] = 8'h67;

//CIPHERTEX [hex] := 1039d7326a7ed17cd80da9a3
	ct[0] = 8'h10;
	ct[1] = 8'h39;
	ct[2] = 8'hd7;
	ct[3] = 8'h32;
	ct[4] = 8'h6a;
	ct[5] = 8'h7e;
	ct[6] = 8'hd1;
	ct[7] = 8'h7c;
	ct[8] = 8'hd8;
	ct[9] = 8'h0d;
	ct[10] = 8'ha9;
	ct[11] = 8'ha3;
	$write("Reading key...\n");
	key_valid = 1;
	@(posedge clk);
	key_valid = 0;

	for(integer i = 0; i < `KEY_SIZE; i++) begin
		key_input = key[i];
		$display("key[%0d] = %x", i, key_input);
		@(posedge clk);
	end
	@(posedge key_stream_valid);
	$write("Encrypting plaintext and check... \n");
	
	for(integer i = 0; i < 12; i++) begin
		din = pt[i];
		din_valid = 1;
		@(posedge clk);
	end
$stop;
end


endmodule


module rc4_file_enc;

	reg clk = 1'b0;	
	always #5 clk = !clk;
	
	reg rst_n = 1'b0;
	event reset_deassertion;
	
	initial begin
		#12.8 rst_n = 1'b1;
		-> reset_deassertion;
	end

	wire [7:0] Key_stream; // output
	reg  [7:0] din;
	reg din_valid;
	wire [7:0] dout;
	wire key_stream_valid;
	wire dout_ready;
	reg key_valid;
	reg [7:0] key_input; //input

	rc4 rc4mod(
		.clk(clk),
		.rst_n(rst_n),
		.key_valid(key_valid),
		.key_input(key_input),
		.din(din),
		.din_valid(din_valid),
		.dout_ready(dout_ready),
		.key_stream_valid(key_stream_valid),
		.dout(dout)
	);

	integer FP_PTXT;
	integer FP_CTXT;
	integer FP_KEY;
	integer i;
	string char;
	string char_ct;

	initial begin
		@(reset_deassertion);
		din_valid = 0;
		key_valid = 0;
		@(posedge clk); 	//-> key_input a metà clock

		FP_KEY = $fopen("tv/key.txt", "r");
		$write("Reading key...\n");
		key_valid = 1;

		@(posedge clk);
		key_valid = 0;
		i = 0;
		while($fscanf(FP_KEY, "%02x", char) == 1) begin
			key_input = byte'(char);
			$display("key[%0d] = %x", i, key_input);
			i = i + 1;
			@(posedge clk);
		end
    	$fclose(FP_KEY);
		@(posedge key_stream_valid);

		FP_PTXT = $fopen("tv/ptxt.txt", "r");
		$write("Encrypting file 'tv/ptxt.txt' and check... \n");
		
		while($fscanf(FP_PTXT, "%02x", char) == 1) begin
			din = byte'(char);
			din_valid = 1;
			@(posedge clk);
		end
		$fclose(FP_PTXT);

		din_valid = 0;
		@(posedge clk);
		@(posedge clk);
		din = 8'h22;
		din_valid = 1;
		@(posedge clk);
		din_valid = 0;
		@(posedge clk);
		$stop;
	end
initial begin
	@(posedge dout_ready)
		FP_CTXT = $fopen("tv/ctxt.txt", "r");
		while($fscanf(FP_CTXT, "%02x", char_ct) == 1) begin
			@(posedge clk);
			$display("pt_txt = %x ct_gen = %x ct_text = %x. The result is: %-7s",din, dout, byte'(char_ct), byte'(char_ct) === dout ? "CORRECT" : "WRONG");
		end
		$fclose(FP_CTXT);
	end
endmodule