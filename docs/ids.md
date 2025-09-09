# RakuAST ID Mappings Documentation

This document provides comprehensive documentation for all ID attribute mappings available in ASTQuery. ID mappings allow you to query for AST nodes based on their attribute values using the `#value` syntax.

## ID Mapping Overview

ID mappings connect RakuAST node types to their most relevant attribute for identification purposes. There are 69 ID mappings covering 17 different attribute types, organized by usage patterns.

## Attribute Types

### `value` - Literal Values
For all literal types, `#value` accesses the literal value itself.

- `RakuAST::Literal` → `value` - Base literal value
- `RakuAST::IntLiteral` → `value` - Integer value (e.g., `#42`)
- `RakuAST::NumLiteral` → `value` - Numeric value (e.g., `#3.14`)
- `RakuAST::StrLiteral` → `value` - String value (e.g., `#"hello"`)
- `RakuAST::RatLiteral` → `value` - Rational value (e.g., `#1/3`)
- `RakuAST::ComplexLiteral` → `value` - Complex value (e.g., `#1+2i`)
- `RakuAST::VersionLiteral` → `value` - Version value (e.g., `#v1.0.0`)

### `name` - Named Constructs
For declarations and named entities, `#name` accesses the name attribute.

- `RakuAST::Call` → `name` - Call name
- `RakuAST::Method` → `name` - Method name (e.g., `#process`)
- `RakuAST::Sub` → `name` - Subroutine name
- `RakuAST::Submethod` → `name` - Submethod name
- `RakuAST::Routine` → `name` - Routine name
- `RakuAST::Class` → `name` - Class name (e.g., `#MyClass`)
- `RakuAST::Role` → `name` - Role name
- `RakuAST::Module` → `name` - Module name
- `RakuAST::Grammar` → `name` - Grammar name
- `RakuAST::Package` → `name` - Package name
- `RakuAST::VarDeclaration` → `name` - Variable declaration name
- `RakuAST::Var` → `name` - Variable name
- `RakuAST::Var::Attribute` → `name` - Attribute name
- `RakuAST::RegexDeclaration` → `name` - Regex name
- `RakuAST::RuleDeclaration` → `name` - Rule name
- `RakuAST::TokenDeclaration` → `name` - Token name
- `RakuAST::Label` → `name` - Label name
- `RakuAST::NamedArg` → `name` - Named argument name
- `RakuAST::Regex::NamedCapture` → `name` - Named capture name

### `desigilname` - Variable Names Without Sigils
For lexical variables, `#desigilname` accesses the variable name without the sigil.

- `RakuAST::Var::Lexical` → `desigilname` - Lexical variable name (e.g., `#foo` for `$foo`)
- `RakuAST::Var::Package` → `desigilname` - Package variable name
- `RakuAST::Var::Dynamic` → `desigilname` - Dynamic variable name

### `condition` - Conditional Expressions
For conditional constructs, `#condition` accesses the condition being tested.

- `RakuAST::Statement::IfWith` → `condition` - If-with condition
- `RakuAST::Statement::Unless` → `condition` - Unless condition
- `RakuAST::Statement::If` → `condition` - If condition
- `RakuAST::Statement::When` → `condition` - When condition
- `RakuAST::Statement::With` → `condition` - With condition
- `RakuAST::Statement::Without` → `condition` - Without condition
- `RakuAST::Statement::Loop` → `condition` - Loop condition
- `RakuAST::Statement::Loop::While` → `condition` - While loop condition
- `RakuAST::Statement::Loop::Until` → `condition` - Until loop condition
- `RakuAST::Statement::Loop::RepeatWhile` → `condition` - Repeat-while condition
- `RakuAST::Statement::Loop::RepeatUntil` → `condition` - Repeat-until condition
- `RakuAST::Ternary` → `condition` - Ternary condition

### `operator` - Operator Names
For operator types, `#operator` accesses the operator name or symbol.

- `RakuAST::Infix` → `operator` - Infix operator (e.g., `#+`, `#*`)
- `RakuAST::Prefix` → `operator` - Prefix operator (e.g., `#!`, `#-`)
- `RakuAST::Postfix` → `operator` - Postfix operator (e.g., `#++`, `#--`)

### `infix` - Applied Infix Operators
For infix applications, `#infix` accesses the infix operator being applied.

- `RakuAST::ApplyInfix` → `infix` - Applied infix operator
- `RakuAST::ApplyListInfix` → `infix` - Applied list infix operator
- `RakuAST::ApplyDottyInfix` → `infix` - Applied dotty infix operator
- `RakuAST::Infixish` → `infix` - Infix-like operator

### `prefix` - Applied Prefix Operators
For prefix applications, `#prefix` accesses the prefix operator being applied.

- `RakuAST::ApplyPrefix` → `prefix` - Applied prefix operator

### `postfix` - Applied Postfix Operators
For postfix applications, `#postfix` accesses the postfix operator being applied.

- `RakuAST::ApplyPostfix` → `postfix` - Applied postfix operator

