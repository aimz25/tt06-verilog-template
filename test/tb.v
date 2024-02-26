module johnson_test;

parameter size=7;
reg clk;
reg r;
wire [0:size]out;

johnson xjohnson(clk,r,out);

initial begin
      clk=1;
      r=0;
      #5 r=1;
      #5 r=0;
      #20 $finish;
end

initial $monitor($time,,"[%b]\t%b\tq=%b",clk,r,out);

always #2 clk=~clk;
   
endmodule


   
