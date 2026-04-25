package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	defaultPort = "8016"
	defaultPath = "/collect-ui"
)

type App struct {
	ctx        context.Context
	serverCmd  *exec.Cmd
	startedByW bool
	targetURL  string
	bootOnce   sync.Once
	bootDone   chan struct{}
	bootErr    error
}

func NewApp() *App {
	return &App{
		bootDone: make(chan struct{}),
	}
}

func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
	a.targetURL = fmt.Sprintf("http://127.0.0.1:%s%s", a.detectPort(), defaultPath)

	go a.bootstrap()
}

func (a *App) shutdown(context.Context) {
	if !a.startedByW || a.serverCmd == nil || a.serverCmd.Process == nil {
		return
	}

	_ = a.serverCmd.Process.Kill()
	_, _ = a.serverCmd.Process.Wait()
}

func (a *App) WaitAndGetTargetURL() (string, error) {
	a.bootstrap()
	if a.bootErr != nil {
		return "", a.bootErr
	}
	return a.targetURL, nil
}

func (a *App) bootstrap() {
	a.bootOnce.Do(func() {
		defer close(a.bootDone)
		a.bootErr = a.ensureBackend()
		if a.bootErr != nil {
			fmt.Fprintf(os.Stderr, "desktop bootstrap failed: %v\n", a.bootErr)
		}
	})
	<-a.bootDone
}

func (a *App) ensureBackend() error {
	port := a.detectPort()
	if portListening(port) {
		return waitForPort(port, 10*time.Second)
	}

	exePath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("resolve executable path: %w", err)
	}

	baseDir := filepath.Dir(exePath)
	serverPath := filepath.Join(baseDir, "main.exe")
	if _, err := os.Stat(serverPath); err != nil {
		return fmt.Errorf("missing backend executable %s: %w", serverPath, err)
	}

	cmd := exec.Command(serverPath)
	cmd.Dir = baseDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	applySysProcAttr(cmd)

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("start backend: %w", err)
	}

	a.serverCmd = cmd
	a.startedByW = true

	if err := waitForPort(port, 20*time.Second); err != nil {
		return fmt.Errorf("wait for backend port %s: %w", port, err)
	}
	return nil
}

func (a *App) detectPort() string {
	exePath, err := os.Executable()
	if err != nil {
		return defaultPort
	}

	confPath := filepath.Join(filepath.Dir(exePath), "conf", "application.properties")
	data, err := os.ReadFile(confPath)
	if err != nil {
		return defaultPort
	}

	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		if !strings.HasPrefix(line, "server_port=") {
			continue
		}
		value := strings.TrimSpace(strings.TrimPrefix(line, "server_port="))
		if value == "" {
			return defaultPort
		}
		if _, err := strconv.Atoi(value); err != nil {
			return defaultPort
		}
		return value
	}
	return defaultPort
}

func portListening(port string) bool {
	conn, err := net.DialTimeout("tcp", "127.0.0.1:"+port, 500*time.Millisecond)
	if err != nil {
		return false
	}
	_ = conn.Close()
	return true
}

func waitForPort(port string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if portListening(port) {
			return nil
		}
		time.Sleep(300 * time.Millisecond)
	}
	return errors.New("timeout")
}
