package main

import (
	text_template "text/template"
	"testing"

	collect "github.com/collect-ui/collect/src/collect/utils"
)

func TestDetectEscapeNestedTemplateReferences(t *testing.T) {
	params := map[string]interface{}{
		"pending_issue_list": []interface{}{},
		"detect_result": map[string]interface{}{
			"result":         "模型输出内容",
			"system_prompt":  "系统提示词内容",
			"prompt_content": "普通提示词内容",
			"is_escape":      "1",
		},
	}

	oldTpl := text_template.Must(text_template.New("old").Parse("{{if gt (len .pending_issue_list) 0}}skip{{else}}[detect_result.result]{{end}}"))
	oldValue := collect.RenderTplData(oldTpl, params)
	if oldValue != "[detect_result.result]" {
		t.Fatalf("expected old template to keep literal placeholder, got %v", oldValue)
	}

	resultTpl := text_template.Must(text_template.New("result").Parse("{{if gt (len .pending_issue_list) 0}}skip{{else}}{{.detect_result.result}}{{end}}"))
	resultValue := collect.RenderTplData(resultTpl, params)
	if resultValue != "模型输出内容" {
		t.Fatalf("expected result template to resolve nested field, got %v", resultValue)
	}

	systemTpl := text_template.Must(text_template.New("system").Parse("{{if gt (len .pending_issue_list) 0}}skip{{else}}{{.detect_result.system_prompt}}{{end}}"))
	systemValue := collect.RenderTplData(systemTpl, params)
	if systemValue != "系统提示词内容" {
		t.Fatalf("expected system template to resolve nested field, got %v", systemValue)
	}

	promptTpl := text_template.Must(text_template.New("prompt").Parse("{{if gt (len .pending_issue_list) 0}}skip{{else}}{{.detect_result.prompt_content}}{{end}}"))
	promptValue := collect.RenderTplData(promptTpl, params)
	if promptValue != "普通提示词内容" {
		t.Fatalf("expected prompt template to resolve nested field, got %v", promptValue)
	}
}

