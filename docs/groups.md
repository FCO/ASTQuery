# RakuAST Groups Documentation

This document provides comprehensive documentation for all RakuAST type groups available in ASTQuery. Groups are semantic collections of related RakuAST node types that can be queried using the `.group` syntax.

## Main Groups

### `expression` (13 types)
Expression-related operators and constructs for building complex expressions.

- `RakuAST::ApplyDottyInfix` - Dotty infix application (method calls with operators)
- `RakuAST::ApplyInfix` - Standard infix operator application 
- `RakuAST::ApplyListInfix` - List infix operator application
- `RakuAST::ApplyPostfix` - Postfix operator application
- `RakuAST::ApplyPrefix` - Prefix operator application
- `RakuAST::BracketedInfix` - Bracketed infix operators
- `RakuAST::DottyInfixish` - Base for dotty infix operators
- `RakuAST::FunctionInfix` - Function-style infix operators
- `RakuAST::Infix` - Infix operators
- `RakuAST::Infixish` - Base for infix-like operators
- `RakuAST::MetaInfix` - Meta infix operators (hyper, cross, etc.)
- `RakuAST::Prefixish` - Base for prefix-like operators
- `RakuAST::Postfixish` - Base for postfix-like operators

### `literal` (8 types)
All literal value types representing constant data.

- `RakuAST::ComplexLiteral` - Complex number literals
- `RakuAST::IntLiteral` - Integer literals
- `RakuAST::NumLiteral` - Numeric literals (floating point)
- `RakuAST::StrLiteral` - String literals
- `RakuAST::RatLiteral` - Rational number literals
- `RakuAST::VersionLiteral` - Version literals
- `RakuAST::Constant` - Named constants
- `RakuAST::Literal` - Base literal type

### `statement` (46 types)
All statement types and statement modifiers for control flow and structure.

- `RakuAST::Block` - Code blocks
- `RakuAST::BlockStatementSensitive` - Context-sensitive blocks
- `RakuAST::BlockThunk` - Block thunks
- `RakuAST::Blockoid` - Block-like constructs
- `RakuAST::Statement` - Base statement type
- `RakuAST::StatementList` - Lists of statements
- `RakuAST::StatementSequence` - Sequential statements
- `RakuAST::StatementModifier` - Statement modifiers base
- `RakuAST::StatementPrefix` - Statement prefixes base
- `RakuAST::Statement::Catch` - Catch statements
- `RakuAST::Statement::Control` - Control statements
- `RakuAST::Statement::Default` - Default statements
- `RakuAST::Statement::Empty` - Empty statements
- `RakuAST::Statement::ExceptionHandler` - Exception handlers
- `RakuAST::Statement::Expression` - Expression statements
- `RakuAST::Statement::For` - For loop statements
- `RakuAST::Statement::Given` - Given statements
- `RakuAST::Statement::If` - If statements
- `RakuAST::Statement::IfWith` - If-with statements
- `RakuAST::Statement::Import` - Import statements
- `RakuAST::Statement::Loop` - Loop statements
- `RakuAST::Statement::Need` - Need statements
- `RakuAST::Statement::Require` - Require statements
- `RakuAST::Statement::Unless` - Unless statements
- `RakuAST::Statement::Use` - Use statements
- `RakuAST::Statement::When` - When statements
- `RakuAST::Statement::Whenever` - Whenever statements
- `RakuAST::Statement::With` - With statements
- `RakuAST::Statement::Without` - Without statements
- `RakuAST::StatementModifier::Condition` - Conditional modifiers
- `RakuAST::StatementModifier::For` - For modifiers
- `RakuAST::StatementModifier::Given` - Given modifiers
- `RakuAST::StatementModifier::If` - If modifiers
- `RakuAST::StatementModifier::Loop` - Loop modifiers
- `RakuAST::StatementModifier::Unless` - Unless modifiers
- `RakuAST::StatementModifier::Until` - Until modifiers
- `RakuAST::StatementModifier::When` - When modifiers
- `RakuAST::StatementModifier::While` - While modifiers
- `RakuAST::StatementModifier::With` - With modifiers
- `RakuAST::StatementModifier::Without` - Without modifiers
- `RakuAST::Statement::Loop::RepeatUntil` - Repeat-until loops
- `RakuAST::Statement::Loop::RepeatWhile` - Repeat-while loops
- `RakuAST::Statement::Loop::Until` - Until loops
- `RakuAST::Statement::Loop::While` - While loops
- `RakuAST::StatementModifier::Condition::Thunk` - Conditional thunks
- `RakuAST::StatementModifier::For::Thunk` - For thunks

