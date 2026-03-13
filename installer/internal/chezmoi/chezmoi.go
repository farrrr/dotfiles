package chezmoi

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// ChezmoiConfig 代表 .chezmoi.yaml 的內容
type ChezmoiConfig struct {
	Data       ChezmoiData `yaml:"data"`
	Encryption string      `yaml:"encryption,omitempty"`
	Age        *ChezmoiAge `yaml:"age,omitempty"`
}

// ChezmoiData 儲存傳入 chezmoi 範本的使用者資料
type ChezmoiData struct {
	Email   string `yaml:"email"`
	System  string `yaml:"system"`
	IsMac   bool   `yaml:"is_mac"`
	IsLinux bool   `yaml:"is_linux"`
}

// ChezmoiAge 代表 age 加密設定
type ChezmoiAge struct {
	Passphrase bool `yaml:"passphrase"`
}

// GenerateConfig 根據使用者設定產生 .chezmoi.yaml
func GenerateConfig(email, system, osName string) *ChezmoiConfig {
	return &ChezmoiConfig{
		Data: ChezmoiData{
			Email:   email,
			System:  system,
			IsMac:   osName == "darwin",
			IsLinux: osName == "linux",
		},
		Encryption: "age",
		Age: &ChezmoiAge{
			Passphrase: true,
		},
	}
}

// WriteConfig 將 .chezmoi.yaml 寫入指定路徑
func WriteConfig(config *ChezmoiConfig, destDir string) error {
	data, err := yaml.Marshal(config)
	if err != nil {
		return fmt.Errorf("序列化 chezmoi 設定失敗: %w", err)
	}

	path := filepath.Join(destDir, ".chezmoi.yaml")
	return os.WriteFile(path, data, 0o644)
}

// IsInstalled 檢查 chezmoi 是否已安裝
func IsInstalled() bool {
	_, err := exec.LookPath("chezmoi")
	return err == nil
}

// Install 安裝 chezmoi（使用官方安裝腳本）
func Install() error {
	cmd := exec.Command("sh", "-c", "curl -sfL https://get.chezmoi.io | sh -s -- -b ~/.local/bin")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// InitAndApply 執行 chezmoi init --apply，首次初始化並套用 dotfiles
func InitAndApply(sourceDir string) error {
	args := []string{"init", "--apply", "--source", sourceDir}

	cmd := exec.Command("chezmoi", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin // age passphrase 需要互動輸入
	return cmd.Run()
}

// Apply 執行 chezmoi apply，套用最新變更
func Apply(sourceDir string) error {
	cmd := exec.Command("chezmoi", "apply", "--source", sourceDir)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}
