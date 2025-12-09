# Multi-Timer Stopwatch with Lap Timing

## Overview
This is an enhanced version of the digital stopwatch with the following new features:
- **2 Independent Timers**: Run two stopwatches simultaneously
- **Lap Timing**: Record up to 10 lap times for each timer
- **Higher Resolution**: Millisecond precision (0.001s) instead of centiseconds (0.01s)
- **Multiple Display Views**: Switch between different time display formats
- **Segmented Display**: View current time or lap records

## Features

### 1. Multi-Timer Mode
- **Timer 1** and **Timer 2** operate independently
- Switch between timers using **SW0** switch
- Each timer has its own state (running/stopped) and time value
- LED indicators show which timer is currently selected:
  - LED1 (M1): Timer 1 active
  - LED2 (L1): Timer 2 active

### 2. Lap Timing (分段计时)
- Record intermediate times while timer is running
- Store up to 10 lap records per timer
- Press **S3** button to record a lap time
- View lap records by enabling lap view mode
- Lap records are preserved even when timer is stopped

### 3. Higher Resolution Display
The display can show time in two formats:

**Format 1: HH-MM-SS-CS** (Hours-Minutes-Seconds-Centiseconds)
- Display: `HH.MM.SS.CS`
- Example: `01.23.45.67` = 1 hour, 23 minutes, 45 seconds, 67 centiseconds

**Format 2: MM-SS-MS** (Minutes-Seconds-Milliseconds)
- Display: `MM.SS.MSx.T`
- Example: `23.45.678.1` = 23 minutes, 45 seconds, 678 milliseconds, Timer 1
- The rightmost digit shows which timer is selected (1 or 2)
- Higher precision with full millisecond display

Switch between formats using **SW1** switch.

### 4. Lap Record View
- Enable lap view mode: Hold **SW1** high and press **S4**
- Display shows "L" and lap number on leftmost digits
- Scroll through laps: Press **S4** while in lap view mode
- Exit lap view mode: Hold **SW1** high and press **S4** again
- Returns to current time display

### 5. Countdown Timer Mode
- Enable countdown with **SW7** switch
- Default countdown starts at 1 minute
- Adjust time using **S3** (minutes) and **S4** (hours) when stopped
- LED alarm blinks when countdown reaches zero

### 6. Display Blinking
- Display blinks (~2 Hz) when timer is in stopped state
- Helps indicate that timer is paused and ready to resume

## Control Mapping

### Buttons
- **S0 (R11)**: Reset - Clear all timers and lap records
- **S1 (R17)**: Start/Resume - Start or resume current timer
- **S2 (R15)**: Stop/Pause - Pause current timer
- **S3 (V1)**: Lap Record - Record lap time (also minute increment in countdown mode)
- **S4 (U4)**: View Scroll - Scroll through lap records (also hour increment in countdown mode)

### Switches
- **SW0 (R1)**: Timer Select
  - OFF (0): Timer 1 selected
  - ON (1): Timer 2 selected
- **SW1 (N4)**: Display View Mode
  - OFF (0): Show HH-MM-SS-CS format
  - ON (1): Show MM-SS-MS format with milliseconds
- **SW7 (P5)**: Countdown Mode
  - OFF (0): Count up (stopwatch mode)
  - ON (1): Count down (timer mode)

### LEDs
- **LED0 (K3)**: Alarm indicator - Blinks when countdown reaches zero
- **LED1 (M1)**: Timer 1 indicator - ON when Timer 1 is selected
- **LED2 (L1)**: Timer 2 indicator - ON when Timer 2 is selected

## Usage Examples

### Example 1: Basic Stopwatch
1. Ensure SW0=0 (Timer 1), SW1=0 (HH-MM-SS format), SW7=0 (count up)
2. Press S1 to start
3. Press S2 to stop
4. Press S1 to resume
5. Press S0 to reset

### Example 2: Recording Lap Times
1. Start timer with S1
2. Press S3 to record first lap
3. Press S3 again for second lap (up to 10 laps)
4. Hold SW1 high and press S4 to enter lap view mode
5. Press S4 to scroll through recorded laps
6. Hold SW1 high and press S4 to exit lap view

### Example 3: Using Two Timers
1. Set SW0=0, press S1 to start Timer 1
2. Set SW0=1, press S1 to start Timer 2
3. Both timers now run independently
4. Toggle SW0 to view either timer
5. Stop/resume each timer independently

### Example 4: High-Resolution Display
1. Set SW1=1 to show MM-SS-MS format
2. Display shows milliseconds (0-999) with higher precision
3. Rightmost digit shows timer number (1 or 2)
4. Useful for precise timing measurements

### Example 5: Countdown Timer
1. Set SW7=1 to enter countdown mode
2. Use S3/S4 to adjust starting time (minutes/hours)
3. Press S1 to start countdown
4. LED alarm blinks when countdown reaches zero
5. Set SW7=0 to return to stopwatch mode

## Technical Details

### Resolution
- Internal timing: 1 kHz (1 millisecond)
- Display update: 1 kHz scan rate
- Time range: 0-99 hours, 59 minutes, 59 seconds, 999 milliseconds

### Memory
- Lap storage: 10 laps × 2 timers = 20 total lap records
- Each lap record: 4 bytes (hours, minutes, seconds, milliseconds)

### Display Format
- 8-digit 7-segment display
- Common anode configuration
- Dual bank: AN0-AN3 (right) and AN4-AN7 (left)
- Active high segment and anode control

## Files

### Main Modules
- `top_multi.v`: Top-level integration module with multi-timer support
- `stopwatch_multi_logic.v`: Multi-timer logic with lap recording
- `display_driver_multi.v`: Enhanced display driver with view switching
- `clk_div.v`: Clock divider (updated for 1kHz timing)
- `debounce.v`: Button/switch debouncing (updated for additional controls)

### Constraint Files
- `stopwatch_multi.xdc`: Pin assignments and constraints for EGO1 board

### Legacy Files (Original Single Timer Version)
- `top.v`: Original single-timer top module
- `stopwatch_logic.v`: Original single-timer logic
- `display_driver.v`: Original display driver
- `stopwatch.xdc`: Original constraint file

## Building and Programming

This design is intended for the EGO1 FPGA development board. To build and program:

1. Open Vivado and create a new project
2. Add all Verilog source files (`.v`)
3. Add the constraint file (`stopwatch_multi.xdc`)
4. Set `top_multi` as the top-level module
5. Run synthesis and implementation
6. Generate bitstream
7. Program the FPGA using Vivado Hardware Manager

## Notes

- The original single-timer version files are preserved for backward compatibility
- To use the original version, use `top.v` as top-level module and `stopwatch.xdc` as constraints
- To use the multi-timer version, use `top_multi.v` as top-level and `stopwatch_multi.xdc` as constraints
- Make sure to select the correct top module in your project settings
