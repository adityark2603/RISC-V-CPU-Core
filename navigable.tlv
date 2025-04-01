\TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/VSDOpen2020_TLV_RISC-V_Tutorial
   
   // Included URL: "https://raw.githubusercontent.com/stevehoover/VSDOpen2020_TLV_RISC-V_Tutorial/dcabbd37512dc05cc7103770c184590387a72ada/lib/shell.tlv"// Included URL: "https://raw.githubusercontent.com/stevehoover/warp-v_includes/2d6d36baa4d2bc62321f982f78c8fe1456641a43/risc-v_defs.tlv"

\SV
   module top(input wire clk, input wire reset, input wire [31:0] cyc_cnt, output wire passed, output wire failed);    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  /* verilator lint_restore */  /* verilator lint_off WIDTH */ /* verilator lint_off UNOPTFLAT */   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */

\TLV

   
   // ------------------------------------------------------------
   //
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   // Inst #0: ADD,r10,r0,r0             // Initialize r10 to 0.
   // Function:
   // Inst #1: ADD,r14,r10,r0            // Initialize sum register r14 with 0x0
   // Inst #2: ADDI,r12,r10,1010         // Store count of 10 in register r12.
   // Inst #3: ADD,r13,r10,r0            // Initialize intermediate sum register r13 with 0
   // Loop:
   // Inst #4: ADD,r14,r13,r14           // Incremental addition
   // Inst #5: ADDI,r13,r13,1            // Increment intermediate register by 1
   // Inst #6: BLT,r13,r12,1111111111000 // If r13 is less than r12, branch to <loop>
   // Inst #7: ADD,r10,r14,r0            // Store final result to register r10 so that it can be read by main program
   //
   // ------------------------------------------------------------
   
   // PC
   $pc[31:0] = >>1$reset        ? 32'b0 :
               >>1$taken_branch ? >>1$br_target_pc :    // (initially $taken_branch == 0)
                                  >>1$pc + 32'b100;
   
   
   // IMem Hookup
   $imem_rd_addr[2:0] = $pc[4:2];
   $instr[31:0] = $imem_rd_data;
   
   
   // **Lab: Instruction Types Decode
   $is_i_instr = $instr[6:5] == 2'b00;
   $is_r_instr = $instr[5] ^ $instr[6];
   $is_b_instr = $instr[6:5] == 2'b11;
   
   
   // **Lab: Instruction Immediate Decode
   $imm[31:0]  = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] }    // I-type
                 :$is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0}
                 :32'b0;   // Default (unused)
   
   
   // **Lab: Instruction Field Decode
   $rs2[4:0]    = $instr[24:20];
   $rs1[4:0]    = $instr[19:15];
   $funct3[2:0] = $instr[14:12];
   $rd[4:0]     = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
   
   
   // **Lab: Register Validity Decode
   $rs1_valid = $is_r_instr || $is_i_instr || $is_b_instr;
   $rs2_valid = $is_r_instr || $is_b_instr;
   $rd_valid  = $is_r_instr || $is_i_instr;
   
   
   // Register File Read Hookup
   $rf_rd_en1         = $rs1_valid;
   $rf_rd_en2         = $rs2_valid;
   $rf_rd_index1[4:0] = $rs1;
   $rf_rd_index2[4:0] = $rs2;
   $src1_value[31:0] = $rf_rd_data1;
   $src2_value[31:0] = $rf_rd_data2;
   
   
   // **Lab: Instruction Decode
   $dec_bits[9:0] = {$funct3, $opcode};
   $is_blt  = $dec_bits == 10'b1001100011;
   $is_addi = 10'b0000010011;
   $is_add  = 10'b0000110011;
   
   
   // **Lab: ALU
   $result[31:0] = $is_addi ? $src1_value + $imm : $is_add ? $src1_value + $src2_value: 32'b0;   // ADDI: src1 + imm
                   //TBD   // ADD: src1 + src2
                                 // Default (unused)
   
   
   // Register File Write Hookup
   $rf_wr_en         = $rd_valid;
   $rf_wr_index[4:0] = $rd;
   $rf_wr_data[31:0] = $result;
   
   
   // **Lab: Branch Condition
   $taken_branch = $is_blt ? $src1_value < $src2_value: 1'b0;
   
   
   // **Lab: Branch Target
   $br_target_pc[31:0] = $taken_branch ? $pc[31:0] + $imm[31:0] : $pc[31:0] + 1;
   // Note: $taken_branch and $br_target_pc control the PC mux.
   
   
   
   \source /raw.githubusercontent.com/stevehoover/VSDOpen2020TLVRISCVTutorial/dcabbd37512dc05cc7103770c184590387a72ada/lib/shell.tlv 16   // Instantiated from top.tlv, 118 as: m4+shell()
      // =======================================================================================================
      // THIS CODE IS PROVIDED. NO NEED TO LOOK BEHIND THE CURTAIN. LEARN MORE USING THE MAKERCHIP TUTORIALS.
      
      
      
      
      $reset = *reset;
      
      // Instruction Memory containing program defined by m4_asm(...) instantiations.
      \SV_plus
         // The program in an instruction memory.
         logic [31:0] instrs [0:8-1];
         assign instrs = '{
            {7'b0000000, 5'd0, 5'd0, 3'b000, 5'd10, 7'b0110011}, {7'b0000000, 5'd0, 5'd10, 3'b000, 5'd14, 7'b0110011}, {12'b1010, 5'd10, 3'b000, 5'd12, 7'b0010011}, {7'b0000000, 5'd0, 5'd10, 3'b000, 5'd13, 7'b0110011}, {7'b0000000, 5'd14, 5'd13, 3'b000, 5'd14, 7'b0110011}, {12'b1, 5'd13, 3'b000, 5'd13, 7'b0010011}, {1'b1, 6'b111111, 5'd12, 5'd13, 3'b100, 4'b1100, 1'b1, 7'b1100011}, {7'b0000000, 5'd0, 5'd14, 3'b000, 5'd10, 7'b0110011}
         };
      /imem[7:0]
         $instr[31:0] = *instrs\[#imem\];
      $imem_rd_data[31:0] = /imem[$imem_rd_addr]$instr;
      `BOGUS_USE($imem_rd_data)
      
      // Reg File
      /xreg[31:0]
         $wr = /top$rf_wr_en && (/top$rf_wr_index != 5'b0) && (/top$rf_wr_index == #xreg);
         $value[31:0] = /top$reset ? 32'b0           :
                        $wr        ? /top$rf_wr_data :
                                     $RETAIN;
      $rf_rd_data1[31:0] = /xreg[$rf_rd_index1]>>1$value;
      $rf_rd_data2[31:0] = /xreg[$rf_rd_index2]>>1$value;
      `BOGUS_USE($rf_rd_data1 $rf_rd_data2)
      
      // Assert these to end simulation (before Makerchip cycle limit).
      *passed = /xreg[10]>>1$value == (1+2+3+4+5+6+7+8+9);
      *failed = *cyc_cnt > 50;
      
      
      |for_viz_only
         @0
            // String representations of the instructions for debug.
            \SV_plus
               logic [40*8-1:0] instr_strs [0:8];
               assign instr_strs = '{ "(R) ADD r10,r0,r0                       ",  "(R) ADD r14,r10,r0                      ",  "(I) ADDI r12,r10,1010                   ",  "(R) ADD r13,r10,r0                      ",  "(R) ADD r14,r13,r14                     ",  "(I) ADDI r13,r13,1                      ",  "(B) BLT r13,r12,1111111111000           ",  "(R) ADD r10,r14,r0                      ",  "END                                     "};
            $ANY = /top<>0$ANY;
            /imem[7:0]
               $ANY = /top/imem<>0$ANY;
               $instr_str[40*8-1:0] = *instr_strs[imem];
   
            $mnemonic[10*8-1:0] = $is_blt  ? "BLT       " :
                                  $is_addi ? "ADDI      " :
                                  $is_add  ? "ADD       " :  "UNKNOWN   ";
            $valid = ! $reset;
            `BOGUS_USE($pc[4:0])  // Bug workaround to pull lower bits.
            $fetch_instr_str[40*8-1:0] = *instr_strs\[$pc[\$clog2(8+1)+1:2]\];
            \viz_js
               box: {strokeWidth: 0},
               init() {
                  let imem_header = new fabric.Text("Instr. Memory", {
                        top: -29,
                        left: -440,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace"
                     })
                  let decode_header = new fabric.Text("Instr. Decode", {
                        top: 0,
                        left: 65,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace"
                     })
                  let rf_header = new fabric.Text("Reg. File", {
                        top: -29 - 40,
                        left: 307,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace"
                     })
                  return {imem_header, decode_header, rf_header}
               },
               render() {
                  //debugger
                  //
                  // PC instr_mem pointer
                  //
                  let $pc = '$pc';
                  let color = !('$valid'.asBool()) ? "gray" :
                                                     "blue";
                  let pcPointer = new fabric.Text("->", {
                     top: 18 * ($pc.asInt() / 4),
                     left: -295,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  let pc_arrow = new fabric.Line([23, 18 * ($pc.asInt() / 4) + 6, 46, 35], {
                     stroke: "#d0e8ff",
                     strokeWidth: 2
                  })
                  let rs1_arrow = new fabric.Line([330, 18 * '$rf_rd_index1'.asInt() + 6 - 40, 190, 75 + 18 * 2], {
                     stroke: "#d0e8ff",
                     strokeWidth: 2,
                     visible: '$rf_rd_en1'.asBool()
                  })
                  let rs2_arrow = new fabric.Line([330, 18 * '$rf_rd_index2'.asInt() + 6 - 40, 190, 75 + 18 * 3], {
                     stroke: "#d0e8ff",
                     strokeWidth: 2,
                     visible: '$rf_rd_en2'.asBool()
                  })
                  let rd_arrow = new fabric.Line([330, 18 * '$rf_wr_index'.asInt() + 6 - 40, 168, 75 + 18 * 0], {
                     stroke: "#d0d0ff",
                     strokeWidth: 3,
                     visible: '$rf_wr_en'.asBool()
                  })
                  //
                  // Fetch Instruction
                  //
                  // TODO: indexing only works in direct lineage.  let fetchInstr = new fabric.Text('|fetch/instr_mem[$Pc]$instr'.asString(), {  // TODO: make indexing recursive.
                  //let fetchInstr = new fabric.Text('$raw'.asString("--"), {
                  //   top: 50,
                  //   left: 90,
                  //   fill: color,
                  //   fontSize: 14,
                  //   fontFamily: "monospace"
                  //});
                  //
                  // Instruction with values.
                  //
                  let regStr = (valid, regNum, regValue) => {
                     return valid ? `r${regNum}` : `rX`  // valid ? `r${regNum} (${regValue})` : `rX`
                  };
                  let srcStr = ($src, $valid, $reg, $value) => {
                     return $valid.asBool(false)
                                ? `\n      ${regStr(true, $reg.asInt(NaN), $value.asInt(NaN))}`
                                : "";
                  };
                  let str = `${regStr('$rd_valid'.asBool(false), '$rd'.asInt(NaN), '$result'.asInt(NaN))}\n` +
                            `  = ${'$mnemonic'.asString()}${srcStr(1, '$rs1_valid', '$rs1', '$src1_value')}${srcStr(2, '$rs2_valid', '$rs2', '$src2_value')}\n` +
                            ('$is_r_instr'.asBool() ? "" : `      i[${'$imm'.asInt(NaN)}]`);
                  let instrWithValues = new fabric.Text(str, {
                     top: 70,
                     left: 65,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  // Animate fetch (and provide onChange behavior for other animation).
                  
                  let fetch_instr = new fabric.Text('$fetch_instr_str'.asString(), {
                     top: 18 * ($pc.asInt() / 4),
                     left: -272,
                     fill: "blue",
                     fontSize: 14,
                     fontFamily: "monospace"
                  })
                  fetch_instr.animate({top: 32, left: 50}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  });
                  
                  let src1_value = new fabric.Text('$src1_value'.asInt(0).toString(), {
                     left: 316 + 8 * 4,
                     top: 18 * '$rs1'.asInt(0) - 40,
                     fill: "blue",
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: '$rs1_valid'.asBool(false)
                  })
                  setTimeout(() => {src1_value.animate({left: 166, top: 70 + 18 * 2}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  })}, 500)
                  let src2_value = new fabric.Text('$src2_value'.asInt(0).toString(), {
                     left: 316 + 8 * 4,
                     top: 18 * '$rs2'.asInt(0) - 40,
                     fill: "blue",
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: '$rs2_valid'.asBool(false)
                  })
                  setTimeout(() => {src2_value.animate({left: 166, top: 70 + 18 * 3}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  })}, 500)
                  let result_shadow = new fabric.Text('$result'.asInt(0).toString(), {
                     left: 146,
                     top: 70,
                     fill: "#d0d0ff",
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: false
                  })
                  let result = new fabric.Text('$result'.asInt(0).toString(), {
                     left: 146,
                     top: 70,
                     fill: "blue",
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: false
                  })
                  if ('$rd_valid'.asBool()) {
                     setTimeout(() => {
                        result.set({visible: true})
                        result_shadow.set({visible: true})
                        result.animate({left: 317 + 8 * 4, top: 18 * '$rd'.asInt(0) - 40}, {
                          onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                          duration: 500
                        })
                     }, 1000)
                  }
                  
                  return [pcPointer, pc_arrow, rs1_arrow, rs2_arrow, rd_arrow, instrWithValues, fetch_instr, src1_value, src2_value, result_shadow, result]
               }
            //
            // Register file
            //
            /imem[7:0]  // TODO: Cleanly report non-integer ranges.
               $rd = ! |for_viz_only$reset && |for_viz_only$pc[4:2] == #imem;
               \viz_js
                  box: {width: 400, height: 18, left: -600, top: 0, strokeWidth: 0},
                  init() {
                    let binary = new fabric.Text("", {
                       top: 0,
                       left: -600,
                       fontSize: 14,
                       fontFamily: "monospace"
                    })
                    let disassembled = new fabric.Text("", {
                       top: 0,
                       left: -270,
                       fontSize: 14,
                       fontFamily: "monospace"
                    })
                    return {binary, disassembled}
                  },
                  onTraceData() {
                     // Instruction memory is constant, so just create it once
                     let binary_str       = '$instr'.asBinaryStr(NaN)
                     let disassembled_str = '$instr_str'.asString()
                     disassembled_str = disassembled_str.slice(0, -5)
                     this.getObjects().binary.set({text: binary_str})
                     this.getObjects().disassembled.set({text: disassembled_str})
                  },
                  render() {
                     this.getObjects().disassembled.set({textBackgroundColor: '$rd'.asBool() ? "#b0ffff" : "white"})
                  }
            /xreg[31:0]
               $ANY = /top/xreg<>0$ANY;
               $rd = (|for_viz_only$rf_rd_en1 && |for_viz_only$rf_rd_index1 == #xreg) ||
                     (|for_viz_only$rf_rd_en2 && |for_viz_only$rf_rd_index2 == #xreg);
               \viz_js
                  box: {width: 100, height: 18, strokeWidth: 0},
                  render() {
                     let rd = '$rd'.asBool(false);
                     let mod = '$wr'.asBool(false);
                     let reg = parseInt(this.getIndex());
                     let regIdent = reg.toString().padEnd(2, " ");
                     let newValStr = regIdent + ": " + (mod ? '$value'.asInt(NaN).toString() : "");
                     let reg_str = new fabric.Text(regIdent + ": " + '>>1$value'.asInt(NaN).toString(), {
                        top: 0, left: 0,
                        fontSize: 14,
                        fill: mod ? "blue" : "black",
                        fontWeight: mod ? 800 : 400,
                        fontFamily: "monospace",
                        textBackgroundColor: rd ? "#b0ffff" : null
                     })
                     if (mod) {
                        setTimeout(() => {
                           console.log(`Reg ${this.getIndex()} written with: ${newValStr}.`)
                           reg_str.set({text: newValStr, dirty: true})
                           this.global.canvas.renderAll()
                        }, 1500)
                     }
                     return [reg_str]
                  },
                  where: {left: 316, top: -40}
   \end_source


\SV
   endmodule
