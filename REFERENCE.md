# ASTQuery Reference: Groups, Built-in Functions, and ID Fields

This document enumerates all built-in groups (used as `.group` in selectors), all built-in `&functions`, and the mapping of RakuAST types to their `#id` attribute used by the matcher when comparing identifiers.

Generated from the implementation in `lib/ASTQuery/Matcher.rakumod` and `lib/ASTQuery.rakumod`. Keep this file in sync with changes to those modules.

## Groups

Each entry lists the group name (as used in queries with a leading `.`), a short description, and the types included in that group.

- `.apply-operator`: Operator application nodes (including ternary)
  - Types: `RakuAST::ApplyInfix`, `RakuAST::ApplyListInfix`, `RakuAST::ApplyPostfix`, `RakuAST::Ternary`

- `.apply-op`: Alias of operator application nodes
  - Types: `RakuAST::ApplyInfix`, `RakuAST::ApplyListInfix`, `RakuAST::ApplyPostfix`, `RakuAST::Ternary`

- `.assignment`: Assignment and initializer forms
  - Types: `RakuAST::Assignment`, `RakuAST::Initializer`, `RakuAST::Initializer::Assign`, `RakuAST::Initializer::Bind`, `RakuAST::Initializer::CallAssign`, `RakuAST::Initializer::Expression`

- `.call`: Call nodes
  - Types: `RakuAST::Call`

- `.code`: Code containers and context helpers
  - Types: `RakuAST::CompUnit`, `RakuAST::Code`, `RakuAST::Routine`, `RakuAST::Method`, `RakuAST::Methodish`, `RakuAST::Sub`, `RakuAST::Submethod`, `RakuAST::Contextualizable`, `RakuAST::Contextualizer`, `RakuAST::Contextualizer::Hash`, `RakuAST::Contextualizer::Item`, `RakuAST::Contextualizer::List`, `RakuAST::ImplicitBlockSemanticsProvider`, `RakuAST::ImplicitDeclarations`, `RakuAST::ImplicitLookups`, `RakuAST::LexicalScope`, `RakuAST::AttachTarget`

- `.control`: High-level control flow constructs
  - Types: `RakuAST::ForLoopImplementation`, `RakuAST::FlipFlop`, `RakuAST::Statement::IfWith`, `RakuAST::Statement::Unless`, `RakuAST::Statement::With`, `RakuAST::Statement::When`, `RakuAST::Statement::Given`, `RakuAST::Statement::Whenever`, `RakuAST::StatementModifier::Condition`, `RakuAST::StatementModifier::For`

- `.data`: Data-ish helpers and containers
  - Types: `RakuAST::CaptureSource`, `RakuAST::ArgList`, `RakuAST::Name`, `RakuAST::Label`, `RakuAST::Lookup`, `RakuAST::ColonPair`, `RakuAST::ColonPair::False`, `RakuAST::ColonPair::Number`, `RakuAST::ColonPair::True`, `RakuAST::ColonPair::Value`, `RakuAST::ColonPair::Variable`, `RakuAST::ColonPairs`, `RakuAST::QuotePair`, `RakuAST::QuoteWordsAtom`, `RakuAST::SemiList`, `RakuAST::Postcircumfix`, `RakuAST::Postcircumfix::ArrayIndex`, `RakuAST::Postcircumfix::HashIndex`, `RakuAST::Postcircumfix::LiteralHashIndex`, `RakuAST::Circumfix`, `RakuAST::Circumfix::ArrayComposer`, `RakuAST::Circumfix::HashComposer`, `RakuAST::Circumfix::Parentheses`, `RakuAST::OnlyStar`

- `.declaration`: Declarations, parameters, and packageish types
  - Types: `RakuAST::Declaration`, `RakuAST::Declaration::External`, `RakuAST::Declaration::Import`, `RakuAST::Declaration::LexicalPackage`, `RakuAST::Declaration::ResolvedConstant`, `RakuAST::Declaration::External::Constant`, `RakuAST::Declaration::External::Setting`, `RakuAST::Var`, `RakuAST::NamedArg`, `RakuAST::Parameter`, `RakuAST::ParameterDefaultThunk`, `RakuAST::ParameterTarget`, `RakuAST::ParameterTarget::Term`, `RakuAST::ParameterTarget::Var`, `RakuAST::ParameterTarget::Whatever`, `RakuAST::Signature`, `RakuAST::Class`, `RakuAST::Role`, `RakuAST::RoleBody`, `RakuAST::Role::ResolveInstantiations`, `RakuAST::Role::TypeEnvVar`, `RakuAST::Module`, `RakuAST::Package`, `RakuAST::Package::Attachable`, `RakuAST::Grammar`, `RakuAST::AttachTarget`

