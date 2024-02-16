module rc4(
	input		      clk,
	input		      rst_n,
	input			  key_valid,
	input		[7:0] key_input,
	input       [7:0] din,
	input			  din_valid,
    output reg        key_stream_valid,
	output reg  [7:0] dout,
	output reg        dout_ready
);

localparam KEY_SIZE = 16;

// Key-scheduling state
localparam KEYREAD = 4'h0;
localparam KSA_1 = 4'h1;
localparam KSA_2 = 4'h2;
localparam KSA_3 = 4'h3;
localparam PRGA	 = 4'h4;
localparam IDLE = 4'h5;


// Key
reg [7:0] key[0:KEY_SIZE-1];

reg	[7:0] Key_stream;

// S array
reg [7:0] S[0:255];

reg first_time;
reg second_time;

reg [3:0] state;
reg [7:0] i; 
reg [7:0] j;

reg [7:0] tmp;

always @ (*)
    if(din_valid == 1) begin
		dout <= din ^ Key_stream; 
        dout_ready <= 1'b1;
    end
	else begin
		dout <= 8'h00;
		dout_ready <= 1'b0;
	end

always @ (posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		begin
			i <= 8'h0;
			state <= IDLE;
			j <= 8'h0; 
			key_stream_valid <= 1'b0;
			first_time <= 1'b1;
			second_time <= 1'b1;
		end
	else if (key_valid)
		begin
			i <= 8'h0;
			state <= KEYREAD;
			j <= 8'h0; 
			key_stream_valid <= 1'b0;
			first_time <= 1'b1;
			second_time <= 1'b1;
		end
	else
	case (state)	
		KEYREAD:	begin // KEYREAD state: Read key from input
				if (i == KEY_SIZE)
					begin
					state <= KSA_1;
					i<=8'h00;
					end
				else	begin
					i <= i+1;
					key[i] <= key_input;
					end
				end
		KSA_1:	begin // KSA_1: Increment counter for S initialization
					S[i] <= i;
					if (i == 8'hFF)
						begin
						state <= KSA_2;
						i <= 8'h00;
						end
					else	i <= i + 1;
				end

		KSA_2:	begin // KSA_2: Initialize S array
					j <= (j + S[i] + key[i[3:0]]);
					state <= KSA_3;
				end

		KSA_3:	begin // KSA_3: S array permutation
					S[i]<=S[j];
					S[j]<=S[i];
					if (i == 8'hFF)
						begin
						state <= PRGA;
						i <= 8'h01;
						j <= S[1];
						end
					else begin
						i <= i + 1;
						state <= KSA_2;
						end
				end

		PRGA: begin
				if(first_time == 1 || din_valid == 1 || second_time == 1) begin
					S[i] <= S[j];
					S[j] <= S[i];
					tmp<=S[i]+S[j];
					Key_stream <= S[tmp];	//S[ S[i]+S[j] ];
					if(i == 8'hFF) begin
						i <= 8'h00;
						j <= (j +S[0]);
					end
					else begin
						i <= i+1;
						j <= (j + S[i+1]);
					end
					first_time <= 1'b0;
					if(first_time == 0) begin
						second_time <= 1'b0;
						key_stream_valid <= 1'b1;
					end
				end
			end

		IDLE: begin
				end

		default:	begin
				end
	endcase
	end

endmodule
