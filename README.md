# Hardware-Accelerated K-Nearest Neighbors (KNN) Classifier on FPGA

> 🥈 **2nd Place Winner** – DREAM-Amrita VLSI Hardware Hackathon (Tantrotsav Techfest)

A fully RTL-based implementation of a **Hardware-Accelerated K-Nearest Neighbors (KNN) Classifier** on the **ZedBoard (Xilinx Zynq-7000 FPGA)**.

The complete classifier was designed using **Verilog HDL** without utilizing the ARM Processing System (PS), demonstrating how a classical machine learning algorithm can be efficiently accelerated using FPGA parallelism, pipelining, and optimized memory architecture.

---

## 📌 Project Overview

The objective of this project was to implement the **K-Nearest Neighbors (KNN)** algorithm entirely in FPGA hardware.

Unlike software implementations that sequentially compute distances for every training sample, this architecture exploits FPGA parallelism to evaluate multiple samples simultaneously while maintaining the nearest neighbours in real time.

### Features

- Fully RTL implementation in Verilog
- Pure Programmable Logic (PL) design
- Runtime configurable **K (3 or 5)**
- 1024 preloaded training samples
- True Dual-Port BRAM
- Parallel distance computation
- Streaming Top-K sorter
- Majority voting classifier
- High-frequency operation at **142 MHz**

---

# Hardware Platform

| Component | Specification |
|-----------|---------------|
| FPGA Board | ZedBoard |
| FPGA | Xilinx Zynq-7000 SoC |
| Language | Verilog HDL |
| Design Methodology | RTL |
| Processing System | Not Used |
| Clock Frequency | 142 MHz |

---

# Dataset

The classifier stores **1024 training samples** in on-chip Block RAM.

Each sample consists of:

- Age (8 bits)
- Heart Rate (8 bits)
- Class Label (2 bits)

The dataset is implemented using **True Dual-Port BRAM**, enabling two samples to be accessed simultaneously each clock cycle.

---

# System Architecture

```text
                 Input Switches
                       │
                       ▼
               Input Controller
                       │
                       ▼
              ┌───────────────────┐
              │  Dual-Port BRAM   │
              │ 1024 Samples       │
              └───────────────────┘
                  │          │
                  ▼          ▼
          Distance Engine A  Distance Engine B
                  │          │
                  └────┬─────┘
                       ▼
             Top-K Distance Selector
                 (Streaming Insert)
                       │
                       ▼
                Majority Voting
                       │
                       ▼
               Classification Output
```

---

# Module Description

## `top.v`

Top-level module integrating all components of the classifier.

---

## `input_file.v`

Handles user interaction through switches and push buttons.

Responsibilities:

- Input feature loading
- Start signal generation
- Runtime K selection
- Input synchronization

---

## `memory.v`

Implements the training dataset using inferred **True Dual-Port BRAM**.

Features:

- 1024 stored samples
- Two simultaneous memory reads
- Continuous data streaming

---

## `distance_engine_top.v`

Coordinates the complete inference pipeline.

Functions:

- Memory address generation
- Pipeline synchronization
- Distance computation control
- Valid signal generation
- Completion detection

---

## Distance Computation Pipeline

The Euclidean distance is calculated using a three-stage pipeline.

### `sub.v`

Computes feature differences:

```text
dx = x_input − x_train
dy = y_input − y_train
```

---

### `multiplier.v`

Squares each difference:

```text
dx²
dy²
```

---

### `adder.v`

Computes the squared Euclidean distance:

```text
Distance = dx² + dy²
```

---

## Parallel Distance Computation

Two identical distance pipelines operate simultaneously.

Each clock cycle:

- Pipeline A processes one dataset sample
- Pipeline B processes another dataset sample

This doubles throughput while reducing overall inference latency.

---

## `k_sel.v`

Maintains the **Top-5 smallest distances** during execution.

Instead of sorting after all distances are computed, each new distance is inserted into its correct position immediately.

Benefits:

- Streaming operation
- Constant storage
- Lower latency
- Reduced hardware complexity

---

## `voting.v`

Performs majority voting using the selected nearest neighbours.

Supports:

- K = 3
- K = 5

Outputs the predicted class label.

---

## `latency_counter.v`

Measures the complete inference latency between:

- Start signal
- Classification complete

---

# Performance

| Metric | Value |
|---------|------:|
| Clock Period | 7 ns |
| Maximum Frequency | ~142 MHz |
| Positive Timing Slack | 3.6 ns |
| Inference Latency | 34 Clock Cycles |
| Total Execution Time | ~340 ns |

---

# Project Structure

```text
.
├── top.v
├── distance_engine_top.v
├── memory.v
├── input_file.v
├── sub.v
├── multiplier.v
├── adder.v
├── k_sel.v
├── voting.v
├── latency_counter.v
├── tb.v
├── constraint.xdc
└── README.md
```

---

# FPGA Optimizations

- True Dual-Port BRAM inference
- Parallel distance computation
- Fully pipelined arithmetic datapath
- Streaming Top-K insertion sorter
- Runtime configurable K
- Timing optimized RTL implementation
- High-frequency operation at 142 MHz

---

# Results

- 🥈 **2nd Place** among **14 teams**
- Fully RTL implementation without ARM processor support
- Successful hardware acceleration of the KNN algorithm
- **34-clock-cycle** inference latency
- **~340 ns** total execution time
- Significant acceleration over the reference Python implementation through hardware parallelism

---

# Team

| Member | Contribution |
|---------|--------------|
| **Rushil V** | Architecture Design, RTL Development |
| **Charan Karthick** | Architecture Design, RTL Development |
| **Sathiya Naarayanan Chandrasekaran** | RTL Support, Dataset Preparation, Validation |
| **Indiran** | RTL Support, Dataset Preparation, Validation, Presentation |

---

# Acknowledgements

We sincerely thank **DREAM-Amrita** and the **Tantrotsav Techfest** organizing committee for conducting an excellent VLSI hardware hackathon. We are also grateful to the faculty members, mentors, and judges for their valuable guidance and support throughout the event.

---

## License

This project is intended for educational and research purposes.

---

**Team XLR8-ers**

*Accelerating Machine Learning with FPGA Hardware.*
LinkedIn Post: https://www.linkedin.com/posts/indiran-t-003495305_hardware-accelerated-knn-classifier-on-fpga-ugcPost-7433159392746754048-nkRh?utm_source=share&utm_medium=member_desktop&rcm=ACoAAB0n350BI9KPtM1-62gKCNUw4jZDWbTooQE
