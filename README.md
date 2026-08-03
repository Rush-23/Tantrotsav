# Hardware-Accelerated K-Nearest Neighbors (KNN) Classifier on FPGA

> **2nd Place Winner** – DREAM-Amrita VLSI Hardware Hackathon (Tantrotsav Techfest)

A high-performance, RTL-based implementation of the **K-Nearest Neighbors (KNN)** classification algorithm on the **ZedBoard (Xilinx Zynq-7000 SoC)** using only the **Programmable Logic (PL)**.

The design demonstrates how a computationally intensive machine learning algorithm can be transformed into a hardware accelerator through parallelism, pipelining, BRAM optimization, and custom sorting architectures.

---

## 🏆 Achievement

- 🥈 **2nd Place** among **14 teams**
- Organized by **DREAM-Amrita** as part of **Tantrotsav Techfest**
- Implemented entirely in **RTL**
- **Processing System (PS) was not allowed**
- Target Platform: **ZedBoard (Zynq-7000 SoC)**

---

# Team

| Member | Contribution |
|---------|--------------|
| **Rushil V** | Architecture Design, RTL Development |
| **Charan Karthick** | Architecture Design, RTL Development |
| **Sathiya Naarayanan Chandrasekaran** | RTL Support, Dataset Preparation, Validation, Presentation |
| **Team Member** | RTL Support, Dataset Preparation, Validation, Presentation |

---

# Project Overview

The objective was to design a fully hardware-based implementation of the **K-Nearest Neighbors (KNN)** algorithm capable of classifying an input vector with minimal latency.

Unlike software implementations that process one dataset element at a time, this design exploits the inherent parallelism of FPGA hardware to significantly accelerate computation.

The complete classifier—including distance computation, sorting, and classification—was implemented using synthesizable Verilog RTL.

---

# Features

- Fully RTL-based implementation
- No ARM processor (PS) usage
- Hardware configurable **K** value
- Parallel distance computation
- Dual-port BRAM based dataset storage
- Systolic sorting architecture
- Low-latency classification
- Timing optimized for high-frequency operation

---

# System Architecture

```
                 Input Switches
                        │
                        ▼
              Input Vector Register
                        │
                        ▼
          ┌─────────────────────────┐
          │   Dual-Port BRAM        │
          │ 64 Training Samples     │
          └─────────────────────────┘
              │               │
              ▼               ▼
      Distance Unit 1   Distance Unit 2
              │               │
              └──────┬────────┘
                     ▼
        Systolic Distance Sorter
                     │
                     ▼
          K Nearest Neighbor List
                     │
                     ▼
          Majority Voting Classifier
                     │
                     ▼
             Classification Output
```

---

# Hardware Specifications

| Parameter | Value |
|-----------|------|
| FPGA Board | ZedBoard |
| FPGA | Xilinx Zynq-7000 |
| Design Language | Verilog HDL |
| Dataset Size | 64 Training Samples |
| Distance Metric | Euclidean Distance (Squared) |
| Memory | True Dual-Port BRAM |
| Parallel Compute Units | 2 |
| User Input | Hardware Switches |
| Configurable K | Yes |

---

# Design Methodology

## 1. Dataset Storage

The training dataset is preloaded into the FPGA's on-chip Block RAM.

- 64 data points
- Dual-port BRAM inference
- Simultaneous access to two samples each clock cycle

---

## 2. Parallel Distance Computation

To improve throughput, two identical compute engines operate simultaneously.

Each clock cycle:

- Sample A → Distance Engine 1
- Sample B → Distance Engine 2

This effectively halves the number of memory accesses required compared to a single-engine architecture.

---

## 3. Systolic Sorter

Instead of storing all computed distances and sorting afterward, the design continuously maintains the nearest distances during computation.

Advantages include:

- Streaming operation
- Reduced latency
- No large sorting buffer
- Lower hardware overhead

Each newly computed distance is inserted into the correct position while previous distances shift through the systolic array.

