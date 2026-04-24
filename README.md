<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,100:16213e&height=180&section=header&text=Pipelined%20RISC%20Processor&fontSize=38&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=32-bit%20Predicated%20%7C%20Verilog%20HDL%20%7C%20Birzeit%20University&descAlignY=60&descSize=15&descColor=a8dadc"/>

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=18&duration=2500&pause=800&color=A8DADC&center=true&vCenter=true&width=700&lines=5-Stage+Pipelined+32-bit+RISC+Processor;Designed+%26+Verified+in+Verilog+HDL;Forwarding+%7C+Stalling+%7C+Predicated+Execution;IF+%E2%86%92+ID+%E2%86%92+EX+%E2%86%92+MEM+%E2%86%92+WB)](https://git.io/typing-svg)

![Verilog](https://img.shields.io/badge/Verilog-HDL-FF6B6B?style=for-the-badge)
![Pipeline](https://img.shields.io/badge/Pipeline-5--Stage-1D9E75?style=for-the-badge)
![Bits](https://img.shields.io/badge/Architecture-32--bit-185FA5?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Verified-success?style=for-the-badge)
![University](https://img.shields.io/badge/Birzeit%20University-ENCS4370-1a1a2e?style=for-the-badge)

</div>

---
## Logisim DataPath of Piplined Proccessor
<img width="4631" height="1861" alt="Piplined_proccessor_Datapath" src="https://github.com/user-attachments/assets/d8814c98-d449-497a-8832-fe545f6dbb7d" />


## 📋 Abstract

A 32-bit predicated RISC processor implemented in Verilog HDL with a **5-stage pipeline** architecture. Supports R-Type, I-Type, and J-Type instructions with predicated execution controlled by a predicate register (Rp). Features a 32-register file, Harvard memory architecture, full forwarding network, stall logic, and kill logic. Verified through simulation covering all instruction types, data hazards, control hazards, and predicated execution.

> **Measured CPI ≈ 1.15** across a full test program including stalls and control-hazard flushes.

---

## ⚙️ The 5-Stage Pipeline

```
  ┌──────────┬──────────┬──────────┬──────────┬──────────┐
  │    IF    │    ID    │    EX    │   MEM    │    WB    │
  │──────────│──────────│──────────│──────────│──────────│
  │  Fetch   │  Decode  │ Execute  │  Memory  │  Write   │
  │ Instr    │  Regs    │ ALU Ops  │  Access  │  Back    │
  └──────────┴──────────┴──────────┴──────────┴──────────┘
       │          │          │          │          │
     IF/ID ──► ID/EX ──► EX/MEM ──► MEM/WB ──► Register File
                    Pipeline Registers carry data forward
```

### Pipeline Timing — 3 instructions in flight simultaneously

| Instruction | C1 | C2 | C3 | C4 | C5 | C6 | C7 |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `ADD R1,R2,R3` | **IF** | **ID** | **EX** | MEM | WB | — | — |
| `LW R4,0(R5)` | — | **IF** | **ID** | **EX** | MEM | WB | — |
| `SUB R6,R4,R1` | — | — | **IF** | **ID** | **EX** | MEM | WB |

---

## 🔮 Predicated Execution

Every instruction has a predicate register field **Rp** — this is what makes this processor unique.

```
  ExecuteEn = (Rp_addr == 0) OR (Reg[Rp] != 0)

  Case 1: Rp = R0           → always executes (unconditional)
  Case 2: Rp = R5, R5 = 99  → ExecuteEn = 1  → instruction runs
  Case 3: Rp = R5, R5 = 0   → ExecuteEn = 0  → instruction becomes NOP
```

**What happens on skip?** The instruction travels through all 5 stages normally. But in the ID stage, `RegWrite`, `MemRead`, and `MemWrite` are all gated to 0. No register or memory is ever modified. No pipeline flush needed — this is more efficient than branching.

---

## 📐 Instruction Set Architecture

<details>
<summary><b>🔷 R-Type — Opcode(5) | Rp(5) | Rd(5) | Rs(5) | Rt(5) | Unused(7)</b></summary>

| Instruction | Opcode | Operation | Path |
|:---|:---:|:---|:---:|
| `ADD Rd,Rs,Rt,Rp` | 0 | `Reg[Rd] = Reg[Rs] + Reg[Rt]` | IF→ID→EX→WB |
| `SUB Rd,Rs,Rt,Rp` | 1 | `Reg[Rd] = Reg[Rs] - Reg[Rt]` | IF→ID→EX→WB |
| `OR Rd,Rs,Rt,Rp` | 2 | `Reg[Rd] = Reg[Rs] \| Reg[Rt]` | IF→ID→EX→WB |
| `NOR Rd,Rs,Rt,Rp` | 3 | `Reg[Rd] = ~(Reg[Rs] \| Reg[Rt])` | IF→ID→EX→WB |
| `AND Rd,Rs,Rt,Rp` | 4 | `Reg[Rd] = Reg[Rs] & Reg[Rt]` | IF→ID→EX→WB |
| `JR Rs,Rp` | 13 | `PC = Reg[Rs]` | IF→ID |

</details>

<details>
<summary><b>🔶 I-Type — Opcode(5) | Rp(5) | Rd(5) | Rs(5) | Imm(12)</b></summary>

| Instruction | Opcode | Operation | Extension |
|:---|:---:|:---|:---:|
| `ADDI Rd,Rs,Imm,Rp` | 5 | `Reg[Rd] = Reg[Rs] + Imm` | Sign-extend |
| `ORI Rd,Rs,Imm,Rp` | 6 | `Reg[Rd] = Reg[Rs] \| Imm` | Zero-extend |
| `NORI Rd,Rs,Imm,Rp` | 7 | `Reg[Rd] = ~(Reg[Rs] \| Imm)` | Zero-extend |
| `ANDI Rd,Rs,Imm,Rp` | 8 | `Reg[Rd] = Reg[Rs] & Imm` | Zero-extend |
| `LW Rd,Imm(Rs),Rp` | 9 | `Reg[Rd] = Mem[Reg[Rs]+Imm]` | Sign-extend |
| `SW Rd,Imm(Rs),Rp` | 10 | `Mem[Reg[Rs]+Imm] = Reg[Rd]` | Sign-extend |

</details>

<details>
<summary><b>🔴 J-Type — Opcode(5) | Rp(5) | Offset(22)</b></summary>

| Instruction | Opcode | Operation | Penalty |
|:---|:---:|:---|:---:|
| `J Label,Rp` | 11 | `PC = PC + SignExt(Offset)` | 1 cycle flush |
| `CALL Label,Rp` | 12 | `R31 = PC+1 ; PC = PC + SignExt(Offset)` | 1 cycle flush |

</details>

---

## 🏗️ Datapath — Stage by Stage

<details>
<summary><b> IF — Instruction Fetch</b></summary>

```
  R30 (PC) ──► Instruction Memory (1KB ROM)
       │              │
       │         32-bit instruction
       │
       ├──► PC + 1 Adder
       │
       └──► PC Control Unit
              ├── PCSrc=00 → PC+1       (normal sequential)
              ├── PCSrc=01 → PC+Offset  (J / CALL)
              └── PCSrc=10 → Reg[Rs]    (JR)

  StallSignal=1 → freeze IF/ID (do not fetch new instruction)
  KillSignal=1  → replace fetched instruction with NOP 0x00000000
```

</details>

<details>
<summary><b> ID — Instruction Decode (most complex stage)</b></summary>

```
  32-bit instruction
       │
       ├──► Splitter      → Opcode | Rp | Rd | Rs | Rt | Imm | Offset
       ├──► Control Unit  → all control signals from opcode
       ├──► Register File → read Rs, Rt, Rp (3 read ports)
       ├──► Predicate Unit → ExecuteEn = (Rp_addr==0) OR (Reg[Rp]!=0)
       ├──► Extender      → 32-bit immediate (zero or sign extend)
       ├──► Forwarding Muxes → select most recent Rs, Rt, Rp values
       ├──► Stall Unit    → Stall = MemRead_EX AND (Rd_EX==Rs/Rt/Rp_ID)
       └──► Kill Unit     → Kill = (PCSrc!=00) AND ExecuteEn

  Control gating (key design choice):
  RegWrite_actual  = RegWrite_CU  AND ExecuteEn AND NOT(Stall)
  MemWrite_actual  = MemWrite_CU  AND ExecuteEn AND NOT(Stall)
  MemRead_actual   = MemRead_CU   AND ExecuteEn AND NOT(Stall)
```

</details>

<details>
<summary><b> EX — Execute (ALU)</b></summary>

```
  ALU Input 1 ← forwarded Rs value
  ALU Input 2 ← Mux(forwarded Rt, ExtImm)  ← ALUSrc signal

  ALU_OP encoding:
  000 → ADD   (also: LW/SW address = Reg[Rs] + Imm)
  001 → SUB
  010 → OR
  011 → NOR
  100 → AND

  ALU Result ──► EX/MEM pipeline register
             ──► forwarding network (immediate availability)
```

</details>

<details>
<summary><b> MEM — Memory Access</b></summary>

```
  ALU Result → memory address (lower 10 bits used for 4KB RAM)

  LW: MemRead=1  → data_out = Mem[address]
  SW: MemWrite=1 → Mem[address] = Reg[Rd]

  Both signals already gated by ExecuteEn from ID stage
  Predicated-false instructions: MemRead=0, MemWrite=0 → memory unchanged
```

</details>

<details>
<summary><b> WB — Write Back</b></summary>

```
  3-to-1 Mux controlled by WB_Sel:
  WB_Sel=00 → ALU result   (arithmetic / logical)
  WB_Sel=01 → Memory data  (LW instruction)
  WB_Sel=10 → PC+1         (CALL instruction → written to R31)

  Final_Data_WB → Reg[Rd] if RegWrite=1
```

</details>

---

## ⚡ Hazard Management

<details>
<summary><b>🔁 Forwarding Network — RAW Data Hazards</b></summary>

```
  3 independent forwarding units: Rs, Rt, Rp

  Priority (highest → lowest):
  ┌─────────────────────────────────────────────────────┐
  │ if  RegWrite_EX  AND Rd_EX ==SrcAddr → fwd = 01   │ EX stage
  │ elif RegWrite_MEM AND Rd_MEM==SrcAddr → fwd = 10   │ MEM stage
  │ elif RegWrite_WB  AND Rd_WB ==SrcAddr → fwd = 11   │ WB stage
  │ else                                  → fwd = 00   │ Register File
  └─────────────────────────────────────────────────────┘

  ⚠️  Rp is also forwarded → correct predicate evaluation
      even when Rp was just written by an instruction in the pipeline
```

</details>

<details>
<summary><b>⏸️ Stall Unit — Load-Use Hazard</b></summary>

```
  Problem:  LW result not available until end of MEM stage.
            Cannot forward from EX to next instruction.

  Detection:
  Stall = MemRead_EX AND
          (Rd_EX == Rs_ID OR Rd_EX == Rt_ID OR Rd_EX == Rp_ID)

  When Stall=1:
  ├── Freeze PC (do not increment)
  ├── Freeze IF/ID register (same instruction held)
  └── Clear ID/EX control signals (insert bubble)

  Penalty: +1 cycle
```

</details>

<details>
<summary><b>🔫 Kill Unit — Control Hazard</b></summary>

```
  Problem:  When J/CALL/JR is taken, the instruction already
            fetched in IF comes from the WRONG address.

  Detection:
  Kill = (PCSrc != 00) AND ExecuteEn

  When Kill=1:
  └── IF/ID instruction replaced with NOP (0x00000000)

  Penalty: +1 cycle
  Key advantage: resolving in ID (not EX) keeps penalty to 1 cycle only
```

</details>

---

## 🧪 Test Program Results

<details>
<summary><b>📊 Expected vs Actual Results — All 30 Cycles</b></summary>

| Register | Value | Commit Cycle | Notes |
|:---|:---:|:---:|:---|
| R1 | 10 | 5 | `ADDI R1, R0, 10` |
| R2 | 15 | 6 | `ADDI R2, R1, 5` |
| R3 | 15 | 7 | `ANDI R3, R2, 15` |
| R4 | 255 | 8 | `ORI R4, R0, 255` |
| R5 | 0xFFFFFF00 | 9 | `NORI R5, R4, 0` |
| R6 | 240 | 10 | `SUB R6, R4, R2` |
| R7 | 0 | 11 | `AND R7, R6, R1` |
| R8 | 15 | 12 | `OR R8, R1, R2` |
| R9 | 0xFFFFFFF5 | 13 | `NOR R9, R1, R0` |
| R10 | 0 | 15 | `LW R10, 20(R0)` |
| R11 | 0 | 17 | `ADD R11, R10, R0` — +1 stall (load-use hazard) |
| R12 | 0 | 18 | `ADDI R12, R0, 0` |
| R13 | 1 | 19 | `ADDI R13, R0, 1` |
| R14 | unchanged | — | Predicated by R12=0 → **SKIPPED** ✓ |
| R15 | 25 | 21 | Predicated by R13=1 → **EXECUTES** ✓ |
| R31 | 22 | 24 | `CALL` saves return address ✓ |
| R24 | 0 | 29 | Inside CALL function body ✓ |

> ✅ **All actual results matched expected results**
> 🕐 **Total: 30 cycles** = N instructions + 4 pipeline stages + stall cycles + flush cycles

</details>

<details>
<summary><b>🔬 Component Testbench Results</b></summary>

| Component | Tests | Result |
|:---|:---:|:---:|
| ALU | ADD, SUB, OR, NOR, AND, overflow wrap | ✅ All passed |
| Data Memory | Read, Write, Write-protect | ✅ All passed |
| Extender | Zero-extend 12b, Sign-extend 12b, Sign-extend 22b | ✅ All passed |
| Predicate Unit | Rp=R0, Rp≠0 non-zero, Rp≠0 zero | ✅ All passed |
| Forwarding Unit | No hazard, EX forward, MEM forward | ✅ All passed |

</details>

---

## 📁 Project Structure

```
pipelined-risc-processor-verilog/
├── src/
│   ├── processor.v          ← top-level processor
│   ├── datapath.v           ← full pipelined datapath
│   ├── control.v            ← control unit
│   ├── alu.v                ← ALU module
│   ├── register_file.v      ← 32×32-bit register file
│   ├── memory.v             ← instruction ROM + data RAM
│   ├── forwarding_unit.v    ← RAW hazard forwarding
│   ├── stall_unit.v         ← load-use hazard detection
│   ├── kill_unit.v          ← control hazard flush
│   ├── predicate_unit.v     ← predicated execution
│   └── extender.v           ← immediate extension
├── testbench/
│   └── testbench.v          ← full simulation testbench
├── datapath/
│   └── datapath.circ        ← Logisim datapath diagram
└── report/
    └── report.pdf           ← full report with waveforms
```

---

## ▶️ How to Run

```bash
vlog src/*.v testbench/testbench.v
vsim testbench
```

---

## 📚 Course Info

| | |
|---|---|
| **Course** | ENCS4370 — Computer Architecture |
| **University** | Birzeit University 🇵🇸 |
| **Semester** | Fall 2025/2026 |


---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:16213e,100:1a1a2e&height=100&section=footer"/>
</div>
