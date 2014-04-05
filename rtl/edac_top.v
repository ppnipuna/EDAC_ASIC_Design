`include "encoder.v"
`include "decoder.v"

module edac_top (clk, reset_b,Data_valid_08p,DataParity_valid_12p,Data_in_08p,Data_out_10p,Parity_out_10p,Data_out_14p,EDACerr1_14p, EDACerr2_14p,
		DataParity_in_12p);
	// local signals
	parameter k = 128;
	parameter r = 9;
	input wire clk, reset_b,Data_valid_08p,DataParity_valid_12p;
	input wire [k:1] Data_in_08p;
	output wire [k:1] Data_out_10p;
	output wire [r:1] Parity_out_10p;
	output wire [k:1] Data_out_14p;
	output wire EDACerr1_14p, EDACerr2_14p;
	input wire [k+r:1] DataParity_in_12p;
		
	// instantiate Encoder
	Encoder #(.DATA_BITS(k),.PARITY_BITS(r)) enc1(
	.clk(clk),
	.reset_b(reset_b),
	.Data_valid_08p(Data_valid_08p),
	.Data_in_08p(Data_in_08p),
	.Data_out_10p(Data_out_10p),
	.Parity_out_10p(Parity_out_10p)
	);	
	
	// instantiate Decoder
	Decoder #(.DATA_BITS(k),.PARITY_BITS(r))dec1(
	.clk(clk),
	.reset_b(reset_b),
	.DataParity_valid_12p(DataParity_valid_12p),
	.DataParity_in_12p(DataParity_in_12p),
	.Data_out_14p(Data_out_14p),
	.EDACerr1_14p(EDACerr1_14p),
	.EDACerr2_14p(EDACerr2_14p)
	); 

endmodule