---

## 4. Classification

After processing all dataset entries:

1. Select the **K** nearest neighbors
2. Perform majority voting
3. Produce the predicted class

---

# Performance

## Timing Results

| Metric | Value |
|---------|------|
| Initial Clock Period | 10 ns |
| Positive Slack | +3.6 ns |
| Optimized Clock Period | 7 ns |
| Operating Frequency | ~142 MHz |

---

## Latency

| Metric | Value |
|---------|------|
| Clock Cycles | 34 |
| Total Execution Time | ~340 ns |

---

## Software Comparison

The hardware implementation was compared against an equivalent Python implementation running on Google Colab.

The FPGA implementation achieved substantial acceleration through:

- Parallel computation
- Dedicated hardware datapaths
- Elimination of software overhead
- Streaming architecture

---

# FPGA Optimizations

## True Dual-Port BRAM

- Simultaneous read access
- Doubled memory bandwidth
- Reduced processing time

---

## Parallel Compute Units

Two identical distance computation modules execute concurrently.

Benefits:

- Increased throughput
- Reduced execution latency
- Improved resource utilization

---

## Systolic Sorting

Rather than waiting for all distances to be calculated:

- Distances are inserted dynamically
- Sorting occurs concurrently with computation
- Eliminates expensive post-processing

---

## Timing Optimization

The RTL was optimized to meet timing at:

- **142 MHz**
- Positive timing closure
- Stable synthesis and implementation

---

# Project Structure

```
Hardware-Accelerated-KNN/
│
├── rtl/
│   ├── knn_top.v
│   ├── bram.v
│   ├── distance_unit.v
│   ├── systolic_sorter.v
│   ├── majority_voter.v
│   └── controller.v
│
├── constraints/
│   └── constraints.xdc
│
├── dataset/
│   └── dataset.mem
│
├── simulation/
│   ├── testbench.v
│   └── waveforms/
│
├── images/
│
├── docs/
│
└── README.md
```

---

# Tools Used

- Vivado Design Suite
- Verilog HDL
- ZedBoard (Zynq-7000)
- Python (Reference Model)
- Google Colab (Software Validation)

---

# Learning Outcomes

This project provided hands-on experience in:

- FPGA Architecture
- RTL Design
- Hardware Acceleration
- Parallel Computing
- Timing Closure
- BRAM Inference
- Systolic Architectures
- Machine Learning Hardware Design
- FPGA Optimization Techniques

---

# Future Improvements

Potential enhancements include:

- Support for larger datasets using external DDR memory
- Higher-dimensional feature vectors
- Fully pipelined distance engine
- Floating-point arithmetic support
- AXI interface integration
- DMA-based dataset loading
- HLS implementation comparison
- Dynamic dataset updates
- Multi-class classifier support

---

# Results

✅ Fully functional RTL implementation

✅ Parallel hardware accelerator

✅ Runtime configurable K

✅ Timing closed at **142 MHz**

✅ **34 clock cycle** classification latency

✅ **2nd Place** at the DREAM-Amrita Hardware Hackathon

---

# Acknowledgements

We would like to sincerely thank:

- **DREAM-Amrita** for organizing the VLSI Hardware Hackathon.
- **Tantrotsav Techfest** for providing an excellent platform to innovate and compete.
- The faculty members, mentors, judges, and volunteers for their guidance and support throughout the event.

---

## License

This project is intended for educational and research purposes.
Feel free to use the architecture and concepts with appropriate attribution.

---

**Team XLR8-ers**  
*Accelerating Machine Learning with FPGA Hardware*
LinkedIn Post: https://www.linkedin.com/posts/indiran-t-003495305_hardware-accelerated-knn-classifier-on-fpga-ugcPost-7433159392746754048-nkRh?utm_source=share&utm_medium=member_desktop&rcm=ACoAAB0n350BI9KPtM1-62gKCNUw4jZDWbTooQE
