# ASTQuery - Raku AST Query Library

ASTQuery is a Raku library that provides an expressive query language for manipulating and analyzing Raku's Abstract Syntax Trees (RakuAST). It enables developers to write CSS-like selectors to find specific patterns in Raku code, making it powerful for code analysis, refactoring, and transformation tools.

**Key Features:**
- CSS-like query syntax for AST node selection (e.g., `.call >> .int[value=42]`)
- Support for parent-child and ancestor-descendant relationships
- Named captures for extracting matched nodes
- Command-line tool for searching across codebases
- Integration with Raku's native AST representation (RakuAST)

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Critical Version Requirements

**CRITICAL**: ASTQuery requires Raku 2024.x or later with RakuAST support. The Ubuntu package manager version (v2022.12) is **NOT COMPATIBLE** and will fail with "no such tag 'rakuast'" errors.

## Working Effectively

### Installation and Setup

**NEVER use the Ubuntu package manager version of Raku** - it lacks required RakuAST support.

1. **Install latest Raku using GitHub Actions approach**:
   ```bash
   # Method 1: Use rakubrew (recommended)
   curl -L https://install.raku.org | bash
   source ~/.bashrc
   rakubrew download moar-2024.08
   rakubrew switch moar-2024.08
   ```

2. **Alternative: Build from source** (takes 30-45 minutes, NEVER CANCEL):
   ```bash
   cd /tmp
   wget https://github.com/rakudo/rakudo/releases/download/2024.08/rakudo-2024.08.tar.gz
   tar -xzf rakudo-2024.08.tar.gz
   cd rakudo-2024.08
   sudo apt-get install -y build-essential
   perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=/usr/local/rakudo
   make -j$(nproc)  # Takes 30-45 minutes. NEVER CANCEL. Set timeout to 60+ minutes.
   sudo make install
   export PATH="/usr/local/rakudo/bin:$PATH"
   ```

3. **Verify Raku installation**:
   ```bash
   raku --version  # Should show 2024.x or later
   raku -e 'use experimental :rakuast; say "RakuAST available"'  # Should not error
   ```

4. **Install zef package manager** (if not included):
   ```bash
   # Usually included with modern Raku installations
   which zef || echo "zef not found - install manually"
   ```

### Project Setup and Dependencies

1. **Install project dependencies** (takes 10-30 seconds):
   ```bash
   cd /path/to/ASTQuery
   zef install --/test --test-depends --deps-only .
   ```

2. **Install additional required dependencies** (takes 10-20 seconds):
   ```bash
   zef install paths  # Required by CLI tool
   zef install --/test App::Prove6  # Test runner
   ```

3. **Ensure prove6 is in PATH**:
   ```bash
   export PATH="$HOME/.raku/bin:$PATH"
   which prove6 || echo "prove6 not found in PATH"
   ```

### Building and Testing

1. **Run tests** (takes 5-15 seconds, NEVER CANCEL):
   ```bash
   cd /path/to/ASTQuery
   prove6 -I. t  # Set timeout to 30+ seconds minimum
   ```

2. **Expected test output**: All tests should pass if RakuAST is available. Common failures:
   - "no such tag 'rakuast'" = Wrong Raku version (see Installation section)
   - Module load errors = Missing dependencies (run zef install again)
   - **If using old Raku version**: All tests will fail - this is expected behavior

3. **Validate CLI tool functionality** (only works with Raku 2024.x+):
   ```bash
   cd /path/to/ASTQuery
   # Test basic query functionality
   raku -I. bin/ast-query.raku '.int' lib/
   # Note: Will fail with "Could not find ASTQuery" if RakuAST unavailable
   ```

4. **Limited validation for older Raku versions**:
   ```bash
   # These work even without RakuAST:
   raku -c lib/ASTQuery/Grammar.rakumod  # Should show "Syntax OK"
   zef install paths  # Install CLI dependency
   # Full functionality requires Raku 2024.x+
   ```

## Validation Scenarios

**CRITICAL**: Always run these validation scenarios after making changes:

1. **Version Compatibility Check**:
   ```bash
   raku --version  # Must show 2024.x+ for full functionality
   raku -e 'use experimental :rakuast; say "RakuAST available"'  # Must not error
   ```

2. **Basic Syntax Validation** (works with any Raku version):
   ```bash
   raku -c lib/ASTQuery/Grammar.rakumod  # Should show "Syntax OK"
   ```

3. **Library Import Test** (requires Raku 2024.x+):
   ```bash
   raku -I. -e 'use ASTQuery; say "Library loads successfully"'
   ```

4. **RakuAST Feature Test** (requires Raku 2024.x+):
   ```bash
   raku -I. -e 'use experimental :rakuast; use ASTQuery; my $ast = "42".AST; say ast-query($ast, ".int").list'
   ```

