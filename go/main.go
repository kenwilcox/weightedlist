package main

import (
	"bufio"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// readLines reads all lines from r, similar to File.ReadAllLines in C#.
// It preserves empty lines and strips trailing newlines. Uses a scanner with an increased buffer.
func readLines(r io.Reader) ([]string, error) {
	scanner := bufio.NewScanner(r)
	// Increase the buffer to handle very long lines (default is 64K).
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 1024*1024*32) // up to 32MB per line
	lines := make([]string, 0, 256)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}
	return lines, nil
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: %s <directory>\n", filepath.Base(os.Args[0]))
}

func validateDir(dir string) error {
	if dir == "" {
		return errors.New("directory is required")
	}
	info, err := os.Stat(dir)
	if err != nil {
		return err
	}
	if !info.IsDir() {
		return fmt.Errorf("%s is not a directory", dir)
	}
	return nil
}

func main() {
	flag.Usage = usage
	flag.Parse()
	if flag.NArg() != 1 {
		usage()
		os.Exit(1)
	}
	dir := flag.Arg(0)
	if err := validateDir(dir); err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error reading directory:", err)
		os.Exit(2)
	}

	// Maps for counts and distinct base filenames per line
	lineCount := make(map[string]int)
	lineToNames := make(map[string]map[string]struct{})

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if strings.HasSuffix(strings.ToLower(name), ".txt") {
			full := filepath.Join(dir, name)
			f, err := os.Open(full)
			if err != nil {
				fmt.Fprintln(os.Stderr, "Error opening file:", full, err)
				os.Exit(2)
			}
			lines, err := readLines(f)
			_ = f.Close()
			if err != nil {
				fmt.Fprintln(os.Stderr, "Error reading file:", full, err)
				os.Exit(2)
			}
			base := strings.TrimSuffix(name, filepath.Ext(name))
			for _, line := range lines {
				lineCount[line]++
				if _, ok := lineToNames[line]; !ok {
					lineToNames[line] = make(map[string]struct{})
				}
				lineToNames[line][base] = struct{}{}
			}
		}
	}

	// Collect keys and sort by count desc, tie-breaker by line asc.
	type item struct {
		line  string
		count int
	}
	items := make([]item, 0, len(lineCount))
	for line, c := range lineCount {
		items = append(items, item{line: line, count: c})
	}
	sort.Slice(items, func(i, j int) bool {
		if items[i].count != items[j].count {
			return items[i].count > items[j].count
		}
		return items[i].line < items[j].line
	})

	for _, it := range items {
		namesSet := lineToNames[it.line]
		names := make([]string, 0, len(namesSet))
		for n := range namesSet {
			names = append(names, n)
		}
		sort.Strings(names)
		fmt.Printf("%d - %s (%s)\n", it.count, it.line, strings.Join(names, ", "))
	}
}