### `function` - Function Names
For function-style operations, `#function` accesses the function name.

- `RakuAST::FunctionInfix` → `function` - Function infix name

### `simple-identifier` - Simple Name Identifiers
For name constructs, `#simple-identifier` accesses the simple identifier.

- `RakuAST::Name` → `simple-identifier` - Simple name identifier
- `RakuAST::Term::Name` → `name` - Term name

### `expression` - Expression Content
For expression containers, `#expression` accesses the contained expression.

- `RakuAST::Statement::Expression` → `expression` - Statement expression

### `topic` - Topic Expressions
For topic-setting constructs, `#topic` accesses the topic expression.

- `RakuAST::Statement::Given` → `topic` - Given topic

### `source` - Source Expressions
For iteration constructs, `#source` accesses the source being iterated.

- `RakuAST::Statement::For` → `source` - For loop source

### `args` - Argument Lists
For argument containers, `#args` accesses the argument list.

- `RakuAST::ArgList` → `args` - Argument list

### `target` - Parameter Targets
For parameter constructs, `#target` accesses the parameter target.

- `RakuAST::Parameter` → `target` - Parameter target

### `type` - Type Information
For trait constructs, `#type` accesses the type information.

- `RakuAST::Trait` → `type` - Trait type
- `RakuAST::Trait::Does` → `type` - Does trait type
- `RakuAST::Trait::Is` → `type` - Is trait type
- `RakuAST::Trait::Of` → `type` - Of trait type
- `RakuAST::Trait::Returns` → `type` - Returns trait type

### `key` - Key Values
For pair constructs, `#key` accesses the key value.

- `RakuAST::ColonPair` → `key` - Colon pair key
- `RakuAST::ColonPair::Value` → `key` - Value colon pair key
- `RakuAST::ColonPair::Variable` → `key` - Variable colon pair key
- `RakuAST::FatArrow` → `key` - Fat arrow key

### `text` - Text Content
For text-containing constructs, `#text` accesses the text content.

- `RakuAST::Regex::Literal` → `text` - Regex literal text

### `literal` - Literal Content
For literal constructs, `#literal` accesses the literal content.

- `RakuAST::QuotedString` → `literal` - Quoted string literal

## Usage Examples

### Literal Values
```raku
# Find integer literal with value 42
$ast.&ast-query('.int#42')
$ast.&ast-query('RakuAST::IntLiteral#42')

# Find string literal with value "hello"  
$ast.&ast-query('.str#"hello"')

# Find any literal with value 3.14
$ast.&ast-query('.literal#3.14')
```

### Named Constructs
```raku
# Find method named "process"
$ast.&ast-query('.method#process')
$ast.&ast-query('RakuAST::Method#process')

# Find class named "MyClass"
$ast.&ast-query('.declaration#MyClass')

# Find calls to "say"
$ast.&ast-query('.call#say')
```

### Variables
```raku
# Find lexical variable "$count" (using desigilname)
$ast.&ast-query('RakuAST::Var::Lexical#count')

# Find any variable named "data"
$ast.&ast-query('.var#data')
```

### Operators
```raku
# Find addition operators
$ast.&ast-query('RakuAST::Infix#+')

# Find applied infix operations with "+"
$ast.&ast-query('RakuAST::ApplyInfix#+')

# Find prefix applications with "!"
$ast.&ast-query('RakuAST::ApplyPrefix#!')
```

### Conditionals
```raku
# Find if conditions that reference variables
$ast.&ast-query('.conditional#condition >>> .var')

# Find specific condition expressions
$ast.&ast-query('RakuAST::Statement::If#condition')
```

### Advanced Usage
```raku
# Find methods named "new" that have parameters
$ast.&ast-query('.method#new >>> .parameter')

# Find integer literals with value 0 in conditional contexts
$ast.&ast-query('.conditional >>> .int#0')

# Find variables named "self" in method contexts
$ast.&ast-query('.method >>> .var#self')

# Find string literals in call arguments
$ast.&ast-query('.call >>> .args >>> .str')

# Find specific operator applications
$ast.&ast-query('.apply-op#+ >>> .int#1')
```

## ID Mapping Validation

All ID mappings are validated to ensure:

1. **Type Existence**: Every mapped type exists in the group definitions
2. **Attribute Validity**: Each attribute exists on the corresponding RakuAST type
3. **Consistency**: No conflicting or orphaned mappings
4. **Completeness**: Common use cases are covered

## Adding Custom ID Mappings

You can add custom ID mappings using the `set-ast-id` method:

```raku
# Add custom ID mapping
ASTQuery::Matcher.set-ast-id("RakuAST::CustomType", "custom-attribute");

# Use the custom mapping
$ast.&ast-query('RakuAST::CustomType#value')
```

## Performance Notes

- ID queries are optimized for direct attribute access
- Using specific type names is faster than group queries
- Combining ID queries with descendant selectors is efficient
- ID mappings avoid reflection overhead during query execution