package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/farrrr/dotfiles/installer/internal/chezmoi"
	"github.com/farrrr/dotfiles/installer/internal/profile"
	"github.com/farrrr/dotfiles/installer/internal/runner"
	"github.com/farrrr/dotfiles/installer/internal/state"
	"github.com/farrrr/dotfiles/installer/internal/tui"
)

var version = "dev"

func main() {
	// 命令列參數
	showVersion := flag.Bool("version", false, "顯示版本資訊")
	diffMode := flag.Bool("diff", false, "差異模式：只安裝新增的模組")
	dryRun := flag.Bool("dry-run", false, "預覽模式：只顯示會執行的動作，不實際安裝")
	flag.Parse()

	if *showVersion {
		fmt.Printf("dotfiles-installer %s\n", version)
		os.Exit(0)
	}

	// 偵測 dotfiles 目錄位置
	dotfilesDir := findDotfilesDir()
	if dotfilesDir == "" {
		fmt.Fprintln(os.Stderr, "錯誤：找不到 dotfiles 目錄")
		os.Exit(1)
	}

	// 載入 profiles 和 modules
	profiles, err := profile.LoadProfiles(filepath.Join(dotfilesDir, "profiles"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "錯誤：%v\n", err)
		os.Exit(1)
	}

	modules, err := profile.LoadModules(filepath.Join(dotfilesDir, "modules"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "錯誤：%v\n", err)
		os.Exit(1)
	}

	// 過濾當前 OS 可用的 profiles
	availableProfiles := profile.FilterProfilesByOS(profiles)
	availableModules := profile.FilterModulesByOS(modules)

	if *diffMode {
		runDiffMode(dotfilesDir, availableProfiles, modules)
		return
	}

	// 啟動 TUI（dry-run 模式下跳過安裝步驟）
	app := tui.NewApp(availableProfiles, availableModules, dotfilesDir, *dryRun)
	p := tea.NewProgram(app, tea.WithAltScreen())
	finalModel, err := p.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "TUI 錯誤：%v\n", err)
		os.Exit(1)
	}

	// 取得使用者設定
	finalApp := finalModel.(tui.App)
	cfg := finalApp.GetConfig()

	// dry-run 模式：只顯示摘要
	if *dryRun {
		printDryRunSummary(cfg, dotfilesDir)
		return
	}

	// --- 第一步：Chezmoi（先同步 config 檔，module 才能讀到最新設定） ---
	homeDir, _ := os.UserHomeDir()
	chezmoiCfg := chezmoi.GenerateConfig(cfg.Email, cfg.System, profile.DetectOS())
	if err := chezmoi.WriteConfig(chezmoiCfg, homeDir); err != nil {
		fmt.Fprintf(os.Stderr, "警告：產生 chezmoi.yaml 失敗: %v\n", err)
	}

	if !chezmoi.IsInstalled() {
		fmt.Println("安裝 chezmoi...")
		if err := chezmoi.Install(); err != nil {
			fmt.Fprintf(os.Stderr, "錯誤：安裝 chezmoi 失敗: %v\n", err)
			os.Exit(1)
		}
	}

	fmt.Println("執行 chezmoi init --apply...")
	if err := chezmoi.InitAndApply("farrrr/dotfiles"); err != nil {
		fmt.Fprintf(os.Stderr, "警告：chezmoi init --apply 失敗: %v\n", err)
	}

	// --- 第二步：執行 modules（TUI 已收集完設定，這裡直接跑） ---
	fmt.Println("\n開始安裝模組...")
	r := runner.NewRunner(dotfilesDir, cfg.System)
	allModules, _ := profile.LoadModules(filepath.Join(dotfilesDir, "modules"))
	sorted, _ := profile.ResolveDependencies(cfg.SelectedModules, allModules)
	r.RunAll(sorted, func(result runner.ModuleResult) {
		meta := allModules[result.Name]
		displayName := result.Name
		if meta.Name != "" {
			displayName = meta.Name
		}
		switch result.Status {
		case runner.StatusRunning:
			fmt.Printf("● 安裝 %s...\n", displayName)
		case runner.StatusDone:
			fmt.Printf("✓ %s\n", displayName)
		case runner.StatusFailed:
			fmt.Printf("✗ %s: %v\n", displayName, result.Error)
		}
	})

	// --- 第三步：儲存狀態 ---
	st := &state.State{
		Profile:          cfg.Profile.Name,
		InstalledModules: cfg.SelectedModules,
		InstalledAt:      time.Now(),
	}
	if err := st.Save(state.DefaultPath()); err != nil {
		fmt.Fprintf(os.Stderr, "警告：儲存狀態失敗: %v\n", err)
	}

	fmt.Println("\n安裝完成！請重新開啟終端機以套用設定。")
}