### `declaration` (23 types)
All declaration types for variables, packages, and program structure.

- `RakuAST::Declaration` - Base declaration type
- `RakuAST::Declaration::External` - External declarations
- `RakuAST::Declaration::External::Constant` - External constants
- `RakuAST::Declaration::External::Setting` - External settings
- `RakuAST::Declaration::Import` - Import declarations
- `RakuAST::Declaration::LexicalPackage` - Lexical packages
- `RakuAST::Declaration::ResolvedConstant` - Resolved constants
- `RakuAST::Var` - Variable declarations
- `RakuAST::NamedArg` - Named arguments
- `RakuAST::Parameter` - Parameters
- `RakuAST::Signature` - Signatures
- `RakuAST::Class` - Class declarations
- `RakuAST::Role` - Role declarations
- `RakuAST::RoleBody` - Role bodies
- `RakuAST::Module` - Module declarations
- `RakuAST::Grammar` - Grammar declarations
- `RakuAST::Package` - Package declarations
- `RakuAST::Package::Attachable` - Attachable packages
- `RakuAST::Knowhow` - Knowhow declarations
- `RakuAST::Native` - Native type declarations
- `RakuAST::RegexDeclaration` - Regex declarations
- `RakuAST::RuleDeclaration` - Rule declarations
- `RakuAST::TokenDeclaration` - Token declarations

### `control` (6 types)
Control flow constructs for conditional logic and loops.

- `RakuAST::ForLoopImplementation` - For loop implementation
- `RakuAST::FlipFlop` - Flip-flop operators
- `RakuAST::Statement::IfWith` - If-with statements
- `RakuAST::Statement::Unless` - Unless statements
- `RakuAST::Statement::With` - With statements
- `RakuAST::Statement::When` - When statements

### `phaser` (22 types)
All phaser blocks and time-based execution constructs.

- `RakuAST::StatementPrefix::Phaser` - Base phaser type
- `RakuAST::StatementPrefix::Phaser::Begin` - BEGIN phasers
- `RakuAST::StatementPrefix::Phaser::Block` - Phaser blocks
- `RakuAST::StatementPrefix::Phaser::Check` - CHECK phasers
- `RakuAST::StatementPrefix::Phaser::Close` - CLOSE phasers
- `RakuAST::StatementPrefix::Phaser::End` - END phasers
- `RakuAST::StatementPrefix::Phaser::Enter` - ENTER phasers
- `RakuAST::StatementPrefix::Phaser::First` - FIRST phasers
- `RakuAST::StatementPrefix::Phaser::Init` - INIT phasers
- `RakuAST::StatementPrefix::Phaser::Keep` - KEEP phasers
- `RakuAST::StatementPrefix::Phaser::Last` - LAST phasers
- `RakuAST::StatementPrefix::Phaser::Leave` - LEAVE phasers
- `RakuAST::StatementPrefix::Phaser::Next` - NEXT phasers
- `RakuAST::StatementPrefix::Phaser::Post` - POST phasers
- `RakuAST::StatementPrefix::Phaser::Pre` - PRE phasers
- `RakuAST::StatementPrefix::Phaser::Quit` - QUIT phasers
- `RakuAST::StatementPrefix::Phaser::Sinky` - Sinky phasers
- `RakuAST::StatementPrefix::Phaser::Temp` - TEMP phasers
- `RakuAST::StatementPrefix::Phaser::Undo` - UNDO phasers
- `RakuAST::BeginTime` - Begin time constructs
- `RakuAST::CheckTime` - Check time constructs
- `RakuAST::ParseTime` - Parse time constructs

### `regex` (92 types)
Complete regex infrastructure including patterns, assertions, and quantifiers.

