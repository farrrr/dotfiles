package tui

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/farrrr/dotfiles/installer/internal/profile"
	"github.com/farrrr/dotfiles/installer/internal/runner"
)

// AppState 代表 TUI 的畫面狀態
type AppState int

const (
	StateProfileSelect AppState = iota
	StateModuleSelect
	StateConfigInput
	StateProgress
	StateDone
)

// Config 儲存使用者在 TUI 中輸入的設定
type Config struct {
	Profile         profile.Profile
	SelectedModules []string
	Email           string
	System          string
}

// App 是主要的 bubbletea Model
type App struct {
	state       AppState
	profiles    []profile.Profile
	modules     map[string]profile.ModuleMeta
	dotfilesDir string

	// 子畫面
	profileSelect profileSelectModel
	moduleSelect  moduleSelectModel
	configInput   configInputModel
	progress      progressModel

	// 最終設定
	config Config
}

// NewApp 建立新的 TUI App
func NewApp(profiles []profile.Profile, modules map[string]profile.ModuleMeta, dotfilesDir string) App {
	return App{
		state:         StateProfileSelect,
		profiles:      profiles,
		modules:       modules,
		dotfilesDir:   dotfilesDir,
		profileSelect: newProfileSelectModel(profiles),
	}
}

func (a App) Init() tea.Cmd {
	return nil
}

func (a App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	// 全域按鍵處理
	if keyMsg, ok := msg.(tea.KeyMsg); ok {
		switch keyMsg.String() {
		case "ctrl+c":
			return a, tea.Quit
		}
	}

	switch a.state {
	case StateProfileSelect:
		model, cmd := a.profileSelect.Update(msg)
		a.profileSelect = model.(profileSelectModel)

		if a.profileSelect.done {
			selectedProfile := a.profiles[a.profileSelect.cursor]
			a.config.Profile = selectedProfile
			a.config.System = selectedProfile.System
			a.moduleSelect = newModuleSelectModel(selectedProfile.Modules, a.modules)
			a.state = StateModuleSelect
		}
		return a, cmd

	case StateModuleSelect:
		model, cmd := a.moduleSelect.Update(msg)
		a.moduleSelect = model.(moduleSelectModel)

		if a.moduleSelect.done {
			a.config.SelectedModules = a.moduleSelect.getSelected()
			a.configInput = newConfigInputModel()
			a.state = StateConfigInput
		}
		return a, cmd

	case StateConfigInput:
		model, cmd := a.configInput.Update(msg)
		a.configInput = model.(configInputModel)

		if a.configInput.done {
			a.config.Email = a.configInput.email
			// 開始安裝
			sorted, _ := profile.ResolveDependencies(a.config.SelectedModules, a.modules)
			r := runner.NewRunner(a.dotfilesDir, a.config.System)
			a.progress = newProgressModel(sorted, r, a.modules)
			a.state = StateProgress
			return a, a.progress.start()
		}
		return a, cmd

	case StateProgress:
		model, cmd := a.progress.Update(msg)
		a.progress = model.(progressModel)

		if a.progress.done {
			a.state = StateDone
		}
		return a, cmd

	case StateDone:
		if keyMsg, ok := msg.(tea.KeyMsg); ok {
			if keyMsg.String() == "enter" || keyMsg.String() == "q" {
				return a, tea.Quit
			}
		}
		return a, nil
	}

	return a, nil
}

func (a App) View() string {
	switch a.state {
	case StateProfileSelect:
		return a.profileSelect.View()
	case StateModuleSelect:
		return a.moduleSelect.View()
	case StateConfigInput:
		return a.configInput.View()
	case StateProgress:
		return a.progress.View()
	case StateDone:
		return titleStyle.Render("安裝完成！") + "\n\n" +
			descStyle.Render("請重新開啟終端機以套用設定。") + "\n" +
			helpStyle.Render("按 Enter 或 q 結束")
	}
	return ""
}

// GetConfig 取得使用者設定（安裝完成後由 main.go 使用）
func (a App) GetConfig() Config {
	return a.config
}