- `.doc`: Documentation and pragma nodes
  - Types: `RakuAST::Doc`, `RakuAST::Doc::Block`, `RakuAST::Doc::Declarator`, `RakuAST::Doc::LegacyRow`, `RakuAST::Doc::Markup`, `RakuAST::Doc::Paragraph`, `RakuAST::Doc::Row`, `RakuAST::Pragma`, `RakuAST::Substitution`, `RakuAST::SubstitutionReplacementThunk`

- `.expression`: Expression wrapper nodes (Statement::Expression)
  - Types: `RakuAST::Statement::Expression`

- `.ignorable`: Nodes skipped by `>>`/`<<` when traversing
  - Types: `RakuAST::Block`, `RakuAST::Blockoid`, `RakuAST::StatementList`, `RakuAST::Statement::Expression`, `RakuAST::ArgList`

- `.int`: Integer literal nodes
  - Types: `RakuAST::IntLiteral`

- `.iterable`: Loop/iteration constructs
  - Types: `RakuAST::Statement::Loop`, `RakuAST::Statement::Loop::RepeatUntil`, `RakuAST::Statement::Loop::RepeatWhile`, `RakuAST::Statement::Loop::Until`, `RakuAST::Statement::Loop::While`, `RakuAST::Statement::For`, `RakuAST::Statement::Whenever`

- `.literal`: Literal and constant nodes
  - Types: `RakuAST::ComplexLiteral`, `RakuAST::IntLiteral`, `RakuAST::NumLiteral`, `RakuAST::StrLiteral`, `RakuAST::RatLiteral`, `RakuAST::VersionLiteral`, `RakuAST::Constant`, `RakuAST::Literal`, `RakuAST::Heredoc`, `RakuAST::Heredoc::InterpolatedWhiteSpace`, `RakuAST::QuotedString`, `RakuAST::QuoteWordsAtom`

- `.meta`: Meta-level constructs and compile-time values
  - Types: `RakuAST::Meta`, `RakuAST::MetaInfix`, `RakuAST::CurryThunk`, `RakuAST::FakeSignature`, `RakuAST::PlaceholderParameterOwner`, `RakuAST::Knowhow`, `RakuAST::Nqp`, `RakuAST::Nqp::Const`, `RakuAST::CompileTimeValue`, `RakuAST::StubbyMeta`

- `.method-declaration`: Method declaration nodes
  - Types: `RakuAST::Method`

- `.node`: Any RakuAST node base
  - Types: `RakuAST::Node`

- `.op`: Operator kinds (alias of `.operator`)
  - Types: `RakuAST::Infixish`, `RakuAST::Prefixish`, `RakuAST::Postfixish`

- `.operator`: Operator kinds
  - Types: `RakuAST::Infixish`, `RakuAST::Prefixish`, `RakuAST::Postfixish`

- `.phaser`: Phasers and phase-time markers
  - Types: `RakuAST::StatementPrefix::Phaser`, `RakuAST::StatementPrefix::Phaser::Begin`, `RakuAST::StatementPrefix::Phaser::Block`, `RakuAST::StatementPrefix::Phaser::Check`, `RakuAST::StatementPrefix::Phaser::Close`, `RakuAST::StatementPrefix::Phaser::End`, `RakuAST::StatementPrefix::Phaser::Enter`, `RakuAST::StatementPrefix::Phaser::First`, `RakuAST::StatementPrefix::Phaser::Init`, `RakuAST::StatementPrefix::Phaser::Keep`, `RakuAST::StatementPrefix::Phaser::Last`, `RakuAST::StatementPrefix::Phaser::Leave`, `RakuAST::StatementPrefix::Phaser::Next`, `RakuAST::StatementPrefix::Phaser::Post`, `RakuAST::StatementPrefix::Phaser::Pre`, `RakuAST::StatementPrefix::Phaser::Quit`, `RakuAST::StatementPrefix::Phaser::Sinky`, `RakuAST::StatementPrefix::Phaser::Temp`, `RakuAST::StatementPrefix::Phaser::Undo`, `RakuAST::BeginTime`, `RakuAST::CheckTime`, `RakuAST::ParseTime`