- `RakuAST::Regex` - Base regex type
- `RakuAST::RegexDeclaration` - Regex declarations
- `RakuAST::RegexThunk` - Regex thunks
- `RakuAST::QuotedRegex` - Quoted regexes
- `RakuAST::QuotedMatchConstruct` - Quoted match constructs
- `RakuAST::QuotedString` - Quoted strings
- `RakuAST::Substitution` - Substitution operations
- `RakuAST::SubstitutionReplacementThunk` - Substitution replacements
- `RakuAST::Regex::Alternation` - Regex alternations
- `RakuAST::Regex::Anchor` - Regex anchors
- `RakuAST::Regex::Anchor::BeginningOfLine` - Beginning of line anchors
- `RakuAST::Regex::Anchor::BeginningOfString` - Beginning of string anchors
- `RakuAST::Regex::Anchor::EndOfLine` - End of line anchors
- `RakuAST::Regex::Anchor::EndOfString` - End of string anchors
- `RakuAST::Regex::Anchor::LeftWordBoundary` - Left word boundary anchors
- `RakuAST::Regex::Anchor::RightWordBoundary` - Right word boundary anchors
- `RakuAST::Regex::Assertion` - Regex assertions
- `RakuAST::Regex::Assertion::Alias` - Assertion aliases
- `RakuAST::Regex::Assertion::Callable` - Callable assertions
- `RakuAST::Regex::Assertion::CharClass` - Character class assertions
- `RakuAST::Regex::Assertion::Fail` - Fail assertions
- `RakuAST::Regex::Assertion::InterpolatedBlock` - Interpolated block assertions
- `RakuAST::Regex::Assertion::InterpolatedVar` - Interpolated variable assertions
- `RakuAST::Regex::Assertion::Lookahead` - Lookahead assertions
- `RakuAST::Regex::Assertion::Named` - Named assertions
- `RakuAST::Regex::Assertion::Named::Args` - Named assertion arguments
- `RakuAST::Regex::Assertion::Named::RegexArg` - Named regex arguments
- `RakuAST::Regex::Assertion::Pass` - Pass assertions
- `RakuAST::Regex::Assertion::PredicateBlock` - Predicate block assertions
- `RakuAST::Regex::Assertion::Recurse` - Recursive assertions
- `RakuAST::Regex::Atom` - Regex atoms
- `RakuAST::Regex::BackReference` - Back references
- `RakuAST::Regex::BackReference::Named` - Named back references
- `RakuAST::Regex::BackReference::Positional` - Positional back references
- `RakuAST::Regex::Backtrack` - Backtracking control
- `RakuAST::Regex::Backtrack::Frugal` - Frugal backtracking
- `RakuAST::Regex::Backtrack::Greedy` - Greedy backtracking
- `RakuAST::Regex::Backtrack::Ratchet` - Ratcheting backtracking
- `RakuAST::Regex::BacktrackModifiedAtom` - Backtrack modified atoms
- `RakuAST::Regex::Block` - Regex blocks
- `RakuAST::Regex::Branching` - Regex branching
- `RakuAST::Regex::CapturingGroup` - Capturing groups
- `RakuAST::Regex::CharClass` - Character classes
- `RakuAST::Regex::CharClass::Any` - Any character class
- `RakuAST::Regex::CharClass::BackSpace` - Backspace character class
- `RakuAST::Regex::CharClass::CarriageReturn` - Carriage return character class
- `RakuAST::Regex::CharClass::Digit` - Digit character class
- `RakuAST::Regex::CharClass::Escape` - Escape character class
- `RakuAST::Regex::CharClass::FormFeed` - Form feed character class
- `RakuAST::Regex::CharClass::HorizontalSpace` - Horizontal space character class
- `RakuAST::Regex::CharClass::Negatable` - Negatable character class
- `RakuAST::Regex::CharClass::Newline` - Newline character class
- `RakuAST::Regex::CharClass::Nul` - NUL character class
- `RakuAST::Regex::CharClass::Space` - Space character class
- `RakuAST::Regex::CharClass::Specified` - Specified character class
- `RakuAST::Regex::CharClass::Tab` - Tab character class
- `RakuAST::Regex::CharClass::VerticalSpace` - Vertical space character class
- `RakuAST::Regex::CharClass::Word` - Word character class
- `RakuAST::Regex::CharClassElement` - Character class elements
- `RakuAST::Regex::CharClassElement::Enumeration` - Character class enumerations
- `RakuAST::Regex::CharClassElement::Property` - Character class properties
- `RakuAST::Regex::CharClassElement::Rule` - Character class rules
- `RakuAST::Regex::CharClassEnumerationElement` - Character class enumeration elements
- `RakuAST::Regex::CharClassEnumerationElement::Character` - Character enumeration elements
- `RakuAST::Regex::CharClassEnumerationElement::Range` - Range enumeration elements
- `RakuAST::Regex::Conjunction` - Regex conjunctions
- `RakuAST::Regex::Group` - Regex groups
- `RakuAST::Regex::InternalModifier` - Internal modifiers
- `RakuAST::Regex::InternalModifier::IgnoreCase` - Ignore case modifiers
- `RakuAST::Regex::InternalModifier::IgnoreMark` - Ignore mark modifiers
- `RakuAST::Regex::InternalModifier::Ratchet` - Ratchet modifiers
- `RakuAST::Regex::InternalModifier::Sigspace` - Sigspace modifiers
- `RakuAST::Regex::Interpolation` - Regex interpolations
- `RakuAST::Regex::Literal` - Regex literals
- `RakuAST::Regex::MatchFrom` - Match from constructs
- `RakuAST::Regex::MatchTo` - Match to constructs
- `RakuAST::Regex::NamedCapture` - Named captures
- `RakuAST::Regex::Nested` - Nested regex constructs
- `RakuAST::Regex::QuantifiedAtom` - Quantified atoms
- `RakuAST::Regex::Quantifier` - Quantifiers
- `RakuAST::Regex::Quantifier::BlockRange` - Block range quantifiers
- `RakuAST::Regex::Quantifier::OneOrMore` - One or more quantifiers (+)
- `RakuAST::Regex::Quantifier::Range` - Range quantifiers
- `RakuAST::Regex::Quantifier::ZeroOrMore` - Zero or more quantifiers (*)
- `RakuAST::Regex::Quantifier::ZeroOrOne` - Zero or one quantifiers (?)
- `RakuAST::Regex::Quote` - Regex quotes
- `RakuAST::Regex::Sequence` - Regex sequences
- `RakuAST::Regex::SequentialAlternation` - Sequential alternations
- `RakuAST::Regex::SequentialConjunction` - Sequential conjunctions
- `RakuAST::Regex::Statement` - Regex statements
- `RakuAST::Regex::Term` - Regex terms
- `RakuAST::Regex::WithWhitespace` - Regex with whitespace

