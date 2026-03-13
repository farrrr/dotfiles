package tui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

// configInputModel 處理設定輸入畫面
type configInputModel struct {
	inputs []textinput.Model
	labels []string
	cursor int
	done   bool
	email  string
}

func newConfigInputModel() configInputModel {
	emailInput := textinput.New()
	emailInput.Placeholder = "your@email.com"
	emailInput.Focus()

	return configInputModel{
		inputs: []textinput.Model{emailInput},
		labels: []string{"Git Email"},
	}
}

func (m configInputModel) Init() tea.Cmd {
	return textinput.Blink
}

func (m configInputModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "enter":
			if m.cursor < len(m.inputs)-1 {
				m.inputs[m.cursor].Blur()
				m.cursor++
				m.inputs[m.cursor].Focus()
			} else {
				m.email = m.inputs[0].Value()
				m.done = true
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

	s += helpStyle.Render("Enter 確認  Ctrl+C 取消")
	return s
}
