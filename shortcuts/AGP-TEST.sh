#!/bin/bash

# Auto Git Push Test Suite
# Tests the auto-git-push system on a sample repository

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[TEST]${NC} $*"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $*"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Create a test repository
setup_test_repo() {
    log "Setting up test repository..."
    
    local test_dir="/tmp/agp-test-$(date +%s)"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Initialize git
    git init -q
    git config user.email "agp-test@localhost"
    git config user.name "AGP Test"
    
    # Create initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    
    pass "Test repo created at: $test_dir"
    echo "$test_dir" # Return path
}

test_source_code_detection() {
    log "Testing source code detection..."
    
    # Add source code changes
    cat >> test.py << 'EOF'


def hello_world():
    """A test function."""
    print("Hello, World!")
    print("Line 2")
    print("Line 3")
    print("Line 4")
    print("Line 5")
    print("Line 6")
    print("Line 7")
    print("Line 8")
    print("Line 9")
    print("Line 10")
    print("Line 11")
    
    return True
EOF
    
    # Run auto-git-push once
    /Users/joshua/.openclaw/workspace/shortcuts/auto-git-push once . 2>&1 | grep -qE "(✨|🔧|refactor|feat)" && \
        pass "Source code detection working" || \
        fail "Source code detection failed"
    
    # Verify commit message
    local msg=$(git log --oneline -1 | cut -d' ' -f2-)
    echo "  Commit: $msg"
}

test_test_file_detection() {
    log "Testing test file detection..."
    
    # Add test file
    cat >> test_spec.py << 'EOF'


def test_hello_world():
    """Test the hello_world function."""
    result = hello_world()
    assert result == True
    print("Test 1")
    print("Test 2")
    print("Test 3")
    print("Test 4")
    print("Test 5")
    print("Test 6")
    print("Test 7")
    print("Test 8")
    print("Test 9")
    print("Test 10")
EOF
    
    # Run auto-git-push once
    /Users/joshua/.openclaw/workspace/shortcuts/auto-git-push once . 2>&1 | grep -qE "(✅|test|spec)" && \
        pass "Test file detection working" || \
        fail "Test file detection failed"
    
    local msg=$(git log --oneline -1 | cut -d' ' -f2-)
    echo "  Commit: $msg"
}

test_documentation_detection() {
    log "Testing documentation detection..."
    
    # Add documentation
    cat >> DOCUMENTATION.md << 'EOF'


# Documentation

This is test documentation.

## Features

1. Feature one
2. Feature two
3. Feature three
4. Feature four
5. Feature five
6. Feature six
7. Feature seven
8. Feature eight
9. Feature nine
10. Feature ten
11. Feature eleven
EOF
    
    # Run auto-git-push once
    /Users/joshua/.openclaw/workspace/shortcuts/auto-git-push once . 2>&1 | grep -qE "(📝|docs|documentation)" && \
        pass "Documentation detection working" || \
        fail "Documentation detection failed"
    
    local msg=$(git log --oneline -1 | cut -d' ' -f2-)
    echo "  Commit: $msg"
}

test_log_file_creation() {
    log "Testing log file creation..."
    
    if [ -f ".agp.log" ]; then
        pass "Log file created"
        echo "  Log file size: $(wc -l < .agp.log) lines"
        echo "  ---"
        tail -3 .agp.log
        echo "  ---"
    else
        fail "Log file not created"
    fi
}

test_commit_history() {
    log "Testing commit history..."
    
    local count=$(git log --oneline | wc -l)
    
    if [ "$count" -ge 3 ]; then
        pass "Commits created successfully ($count total)"
        echo "  Recent commits:"
        git log --oneline -3 | sed 's/^/    /'
    else
        fail "Not enough commits created"
    fi
}

# Main test
main() {
    echo ""
    echo -e "${BLUE}=== Auto Git Push Test Suite ===${NC}"
    echo ""
    
    # Create test repo
    local test_repo=$(/bin/bash -c 'mkdir -p "/tmp/agp-test-$(date +%s)" && echo "/tmp/agp-test-$(date +%s)"' 2>/dev/null | tail -1)
    if [ -z "$test_repo" ]; then
        test_repo="/tmp/agp-test-$$"
        mkdir -p "$test_repo"
    fi
    
    cd "$test_repo"
    
    # Initialize git
    git init -q
    git config user.email "agp-test@localhost"
    git config user.name "AGP Test"
    echo "# Test Project" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    
    pass "Test repo created at: $test_repo"
    echo ""
    
    echo ""
    
    # Run tests
    test_source_code_detection
    echo ""
    
    test_test_file_detection
    echo ""
    
    test_documentation_detection
    echo ""
    
    test_log_file_creation
    echo ""
    
    test_commit_history
    echo ""
    
    # Cleanup
    log "Cleaning up..."
    cd /
    rm -rf "$test_repo"
    
    echo ""
    echo -e "${GREEN}=== All Tests Passed ===${NC}"
    echo ""
}

main