### `data` (21 types)
Data structures and containers including pairs, circumfixes, and argument lists.

- `RakuAST::CaptureSource` - Capture sources
- `RakuAST::ArgList` - Argument lists
- `RakuAST::ColonPair` - Colon pairs
- `RakuAST::ColonPair::False` - False colon pairs
- `RakuAST::ColonPair::Number` - Number colon pairs
- `RakuAST::ColonPair::True` - True colon pairs
- `RakuAST::ColonPair::Value` - Value colon pairs
- `RakuAST::ColonPair::Variable` - Variable colon pairs
- `RakuAST::ColonPairs` - Multiple colon pairs
- `RakuAST::FatArrow` - Fat arrows (=>)
- `RakuAST::QuotePair` - Quote pairs
- `RakuAST::QuoteWordsAtom` - Quote words atoms
- `RakuAST::SemiList` - Semicolon lists
- `RakuAST::Circumfix` - Circumfix operators
- `RakuAST::Circumfix::ArrayComposer` - Array composer ([])
- `RakuAST::Circumfix::HashComposer` - Hash composer ({})
- `RakuAST::Circumfix::Parentheses` - Parentheses (())
- `RakuAST::Postcircumfix` - Postcircumfix operators
- `RakuAST::Postcircumfix::ArrayIndex` - Array indexing
- `RakuAST::Postcircumfix::HashIndex` - Hash indexing
- `RakuAST::Postcircumfix::LiteralHashIndex` - Literal hash indexing

### `code` (18 types)
Code structures including routines, thunks, and contextualizers.

