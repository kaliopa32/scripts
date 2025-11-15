
$signature = @"
using System;
using System.Runtime.InteropServices;
public class KeyboardState {
    [DllImport("user32.dll")]
    public static extern short GetKeyState(int nVirtKey);
}
"@
Add-Type $signature

Write-Host "Monitoring key states... Press Q at any time to exit.`n"

$keys = @{
    "Shift" = 0x10   # VK_SHIFT
    "Ctrl"  = 0x11   # VK_CONTROL
    "Alt"   = 0x12   # VK_MENU
    "LWin"  = 0x5B   # VK_LWIN
    "RWin"  = 0x5C   # VK_RWIN
    "Esc"   = 0x1B   # VK_ESCAPE
    "Space" = 0x20   # VK_SPACE	
}

$breakKey = 0x51    # Q — VK_Q

# per-key consecutive-down streaks
$streaks = @{}
foreach ($k in $keys.Keys) {
    $streaks[$k] = 0
}

while ($true) {

    # Check for break key
    $bk = [KeyboardState]::GetKeyState($breakKey)
    if ($bk -band 0x8000) {
        Write-Host "`nBreak key (Q) pressed. Exiting."
        break
    }

    $down = @()
    $anyKeyHighStreak = $false

    foreach ($entry in $keys.GetEnumerator()) {
        $keyName  = $entry.Key
        $vk       = $entry.Value
        $state    = [KeyboardState]::GetKeyState($vk)

        if ($state -band 0x8000) {
            # key is currently down
            $down += $keyName
            $streaks[$keyName]++

            if ($streaks[$keyName] -ge 10) {
                $anyKeyHighStreak = $true
            }
        } else {
            # reset that key's streak when it's up
            $streaks[$keyName] = 0
        }
    }

    if ($down.Count -gt 0) {
        $msg = "DOWN: {0}" -f ($down -join ", ")

        if ($anyKeyHighStreak) {
            Write-Host $msg -ForegroundColor Red
        } else {
            Write-Host $msg
        }
    }

    Start-Sleep -Milliseconds 200
}
