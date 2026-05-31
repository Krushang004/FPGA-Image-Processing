# FPGA-Image-Processing
Basys3 fpga board image processing project.
# 🖼️ Real-Time FPGA Image Processing System

> 🏆 1st Place — FPGA Design Challenge 2.0 | SCET Surat | 22 teams competing

## Overview
A real-time image processing system implemented on a **Basys 3 (Artix-7 FPGA)** board using Vivado. 
Processes live video input and applies 16 different filters in real time.

## Filters Implemented
| Category | Filters |
|----------|---------|
| Color | Grayscale, Invert, Sepia, Channel Isolation |
| Blur | Gaussian Blur, Box Blur, Motion Blur |
| Edge Detection | Sobel X, Sobel Y, Combined Sobel, Laplacian |
| Enhancement | Brightness, Contrast, Sharpen, Threshold, Emboss |

> 💡 The **Gaussian Blur** filter drew the most attention from judges during evaluation.

## Tech Stack
- **Board:** Digilent Basys 3 (Xilinx Artix-7)
- **Tool:** Vivado 2014
- **Language:** Verilog HDL
- **Interface:** VGA output

## Team
| Name | Role |
|------|------|
| Krushang Prajapati | Technical Lead |
| Pari Lad | Team Member |
| Chharvvi Batra | Team Member |
| Yasvi Desai | Team Member |

**Faculty Coordinator:** Nehal Shah  
**Institution:** SCET, Surat

## Results
- ✅ All 16 filters functional in real-time
- ✅ 1st place out of 22 teams
- ✅ Judges specifically noted blur filter implementation quality
