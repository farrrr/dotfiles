package tui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/fartseng/dotfiles/installer/internal/profile"
	"github.com/fartseng/dotfiles/installer/internal/runner"
)

// moduleProgressMsg 代表模組安裝進度更新
type moduleProgressMsg struct {
	result runner.ModuleResult
}

// allDoneMsg 代表所有模組安裝完成
type allDoneMsg struct{}

// progressModel 處理安裝進度畫面
type progressModel struct {
	modules    []string
	moduleMeta map[string]profile.ModuleMeta
	statuses   map[string]runner.ModuleStatus
	errors     map[string]error
	runner     *runner.Runner
	spinner    spinner.Model
	current    string
	done       bool
}

func newProgressModel(modules []string, r *runner.Runner, meta map[string]profile.ModuleMeta) progressModel {
	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = statusRunning

	statuses := make(map[string]runner.ModuleStatus)
	for _, m := range modules {
		statuses[m] = runner.StatusPending
	}

	return progressModel{
		modules:    modules,
		moduleMeta: meta,
		statuses:   statuses,
		errors:     make(map[string]error),
		runner:     r,
		spinner:    s,
	}
}

func (m progressModel) Init() tea.Cmd { return nil }

// start 開始安裝流程
func (m progressModel) start() tea.Cmd {
	return tea.Batch(
		m.spinner.Tick,
		m.runModules(),
	)
}

// runModules 在背景執行所有模組安裝
func (m progressModel) runModules() tea.Cmd {
	return func() tea.Msg {
		for _, name := range m.modules {
			// 注意：bubbletea 的 Cmd 是非同步的，這裡用同步方式簡化
			err := m.runner.RunModule(name)
			if err != nil {
				return moduleProgressMsg{result: runner.ModuleResult{
					Name:   name,
					Status: runner.StatusFailed,
					Error:  err,
				}}
			}
		}
		return allDoneMsg{}
	}
}

func (m progressModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd

	case moduleProgressMsg:
		m.statuses[msg.result.Name] = msg.result.Status
		if msg.result.Error != nil {
			m.errors[msg.result.Name] = msg.result.Error
		}
		return m, nil

	case allDoneMsg:
		// 標記所有未失敗的為完成
		for _, name := range m.modules {
			if m.statuses[name] == runner.StatusPending || m.statuses[name] == runner.StatusRunning {
				m.statuses[name] = runner.StatusDone
			}
		}
		m.done = true
		return m, nil
	}

	return m, nil
}

func (m progressModel) View() string {
	s := titleStyle.Render("安裝中...") + "\n\n"

	for _, name := range m.modules {
		status := m.statuses[name]
		displayName := name
		if meta, ok := m.moduleMeta[name]; ok {
			displayName = meta.Name
		}

		var icon string
		switch status {
		case runner.StatusPending:
			icon = statusPending.Render("○")
		case runner.StatusRunning:
			icon = m.spinner.View()
		case runner.StatusDone:
			icon = statusDone.Render("✓")
		case runner.StatusFailed:
			icon = statusFailed.Render("✗")
		}

		line := fmt.Sprintf("  %s %s", icon, normalStyle.Render(displayName))
		if err, ok := m.errors[name]; ok {
			line += statusFailed.Render(fmt.Sprintf("  %v", err))
		}
		s += line + "\n"
	}

	if !m.done {
		s += helpStyle.Render("\n安裝進行中，請稍候...")
	}

	return s
}
