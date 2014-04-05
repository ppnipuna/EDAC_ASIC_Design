module Decoder#(parameter DATA_BITS = 8, PARITY_BITS = 4)(
                DataParity_in_12p, DataParity_valid_12p,reset_b,clk,
                Data_out_14p, EDACerr1_14p,EDACerr2_14p);
	                
	// declare the local parameters and signals
	localparam k = DATA_BITS;
	localparam r = PARITY_BITS;
	input wire clk, reset_b, DataParity_valid_12p;
	input wire [k+r:1] DataParity_in_12p;
	output reg EDACerr1_14p;
	output reg EDACerr2_14p;
	output reg [k:1] Data_out_14p;
	
	//intermediate signals
	reg [r-1:1] syndrome; // required for single error correction
	reg [k+r:1] data_in,temp_data;
	reg [k:1] data_out;
	reg dataparity_valid_int;
	reg err1, err2; // flags to detect single/ double errors
	
	
	// sequential elements
	
	always@(posedge clk or negedge reset_b) begin
	  
	if(~reset_b) begin
	    
		data_in <= 'd0;
	    
		dataparity_valid_int <= 'd0;
	    
		err1 <= 'd0; err2 <= 'd0;
	    
		Data_out_14p <= 'd0;
	    
		EDACerr1_14p <= 1'b0;
	    
		EDACerr2_14p <= 1'b0;
	  
	end
	  
	else if(DataParity_valid_12p) begin
	    
		data_in <= DataParity_in_12p;
		dataparity_valid_int <= DataParity_valid_12p;

		if(dataparity_valid_int) begin
		Data_out_14p <= data_out;
	    
		EDACerr1_14p <= err1;

		EDACerr2_14p <= err2;
	 
		end

	end
		
  end
	
	// combinational logic syndrome generation
	integer i,j,a,l;
	integer cnt;
	reg P;
	 
	always @(data_in) begin
		if(reset_b) begin // only if reset is de-asserted
	  	// calculate the parity over entire codeword to detect double bit errors
		P = ^(data_in);
		temp_data = data_in; //temporary data_in storage
	 
	  for(i=1;i<r;i=i+1) begin
	  	cnt = 1;
		  a = cnt[i-1] & data_in[1];
		  for(cnt=2;cnt<(k+r);cnt=cnt+1) begin
		  	a = a ^ (data_in[cnt] & cnt[i-1]);
		  end
		  syndrome[i] = a;
	  end
	   
	  	// check for errors
		  if(|(syndrome) && P) begin
	    	// which means 1 bit error present
	    	$display("Inside decoder: One bit error was present at %0d bit, and is corrected",syndrome);
			temp_data[syndrome] = ~temp_data[syndrome]; // bit corrected
			err1 = 1'b1; err2 = 1'b0;
	    	end
	  	  else if(|(syndrome) && ~P) begin
	    	// double error present
			$display("Inside decoder: Double bit error was present");
	    	err2 = 1'b1; err1 = 1'b0;
	  	  end
	  	  else if (~(|syndrome) && ~P)begin
		   // no error present
		  $display("Inside decoder: No error was found in the data received");
		  err1 = 1'b0; err2 = 1'b0;
		  end
		  
		  // extract data_out from data_in
	   		j = 1; l = 1;
	  		while ( (l<k+r) || (j<=k)) begin
	    	if ( l == ((~l+1)&l)) begin
	      		l = l+1;
	    	end
	    	else begin
	      	data_out[j] = temp_data[l];
	      	j = j+1; l = l+1;
	    	end
	  		end
			  
			if(|(err1))
				$display("Inside decoder: Data after correction: %h",data_out);
			else
				$display("Decoder output: Data: %h",data_out);
	  	end
	end 
endmodule