- `.regex`: Regex AST nodes
  - Types: `RakuAST::Regex`, `RakuAST::RegexDeclaration`, `RakuAST::RegexThunk`, `RakuAST::QuotedRegex`, `RakuAST::QuotedMatchConstruct`, `RakuAST::QuotedString`, `RakuAST::Regex::Alternation`, `RakuAST::Regex::Anchor`, `RakuAST::Regex::Anchor::BeginningOfLine`, `RakuAST::Regex::Anchor::BeginningOfString`, `RakuAST::Regex::Anchor::EndOfLine`, `RakuAST::Regex::Anchor::EndOfString`, `RakuAST::Regex::Anchor::LeftWordBoundary`, `RakuAST::Regex::Anchor::RightWordBoundary`, `RakuAST::Regex::Assertion`, `RakuAST::Regex::Assertion::Alias`, `RakuAST::Regex::Assertion::Callable`, `RakuAST::Regex::Assertion::CharClass`, `RakuAST::Regex::Assertion::Fail`, `RakuAST::Regex::Assertion::InterpolatedBlock`, `RakuAST::Regex::Assertion::InterpolatedVar`, `RakuAST::Regex::Assertion::Lookahead`, `RakuAST::Regex::Assertion::Named`, `RakuAST::Regex::Assertion::Named::Args`, `RakuAST::Regex::Assertion::Named::RegexArg`, `RakuAST::Regex::Assertion::Pass`, `RakuAST::Regex::Assertion::PredicateBlock`, `RakuAST::Regex::Assertion::Recurse`, `RakuAST::Regex::Atom`, `RakuAST::Regex::BackReference`, `RakuAST::Regex::BackReference::Named`, `RakuAST::Regex::BackReference::Positional`, `RakuAST::Regex::Backtrack`, `RakuAST::Regex::Backtrack::Frugal`, `RakuAST::Regex::Backtrack::Greedy`, `RakuAST::Regex::Backtrack::Ratchet`, `RakuAST::Regex::BacktrackModifiedAtom`, `RakuAST::Regex::Block`, `RakuAST::Regex::Branching`, `RakuAST::Regex::CapturingGroup`, `RakuAST::Regex::CharClass`, `RakuAST::Regex::CharClass::Any`, `RakuAST::Regex::CharClass::BackSpace`, `RakuAST::Regex::CharClass::CarriageReturn`, `RakuAST::Regex::CharClass::Digit`, `RakuAST::Regex::CharClass::Escape`, `RakuAST::Regex::CharClass::FormFeed`, `RakuAST::Regex::CharClass::HorizontalSpace`, `RakuAST::Regex::CharClass::Negatable`, `RakuAST::Regex::CharClass::Newline`, `RakuAST::Regex::CharClass::Nul`, `RakuAST::Regex::CharClass::Space`, `RakuAST::Regex::CharClass::Specified`, `RakuAST::Regex::CharClass::Tab`, `RakuAST::Regex::CharClass::VerticalSpace`, `RakuAST::Regex::CharClass::Word`, `RakuAST::Regex::CharClassElement`, `RakuAST::Regex::CharClassElement::Enumeration`, `RakuAST::Regex::CharClassElement::Property`, `RakuAST::Regex::CharClassElement::Rule`, `RakuAST::Regex::CharClassEnumerationElement`, `RakuAST::Regex::CharClassEnumerationElement::Character`, `RakuAST::Regex::CharClassEnumerationElement::Range`, `RakuAST::Regex::Conjunction`, `RakuAST::Regex::Group`, `RakuAST::Regex::InternalModifier`, `RakuAST::Regex::InternalModifier::IgnoreCase`, `RakuAST::Regex::InternalModifier::IgnoreMark`, `RakuAST::Regex::InternalModifier::Ratchet`, `RakuAST::Regex::InternalModifier::Sigspace`, `RakuAST::Regex::Interpolation`, `RakuAST::Regex::Literal`, `RakuAST::Regex::MatchFrom`, `RakuAST::Regex::MatchTo`, `RakuAST::Regex::NamedCapture`, `RakuAST::Regex::Nested`, `RakuAST::Regex::QuantifiedAtom`, `RakuAST::Regex::Quantifier`, `RakuAST::Regex::Quantifier::BlockRange`, `RakuAST::Regex::Quantifier::OneOrMore`, `RakuAST::Regex::Quantifier::Range`, `RakuAST::Regex::Quantifier::ZeroOrMore`, `RakuAST::Regex::Quantifier::ZeroOrOne`, `RakuAST::Regex::Quote`, `RakuAST::Regex::Sequence`, `RakuAST::Regex::SequentialAlternation`, `RakuAST::Regex::SequentialConjunction`, `RakuAST::Regex::Statement`, `RakuAST::Regex::Term`, `RakuAST::Regex::WithWhitespace`, `RakuAST::RuleDeclaration`, `RakuAST::TokenDeclaration`

