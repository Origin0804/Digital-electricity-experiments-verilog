# Stopwatch Implementation Comparison

This directory contains two versions of the stopwatch implementation:

## Version 1: Original Single-Timer Stopwatch

**Files:**
- `top.v` - Top-level module
- `stopwatch_logic.v` - Single timer logic
- `display_driver.v` - Basic display driver
- `stopwatch.xdc` - Pin constraints

**Features:**
- Single stopwatch with start/stop/reset
- Resolution: 0.01s (centiseconds)
- Display format: HH.MM.SS.XX (fixed)
- Countdown timer mode
- Alarm LED when countdown reaches zero
- Display blinks when stopped

**Usage:**
- S0: Reset
- S1: Start/Resume
- S2: Stop/Pause
- S3: Minute increment (countdown mode)
- S4: Hour increment (countdown mode)
- SW7: Countdown mode enable

## Version 2: Enhanced Multi-Timer Stopwatch with Lap Timing

**Files:**
- `top_multi.v` - Enhanced top-level module
- `stopwatch_multi_logic.v` - Multi-timer logic with lap recording
- `display_driver_multi.v` - Advanced display driver with view switching
- `stopwatch_multi.xdc` - Extended pin constraints
- `README_MULTI.md` - Detailed documentation

**Additional Features:**
- **Two independent timers** running simultaneously
- **Lap timing** - record up to 10 intermediate times per timer
- **Higher resolution**: 0.001s (milliseconds) instead of 0.01s
- **Multiple display views**:
  - View 1: HH.MM.SS.CS (hours-minutes-seconds-centiseconds)
  - View 2: MM.SS.MSx.T (minutes-seconds-milliseconds-timer#)
- **Lap record viewing** - review recorded lap times
- **Timer indicator LEDs** - show which timer is active
- All original features preserved

**Additional Controls:**
- S3: Lap record (in addition to minute increment)
- S4: View scroll (in addition to hour increment)
- SW0: Timer select (0=Timer1, 1=Timer2)
- SW1: Display view mode (0=HH-MM-SS-CS, 1=MM-SS-MS)
- LED1: Timer 1 indicator
- LED2: Timer 2 indicator

**Enhanced Functionality:**
1. **Multi-Timer Operation:**
   - Switch between Timer 1 and Timer 2 using SW0
   - Each timer maintains independent state
   - Can start/stop timers separately

2. **Lap Timing:**
   - Press S3 to record lap time while running
   - Up to 10 laps per timer
   - View laps: Hold SW1 high + press S4 to toggle lap view
   - Scroll laps: Press S4 in lap view mode
   - Lap display shows "L" + lap number

3. **Display Flexibility:**
   - SW1=0: Traditional format with hours
   - SW1=1: Millisecond precision format
   - Automatic timer indicator in millisecond view

## Shared Modules

Both versions share these common modules:
- `clk_div.v` - Clock divider (provides both 100Hz and 1kHz clocks)
- `debounce.v` - Button/switch debouncing (supports both configurations)

The shared modules are **backward compatible** - they support both the original single-timer design and the enhanced multi-timer design.

## Choosing Which Version to Use

### Use Original Version (Version 1) if:
- You only need a basic stopwatch
- You want simpler code and fewer resources
- You don't need lap timing
- Centisecond resolution is sufficient

### Use Enhanced Version (Version 2) if:
- You need to time multiple events simultaneously
- You need lap/split timing functionality
- You need millisecond precision
- You want flexible display options
- You're implementing the requirements from the problem statement

## Building the Project

### For Original Version:
1. In Vivado, set top-level module: `top`
2. Use constraint file: `stopwatch.xdc`
3. Add source files: `top.v`, `stopwatch_logic.v`, `display_driver.v`, `clk_div.v`, `debounce.v`

### For Enhanced Version:
1. In Vivado, set top-level module: `top_multi`
2. Use constraint file: `stopwatch_multi.xdc`
3. Add source files: `top_multi.v`, `stopwatch_multi_logic.v`, `display_driver_multi.v`, `clk_div.v`, `debounce.v`

## Resource Comparison

### Original Version:
- Smaller footprint
- Lower FPGA resource usage
- Simpler state machine

### Enhanced Version:
- Larger footprint (2x timers + 20 lap records)
- Higher FPGA resource usage
- More complex state machines
- Additional memory for lap storage

Both versions are designed for the **EGO1 FPGA Board** and use the same pin assignments for common controls.
