package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/fartseng/dotfiles/installer/internal/profile"
	"github.com/fartseng/dotfiles/installer/internal/runner"
	"github.com/fartseng/dotfiles/installer/internal/state"
)

var version = "dev"

func main() {
	// 命令列參數
	showVersion := flag.Bool("version", false, "顯示版本資訊")
	diffMode := flag.Bool("diff", false, "差異模式：只安裝新增的模組")
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

	fmt.Printf("Dotfiles 目錄: %s\n", dotfilesDir)
	fmt.Printf("作業系統: %s/%s\n", profile.DetectOS(), profile.DetectArch())

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

	fmt.Printf("可用 Profiles: %d\n", len(availableProfiles))
	fmt.Printf("可用 Modules: %d\n", len(availableModules))

	if *diffMode {
		runDiffMode(dotfilesDir, availableProfiles, modules)
		return
	}

	// TODO: Task 10 會在這裡加入 TUI 互動介面
	// 目前先印出可用的 profiles 和 modules
	fmt.Println("\n可用的 Profiles:")
	for _, p := range availableProfiles {
		fmt.Printf("  - %s: %s\n", p.Name, p.Description)
	}

	fmt.Println("\n可用的 Modules:")
	for name, m := range availableModules {
		fmt.Printf("  - %s: %s\n", name, m.Name)
	}
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
