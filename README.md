# 🚀 1x3 Packet Router (Verilog RTL)

A Verilog-based **1x3 Packet Router** built for high-throughput, byte-wise data routing across multiple output channels. Designed using modular RTL architecture and verified via simulation and synthesis on **Xilinx Vivado**.

---

## 🛠️ Tech Stack

- **Language**: Verilog (RTL)
- **Design Concepts**: Digital Logic, FSMs, FIFOs, Synchronizers
- **Tools**: Xilinx Vivado (Simulation & Synthesis)
- **Platform**: Linux-based development environment

---

## 📦 Project Highlights

- ✅ **1x3 Routing**: Routes byte-serialized packets to one of 3 output ports based on destination header.
- ✅ **Custom Protocol**: Packet includes header, payload, and a parity byte.
- ✅ **Flow Control Signals**:
  - `pkt_valid` — Valid input indicator
  - `vld_out[2:0]` — Valid signal per output port
  - `read_enb[2:0]` — Read enable for each FIFO
  - `busy` — Prevents overflow by stalling input
- ✅ **On-the-Fly Parity Check**: Ensures error detection during packet reception.
- ✅ **Simultaneous Operations**: Read from any output while writing a new packet to another.

---

## 🧩 Submodules

| Module         | Description                                         |
|----------------|-----------------------------------------------------|
| `fifo.v`       | Byte-wise FIFO buffers for output channels          |
| `fsm.v`        | Finite State Machine handling protocol control      |
| `synchronizer.v` | Ensures signal integrity across logic boundaries |
| `router_top.v` | Integrates all submodules into a single system      |

---

## 🔄 Data Flow

```text
[Input Stream] --> [FSM + Parity Check] --> [FIFO 0 | FIFO 1 | FIFO 2] --> [Output Ports]