- `.special`: Special terms and sink/sinkable helpers
  - Types: `RakuAST::Blorst`, `RakuAST::Stub`, `RakuAST::Stub::Die`, `RakuAST::Stub::Fail`, `RakuAST::Stub::Warn`, `RakuAST::Term`, `RakuAST::Termish`, `RakuAST::Term::Capture`, `RakuAST::Term::EmptySet`, `RakuAST::Term::HyperWhatever`, `RakuAST::Term::Name`, `RakuAST::Term::Named`, `RakuAST::Term::RadixNumber`, `RakuAST::Term::Rand`, `RakuAST::Term::Reduce`, `RakuAST::Term::Self`, `RakuAST::Term::TopicCall`, `RakuAST::Term::Whatever`, `RakuAST::OnlyStar`, `RakuAST::ProducesNil`, `RakuAST::SinkBoundary`, `RakuAST::SinkPropagator`, `RakuAST::Sinkable`

- `.statement`: Statement nodes (broad wrapper)
  - Types: `RakuAST::Statement`

- `.str`: String literal nodes
  - Types: `RakuAST::StrLiteral`

- `.type`: Type objects and trait nodes
  - Types: `RakuAST::Type`, `RakuAST::Type::Capture`, `RakuAST::Type::Coercion`, `RakuAST::Type::Definedness`, `RakuAST::Type::Derived`, `RakuAST::Type::Enum`, `RakuAST::Type::Parameterized`, `RakuAST::Type::Setting`, `RakuAST::Type::Simple`, `RakuAST::Type::Subset`, `RakuAST::Native`, `RakuAST::Trait`, `RakuAST::Trait::Does`, `RakuAST::Trait::Handles`, `RakuAST::Trait::Hides`, `RakuAST::Trait::Is`, `RakuAST::Trait::Of`, `RakuAST::Trait::Returns`, `RakuAST::Trait::Type`, `RakuAST::Trait::Will`, `RakuAST::Trait::WillBuild`

- `.variable`: Variables and declarations
  - Types: `RakuAST::Var`, `RakuAST::VarDeclaration`, `RakuAST::VarDeclaration::Simple`

- `.variable-declaration`: Variable declaration nodes
  - Types: `RakuAST::VarDeclaration::Simple`, `RakuAST::VarDeclaration`

- `.variable-usage`: Variable usage nodes
  - Types: `RakuAST::Var`

- `.var`: Variable family (usage and assorted specialized forms)
  - Types: `RakuAST::VarDeclaration`, `RakuAST::Var`, `RakuAST::Var::Attribute`, `RakuAST::Var::Compiler`, `RakuAST::Var::Doc`, `RakuAST::Var::Dynamic`, `RakuAST::Var::Lexical`, `RakuAST::Var::NamedCapture`, `RakuAST::Var::Package`, `RakuAST::Var::PositionalCapture`, `RakuAST::Var::Slang`, `RakuAST::Var::Attribute::Public`, `RakuAST::Var::Compiler::Block`, `RakuAST::Var::Compiler::File`, `RakuAST::Var::Compiler::Line`, `RakuAST::Var::Compiler::Lookup`, `RakuAST::Var::Compiler::Routine`, `RakuAST::Var::Lexical::Constant`, `RakuAST::Var::Lexical::Setting`

