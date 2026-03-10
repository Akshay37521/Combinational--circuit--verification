interface MUX_bus;
  logic [3:0] ip;
  logic [1:0] sel;
  logic out;
endinterface

module MUX_tb;
  MUX_bus inf();
  MUX41 dut(inf.ip,inf.sel,inf.out);
  
  class MUX_trans;
    rand bit[3:0] ip;
    rand bit[1:0] sel;
    bit out;
  endclass
  
  mailbox #(MUX_trans) mbx = new();
  mailbox #(MUX_trans) mbs = new();
    
  
  class MUX_gen;
    mailbox #(MUX_trans) mbx;
    function new(mailbox #(MUX_trans) mbx );
      this.mbx = mbx;
    endfunction
    
    task run();
      MUX_trans m;
      repeat(200) begin
        m = new();
        assert (m.randomize());
        mbx.put(m);
      end
    endtask
  endclass
  
  class MUX_drive;
    virtual MUX_bus inf;
    mailbox #(MUX_trans) mbx;
    function new(mailbox #(MUX_trans) mbx );
      this.mbx = mbx;
    endfunction
    task run();
      MUX_trans m;
      repeat(200) begin
        mbx.get(m);
        inf.sel = m.sel;
        inf.ip = m.ip;
        #10;
      end
      
      
    endtask
  endclass
  
  class MUX_monitor;
    virtual MUX_bus inf;
    mailbox #(MUX_trans) mbs;
    function new(virtual MUX_bus inf,mailbox #(MUX_trans) mbs);
      this.mbs = mbs;
      this.inf = inf;
    endfunction
    task run();
      MUX_trans p1;
      repeat(200) begin
      #5;
        p1 = new();
        p1.sel = inf.sel;
        p1.ip = inf.ip;
        p1.out = inf.out;
      $display("[Monitor] Select-line %b,input:%b out:%b",p1.sel,p1.ip,p1.out);
      mbs.put(p1); // Send to scoreboard
      end
    
  endtask
  endclass
  
  class MUX_scoreb;
    mailbox #(MUX_trans) mbs;
    int item_pass,item_fail;
    function new(mailbox #(MUX_trans) mbs);
      this.mbs = mbs;
    endfunction
    task run();
      MUX_trans p2 ;
      bit expected;
      repeat(200) begin
        
        
        mbs.get(p2);
        expected = p2.ip[p2.sel];
        
        
        if(p2.out == expected) begin
          $display("PASS: t=%0t sel = %b ip =%b out =%b",$time,p2.sel,p2.ip,p2.out);
         item_pass++;
        end
        else begin
          $display("FAIL: t=%0t sel = %b ip =%b out =%b expected = %b",$time,p2.sel,p2.ip,p2.out,expected);
        item_fail++;
        end
        
        
      end
      $display("NO. of pass test case is %d",item_pass);
        $display("NO.of fail test case is %d",item_fail);
    endtask
    
  endclass
  
        
          
  MUX_gen g1;
  MUX_drive d1;
  MUX_monitor m1;
  MUX_scoreb s1;
  
  initial begin
    g1 = new(mbx);
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

    
      
