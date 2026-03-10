interface adder4_bus;
  logic[3:0] a;
  logic[3:0] b;
  logic cin;
  logic [3:0] s;
  logic out;
endinterface

module adder4_tb;
  adder4_bus inf();
  four_bit_adder dut(inf.a,inf.b,inf.cin,inf.s,inf.out);
  
  class adder4_trans;
    rand bit [3:0] a;
    rand bit [3:0] b;
    rand bit cin;
    bit[3:0] s;
    bit out;
  endclass
  
  mailbox #(adder4_trans) mbx = new();
  mailbox #(adder4_trans) mbs = new();
  
  class adder4_gen;
    mailbox #(adder4_trans) mbx;
    function new(mailbox #(adder4_trans) mbx);
      this.mbx = mbx;
    endfunction
    
    task run();
      adder4_trans p1;
      repeat(200) begin
        p1 = new();
        assert(p1.randomize());
        mbx.put(p1);
      end
    endtask
  endclass
  
  class adder4_drive;
    virtual adder4_bus inf;
    mailbox #(adder4_trans) mbx;
    function new(mailbox #(adder4_trans) mbx);
      this.mbx = mbx;
    endfunction
    
    task run();
      adder4_trans p1;
      repeat(200) begin
        mbx.get(p1);
        inf.a = p1.a;
        inf.b = p1.b;
        inf.cin = p1.cin;
        #10;
      end
    endtask
  endclass
  
  
  class adder4_monitor;
    virtual adder4_bus inf;
    mailbox #(adder4_trans) mbs;
    function new(virtual adder4_bus inf,mailbox #(adder4_trans) mbs);
      this.mbs = mbs;
      this.inf = inf;
    endfunction
    task run();
      adder4_trans p2;
      repeat(200) begin
        #11;
        p2 = new();
        p2.a = inf.a;
        p2.b = inf.b;
        p2.cin = inf.cin;
        p2.s = inf.s;
        p2.out = inf.out;
        mbs.put(p2);
      end
    endtask
  endclass
  
  
  class adder4_scoreb;
    mailbox #(adder4_trans) mbs;
    int item_pass,item_fail;
    function new(mailbox #(adder4_trans) mbs);
      this.mbs = mbs;
    endfunction
    task run();

  adder4_trans p3;

  bit [4:0] expected;
  bit [3:0] expected_sum;
  bit expected_out;

  repeat(200) begin

    mbs.get(p3);

    expected = p3.a + p3.b + p3.cin;

    expected_sum = expected[3:0];
    expected_out = expected[4];

    if((p3.out == expected_out) && (p3.s == expected_sum)) begin

      $display("PASS: t=%0t a=%b b=%b cin=%b s=%b out=%b",
      $time,p3.a,p3.b,p3.cin,p3.s,p3.out);

      item_pass++;

    end
    else begin

      $display("FAIL: t=%0t a=%b b=%b cin=%b s=%b out=%b expected_s=%b expected_out=%b",
      $time,p3.a,p3.b,p3.cin,p3.s,p3.out,expected_sum,expected_out);

      item_fail++;

    end

  end

  $display("PASS COUNT = %0d",item_pass);
  $display("FAIL COUNT = %0d",item_fail);

endtask
endclass
  
        
  adder4_gen g1;
  adder4_drive d1;
  adder4_monitor m1;
  adder4_scoreb s1;
  
  initial begin
    g1= new(mbx);
    d1 = new(mbx);
    m1 = new(inf,mbs);
    s1 = new(mbs);
    
    d1.inf = inf;
    fork
      g1.run();
      d1.run();
      m1.run();
      s1.run();
    join
     $display("Simulation Finished");
    $finish;
    
  end
  
endmodule