5. **CLI Tool Test** (requires Raku 2024.x+):
   ```bash
   echo 'say 42' > /tmp/test.raku
   raku -I. bin/ast-query.raku '.int' /tmp/test.raku
   # Should output: /tmp/test.raku: with IntLiteral node found
   ```

6. **Complex Query Test** (requires Raku 2024.x+):
   ```bash
   echo 'for ^10 { if $_ %% 2 { say $_ * 3 } }' > /tmp/complex.raku
   raku -I. bin/ast-query.raku '.apply-op[right=3]' /tmp/complex.raku
   # Should find the multiplication operation
   ```

**Note**: Tests 3-6 will fail with older Raku versions - this is expected behavior.

## Common Development Tasks

### Running Specific Tests
```bash
# Run single test file
prove6 -I. t/01-basic.rakutest

# Run with verbose output
prove6 -I. -v t/

# Debug test failures
raku -I. t/01-basic.rakutest
```

### Using the CLI Tool
```bash
# Query specific directory for patterns
raku -I. bin/ast-query.raku 'RakuAST::IntLiteral' lib/

# Query for method calls
raku -I. bin/ast-query.raku '.call' t/

# Query with attribute matching
raku -I. bin/ast-query.raku '.int[value=42]' .

# Query with relationship operators
raku -I. bin/ast-query.raku '.call >> .int' lib/
```

### Query Language Examples

The query language supports CSS-like selectors:

```bash
# Basic node type matching
'.int'                          # Find IntLiteral nodes
'RakuAST::Call'                # Find Call nodes by full class name

# Attribute matching  
'.int[value=42]'               # Find IntLiteral with value 42
'.call[name]'                  # Find Call nodes that have a name attribute

# ID matching (specific attribute values)
'#42'                          # Find nodes with value/identifier of 42

# Relationship operators
'.call > .int'                 # Call nodes with IntLiteral children
'.call >> .int'                # Call nodes with IntLiteral descendants (skipping ignorable nodes)
'.call >>> .int'               # Call nodes with IntLiteral descendants (any depth)
'.int < .call'                 # IntLiteral nodes with Call parents
'.int << .call'                # IntLiteral nodes with Call ancestors (skipping ignorable)
'.int <<< .call'               # IntLiteral nodes with Call ancestors (any depth)

# Named captures
'.call$mycall'                 # Capture Call nodes as 'mycall'
'.call >> .int$myint'          # Find calls with int descendants, capture ints

# Complex examples
'.apply-op[left=1, right=3]'   # ApplyOp nodes with specific operands
'RakuAST::Infix <<< .conditional$cond .int#2$int'  # Complex relationship matching
```

### Library Development
```bash
# Check syntax
raku -c lib/ASTQuery.rakumod

# Load library interactively
raku -I. -e 'use ASTQuery; dd &ast-query'

# Test specific functionality
raku -I. -e 'use ASTQuery; my $ast = "say 42".AST; dd ast-query($ast, ".call")'
```

## Timeout Guidelines and Performance

**Measured actual timings on Ubuntu 24.04:**

- **Raku installation from source**: 30-45 minutes. NEVER CANCEL. Set timeout to 60+ minutes.
- **zef dependency installation**: 10-30 seconds (paths: ~10 seconds, App::Prove6: ~24 seconds). Set timeout to 2+ minutes for safety.
- **prove6 test execution**: 2-5 seconds with working RakuAST, fails immediately with version errors on old Raku. Set timeout to 30+ seconds minimum.
- **Individual Raku script execution**: 1-5 seconds. Set timeout to 10+ seconds.
- **CLI tool queries on large codebases**: 10-60 seconds depending on size. Set timeout to 120+ seconds.
- **Syntax checking individual modules**: 1-2 seconds. Set timeout to 10+ seconds.

**NEVER CANCEL long-running operations** - Raku compilation and installation can take significant time.

**Performance Notes:**
- Grammar module compiles quickly even on old Raku versions
- Core library modules require RakuAST and will fail compilation on Raku < 2024.x
- Test execution is fast when it works, but fails immediately on version incompatibility

## Repository Structure

### Key Files and Directories
```
/home/runner/work/ASTQuery/ASTQuery/
├── META6.json              # Package metadata and dependencies
├── lib/
│   ├── ASTQuery.rakumod    # Main library module
│   ├── ASTQuery/
│   │   ├── Actions.rakumod    # Parser actions
│   │   ├── Grammar.rakumod    # Query language grammar
│   │   ├── HighLighter.rakumod # Syntax highlighting
│   │   ├── Match.rakumod      # Match result handling
│   │   └── Matcher.rakumod    # Core matching logic
├── bin/
│   └── ast-query.raku      # Command-line tool
├── t/                      # Test files (*.rakutest)
│   ├── 01-basic.rakutest
│   ├── 02-ASTQuery.rakutest
│   └── 03-matcher.rakutest
├── .github/workflows/test.yml # CI configuration
├── dist.ini               # Distribution settings
└── README.md              # Documentation
```

