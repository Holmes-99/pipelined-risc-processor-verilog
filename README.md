<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,100:16213e&height=200&section=header&text=Pipelined%20RISC%20Processor&fontSize=40&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=32-bit%20Predicated%20%7C%20Verilog%20%7C%20Birzeit%20University&descAlignY=60&descSize=16&descColor=a8dadc"/>
Show Image
Show Image
Show Image
Show Image
Show Image
</div>

🚀 The Pipeline — How It Works

Every instruction travels through 5 stages simultaneously — like an assembly line. While one instruction is executing, the next is being decoded, and the one after is being fetched.

  Clock Cycle →    1      2      3      4      5      6      7
                ┌──────┬──────┬──────┬──────┬──────┬──────┬──────┐
  Instruction 1 │  IF  │  ID  │  EX  │  MEM │  WB  │      │      │
                ├──────┼──────┼──────┼──────┼──────┼──────┼──────┤
  Instruction 2 │      │  IF  │  ID  │  EX  │  MEM │  WB  │      │
                ├──────┼──────┼──────┼──────┼──────┼──────┼──────┤
  Instruction 3 │      │      │  IF  │  ID  │  EX  │  MEM │  WB  │
                └──────┴──────┴──────┴──────┴──────┴──────┴──────┘

⚙️ Pipeline Stages
  ┌─────────────────────────────────────────────────────────────────┐
  │                                                                 │
  │   ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐    │
  │   │  IF  │───▶│  ID  │───▶│  EX  │───▶│ MEM  │───▶│  WB  │    │
  │   │      │    │      │    │      │    │      │    │      │    │
  │   │Fetch │    │Decode│    │ ALU  │    │ Data │    │Write │    │
  │   │Instr │    │ Regs │    │ Ops  │    │ Mem  │    │ Back │    │
  │   └──────┘    └──────┘    └──────┘    └──────┘    └──────┘    │
  │       │           │           │           │           │        │
  │    PC+1        Control      Result      Load/     Register     │
  │    Update      Signals    Computed      Store      Update      │
  │                                                                 │
  └─────────────────────────────────────────────────────────────────┘
StageNameWhat HappensIFInstruction FetchPC → Memory → Fetch 32-bit instruction → PC+1IDInstruction DecodeDecode opcode, read Rp, Rs, Rt from register file, check predicateEXExecuteALU performs operation — ADD, SUB, AND, OR, address calcMEMMemory AccessLoad (LW) reads from data memory, Store (SW) writes to data memoryWBWrite BackResult written back to destination register Rd

🔮 Predicated Execution

This processor supports predicated execution — every instruction has a predicate register Rp that controls whether it runs.

  ┌─────────────────────────────────────────────────┐
  │           PREDICATED EXECUTION LOGIC            │
  │                                                 │
  │   Instruction: ADD R1, R2, R3, Rp               │
  │                                                 │
  │         ┌──────────────────┐                   │
  │         │  Read Reg[Rp]    │                   │
  │         └────────┬─────────┘                   │
  │                  │                              │
  │         ┌────────▼─────────┐                   │
  │         │   Reg[Rp] == 0 ? │                   │
  │         └────────┬─────────┘                   │
  │          YES ◀───┴───▶ NO                       │
  │           │               │                    │
  │    ┌──────▼──────┐ ┌──────▼──────┐             │
  │    │    SKIP     │ │   EXECUTE   │             │
  │    │ (NOP/Bubble)│ │ R1 = R2+R3  │             │
  │    └─────────────┘ └─────────────┘             │
  └─────────────────────────────────────────────────┘

📋 Instruction Set
<details>
<summary><b>🔷 R-Type Instructions (click to expand)</b></summary>
  Format: | Opcode(5) | Rp(5) | Rd(5) | Rs(5) | Rt(5) | Unused(7) |
