# FPGA Rhythm Game

A real-time rhythm game implemented on an FPGA using SystemVerilog, VGA graphics, keyboard input, and PWM-based audio output.

## Overview

This project implements a four-lane rhythm game where notes fall in real time and the player must press the correct keys as notes reach the hit zone. The system tracks score, lives, and game state, while rendering graphics through VGA and outputting audio through a PWM-based pipeline.

## Features

- Four-lane gameplay with falling notes
- VGA-based real-time graphics rendering
- Keyboard input for lane controls and state transitions
- Finite state machine for start screen, gameplay, and game over flow
- Score and lives tracking with HUD display
- PWM-based audio playback using ROM-stored samples
- Difficulty scaling through increasing note speed
- Pseudo-random note generation using LFSR logic

## Technical Highlights

- Developed in **SystemVerilog**
- Built a hardware audio pipeline using **ROM-based sample playback** and **PWM output**
- Implemented lane-based rendering, hit/miss detection, and game state control
- Integrated multiple hardware subsystems including:
  - VGA rendering
  - FSM-based gameplay control
  - keyboard input handling
  - score/lives tracking
  - audio output

## Repository Structure

- `final_project.srcs/`: HDL source files, constraints, and project assets
- `final_project.xpr`: Vivado project file
- `mb_usb_hdmi_top/`: top-level design files
- `mb_usb_hdmi_top.xsa`: exported hardware design
- `final385_system/`: supporting system files
