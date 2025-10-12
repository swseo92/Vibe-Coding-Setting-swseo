@echo off
echo Hook triggered at: %date% %time%
powershell -c "Add-Type -AssemblyName System.Speech; $folderName = Split-Path (Get-Location) -Leaf; $message = $folderName + ': ' + '%1'; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak($message)"