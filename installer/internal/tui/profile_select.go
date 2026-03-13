package tui

import (
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/farrrr/dotfiles/installer/internal/profile"
)

// profileSelectModel 處理 Profile 選擇畫面
type profileSelectModel struct {
	profiles []profile.Profile
	cursor   int
	done     bool
}

func newProfileSelectModel(profiles []profile.Profile) profileSelectModel {
	return profileSelectModel{profiles: profiles}
}

func (m profileSelectModel) Init() tea.Cmd { return nil }

func (m profileSelectModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.profiles)-1 {
				m.cursor++
			}
		case "enter":
			m.done = true
		}
	}
	return m, nil
}

func (m profileSelectModel) View() string {
	s := titleStyle.Render("歡迎使用 Far's Dotfiles Installer") + "\n"
	s += descStyle.Render(fmt.Sprintf("偵測到：%s %s", profile.DetectOS(), profile.DetectArch())) + "\n\n"
	s += titleStyle.Render("選擇 Profile：") + "\n"

	for i, p := range m.profiles {
		cursor := "  "
		style := normalStyle
		if i == m.cursor {
			cursor = "> "
			style = selectedStyle
		}
		s += fmt.Sprintf("%s%s\n", cursor, style.Render(fmt.Sprintf("%-20s %s", p.Name, descStyle.Render(p.Description))))
	}

	s += helpStyle.Render("\n↑/↓ 移動  Enter 確認  Ctrl+C 取消")
	return s
}
