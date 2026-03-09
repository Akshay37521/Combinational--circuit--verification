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
        #5;
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
    forever begin
      #5;
      
      
        MUX_trans p1 = new();
      
      
        p1.sel = inf.sel;
        p1.ip = inf.ip;
        p1.out = inf.out;
      $display("[Monitor] Select-line %b,input:%b out:%b",p1.sel,p1.ip,p1.out);
      mbs.put(p1); // Send to scoreboard
      end
    
  endtask
  endclass
  
  
  MUX_gen g1;
  MUX_drive d1;
  MUX_monitor m1;
  
  initial begin
    g1 = new(mbx);
    d1 = new(mbx);
    m1 = new(inf,mbs);
    
    d1.inf = inf;
    fork
      g1.run();
      d1.run();
      m1.run();
    join
    
  end
  
endmodule

    
      