- `RakuAST::Code` - Base code type
- `RakuAST::Routine` - Routines
- `RakuAST::Method` - Methods
- `RakuAST::Methodish` - Method-like constructs
- `RakuAST::Sub` - Subroutines
- `RakuAST::Submethod` - Submethods
- `RakuAST::PointyBlock` - Pointy blocks
- `RakuAST::ExpressionThunk` - Expression thunks
- `RakuAST::ParameterDefaultThunk` - Parameter default thunks
- `RakuAST::Contextualizable` - Contextualizable constructs
- `RakuAST::Contextualizer` - Contextualizers
- `RakuAST::Contextualizer::Hash` - Hash contextualizers
- `RakuAST::Contextualizer::Item` - Item contextualizers
- `RakuAST::Contextualizer::List` - List contextualizers
- `RakuAST::LexicalScope` - Lexical scopes
- `RakuAST::ImplicitBlockSemanticsProvider` - Implicit block semantics
- `RakuAST::ImplicitDeclarations` - Implicit declarations
- `RakuAST::ImplicitLookups` - Implicit lookups

### `type` (22 types)
Type definitions and trait systems.

- `RakuAST::Type` - Base type
- `RakuAST::Type::Capture` - Capture types
- `RakuAST::Type::Coercion` - Type coercions
- `RakuAST::Type::Definedness` - Definedness types
- `RakuAST::Type::Derived` - Derived types
- `RakuAST::Type::Enum` - Enum types
- `RakuAST::Type::Parameterized` - Parameterized types
- `RakuAST::Type::Setting` - Setting types
- `RakuAST::Type::Simple` - Simple types
- `RakuAST::Type::Subset` - Subset types
- `RakuAST::Trait` - Base trait type
- `RakuAST::Trait::Does` - Does traits
- `RakuAST::Trait::Handles` - Handles traits
- `RakuAST::Trait::Hides` - Hides traits
- `RakuAST::Trait::Is` - Is traits
- `RakuAST::Trait::Of` - Of traits
- `RakuAST::Trait::Returns` - Returns traits
- `RakuAST::Trait::Type` - Type traits
- `RakuAST::Trait::Will` - Will traits
- `RakuAST::Trait::WillBuild` - WillBuild traits
- `RakuAST::Role::ResolveInstantiations` - Role instantiation resolution
- `RakuAST::Role::TypeEnvVar` - Role type environment variables

### `meta` (5 types)
Meta-programming constructs and advanced language features.

- `RakuAST::Meta` - Meta constructs
- `RakuAST::MetaInfix` - Meta infix operators
- `RakuAST::CurryThunk` - Curry thunks
- `RakuAST::FakeSignature` - Fake signatures
- `RakuAST::PlaceholderParameterOwner` - Placeholder parameter owners

### `doc` (8 types)
Documentation and pragma constructs.

- `RakuAST::Doc` - Base documentation type
- `RakuAST::Doc::Block` - Documentation blocks
- `RakuAST::Doc::Declarator` - Documentation declarators
- `RakuAST::Doc::LegacyRow` - Legacy documentation rows
- `RakuAST::Doc::Markup` - Documentation markup
- `RakuAST::Doc::Paragraph` - Documentation paragraphs
- `RakuAST::Doc::Row` - Documentation rows
- `RakuAST::Pragma` - Pragma constructs

### `special` (23 types)
Special-purpose constructs and advanced language features.

- `RakuAST::Blorst` - Blorst constructs
- `RakuAST::Stub` - Stub constructs
- `RakuAST::Stub::Die` - Die stubs
- `RakuAST::Stub::Fail` - Fail stubs
- `RakuAST::Stub::Warn` - Warn stubs
- `RakuAST::StubbyMeta` - Stubby meta constructs
- `RakuAST::Term` - Base term type
- `RakuAST::Term::Capture` - Capture terms
- `RakuAST::Term::EmptySet` - Empty set terms
- `RakuAST::Term::HyperWhatever` - Hyper whatever terms
- `RakuAST::Term::Name` - Name terms
- `RakuAST::Term::Named` - Named terms
- `RakuAST::Term::RadixNumber` - Radix number terms
- `RakuAST::Term::Rand` - Random terms
- `RakuAST::Term::Reduce` - Reduce terms
- `RakuAST::Term::Self` - Self terms
- `RakuAST::Term::TopicCall` - Topic call terms
- `RakuAST::Term::Whatever` - Whatever terms
- `RakuAST::Termish` - Term-like constructs
- `RakuAST::OnlyStar` - Only star constructs
- `RakuAST::ProducesNil` - Nil-producing constructs
- `RakuAST::Ternary` - Ternary operators
- `RakuAST::Feed` - Feed operators
- `RakuAST::Mixin` - Mixin constructs
- `RakuAST::AttachTarget` - Attach targets
- `RakuAST::Label` - Labels
- `RakuAST::SinkBoundary` - Sink boundaries
- `RakuAST::SinkPropagator` - Sink propagators
- `RakuAST::Sinkable` - Sinkable constructs

