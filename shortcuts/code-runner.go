package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

type Result struct {
	Success  bool        `json:"success"`
	Output   string      `json:"output"`
	Error    string      `json:"error,omitempty"`
	ExitCode int         `json:"exitCode,omitempty"`
	Runtime  string      `json:"runtime"`
	Type     string      `json:"type"`
	TruncAt  int         `json:"truncAt,omitempty"`
}

const MaxOutputBytes = 8000 // iMessage friendly size

func main() {
	codeType := flag.String("type", "python", "Code type: python, node, c, sql, bash")
	inputFile := flag.String("file", "", "Input file (default: stdin)")
	format := flag.String("format", "text", "Output format: text, json")
	flag.Parse()

	code, err := readInput(*inputFile)
	if err != nil {
		fatal(*codeType, "Failed to read input", err, *format)
	}

	start := time.Now()
	result := execute(*codeType, code)
	result.Runtime = time.Since(start).String()
	result.Type = *codeType

	output(result, *format)
}

func readInput(filename string) (string, error) {
	if filename != "" {
		data, err := os.ReadFile(filename)
		return string(data), err
	}
	var buf bytes.Buffer
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		buf.WriteString(scanner.Text())
		buf.WriteString("\n")
	}
	return buf.String(), scanner.Err()
}

func execute(codeType, code string) Result {
	code = strings.TrimSpace(code)
	if code == "" {
		return Result{Success: false, Error: "Empty code"}
	}

	switch codeType {
	case "python", "py":
		return executePython(code)
	case "node", "js":
		return executeNode(code)
	case "c":
		return executeC(code)
	case "sql":
		return executeSQL(code)
	case "bash", "sh":
		return executeBash(code)
	default:
		return Result{Success: false, Error: fmt.Sprintf("Unknown type: %s", codeType)}
	}
}

func executePython(code string) Result {
	cmd := exec.Command("python3", "-u", "-c", code)
	return runCmd(cmd, "python")
}

func executeNode(code string) Result {
	cmd := exec.Command("node", "-e", code)
	return runCmd(cmd, "node")
}

func executeC(code string) Result {
	tmpDir := os.TempDir()
	srcFile := filepath.Join(tmpDir, fmt.Sprintf("code_%d.c", time.Now().UnixNano()))
	outFile := filepath.Join(tmpDir, fmt.Sprintf("code_%d", time.Now().UnixNano()))
	defer os.Remove(srcFile)
	defer os.Remove(outFile)

	if err := os.WriteFile(srcFile, []byte(code), 0644); err != nil {
		return Result{Success: false, Error: fmt.Sprintf("Failed to write temp file: %v", err)}
	}

	// Compile
	cc := exec.Command("gcc", "-o", outFile, srcFile)
	var stderr bytes.Buffer
	cc.Stderr = &stderr
	if err := cc.Run(); err != nil {
		return Result{Success: false, Error: fmt.Sprintf("Compilation failed: %s", stderr.String())}
	}

	// Run
	cmd := exec.Command(outFile)
	return runCmd(cmd, "c")
}

func executeSQL(query string) Result {
	dbFile := filepath.Join(os.TempDir(), "runner.db")
	cmd := exec.Command("sqlite3", dbFile, query)
	return runCmd(cmd, "sql")
}

func executeBash(script string) Result {
	cmd := exec.Command("bash", "-c", script)
	return runCmd(cmd, "bash")
}

func runCmd(cmd *exec.Cmd, cmdType string) Result {
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()
	output := strings.TrimSpace(stdout.String())
	errMsg := strings.TrimSpace(stderr.String())

	if err != nil {
		if errMsg == "" {
			errMsg = err.Error()
		}
		return Result{
			Success:  false,
			Output:   output,
			Error:    errMsg,
			ExitCode: getExitCode(err),
		}
	}

	// Truncate if needed
	truncAt := 0
	if len(output) > MaxOutputBytes {
		output = output[:MaxOutputBytes]
		truncAt = len(output)
	}

	return Result{
		Success: true,
		Output:  output,
		TruncAt: truncAt,
	}
}

func getExitCode(err error) int {
	if exiterr, ok := err.(*exec.ExitError); ok {
		return exiterr.ExitCode()
	}
	return -1
}

func output(r Result, format string) {
	if format == "json" {
		data, _ := json.MarshalIndent(r, "", "  ")
		fmt.Println(string(data))
		return
	}

	// Text format (friendly)
	if r.Success {
		fmt.Println(r.Output)
		if r.TruncAt > 0 {
			fmt.Printf("\n[Output truncated at %d bytes]\n", r.TruncAt)
		}
	} else {
		fmt.Fprintf(os.Stderr, "Error (%s): %s\n", r.Type, r.Error)
		if r.Output != "" {
			fmt.Fprintf(os.Stderr, "Output: %s\n", r.Output)
		}
		os.Exit(1)
	}
}

func fatal(codeType, msg string, err error, format string) {
	r := Result{
		Success: false,
		Error:   fmt.Sprintf("%s: %v", msg, err),
		Type:    codeType,
	}
	output(r, format)
	os.Exit(1)
}
