# PowerShell Profile

# --- Oh My Posh 提示符 ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\config.yaml" | Invoke-Expression
}

# --- 編輯器 ---
$env:EDITOR = "nvim"
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue

# --- 現代 CLI 替代品 ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza -F --icons -a --group-directories-first --git @args }
    function ll { eza -F --icons -a --group-directories-first --git --long --group --header @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -ErrorAction SilentlyContinue
}

# --- PSReadLine 強化 ---
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# --- Mise ---
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Invoke-Expression
}
