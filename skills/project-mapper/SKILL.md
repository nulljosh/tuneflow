---
name: project-mapper
description: Auto-generate and update SVG mind maps for code projects
---

# Project Mapper

Automatically creates and updates `map.svg` architecture diagrams for code projects.

## Usage

When creating a new project, run:
```bash
project-mapper <project-dir>
```

Updates existing map when project structure changes.

## What It Does

1. Scans project structure (files, folders, dependencies)
2. Identifies project type (React, C, Jekyll, etc.)
3. Generates SVG mind map showing:
   - Core components
   - Data flow
   - Build pipeline
   - Deployment target

## Examples

**React project:**
- Components → State → API → Deploy

**C compiler:**
- Lexer → Parser → AST → Codegen → Binary

**Jekyll blog:**
- Posts → Jekyll → GitHub Pages → Live URL

## Auto-Update Trigger

Add to `.git/hooks/post-commit`:
```bash
#!/bin/bash
project-mapper .
git add map.svg
git commit --amend --no-edit
```

Map updates automatically on every commit.

## Templates

Located in `skills/project-mapper/templates/`:
- `react.svg`
- `node.svg`
- `c-project.svg`
- `jekyll.svg`
- `generic.svg`
