package tui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

// configInputModel 處理設定輸入畫面
type configInputModel struct {
	inputs         []textinput.Model
	labels         []string
	cursor         int
	done           bool
	email          string
	installSSHKeys bool
	// SSH 選項在文字輸入完成後顯示
	showSSHOption  bool
	sshOptionIndex int // 0 = Yes, 1 = No
}

func newConfigInputModel(defaultEmail string) configInputModel {
	emailInput := textinput.New()
	emailInput.Placeholder = "your@email.com"
	if defaultEmail != "" {
		emailInput.SetValue(defaultEmail)
	}
	emailInput.Focus()

	return configInputModel{
		inputs:         []textinput.Model{emailInput},
		labels:         []string{"Git Email"},
		sshOptionIndex: 1, // 預設 No
	}
}

func (m configInputModel) Init() tea.Cmd {
	return textinput.Blink
}

func (m configInputModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		// SSH 選項畫面
		if m.showSSHOption {
			switch keyMsg.String() {
			case "left", "h":
				m.sshOptionIndex = 0
			case "right", "l":
				m.sshOptionIndex = 1
			case "enter":
				m.installSSHKeys = m.sshOptionIndex == 0
				m.done = true
			}
			return m, nil
		}

		// 文字輸入畫面
		switch keyMsg.String() {
		case "enter":
			if m.cursor < len(m.inputs)-1 {
				m.inputs[m.cursor].Blur()
				m.cursor++
				m.inputs[m.cursor].Focus()
			} else {
				m.email = m.inputs[0].Value()
				m.showSSHOption = true
			}
			return m, nil
		case "tab":
			if m.cursor < len(m.inputs)-1 {
				m.inputs[m.cursor].Blur()
				m.cursor++
				m.inputs[m.cursor].Focus()
			}
			return m, nil
		}
	}

	var cmd tea.Cmd
	m.inputs[m.cursor], cmd = m.inputs[m.cursor].Update(msg)
	return m, cmd
}

func (m configInputModel) View() string {
	s := titleStyle.Render("設定") + "\n\n"

	for i, input := range m.inputs {
		label := inputLabelStyle.Render(m.labels[i] + "：")
		s += fmt.Sprintf("%s\n%s\n\n", label, input.View())
	}

	if m.showSSHOption {
		s += inputLabelStyle.Render("安裝 SSH 私鑰？") + "\n"
		s += descStyle.Render("選 No 則使用 SSH Agent Forwarding") + "\n\n"

		yes := "  Yes  "
		no := "  No  "
		if m.sshOptionIndex == 0 {
			yes = selectedStyle.Render(yes)
			no = normalStyle.Render(no)
		} else {
			yes = normalStyle.Render(yes)
			no = selectedStyle.Render(no)
		}
		s += fmt.Sprintf("  %s    %s\n\n", yes, no)

		s += helpStyle.Render("← → 切換  Enter 確認  Ctrl+C 取消")
	} else {
		s += helpStyle.Render("Enter 確認  Ctrl+C 取消")
	}
	return s
}