InstructionOpcodeOperationADD Rd, Rs, Rt, Rp00000Reg[Rd] = Reg[Rs] + Reg[Rt]SUB Rd, Rs, Rt, Rp00001Reg[Rd] = Reg[Rs] - Reg[Rt]OR Rd, Rs, Rt, Rp00010Reg[Rd] = Reg[Rs] OR Reg[Rt]NOR Rd, Rs, Rt, Rp00011Reg[Rd] = NOT(Reg[Rs] OR Reg[Rt])AND Rd, Rs, Rt, Rp00100Reg[Rd] = Reg[Rs] AND Reg[Rt]JR Rs, Rp01110PC = Reg[Rs]
</details>
<details>
<summary><b>🔶 I-Type Instructions (click to expand)</b></summary>
  Format: | Opcode(5) | Rp(5) | Rd(5) | Rs(5) | Immediate(12) |
InstructionOpcodeOperationADDI Rd, Rs, Imm, Rp00101Reg[Rd] = Reg[Rs] + ImmORI Rd, Rs, Imm, Rp00110Reg[Rd] = Reg[Rs] OR ImmNORI Rd, Rs, Imm, Rp00111Reg[Rd] = NOT(Reg[Rs] OR Imm)ANDI Rd, Rs, Imm, Rp01001Reg[Rd] = Reg[Rs] AND ImmLW Rd, Imm(Rs), Rp01010Reg[Rd] = Mem(Reg[Rs] + Imm)SW Rd, Imm(Rs), Rp01011Mem(Reg[Rs] + Imm) = Reg[Rd]
</details>
<details>
<summary><b>🔴 J-Type Instructions (click to expand)</b></summary>
  Format: | Opcode(5) | Rp(5) | Offset(22) |
InstructionOpcodeOperationJ Label, Rp01100PC = PC + sign_extend(Offset)CALL Label, Rp01101R31 = PC+1, PC = PC + sign_extend(Offset)
</details>

🏗️ Processor Architecture
                    ┌─────────────────────────────────┐
                    │         REGISTER FILE            │
                    │  R0=0  R30=PC  R31=RetAddr       │
                    │  32 × 32-bit General Purpose     │
                    └──────────────┬──────────────────┘
                                   │
   ┌──────────┐    ┌──────────┐    │    ┌──────────┐    ┌──────────┐
   │   INSTR  │    │  CONTROL │    │    │   ALU    │    │   DATA   │
   │  MEMORY  │───▶│   PATH   │    │    │          │    │  MEMORY  │
   │          │    │          │    │    │ +,-,AND  │    │          │
   └──────────┘    └──────────┘    │    │  OR,NOR  │    └──────────┘
                                   ▼    └──────────┘
              ┌────────────────────────────────────────┐
              │         IF/ID  │  ID/EX  │ EX/MEM │ MEM/WB │
              │         PIPELINE REGISTERS             │
              └────────────────────────────────────────┘

📁 Project Structure
pipelined-risc-processor-verilog/
│
├── src/
│   ├── processor.v       ← Top-level pipelined processor
│   ├── datapath.v        ← Pipelined datapath + pipeline registers
│   ├── control.v         ← Control signals generation
│   ├── alu.v             ← ALU module
│   └── memory.v          ← Instruction & data memory
│
├── testbench/
│   └── testbench.v       ← Simulation testbench
│
├── datapath/
│   └── datapath.circ     ← Full datapath diagram (Logisim/CircuitVerse)
│
└── report/
    └── report.pdf        ← Full report with simulation screenshots

▶️ How to Run
bash# 1. Open ModelSim or Vivado
# 2. Compile all source files
vlog src/*.v testbench/testbench.v

# 3. Run simulation
vsim testbench

# 4. View waveforms to verify pipeline stages

📚 Course Info
CourseENCS4370 — Computer ArchitectureUniversityBirzeit University 🇵🇸SemesterFall 2025/2026LanguageVerilog HDL

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:16213e,100:1a1a2e&height=100&section=footer"/>
</div>