### `prefix` (20 types)
All prefix operators and statement prefixes.

- `RakuAST::StatementPrefix` - Base statement prefix type
- `RakuAST::StatementPrefix::Blorst` - Blorst statement prefixes
- `RakuAST::StatementPrefix::CallMethod` - Call method prefixes
- `RakuAST::StatementPrefix::Do` - Do prefixes
- `RakuAST::StatementPrefix::Eager` - Eager prefixes
- `RakuAST::StatementPrefix::Gather` - Gather prefixes
- `RakuAST::StatementPrefix::Hyper` - Hyper prefixes
- `RakuAST::StatementPrefix::Lazy` - Lazy prefixes
- `RakuAST::StatementPrefix::Once` - Once prefixes
- `RakuAST::StatementPrefix::Quietly` - Quietly prefixes
- `RakuAST::StatementPrefix::Race` - Race prefixes
- `RakuAST::StatementPrefix::React` - React prefixes
- `RakuAST::StatementPrefix::Sink` - Sink prefixes
- `RakuAST::StatementPrefix::Start` - Start prefixes
- `RakuAST::StatementPrefix::Supply` - Supply prefixes
- `RakuAST::StatementPrefix::Thunky` - Thunky prefixes
- `RakuAST::StatementPrefix::Try` - Try prefixes
- `RakuAST::StatementPrefix::Wheneverable` - Wheneverable prefixes
- `RakuAST::Prefix` - Prefix operators
- `RakuAST::Prefixish` - Prefix-like operators

### `postfix` (5 types)
All postfix operators and constructs.

- `RakuAST::Postfix` - Postfix operators
- `RakuAST::Postfix::Literal` - Literal postfix operators
- `RakuAST::Postfix::Power` - Power postfix operators
- `RakuAST::Postfix::Vulgar` - Vulgar postfix operators
- `RakuAST::Postfixish` - Postfix-like operators

### `var` (20 types)
Complete variable type hierarchy for all scopes and contexts.

- `RakuAST::Var` - Base variable type
- `RakuAST::VarDeclaration` - Variable declarations
- `RakuAST::VarDeclaration::Simple` - Simple variable declarations
- `RakuAST::Var::Attribute` - Attribute variables
- `RakuAST::Var::Attribute::Public` - Public attribute variables
- `RakuAST::Var::Compiler` - Compiler variables
- `RakuAST::Var::Compiler::Block` - Block compiler variables
- `RakuAST::Var::Compiler::File` - File compiler variables
- `RakuAST::Var::Compiler::Line` - Line compiler variables
- `RakuAST::Var::Compiler::Lookup` - Lookup compiler variables
- `RakuAST::Var::Compiler::Routine` - Routine compiler variables
- `RakuAST::Var::Doc` - Documentation variables
- `RakuAST::Var::Dynamic` - Dynamic variables
- `RakuAST::Var::Lexical` - Lexical variables
- `RakuAST::Var::Lexical::Constant` - Lexical constants
- `RakuAST::Var::Lexical::Setting` - Lexical settings
- `RakuAST::Var::NamedCapture` - Named capture variables
- `RakuAST::Var::Package` - Package variables
- `RakuAST::Var::PositionalCapture` - Positional capture variables
- `RakuAST::Var::Slang` - Slang variables

### `parameter` (6 types)
Parameter and target types for function signatures.

- `RakuAST::Parameter` - Parameters
- `RakuAST::ParameterDefaultThunk` - Parameter default thunks
- `RakuAST::ParameterTarget` - Parameter targets
- `RakuAST::ParameterTarget::Term` - Term parameter targets
- `RakuAST::ParameterTarget::Var` - Variable parameter targets
- `RakuAST::ParameterTarget::Whatever` - Whatever parameter targets

### `initializer` (6 types)
Assignment and initialization operations.

