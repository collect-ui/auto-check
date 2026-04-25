//go:build !windows

package main

import "os/exec"

func applySysProcAttr(cmd *exec.Cmd) {
}
