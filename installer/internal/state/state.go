package state

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"gopkg.in/yaml.v3"
)

// State 代表安裝狀態，儲存在 ~/.config/dotfiles/state.yaml
type State struct {
	Profile          string    `yaml:"profile"`
	InstalledModules []string  `yaml:"installed_modules"`
	InstalledAt      time.Time `yaml:"installed_at"`
}

// DefaultPath 回傳預設的 state 檔案路徑
func DefaultPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "dotfiles", "state.yaml")
}

// Load 從檔案載入狀態
func Load(path string) (*State, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return &State{}, nil
		}
		return nil, fmt.Errorf("讀取狀態檔案失敗: %w", err)
	}

	var s State
	if err := yaml.Unmarshal(data, &s); err != nil {
		return nil, fmt.Errorf("解析狀態檔案失敗: %w", err)
	}
	return &s, nil
}

// Save 將狀態寫入檔案
func (s *State) Save(path string) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return fmt.Errorf("建立狀態目錄失敗: %w", err)
	}

	data, err := yaml.Marshal(s)
	if err != nil {
		return fmt.Errorf("序列化狀態失敗: %w", err)
	}

	return os.WriteFile(path, data, 0o644)
}

// Diff 比較當前狀態與新的模組清單，回傳需要新安裝的模組
func (s *State) Diff(newModules []string) []string {
	installed := make(map[string]bool)
	for _, m := range s.InstalledModules {
		installed[m] = true
	}

	var added []string
	for _, m := range newModules {
		if !installed[m] {
			added = append(added, m)
		}
	}
	return added
}
