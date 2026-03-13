# Dotfiles Installer 建置腳本

APP_NAME := dotfiles-installer
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS := -ldflags "-s -w -X main.version=$(VERSION)"
PLATFORMS := darwin/amd64 darwin/arm64 linux/amd64 linux/arm64 windows/amd64

.PHONY: build clean all

# 建置當前平台
build:
	go build $(LDFLAGS) -o bin/$(APP_NAME) ./cmd/

# 交叉編譯所有平台
all: clean
	@for platform in $(PLATFORMS); do \
		os=$${platform%/*}; arch=$${platform#*/}; \
		ext=""; [ "$$os" = "windows" ] && ext=".exe"; \
		echo "建置 $$os/$$arch..."; \
		GOOS=$$os GOARCH=$$arch go build $(LDFLAGS) \
			-o dist/$(APP_NAME)-$$os-$$arch$$ext ./cmd/; \
	done
	@echo "完成！輸出在 dist/ 目錄"

# 清除建置產物
clean:
	rm -rf bin/ dist/
