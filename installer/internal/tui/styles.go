package tui

import "github.com/charmbracelet/lipgloss"

// Catppuccin Mocha 配色
var (
	colorBase    = lipgloss.Color("#1e1e2e")
	colorSurface = lipgloss.Color("#313244")
	colorText    = lipgloss.Color("#cdd6f4")
	colorBlue    = lipgloss.Color("#89b4fa")
	colorGreen   = lipgloss.Color("#a6e3a1")
	colorYellow  = lipgloss.Color("#f9e2af")
	colorRed     = lipgloss.Color("#f38ba8")
	colorMauve   = lipgloss.Color("#cba6f7")

	// 標題樣式
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(colorMauve).
			MarginBottom(1)

	// 描述文字樣式
	descStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#a6adc8"))

	// 選中項目樣式
	selectedStyle = lipgloss.NewStyle().
			Foreground(colorGreen).
			Bold(true)

	// 未選中項目樣式
	normalStyle = lipgloss.NewStyle().
			Foreground(colorText)

	// 勾選框樣式
	checkedStyle = lipgloss.NewStyle().
			Foreground(colorGreen)

	uncheckedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#585b70"))

	// 狀態指示
	statusRunning = lipgloss.NewStyle().Foreground(colorYellow)
	statusDone    = lipgloss.NewStyle().Foreground(colorGreen)
	statusFailed  = lipgloss.NewStyle().Foreground(colorRed)
	statusPending = lipgloss.NewStyle().Foreground(lipgloss.Color("#585b70"))

	// 提示文字
	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#585b70")).
			MarginTop(1)

	// 輸入框
	inputLabelStyle = lipgloss.NewStyle().
			Foreground(colorBlue).
			Bold(true)
)

// 抑制未使用的變數警告（顏色常數供日後擴充使用）
var _ = colorBase
var _ = colorSurface