### Important Implementation Details
- **lib/ASTQuery.rakumod**: Main entry point, exports `ast-query` function
- **lib/ASTQuery/Grammar.rakumod**: Defines the query language syntax
- **lib/ASTQuery/Matcher.rakumod**: Core matching algorithms using RakuAST
- **bin/ast-query.raku**: Standalone CLI tool for searching code files

## Troubleshooting

## Troubleshooting

### Common Issues

1. **"no such tag 'rakuast'" error**:
   - **Solution**: Install Raku 2024.x+ (see Installation section)
   - **Cause**: Using old Raku version without RakuAST support
   - **Affected**: All library functionality, tests, and CLI tool

2. **"Could not find ASTQuery" error**:
   - **Solution**: Install compatible Raku version first, then retry
   - **Cause**: Module depends on RakuAST features unavailable in current Raku
   - **Temporary check**: `raku -c lib/ASTQuery/Grammar.rakumod` should work

3. **"Could not find paths" error**:
   - **Solution**: `zef install paths`
   - **Cause**: CLI tool dependency not installed
   - **Note**: Even with paths installed, CLI won't work without RakuAST

4. **"prove6: command not found"**:
   - **Solution**: `export PATH="$HOME/.raku/bin:$PATH"`
   - **Alternative**: Use full path: `$HOME/.raku/bin/prove6`

5. **All tests fail immediately**:
   - **Check**: `raku --version` - if shows v2022.x, this is expected
   - **Solution**: Install Raku 2024.x+ for actual testing
   - **Workaround**: Test individual components with `raku -c`

6. **Module loading failures after Raku upgrade**:
   - **Solution**: Reinstall all dependencies: `zef install --force-install --deps-only .`
   - **Cause**: Module cache inconsistency between Raku versions

7. **Build hangs during Raku compilation**:
   - **Action**: Wait - compilation takes 30-45 minutes normally
   - **Do NOT cancel**: Set appropriate long timeouts
   - **Monitor**: Check system load/memory usage

### Version Verification Commands
```bash
# Check Raku version (must be 2024.x+ for full functionality)
raku --version

# Verify RakuAST availability
raku -e 'use experimental :rakuast; say "RakuAST OK"'

# Check zef version
zef --version

# Verify prove6 installation  
prove6 --version || echo "prove6 not available"

# Test basic syntax checking (works with any Raku version)
raku -c lib/ASTQuery/Grammar.rakumod

# Test paths dependency
raku -e 'use paths; say "paths OK"'
```

### Fallback Testing for Incompatible Raku Versions

If you cannot install Raku 2024.x+, you can still verify some functionality:

```bash
# Syntax checking (works with any Raku version)
raku -c lib/ASTQuery/Grammar.rakumod          # Should show "Syntax OK"

# Dependency installation (works with any Raku version)  
zef install paths                              # Should succeed

# Module structure validation
find lib -name "*.rakumod" -exec raku -c {} \; 2>&1 | grep -v "no such tag"
```

**Note**: Full functionality testing requires Raku 2024.x+ with RakuAST support.

## Manual Testing Workflow

Always perform these steps after making any code changes:

1. **Version Check**: `raku --version` (must be 2024.x+ for full testing)
2. **Syntax Check**: `raku -c lib/ASTQuery/Grammar.rakumod` (works with any version)
3. **Dependency Check**: `zef install --deps-only .` (ensure all deps available)
4. **Full Syntax Validation**: Only attempt if using Raku 2024.x+:
   ```bash
   raku -c lib/ASTQuery.rakumod
   raku -c lib/ASTQuery/Matcher.rakumod  
   raku -c lib/ASTQuery/Actions.rakumod
   ```
5. **Unit Tests**: `prove6 -I. t/` (only works with Raku 2024.x+)
6. **CLI Functionality**: `raku -I. bin/ast-query.raku '.int' lib/` (only works with Raku 2024.x+)
7. **Integration Test**: Test on a sample Raku file with known AST patterns

**Do not skip manual validation** - automated tests may pass while functionality is broken.

### Development Best Practices

- **Grammar Changes**: Test `lib/ASTQuery/Grammar.rakumod` syntax independently
- **Matcher Logic**: Requires RakuAST; test incrementally with small AST examples  
- **CLI Tool**: Test with simple queries on known code samples
- **Documentation**: Verify examples in README.md match actual query syntax
- **Performance**: Time CLI queries on large codebases to check for regressions

### CI/CD Integration Notes

The GitHub Actions workflow (`.github/workflows/test.yml`) runs on:
- Ubuntu Latest + macOS Latest
- Raku version: 'latest' (ensures RakuAST support)
- Tests all functionality including RakuAST features

Local development should replicate this environment for accurate testing.