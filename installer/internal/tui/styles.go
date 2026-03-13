package tui

import "github.com/charmbracelet/lipgloss"

// Tokyo Night 配色
var (
	colorBg        = lipgloss.Color("#1a1b26")
	colorBgHighlight = lipgloss.Color("#292e42")
	colorFg        = lipgloss.Color("#c0caf5")
	colorBlue      = lipgloss.Color("#7aa2f7")
	colorGreen     = lipgloss.Color("#9ece6a")
	colorYellow    = lipgloss.Color("#e0af68")
	colorRed       = lipgloss.Color("#f7768e")
	colorMagenta   = lipgloss.Color("#bb9af7")
	colorCyan      = lipgloss.Color("#7dcfff")
	colorComment   = lipgloss.Color("#565f89")

	// 標題樣式
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(colorMagenta).
			MarginBottom(1)

	// 描述文字樣式
	descStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#a9b1d6"))

	// 選中項目樣式
	selectedStyle = lipgloss.NewStyle().
			Foreground(colorGreen).
			Bold(true)

	// 未選中項目樣式
	normalStyle = lipgloss.NewStyle().
			Foreground(colorFg)

	// 勾選框樣式
	checkedStyle = lipgloss.NewStyle().
			Foreground(colorGreen)

	uncheckedStyle = lipgloss.NewStyle().
			Foreground(colorComment)

	// 狀態指示
	statusRunning = lipgloss.NewStyle().Foreground(colorYellow)
	statusDone    = lipgloss.NewStyle().Foreground(colorGreen)
	statusFailed  = lipgloss.NewStyle().Foreground(colorRed)
	statusPending = lipgloss.NewStyle().Foreground(colorComment)

	// 提示文字
	helpStyle = lipgloss.NewStyle().
			Foreground(colorComment).
			MarginTop(1)

	// 輸入框
	inputLabelStyle = lipgloss.NewStyle().
			Foreground(colorBlue).
			Bold(true)
)

// 抑制未使用的變數警告
var _ = colorBg
var _ = colorBgHighlight
var _ = colorCyan