// findDotfilesDir 尋找 dotfiles 目錄
func findDotfilesDir() string {
	// 優先使用執行檔所在目錄的父目錄
	exe, err := os.Executable()
	if err == nil {
		dir := filepath.Dir(filepath.Dir(exe))
		if isValidDotfilesDir(dir) {
			return dir
		}
	}

	// 其次嘗試當前目錄
	cwd, err := os.Getwd()
	if err == nil {
		if isValidDotfilesDir(cwd) {
			return cwd
		}
	}

	// 最後嘗試常見路徑
	home, _ := os.UserHomeDir()
	candidates := []string{
		filepath.Join(home, ".local", "share", "chezmoi"),
		filepath.Join(home, "dotfiles"),
		filepath.Join(home, "codebase", "src", "dotfiles"),
	}
	for _, c := range candidates {
		if isValidDotfilesDir(c) {
			return c
		}
	}

	return ""
}

// isValidDotfilesDir 檢查目錄是否為有效的 dotfiles 目錄
func isValidDotfilesDir(dir string) bool {
	// 檢查是否有 profiles/ 和 modules/ 子目錄
	for _, sub := range []string{"profiles", "modules", "home"} {
		info, err := os.Stat(filepath.Join(dir, sub))
		if err != nil || !info.IsDir() {
			return false
		}
	}
	return true
}

// printDryRunSummary 顯示 dry-run 摘要
func printDryRunSummary(cfg tui.Config, dotfilesDir string) {
	fmt.Println("\n========== Dry Run 摘要 ==========")
	fmt.Printf("Profile:     %s\n", cfg.Profile.Name)
	fmt.Printf("System:      %s\n", cfg.System)
	fmt.Printf("Email:       %s\n", cfg.Email)
	fmt.Printf("OS:          %s/%s\n", profile.DetectOS(), profile.DetectArch())
	fmt.Printf("Dotfiles:    %s\n", dotfilesDir)

	// 依賴排序
	allModules, _ := profile.LoadModules(filepath.Join(dotfilesDir, "modules"))
	sorted, _ := profile.ResolveDependencies(cfg.SelectedModules, allModules)

	fmt.Printf("\n將安裝的模組（按執行順序）:\n")
	for i, name := range sorted {
		meta := allModules[name]
		fmt.Printf("  %d. %-15s %s\n", i+1, name, meta.Description)
	}

	fmt.Printf("\n將執行的動作:\n")
	fmt.Println("  1. 依序執行上述模組的 install.sh")
	fmt.Println("  2. 產生 ~/.chezmoi.yaml")
	fmt.Println("  3. 執行 chezmoi init --apply")
	fmt.Println("  4. 儲存安裝狀態到 ~/.config/dotfiles/state.yaml")
	fmt.Println("\n以上為預覽，未實際執行任何操作。")
	fmt.Println("移除 --dry-run 參數以執行實際安裝。")
}

// runDiffMode 差異模式：比對 state 並安裝新增的模組
func runDiffMode(dotfilesDir string, profiles []profile.Profile, allModules map[string]profile.ModuleMeta) {
	st, err := state.Load(state.DefaultPath())
	if err != nil {
		fmt.Fprintf(os.Stderr, "錯誤：%v\n", err)
		os.Exit(1)
	}

	// 找到當前 profile
	var currentProfile *profile.Profile
	for _, p := range profiles {
		if p.Name == st.Profile {
			currentProfile = &p
			break
		}
	}

	if currentProfile == nil {
		fmt.Fprintln(os.Stderr, "找不到已儲存的 profile，請重新執行完整安裝")
		os.Exit(1)
	}

	// 比對差異
	newModules := st.Diff(currentProfile.Modules)
	if len(newModules) == 0 {
		fmt.Println("沒有需要新安裝的模組")
		return
	}

	fmt.Printf("偵測到 %d 個新模組需要安裝:\n", len(newModules))
	for _, m := range newModules {
		fmt.Printf("  + %s\n", m)
	}

	// 依賴排序
	sorted, err := profile.ResolveDependencies(newModules, allModules)
	if err != nil {
		fmt.Fprintf(os.Stderr, "錯誤：%v\n", err)
		os.Exit(1)
	}

	// 執行安裝
	r := runner.NewRunner(dotfilesDir, currentProfile.System)
	r.RunAll(sorted, func(result runner.ModuleResult) {
		switch result.Status {
		case runner.StatusRunning:
			fmt.Printf("● 安裝 %s...\n", result.Name)
		case runner.StatusDone:
			fmt.Printf("✓ %s 完成\n", result.Name)
		case runner.StatusFailed:
			fmt.Printf("✗ %s 失敗: %v\n", result.Name, result.Error)
		}
	})

	// 更新狀態
	st.Profile = currentProfile.Name
	st.InstalledModules = currentProfile.Modules
	st.InstalledAt = time.Now()
	if err := st.Save(state.DefaultPath()); err != nil {
		fmt.Fprintf(os.Stderr, "警告：儲存狀態失敗: %v\n", err)
	}
}