- `.var-declaration`: Variable declaration (simple)
  - Types: `RakuAST::VarDeclaration::Simple`

- `.var-usage`: Variable usage nodes
  - Types: `RakuAST::Var`

- `.conditional`: Conditional statements (if/unless/without variants)
  - Types: `RakuAST::Statement::IfWith`, `RakuAST::Statement::Unless`, `RakuAST::Statement::Without`

## Built-in `&functions`

These are registered at module load and are always available in selectors.

- `&is-call`: True when the node type name starts with `RakuAST::Call` (any call form).
- `&is-operator`: True for operator-kind nodes (`Infix*`, `Prefix*`, `Postfix*`, including `*ish`).
- `&is-apply-operator`: True for operator application nodes (`ApplyInfix`, `ApplyListInfix`, `ApplyPostfix`) or `Ternary`.
- `&is-assignment`: True for assignment or initializer nodes (type name contains `Assignment` or starts with `RakuAST::Initializer::`).
- `&is-conditional`: True for conditional statements (`Statement::If`, `Statement::Unless`, `Statement::With`, `Statement::Without`).
- `&has-var`: True if the node has a descendant that matches `.variable-usage`.
- `&has-call`: True if the node has a descendant that matches `.call`.
- `&has-int`: True if the node has a descendant that matches `.int`.

## ID Fields (`#id`)

The matcher uses the following attribute for the `#id` comparison per type (including via MRO lookup):

- `RakuAST::ArgList`: `args`
- `RakuAST::ApplyDottyInfix`: `infix`
- `RakuAST::ApplyInfix`: `infix`
- `RakuAST::ApplyListInfix`: `infix`
- `RakuAST::ApplyPostfix`: `postfix`
- `RakuAST::ApplyPrefix`: `prefix`
- `RakuAST::Assignment`: `operator`
- `RakuAST::Call`: `name`
- `RakuAST::Class`: `name`
- `RakuAST::ColonPair`: `key`
- `RakuAST::FatArrow`: `key`
- `RakuAST::Grammar`: `name`
- `RakuAST::Infix`: `operator`
- `RakuAST::Infixish`: `infix`
- `RakuAST::Label`: `name`
- `RakuAST::Literal`: `value`
- `RakuAST::Method`: `name`
- `RakuAST::Module`: `name`
- `RakuAST::Name`: `simple-identifier`
- `RakuAST::Package`: `name`
- `RakuAST::Prefix`: `operator`
- `RakuAST::Postfix`: `operator`
- `RakuAST::Regex::NamedCapture`: `name`
- `RakuAST::RegexDeclaration`: `name`
- `RakuAST::Role`: `name`
- `RakuAST::Routine`: `name`
- `RakuAST::RuleDeclaration`: `name`
- `RakuAST::Statement::Expression`: `expression`
- `RakuAST::Statement::For`: `source`
- `RakuAST::Statement::If`: `condition`
- `RakuAST::Statement::IfWith`: `condition`
- `RakuAST::Statement::Loop`: `condition`
- `RakuAST::Statement::Unless`: `condition`
- `RakuAST::Statement::When`: `condition`
- `RakuAST::Statement::With`: `condition`
- `RakuAST::Statement::Without`: `condition`
- `RakuAST::Sub`: `name`
- `RakuAST::Submethod`: `name`
- `RakuAST::Term::Name`: `name`
- `RakuAST::TokenDeclaration`: `name`
- `RakuAST::Var::Attribute`: `name`
- `RakuAST::Var::Doc`: `name`
- `RakuAST::Var::Dynamic`: `name`
- `RakuAST::Var::Lexical`: `desigilname`
- `RakuAST::Var::Package`: `name`
- `RakuAST::VarDeclaration`: `name`
- `RakuAST::VarDeclaration::Simple`: `name`

Notes
- The matcher traverses nested RakuAST nodes following their configured id field to reach comparable leaf values when matching attributes.
- For variable declarations, bare identifiers in selectors (e.g., `#x`) automatically strip sigils for comparison with declaration names.
