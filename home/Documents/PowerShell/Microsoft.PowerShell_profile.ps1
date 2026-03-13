# PowerShell Profile
# Oh My Posh 提示符

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\config.yaml" | Invoke-Expression
}

# --- 別名 ---
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue

# 使用 eza 替代 ls（如果有安裝）
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza -F --icons -a --group-directories-first --git @args }
    function ll { eza -F --icons -a --group-directories-first --git --long --group --header @args }
}
