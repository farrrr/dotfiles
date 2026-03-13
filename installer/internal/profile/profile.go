package profile

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"sort"

	"gopkg.in/yaml.v3"
)

// Profile 代表一個安裝設定檔
type Profile struct {
	Name        string   `yaml:"name"`
	Description string   `yaml:"description"`
	OS          string   `yaml:"os"`
	System      string   `yaml:"system"`
	Modules     []string `yaml:"modules"`
}

// ModuleMeta 代表一個模組的描述資訊
type ModuleMeta struct {
	Name        string   `yaml:"name"`
	Description string   `yaml:"description"`
	OS          []string `yaml:"os"`
	DependsOn   []string `yaml:"depends_on"`
}

// LoadProfiles 從指定目錄載入所有 profile YAML 檔案
func LoadProfiles(dir string) ([]Profile, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("讀取 profiles 目錄失敗: %w", err)
	}

	var profiles []Profile
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".yaml" {
			continue
		}

		data, err := os.ReadFile(filepath.Join(dir, entry.Name()))
		if err != nil {
			return nil, fmt.Errorf("讀取 %s 失敗: %w", entry.Name(), err)
		}

		var p Profile
		if err := yaml.Unmarshal(data, &p); err != nil {
			return nil, fmt.Errorf("解析 %s 失敗: %w", entry.Name(), err)
		}
		profiles = append(profiles, p)
	}

	return profiles, nil
}

// LoadModules 從 modules 目錄載入所有模組的 meta.yaml
func LoadModules(dir string) (map[string]ModuleMeta, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("讀取 modules 目錄失敗: %w", err)
	}

	modules := make(map[string]ModuleMeta)
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		metaPath := filepath.Join(dir, entry.Name(), "meta.yaml")
		data, err := os.ReadFile(metaPath)
		if err != nil {
			// 跳過沒有 meta.yaml 的目錄（如 _common.sh 所在目錄）
			continue
		}

		var m ModuleMeta
		if err := yaml.Unmarshal(data, &m); err != nil {
			return nil, fmt.Errorf("解析 %s/meta.yaml 失敗: %w", entry.Name(), err)
		}
		modules[entry.Name()] = m
	}

	return modules, nil
}

// FilterProfilesByOS 根據當前 OS 過濾可用的 profiles
func FilterProfilesByOS(profiles []Profile) []Profile {
	currentOS := DetectOS()
	var filtered []Profile
	for _, p := range profiles {
		if p.OS == "all" || p.OS == currentOS {
			filtered = append(filtered, p)
		}
	}
	return filtered
}

// FilterModulesByOS 根據當前 OS 過濾可用的模組
func FilterModulesByOS(modules map[string]ModuleMeta) map[string]ModuleMeta {
	currentOS := DetectOS()
	filtered := make(map[string]ModuleMeta)
	for name, m := range modules {
		for _, os := range m.OS {
			if os == currentOS {
				filtered[name] = m
				break
			}
		}
	}
	return filtered
}

// ResolveDependencies 根據 depends_on 做拓撲排序，回傳執行順序
func ResolveDependencies(selectedModules []string, allModules map[string]ModuleMeta) ([]string, error) {
	// 建立鄰接表
	inDegree := make(map[string]int)
	dependents := make(map[string][]string)
	moduleSet := make(map[string]bool)

	for _, name := range selectedModules {
		moduleSet[name] = true
		inDegree[name] = 0
	}

	for _, name := range selectedModules {
		meta, ok := allModules[name]
		if !ok {
			continue
		}
		for _, dep := range meta.DependsOn {
			if moduleSet[dep] {
				inDegree[name]++
				dependents[dep] = append(dependents[dep], name)
			}
		}
	}

	// Kahn's algorithm
	var queue []string
	for _, name := range selectedModules {
		if inDegree[name] == 0 {
			queue = append(queue, name)
		}
	}
	sort.Strings(queue) // 穩定排序

	var result []string
	for len(queue) > 0 {
		node := queue[0]
		queue = queue[1:]
		result = append(result, node)

		for _, dep := range dependents[node] {
			inDegree[dep]--
			if inDegree[dep] == 0 {
				queue = append(queue, dep)
				sort.Strings(queue)
			}
		}
	}

	if len(result) != len(selectedModules) {
		return nil, fmt.Errorf("偵測到循環依賴")
	}

	return result, nil
}

// DetectOS 偵測當前作業系統，回傳 darwin / linux / windows
func DetectOS() string {
	return runtime.GOOS
}

// DetectArch 偵測當前架構，回傳 amd64 / arm64
func DetectArch() string {
	return runtime.GOARCH
}
