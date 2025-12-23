# Multi-Timer Stopwatch Testing Guide

## Test Plan for EGO1 FPGA Board

This document provides a comprehensive testing guide for validating the multi-timer stopwatch functionality on the EGO1 FPGA board.

## Prerequisites

1. EGO1 FPGA board with programmed bitstream
2. Power supply connected
3. All switches in known positions

## Initial Setup

Before testing, ensure:
- All switches (SW0, SW1, SW7) are in OFF (0) position
- Press S0 (Reset) to initialize the system
- Verify all 8 seven-segment displays are showing "00.00.00.00"
- LED0, LED1, LED2 should be off initially

## Test Suite

### Test 1: Basic Stopwatch Mode (Timer 1)

**Setup:**
- SW0 = 0 (Timer 1 selected)
- SW1 = 0 (HH.MM.SS.CS format)
- SW7 = 0 (Count up mode)

**Steps:**
1. Press S0 (Reset) - Display shows "00.00.00.00"
2. Press S1 (Start) - Timer starts counting up
3. Wait 10 seconds - Verify display shows approximately "00.00.10.00"
4. Press S2 (Stop) - Timer stops, display blinks at ~2Hz
5. Press S1 (Resume) - Timer resumes from stopped value
6. Press S0 (Reset) - Timer resets to "00.00.00.00"

**Expected Results:**
- Timer counts up continuously when running
- Display blinks when stopped
- LED1 (M1) should be ON indicating Timer 1 is selected

### Test 2: Millisecond Resolution Display

**Setup:**
- SW0 = 0 (Timer 1 selected)
- SW1 = 1 (MM.SS.MS format - millisecond view)
- SW7 = 0 (Count up mode)

**Steps:**
1. Press S0 (Reset)
2. Press S1 (Start)
3. Observe the rightmost digit shows "1" (Timer 1 indicator)
4. Watch milliseconds increment rapidly (0-999)
5. Press S2 (Stop)

**Expected Results:**
- Display format: "MM.SS.MSx.1" where MSx are millisecond digits
- Rightmost display shows "1" indicating Timer 1
- Milliseconds update at 1kHz rate

### Test 3: Lap Timing (Single Timer)

**Setup:**
- SW0 = 0 (Timer 1)
- SW1 = 0 (Normal view)
- SW7 = 0 (Count up)

**Steps:**
1. Press S0 (Reset)
2. Press S1 (Start)
3. Wait 5 seconds, press S3 (Record Lap 0)
4. Wait 3 seconds, press S3 (Record Lap 1)
5. Wait 2 seconds, press S3 (Record Lap 2)
6. Press S2 (Stop)
7. Hold SW1 high and press S4 - Enter lap view mode
8. Display should show "L0" on left with lap 0 time
9. Press S4 repeatedly - Cycle through "L0", "L1", "L2"
10. Hold SW1 high and press S4 - Exit lap view mode

**Expected Results:**
- Up to 10 laps can be recorded
- Lap times are preserved when timer stops
- Lap view shows "L" + lap number
- Can scroll through all recorded laps

### Test 4: Multi-Timer Operation

**Setup:**
- SW7 = 0 (Count up mode for both timers)
- SW1 = 0 (Normal view)

**Steps:**
1. Press S0 (Reset both timers)
2. SW0 = 0 (Select Timer 1), verify LED1 ON
3. Press S1 (Start Timer 1)
4. Wait 5 seconds
5. SW0 = 1 (Select Timer 2), verify LED2 ON, LED1 OFF
6. Press S1 (Start Timer 2)
7. Wait 3 seconds
8. SW0 = 0 (Back to Timer 1)
9. Observe Timer 1 shows ~8 seconds
10. SW0 = 1 (Back to Timer 2)
11. Observe Timer 2 shows ~3 seconds
12. Press S2 (Stop Timer 2)
13. SW0 = 0 (Back to Timer 1)
14. Observe Timer 1 still running
15. Press S2 (Stop Timer 1)

**Expected Results:**
- Both timers run independently
- Switching between timers shows different times
- LED1/LED2 indicate active timer
- Stopping one timer doesn't affect the other

### Test 5: Countdown Timer Mode

**Setup:**
- SW0 = 0 (Timer 1)
- SW1 = 0 (Normal view)
- SW7 = 1 (Countdown mode)

**Steps:**
1. Press S0 (Reset)
2. Display should show "00.01.00.00" (default 1 minute)
3. Press S3 multiple times - Increment minutes
4. Press S4 multiple times - Increment hours
5. Set timer to "00.00.10.00" (10 seconds)
6. Press S1 (Start countdown)
7. Watch timer count down
8. When timer reaches "00.00.00.00":
   - LED0 should blink at ~1Hz (alarm)
   - Timer stops automatically
9. Press S0 (Reset)

**Expected Results:**
- Default countdown starts at 1 minute
- Can adjust time before starting
- Counts down to zero
- Alarm LED blinks when reaching zero
- Timer stops at zero

### Test 6: Independent Countdown Timers

**Setup:**
- SW7 = 1 (Countdown mode)

**Steps:**
1. Press S0 (Reset)
2. SW0 = 0 (Timer 1), set to 20 seconds using S3/S4
3. Press S1 (Start Timer 1 countdown)
4. SW0 = 1 (Timer 2), set to 10 seconds using S3/S4
5. Press S1 (Start Timer 2 countdown)
6. SW0 = 1 (Watch Timer 2)
7. When Timer 2 reaches zero, LED0 should blink
8. SW0 = 0 (Switch to Timer 1)
9. Timer 1 should still be counting down
10. Wait for Timer 1 to reach zero

