package runner

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/farrrr/dotfiles/installer/internal/profile"
)

// ModuleStatus 代表模組安裝狀態
type ModuleStatus int

const (
	StatusPending ModuleStatus = iota
	StatusRunning
	StatusDone
	StatusFailed
)

// ModuleResult 代表單一模組的執行結果
type ModuleResult struct {
	Name   string
	Status ModuleStatus
	Error  error
}

// Runner 負責依序執行 module 的 install.sh
type Runner struct {
	DotfilesDir string
	OS          string
	Arch        string
	System      string
}

// NewRunner 建立新的 Runner
func NewRunner(dotfilesDir, system string) *Runner {
	return &Runner{
		DotfilesDir: dotfilesDir,
		OS:          profile.DetectOS(),
		Arch:        profile.DetectArch(),
		System:      system,
	}
}

// RunModule 執行單一模組的 install.sh
func (r *Runner) RunModule(moduleName string) error {
	scriptPath := filepath.Join(r.DotfilesDir, "modules", moduleName, "install.sh")

	if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
		return fmt.Errorf("找不到 %s 的安裝腳本: %s", moduleName, scriptPath)
	}

	cmd := exec.Command("bash", scriptPath)
	cmd.Dir = r.DotfilesDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = append(os.Environ(),
		fmt.Sprintf("DOTFILES_DIR=%s", r.DotfilesDir),
		fmt.Sprintf("DOTFILES_OS=%s", r.OS),
		fmt.Sprintf("DOTFILES_ARCH=%s", r.Arch),
		fmt.Sprintf("DOTFILES_SYSTEM=%s", r.System),
	)

	return cmd.Run()
}

// RunAll 依序執行多個模組，透過 callback 回報進度
func (r *Runner) RunAll(modules []string, onProgress func(result ModuleResult)) {
	for _, name := range modules {
		onProgress(ModuleResult{Name: name, Status: StatusRunning})

		if err := r.RunModule(name); err != nil {
			onProgress(ModuleResult{Name: name, Status: StatusFailed, Error: err})
		} else {
			onProgress(ModuleResult{Name: name, Status: StatusDone})
		}
	}
}
