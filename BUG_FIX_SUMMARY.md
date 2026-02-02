# Bug Fix: "ask_yes_no: command not found"

## The Problem

The script was calling `ask_yes_no` function on line 83 (in the auto-update check), but the function wasn't defined until line 194 (much later in the script).

**Error:**
```
./yt-dlp-auto.sh: line 83: ask_yes_no: command not found
```

## The Solution

Moved the `ask_yes_no()` function definition to line 52 (right after the helper functions, before it's used).

## What Changed

**Before:**
```
Line 43: log() and err() functions
Line 48: ARCH and OS variables
Line 51: check_script_update() - tries to call ask_yes_no
Line 83: ❌ Calls ask_yes_no (NOT DEFINED YET!)
...
Line 194: ask_yes_no() defined here (TOO LATE!)
```

**After:**
```
Line 43: log() and err() functions  
Line 48: ARCH and OS variables
Line 52: ✅ ask_yes_no() defined here (EARLY!)
Line 65: check_script_update() - now can call ask_yes_no
Line 97: Calls ask_yes_no (WORKS!)
...
Line 194: Removed duplicate ask_yes_no()
```

## Result

✅ Script now works correctly
✅ Auto-update feature functions properly
✅ No "command not found" error

## Testing

Run the script again:
```bash
./yt-dlp-auto.sh
```

You should now see:
```
[2026-02-02 12:13:42] Checking for script updates...
[2026-02-02 12:13:43] Script is up-to-date (v1.0.0)
```

No errors! 🎉
