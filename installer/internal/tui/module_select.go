package tui

import (
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/farrrr/dotfiles/installer/internal/profile"
)

// moduleItem 代表一個可勾選的模組
type moduleItem struct {
	name     string
	meta     profile.ModuleMeta
	selected bool
}

// moduleSelectModel 處理模組勾選畫面
type moduleSelectModel struct {
	items  []moduleItem
	cursor int
	done   bool
}

func newModuleSelectModel(defaultModules []string, allModules map[string]profile.ModuleMeta) moduleSelectModel {
	defaultSet := make(map[string]bool)
	for _, m := range defaultModules {
		defaultSet[m] = true
	}

	var items []moduleItem
	// 先加入預設模組（保持順序）
	for _, name := range defaultModules {
		if meta, ok := allModules[name]; ok {
			items = append(items, moduleItem{name: name, meta: meta, selected: true})
		}
	}
	// 再加入其他可用模組
	for name, meta := range allModules {
		if !defaultSet[name] {
			items = append(items, moduleItem{name: name, meta: meta, selected: false})
		}
	}

	return moduleSelectModel{items: items}
}

func (m moduleSelectModel) Init() tea.Cmd { return nil }

func (m moduleSelectModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.items)-1 {
				m.cursor++
			}
		case " ":
			m.items[m.cursor].selected = !m.items[m.cursor].selected
		case "enter":
			m.done = true
		}
	}
	return m, nil
}

func (m moduleSelectModel) View() string {
	s := titleStyle.Render("選擇要安裝的模組：") + "\n\n"

	for i, item := range m.items {
		cursor := "  "
		if i == m.cursor {
			cursor = "> "
		}

		check := uncheckedStyle.Render("[ ]")
		if item.selected {
			check = checkedStyle.Render("[✓]")
		}

		nameStyle := normalStyle
		if i == m.cursor {
			nameStyle = selectedStyle
		}

		s += fmt.Sprintf("%s%s %s  %s\n", cursor, check,
			nameStyle.Render(fmt.Sprintf("%-12s", item.name)),
			descStyle.Render(item.meta.Description))
	}

	s += helpStyle.Render("\n↑/↓ 移動  空白鍵 切換  Enter 確認  Ctrl+C 取消")
	return s
}

func (m moduleSelectModel) getSelected() []string {
	var selected []string
	for _, item := range m.items {
		if item.selected {
			selected = append(selected, item.name)
		}
	}
	return selected
}