- `RakuAST::Initializer` - Base initializer type
- `RakuAST::Initializer::Assign` - Assignment initializers
- `RakuAST::Initializer::Bind` - Binding initializers
- `RakuAST::Initializer::CallAssign` - Call assignment initializers
- `RakuAST::Initializer::Expression` - Expression initializers
- `RakuAST::Assignment` - Assignment operations

### `metainfix` (8 types)
Meta-infix operators for advanced operator manipulation.

- `RakuAST::MetaInfix` - Base meta-infix type
- `RakuAST::MetaInfix::Assign` - Assignment meta-infix
- `RakuAST::MetaInfix::Cross` - Cross meta-infix (X)
- `RakuAST::MetaInfix::Hyper` - Hyper meta-infix (>>)
- `RakuAST::MetaInfix::Negate` - Negate meta-infix
- `RakuAST::MetaInfix::Reverse` - Reverse meta-infix (R)
- `RakuAST::MetaInfix::Sequence` - Sequence meta-infix
- `RakuAST::MetaInfix::Zip` - Zip meta-infix (Z)

### `compile` (8 types)
Compilation units and compile-time constructs.

- `RakuAST::CompUnit` - Compilation units
- `RakuAST::CompileTimeValue` - Compile-time values
- `RakuAST::Lookup` - Name lookups
- `RakuAST::Name` - Names
- `RakuAST::Heredoc` - Heredoc constructs
- `RakuAST::Heredoc::InterpolatedWhiteSpace` - Interpolated whitespace heredocs
- `RakuAST::Nqp` - NQP constructs
- `RakuAST::Nqp::Const` - NQP constants

### `core` (2 types)
Fundamental AST node types.

- `RakuAST::Node` - Base AST node type
- `RakuAST::Expression` - Base expression type

## Convenience Groups

### `call` (1 type)
Function and method calls.

- `RakuAST::Call` - Function/method calls

### `int` (1 type)  
Integer literals (alias for convenience).

- `RakuAST::IntLiteral` - Integer literals

### `str` (1 type)
String literals (alias for convenience).

- `RakuAST::StrLiteral` - String literals

### `op` (3 types)
General operators (infix, prefix, postfix).

- `RakuAST::Infixish` - Infix-like operators
- `RakuAST::Prefixish` - Prefix-like operators
- `RakuAST::Postfixish` - Postfix-like operators

### `apply-op` (6 types)
Operator applications and ternary constructs.

- `RakuAST::ApplyInfix` - Infix operator applications
- `RakuAST::ApplyListInfix` - List infix operator applications
- `RakuAST::ApplyDottyInfix` - Dotty infix operator applications
- `RakuAST::ApplyPostfix` - Postfix operator applications
- `RakuAST::ApplyPrefix` - Prefix operator applications
- `RakuAST::Ternary` - Ternary operators

### `conditional` (6 types)
Conditional statements for branching logic.

- `RakuAST::Statement::IfWith` - If-with statements
- `RakuAST::Statement::Unless` - Unless statements  
- `RakuAST::Statement::Without` - Without statements
- `RakuAST::Statement::If` - If statements
- `RakuAST::Statement::When` - When statements
- `RakuAST::Statement::With` - With statements

### `iterable` (4 types)
Looping and iteration constructs.

- `RakuAST::Statement::Loop` - Loop statements
- `RakuAST::Statement::For` - For statements
- `RakuAST::Statement::Whenever` - Whenever statements
- `RakuAST::ForLoopImplementation` - For loop implementations

### `ignorable` (5 types)
Structural elements often ignored during AST traversal.

- `RakuAST::Block` - Code blocks
- `RakuAST::Blockoid` - Block-like constructs
- `RakuAST::StatementList` - Statement lists
- `RakuAST::Statement::Expression` - Expression statements
- `RakuAST::ArgList` - Argument lists

## Usage Examples

```raku
# Find all literal values
$ast.&ast-query('.literal')

# Find all conditional statements
$ast.&ast-query('.conditional') 

# Find variables in regex context
$ast.&ast-query('.regex >>> .var')

# Find all operators
$ast.&ast-query('.op')

# Find statement prefixes (like 'do', 'try', etc.)
$ast.&ast-query('.prefix')

# Combine multiple groups
$ast.&ast-query('.statement.conditional')
```