**Expected Results:**
- Both countdown timers run independently
- Alarm activates when either timer reaches zero
- Each timer can have different countdown values

### Test 7: Lap Recording with Two Timers

**Setup:**
- SW7 = 0 (Stopwatch mode)
- SW1 = 0 (Normal view)

**Steps:**
1. Press S0 (Reset)
2. SW0 = 0 (Timer 1)
3. Press S1 (Start Timer 1)
4. Press S3 3 times at intervals (Record 3 laps for Timer 1)
5. SW0 = 1 (Timer 2)
6. Press S1 (Start Timer 2)
7. Press S3 2 times at intervals (Record 2 laps for Timer 2)
8. SW0 = 0 (Back to Timer 1)
9. Hold SW1 high and press S4 (Enter lap view for Timer 1)
10. Press S4 repeatedly - Should show L0, L1, L2 (3 laps)
11. Hold SW1 high and press S4 (Exit lap view)
12. SW0 = 1 (Switch to Timer 2)
13. Hold SW1 high and press S4 (Enter lap view for Timer 2)
14. Press S4 repeatedly - Should show L0, L1 (2 laps)

**Expected Results:**
- Each timer has independent lap storage
- Timer 1 shows 3 laps
- Timer 2 shows 2 laps
- Lap records don't mix between timers

### Test 8: Maximum Lap Storage

**Setup:**
- SW0 = 0 (Timer 1)
- SW7 = 0 (Stopwatch mode)

**Steps:**
1. Press S0 (Reset)
2. Press S1 (Start)
3. Press S3 rapidly 15 times (attempt to record 15 laps)
4. Hold SW1 high and press S4 (Enter lap view)
5. Press S4 repeatedly to count laps
6. Should only show L0 through L9 (10 laps maximum)

**Expected Results:**
- Maximum 10 laps per timer
- Additional lap button presses beyond 10 have no effect
- All 10 laps are preserved and viewable

### Test 9: Display Blinking When Stopped

**Setup:**
- Any timer configuration

**Steps:**
1. Start any timer
2. Press Stop button
3. Observe display blinking at ~2Hz
4. Press Start to resume
5. Display should stop blinking and show solid

**Expected Results:**
- Display blinks only when timer is in STOPPED state
- Blinking stops when timer resumes
- Blinking helps indicate paused state

### Test 10: Reset Functionality

**Setup:**
- Create a complex state: both timers running, some laps recorded

**Steps:**
1. Start Timer 1, record some laps
2. Start Timer 2, record some laps
3. Press S0 (Reset)
4. Verify both timers show "00.00.00.00"
5. Check lap view for both timers - should be empty

**Expected Results:**
- S0 resets ALL timers to zero
- All lap records for both timers are cleared
- Both timers return to IDLE state
- LEDs return to initial state

## Troubleshooting

### Display Not Updating
- Check clock generation - verify 1kHz timing clock
- Verify display scan rate (1kHz)
- Check anode/cathode connections

### Timer Not Starting
- Verify debounce circuit working
- Check state machine transitions
- Verify clock divider output

### Lap Recording Not Working
- Ensure not in countdown mode (SW7 = 0)
- Verify button debouncing
- Check lap count doesn't exceed 10

### LEDs Not Working
- Check LED pin assignments in constraint file
- Verify LED logic (active high)
- Check timer selection switch

### Countdown Not Working
- Ensure SW7 is high
- Verify time adjustment buttons in IDLE state
- Check countdown logic for underflow

## Performance Metrics

### Timing Accuracy
- Resolution: 1ms (0.001s)
- Expected drift: < 0.1% over 1 hour
- Countdown precision: Within ±1ms

### Response Time
- Button response: < 30ms (3 debounce samples)
- Display update: < 4ms (4 scan cycles)
- State transition: Immediate (next clock edge)

### Resource Usage (Estimated)
- Logic cells: ~500-700
- Memory bits: ~640 (lap storage)
- DSP blocks: 0
- I/O pins: 35 (configured)

## Summary Checklist

Use this checklist to verify all functionality:

- [ ] Basic stopwatch (start/stop/reset) - Timer 1
- [ ] Basic stopwatch (start/stop/reset) - Timer 2
- [ ] Millisecond resolution display
- [ ] Lap timing (10 laps per timer)
- [ ] Lap view and scrolling
- [ ] Multi-timer independent operation
- [ ] Timer selection with LED indicators
- [ ] Countdown timer mode
- [ ] Countdown alarm (LED blink)
- [ ] Display blinking when stopped
- [ ] Reset clears all state
- [ ] Both display formats work (HH.MM.SS.CS and MM.SS.MS.T)
- [ ] Time adjustment in countdown mode (IDLE and STOPPED states)
- [ ] Button debouncing works properly
- [ ] No interference between timers

## Notes for Hardware Testing

1. **Debouncing**: If buttons are unreliable, increase debounce time in debounce.v
2. **Display Brightness**: Can be adjusted by modifying scan duty cycle
3. **Alarm Duration**: LED blinks continuously until reset in current implementation
4. **Lap Overflow**: After 10 laps, additional S3 presses are safely ignored
5. **View Mode**: Hold SW1 HIGH while pressing S4 to toggle lap view mode

## Known Limitations

1. Maximum time: 99:59:59.999 (then rolls over to 00:00:00.000)
2. Maximum laps: 10 per timer (20 total)
3. Countdown minimum: 1 millisecond
4. No lap time differences displayed (only absolute times)
5. Alarm continues indefinitely until reset

## Future Enhancement Ideas

1. Split/lap time differences
2. Average lap time calculation
3. Fastest/slowest lap indication
4. More than 2 timers
5. UART output of lap times for data logging
6. Non-volatile lap storage (if EEPROM available)
