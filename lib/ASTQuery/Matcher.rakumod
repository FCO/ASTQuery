use experimental :rakuast, :will-complain;
use ASTQuery::Match;
use ASTQuery::HighLighter;
unit class ASTQuery::Matcher;

my $DEBUG = %*ENV<ASTQUERY_DEBUG>;

=head1 List of RakuAST classes

=item RakuAST::ApplyDottyInfix
=item RakuAST::ApplyInfix
=item RakuAST::ApplyListInfix
=item RakuAST::ApplyPostfix
=item RakuAST::ApplyPrefix
=item RakuAST::ArgList
=item RakuAST::Assignment
=item RakuAST::AttachTarget
=item RakuAST::BeginTime
=item RakuAST::Block
=item RakuAST::BlockStatementSensitive
=item RakuAST::BlockThunk
=item RakuAST::Blockoid
=item RakuAST::Blorst
=item RakuAST::BracketedInfix
=item RakuAST::CaptureSource
=item RakuAST::CheckTime
=item RakuAST::Circumfix
=item RakuAST::Class
=item RakuAST::Code
=item RakuAST::ColonPair
=item RakuAST::ColonPairs
=item RakuAST::CompUnit
=item RakuAST::CompileTimeValue
=item RakuAST::ComplexLiteral
=item RakuAST::Constant
=item RakuAST::Contextualizable
=item RakuAST::Contextualizer
=item RakuAST::CurryThunk
=item RakuAST::Declaration
=item RakuAST::Doc
=item RakuAST::DottyInfixish
=item RakuAST::Expression
=item RakuAST::ExpressionThunk
=item RakuAST::FakeSignature
=item RakuAST::FatArrow
=item RakuAST::Feed
=item RakuAST::FlipFlop
=item RakuAST::ForLoopImplementation
=item RakuAST::FunctionInfix
=item RakuAST::Grammar
=item RakuAST::Heredoc
=item RakuAST::ImplicitBlockSemanticsProvider
=item RakuAST::ImplicitDeclarations
=item RakuAST::ImplicitLookups
=item RakuAST::Infix
=item RakuAST::Infixish
=item RakuAST::Initializer
=item RakuAST::IntLiteral
=item RakuAST::Knowhow
=item RakuAST::Label
=item RakuAST::LexicalScope
=item RakuAST::Literal
=item RakuAST::Lookup
=item RakuAST::Meta
=item RakuAST::MetaInfix
=item RakuAST::Method
=item RakuAST::Methodish
=item RakuAST::Mixin
=item RakuAST::Module
=item RakuAST::Name
=item RakuAST::NamedArg
=item RakuAST::Native
=item RakuAST::Node
=item RakuAST::Nqp
=item RakuAST::NumLiteral
=item RakuAST::OnlyStar
=item RakuAST::Package
=item RakuAST::Parameter
=item RakuAST::ParameterDefaultThunk
=item RakuAST::ParameterTarget
=item RakuAST::ParseTime
=item RakuAST::PlaceholderParameterOwner
=item RakuAST::PointyBlock
=item RakuAST::Postcircumfix
=item RakuAST::Postfix
=item RakuAST::Postfixish
=item RakuAST::Pragma
=item RakuAST::Prefix
=item RakuAST::Prefixish
=item RakuAST::ProducesNil
=item RakuAST::QuotePair
=item RakuAST::QuoteWordsAtom
=item RakuAST::QuotedMatchConstruct
=item RakuAST::QuotedRegex
=item RakuAST::QuotedString
=item RakuAST::RatLiteral
=item RakuAST::Regex
=item RakuAST::RegexDeclaration
=item RakuAST::RegexThunk
=item RakuAST::Role
=item RakuAST::RoleBody
=item RakuAST::Routine
=item RakuAST::RuleDeclaration
=item RakuAST::SemiList
=item RakuAST::Signature
=item RakuAST::SinkBoundary
=item RakuAST::SinkPropagator
=item RakuAST::Sinkable
=item RakuAST::Statement
=item RakuAST::StatementList
=item RakuAST::StatementModifier
=item RakuAST::StatementPrefix
=item RakuAST::StatementSequence
=item RakuAST::StrLiteral
=item RakuAST::Stub
=item RakuAST::StubbyMeta
=item RakuAST::Sub
=item RakuAST::Submethod
=item RakuAST::Substitution
=item RakuAST::SubstitutionReplacementThunk
=item RakuAST::Term
=item RakuAST::Termish
=item RakuAST::Ternary
=item RakuAST::TokenDeclaration
=item RakuAST::Trait
=item RakuAST::Type
=item RakuAST::Var
=item RakuAST::VersionLiteral
=item RakuAST::Circumfix::ArrayComposer
=item RakuAST::Circumfix::HashComposer
=item RakuAST::Circumfix::Parentheses
=item RakuAST::ColonPair::False
=item RakuAST::ColonPair::Number
=item RakuAST::ColonPair::True
=item RakuAST::ColonPair::Value
=item RakuAST::ColonPair::Variable
=item RakuAST::Contextualizer::Hash
=item RakuAST::Contextualizer::Item
=item RakuAST::Contextualizer::List
=item RakuAST::Declaration::External
=item RakuAST::Declaration::Import
=item RakuAST::Declaration::LexicalPackage
=item RakuAST::Declaration::ResolvedConstant
=item RakuAST::Doc::Block
=item RakuAST::Doc::Declarator
=item RakuAST::Doc::LegacyRow
=item RakuAST::Doc::Markup
=item RakuAST::Doc::Paragraph
=item RakuAST::Doc::Row
=item RakuAST::Heredoc::InterpolatedWhiteSpace
=item RakuAST::Initializer::Assign
=item RakuAST::Initializer::Bind
=item RakuAST::Initializer::CallAssign
=item RakuAST::Initializer::Expression
=item RakuAST::MetaInfix::Assign
=item RakuAST::MetaInfix::Cross
=item RakuAST::MetaInfix::Hyper
=item RakuAST::MetaInfix::Negate
=item RakuAST::MetaInfix::Reverse
=item RakuAST::MetaInfix::Sequence
=item RakuAST::MetaInfix::Zip
=item RakuAST::Nqp::Const
=item RakuAST::Package::Attachable
=item RakuAST::ParameterTarget::Term
=item RakuAST::ParameterTarget::Var
=item RakuAST::ParameterTarget::Whatever
=item RakuAST::Postcircumfix::ArrayIndex
=item RakuAST::Postcircumfix::HashIndex
=item RakuAST::Postcircumfix::LiteralHashIndex
=item RakuAST::Postfix::Literal
=item RakuAST::Postfix::Power
=item RakuAST::Postfix::Vulgar
=item RakuAST::Regex::Alternation
=item RakuAST::Regex::Anchor
=item RakuAST::Regex::Assertion
=item RakuAST::Regex::Atom
=item RakuAST::Regex::BackReference
=item RakuAST::Regex::Backtrack
=item RakuAST::Regex::BacktrackModifiedAtom
=item RakuAST::Regex::Block
=item RakuAST::Regex::Branching
=item RakuAST::Regex::CapturingGroup
=item RakuAST::Regex::CharClass
=item RakuAST::Regex::CharClassElement
=item RakuAST::Regex::CharClassEnumerationElement
=item RakuAST::Regex::Conjunction
=item RakuAST::Regex::Group
=item RakuAST::Regex::InternalModifier
=item RakuAST::Regex::Interpolation
=item RakuAST::Regex::Literal
=item RakuAST::Regex::MatchFrom
=item RakuAST::Regex::MatchTo
=item RakuAST::Regex::NamedCapture
=item RakuAST::Regex::Nested
=item RakuAST::Regex::QuantifiedAtom
=item RakuAST::Regex::Quantifier
=item RakuAST::Regex::Quote
=item RakuAST::Regex::Sequence
=item RakuAST::Regex::SequentialAlternation
=item RakuAST::Regex::SequentialConjunction
=item RakuAST::Regex::Statement
=item RakuAST::Regex::Term
=item RakuAST::Regex::WithWhitespace
=item RakuAST::Role::ResolveInstantiations
=item RakuAST::Role::TypeEnvVar
=item RakuAST::Statement::Catch
=item RakuAST::Statement::Control
=item RakuAST::Statement::Default
=item RakuAST::Statement::Empty
=item RakuAST::Statement::ExceptionHandler
=item RakuAST::Statement::Expression
=item RakuAST::Statement::For
=item RakuAST::Statement::Given
=item RakuAST::Statement::If
=item RakuAST::Statement::IfWith
=item RakuAST::Statement::Import
=item RakuAST::Statement::Loop
=item RakuAST::Statement::Need
=item RakuAST::Statement::Require
=item RakuAST::Statement::Unless
=item RakuAST::Statement::Use
=item RakuAST::Statement::When
=item RakuAST::Statement::Whenever
=item RakuAST::Statement::With
=item RakuAST::Statement::Without
=item RakuAST::StatementModifier::Condition
=item RakuAST::StatementModifier::For
=item RakuAST::StatementModifier::Given
=item RakuAST::StatementModifier::If
=item RakuAST::StatementModifier::Loop
=item RakuAST::StatementModifier::Unless
=item RakuAST::StatementModifier::Until
=item RakuAST::StatementModifier::When
=item RakuAST::StatementModifier::While
=item RakuAST::StatementModifier::With
=item RakuAST::StatementModifier::Without
=item RakuAST::StatementPrefix::Blorst
=item RakuAST::StatementPrefix::CallMethod
=item RakuAST::StatementPrefix::Do
=item RakuAST::StatementPrefix::Eager
=item RakuAST::StatementPrefix::Gather
=item RakuAST::StatementPrefix::Hyper
=item RakuAST::StatementPrefix::Lazy
=item RakuAST::StatementPrefix::Once
=item RakuAST::StatementPrefix::Phaser
=item RakuAST::StatementPrefix::Quietly
=item RakuAST::StatementPrefix::Race
=item RakuAST::StatementPrefix::React
=item RakuAST::StatementPrefix::Sink
=item RakuAST::StatementPrefix::Start
=item RakuAST::StatementPrefix::Supply
=item RakuAST::StatementPrefix::Thunky
=item RakuAST::StatementPrefix::Try
=item RakuAST::StatementPrefix::Wheneverable
=item RakuAST::Stub::Die
=item RakuAST::Stub::Fail
=item RakuAST::Stub::Warn
=item RakuAST::Term::Capture
=item RakuAST::Term::EmptySet
=item RakuAST::Term::HyperWhatever
=item RakuAST::Term::Name
=item RakuAST::Term::Named
=item RakuAST::Term::RadixNumber
=item RakuAST::Term::Rand
=item RakuAST::Term::Reduce
=item RakuAST::Term::Self
=item RakuAST::Term::TopicCall
=item RakuAST::Term::Whatever
=item RakuAST::Trait::Does
=item RakuAST::Trait::Handles
=item RakuAST::Trait::Hides
=item RakuAST::Trait::Is
=item RakuAST::Trait::Of
=item RakuAST::Trait::Returns
=item RakuAST::Trait::Type
=item RakuAST::Trait::Will
=item RakuAST::Trait::WillBuild
=item RakuAST::Type::Capture
=item RakuAST::Type::Coercion
=item RakuAST::Type::Definedness
=item RakuAST::Type::Derived
=item RakuAST::Type::Enum
=item RakuAST::Type::Parameterized
=item RakuAST::Type::Setting
=item RakuAST::Type::Simple
=item RakuAST::Type::Subset
=item RakuAST::Var::Attribute
=item RakuAST::Var::Compiler
=item RakuAST::Var::Doc
=item RakuAST::Var::Dynamic
=item RakuAST::Var::Lexical
=item RakuAST::Var::NamedCapture
=item RakuAST::Var::Package
=item RakuAST::Var::PositionalCapture
=item RakuAST::Var::Slang
=item RakuAST::Declaration::External::Constant
=item RakuAST::Declaration::External::Setting
=item RakuAST::Regex::Anchor::BeginningOfLine
=item RakuAST::Regex::Anchor::BeginningOfString
=item RakuAST::Regex::Anchor::EndOfLine
=item RakuAST::Regex::Anchor::EndOfString
=item RakuAST::Regex::Anchor::LeftWordBoundary
=item RakuAST::Regex::Anchor::RightWordBoundary
=item RakuAST::Regex::Assertion::Alias
=item RakuAST::Regex::Assertion::Callable
=item RakuAST::Regex::Assertion::CharClass
=item RakuAST::Regex::Assertion::Fail
=item RakuAST::Regex::Assertion::InterpolatedBlock
=item RakuAST::Regex::Assertion::InterpolatedVar
=item RakuAST::Regex::Assertion::Lookahead
=item RakuAST::Regex::Assertion::Named
=item RakuAST::Regex::Assertion::Pass
=item RakuAST::Regex::Assertion::PredicateBlock
=item RakuAST::Regex::Assertion::Recurse
=item RakuAST::Regex::BackReference::Named
=item RakuAST::Regex::BackReference::Positional
=item RakuAST::Regex::Backtrack::Frugal
=item RakuAST::Regex::Backtrack::Greedy
=item RakuAST::Regex::Backtrack::Ratchet
=item RakuAST::Regex::CharClass::Any
=item RakuAST::Regex::CharClass::BackSpace
=item RakuAST::Regex::CharClass::CarriageReturn
=item RakuAST::Regex::CharClass::Digit
=item RakuAST::Regex::CharClass::Escape
=item RakuAST::Regex::CharClass::FormFeed
=item RakuAST::Regex::CharClass::HorizontalSpace
=item RakuAST::Regex::CharClass::Negatable
=item RakuAST::Regex::CharClass::Newline
=item RakuAST::Regex::CharClass::Nul
=item RakuAST::Regex::CharClass::Space
=item RakuAST::Regex::CharClass::Specified
=item RakuAST::Regex::CharClass::Tab
=item RakuAST::Regex::CharClass::VerticalSpace
=item RakuAST::Regex::CharClass::Word
=item RakuAST::Regex::CharClassElement::Enumeration
=item RakuAST::Regex::CharClassElement::Property
=item RakuAST::Regex::CharClassElement::Rule
=item RakuAST::Regex::CharClassEnumerationElement::Character
=item RakuAST::Regex::CharClassEnumerationElement::Range
=item RakuAST::Regex::InternalModifier::IgnoreCase
=item RakuAST::Regex::InternalModifier::IgnoreMark
=item RakuAST::Regex::InternalModifier::Ratchet
=item RakuAST::Regex::InternalModifier::Sigspace
=item RakuAST::Regex::Quantifier::BlockRange
=item RakuAST::Regex::Quantifier::OneOrMore
=item RakuAST::Regex::Quantifier::Range
=item RakuAST::Regex::Quantifier::ZeroOrMore
=item RakuAST::Regex::Quantifier::ZeroOrOne
=item RakuAST::Statement::Loop::RepeatUntil
=item RakuAST::Statement::Loop::RepeatWhile
=item RakuAST::Statement::Loop::Until
=item RakuAST::Statement::Loop::While
=item RakuAST::StatementModifier::Condition::Thunk
=item RakuAST::StatementModifier::For::Thunk
=item RakuAST::StatementPrefix::Phaser::Begin
=item RakuAST::StatementPrefix::Phaser::Block
=item RakuAST::StatementPrefix::Phaser::Check
=item RakuAST::StatementPrefix::Phaser::Close
=item RakuAST::StatementPrefix::Phaser::End
=item RakuAST::StatementPrefix::Phaser::Enter
=item RakuAST::StatementPrefix::Phaser::First
=item RakuAST::StatementPrefix::Phaser::Init
=item RakuAST::StatementPrefix::Phaser::Keep
=item RakuAST::StatementPrefix::Phaser::Last
=item RakuAST::StatementPrefix::Phaser::Leave
=item RakuAST::StatementPrefix::Phaser::Next
=item RakuAST::StatementPrefix::Phaser::Post
=item RakuAST::StatementPrefix::Phaser::Pre
=item RakuAST::StatementPrefix::Phaser::Quit
=item RakuAST::StatementPrefix::Phaser::Sinky
=item RakuAST::StatementPrefix::Phaser::Temp
=item RakuAST::StatementPrefix::Phaser::Undo
=item RakuAST::Var::Attribute::Public
=item RakuAST::Var::Compiler::Block
=item RakuAST::Var::Compiler::File
=item RakuAST::Var::Compiler::Line
=item RakuAST::Var::Compiler::Lookup
=item RakuAST::Var::Compiler::Routine
=item RakuAST::Var::Lexical::Constant
=item RakuAST::Var::Lexical::Setting
=item RakuAST::Regex::Assertion::Named::Args
=item RakuAST::Regex::Assertion::Named::RegexArg

my %groups is Map = (
	expression => [
		RakuAST::ApplyDottyInfix,
		RakuAST::ApplyInfix,
		RakuAST::ApplyListInfix,
		RakuAST::ApplyPostfix,
		RakuAST::ApplyPrefix,
		RakuAST::BracketedInfix,
		RakuAST::DottyInfixish,
		RakuAST::FunctionInfix,
		RakuAST::Infix,
		RakuAST::Infixish,
		RakuAST::MetaInfix,
		RakuAST::Prefixish,
		RakuAST::Postfixish
	],
	literal => [
		RakuAST::ComplexLiteral,
		RakuAST::IntLiteral,
		RakuAST::NumLiteral,
		RakuAST::StrLiteral,
		RakuAST::RatLiteral,
		RakuAST::VersionLiteral,
		RakuAST::Constant,
		RakuAST::Literal
	],
	statement => [
		RakuAST::Block,
		RakuAST::BlockStatementSensitive,
		RakuAST::BlockThunk,
		RakuAST::Blockoid,
		RakuAST::Statement,
		RakuAST::StatementList,
		RakuAST::StatementSequence,
		RakuAST::StatementModifier,
		RakuAST::StatementPrefix,
		RakuAST::Statement::Catch,
		RakuAST::Statement::Control,
		RakuAST::Statement::Default,
		RakuAST::Statement::Empty,
		RakuAST::Statement::ExceptionHandler,
		RakuAST::Statement::Expression,
		RakuAST::Statement::For,
		RakuAST::Statement::Given,
		RakuAST::Statement::If,
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Import,
		RakuAST::Statement::Loop,
		RakuAST::Statement::Need,
		RakuAST::Statement::Require,
		RakuAST::Statement::Unless,
		RakuAST::Statement::Use,
		RakuAST::Statement::When,
		RakuAST::Statement::Whenever,
		RakuAST::Statement::With,
		RakuAST::Statement::Without,
		RakuAST::StatementModifier::Condition,
		RakuAST::StatementModifier::For,
		RakuAST::StatementModifier::Given,
		RakuAST::StatementModifier::If,
		RakuAST::StatementModifier::Loop,
		RakuAST::StatementModifier::Unless,
		RakuAST::StatementModifier::Until,
		RakuAST::StatementModifier::When,
		RakuAST::StatementModifier::While,
		RakuAST::StatementModifier::With,
		RakuAST::StatementModifier::Without,
		RakuAST::Statement::Loop::RepeatUntil,
		RakuAST::Statement::Loop::RepeatWhile,
		RakuAST::Statement::Loop::Until,
		RakuAST::Statement::Loop::While,
		RakuAST::StatementModifier::Condition::Thunk,
		RakuAST::StatementModifier::For::Thunk
	],
	declaration => [
		RakuAST::Declaration,
		RakuAST::Declaration::External,
		RakuAST::Declaration::External::Constant,
		RakuAST::Declaration::External::Setting,
		RakuAST::Declaration::Import,
		RakuAST::Declaration::LexicalPackage,
		RakuAST::Declaration::ResolvedConstant,
		RakuAST::Var,
		RakuAST::NamedArg,
		RakuAST::Parameter,
		RakuAST::Signature,
		RakuAST::Class,
		RakuAST::Role,
		RakuAST::RoleBody,
		RakuAST::Module,
		RakuAST::Grammar,
		RakuAST::Package,
		RakuAST::Package::Attachable,
		RakuAST::Knowhow,
		RakuAST::Native,
		RakuAST::RegexDeclaration,
		RakuAST::RuleDeclaration,
		RakuAST::TokenDeclaration
	],
	control => [
		RakuAST::ForLoopImplementation,
		RakuAST::FlipFlop,
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
		RakuAST::Statement::With,
		RakuAST::Statement::When
	],
	phaser => [
		RakuAST::StatementPrefix::Phaser,
		RakuAST::StatementPrefix::Phaser::Begin,
		RakuAST::StatementPrefix::Phaser::Block,
		RakuAST::StatementPrefix::Phaser::Check,
		RakuAST::StatementPrefix::Phaser::Close,
		RakuAST::StatementPrefix::Phaser::End,
		RakuAST::StatementPrefix::Phaser::Enter,
		RakuAST::StatementPrefix::Phaser::First,
		RakuAST::StatementPrefix::Phaser::Init,
		RakuAST::StatementPrefix::Phaser::Keep,
		RakuAST::StatementPrefix::Phaser::Last,
		RakuAST::StatementPrefix::Phaser::Leave,
		RakuAST::StatementPrefix::Phaser::Next,
		RakuAST::StatementPrefix::Phaser::Post,
		RakuAST::StatementPrefix::Phaser::Pre,
		RakuAST::StatementPrefix::Phaser::Quit,
		RakuAST::StatementPrefix::Phaser::Sinky,
		RakuAST::StatementPrefix::Phaser::Temp,
		RakuAST::StatementPrefix::Phaser::Undo,
		RakuAST::BeginTime,
		RakuAST::CheckTime,
		RakuAST::ParseTime
	],
	regex => [
		RakuAST::Regex,
		RakuAST::RegexDeclaration,
		RakuAST::RegexThunk,
		RakuAST::QuotedRegex,
		RakuAST::QuotedMatchConstruct,
		RakuAST::QuotedString,
		RakuAST::Substitution,
		RakuAST::SubstitutionReplacementThunk,
		RakuAST::Regex::Alternation,
		RakuAST::Regex::Anchor,
		RakuAST::Regex::Anchor::BeginningOfLine,
		RakuAST::Regex::Anchor::BeginningOfString,
		RakuAST::Regex::Anchor::EndOfLine,
		RakuAST::Regex::Anchor::EndOfString,
		RakuAST::Regex::Anchor::LeftWordBoundary,
		RakuAST::Regex::Anchor::RightWordBoundary,
		RakuAST::Regex::Assertion,
		RakuAST::Regex::Assertion::Alias,
		RakuAST::Regex::Assertion::Callable,
		RakuAST::Regex::Assertion::CharClass,
		RakuAST::Regex::Assertion::Fail,
		RakuAST::Regex::Assertion::InterpolatedBlock,
		RakuAST::Regex::Assertion::InterpolatedVar,
		RakuAST::Regex::Assertion::Lookahead,
		RakuAST::Regex::Assertion::Named,
		RakuAST::Regex::Assertion::Named::Args,
		RakuAST::Regex::Assertion::Named::RegexArg,
		RakuAST::Regex::Assertion::Pass,
		RakuAST::Regex::Assertion::PredicateBlock,
		RakuAST::Regex::Assertion::Recurse,
		RakuAST::Regex::Atom,
		RakuAST::Regex::BackReference,
		RakuAST::Regex::BackReference::Named,
		RakuAST::Regex::BackReference::Positional,
		RakuAST::Regex::Backtrack,
		RakuAST::Regex::Backtrack::Frugal,
		RakuAST::Regex::Backtrack::Greedy,
		RakuAST::Regex::Backtrack::Ratchet,
		RakuAST::Regex::BacktrackModifiedAtom,
		RakuAST::Regex::Block,
		RakuAST::Regex::Branching,
		RakuAST::Regex::CapturingGroup,
		RakuAST::Regex::CharClass,
		RakuAST::Regex::CharClass::Any,
		RakuAST::Regex::CharClass::BackSpace,
		RakuAST::Regex::CharClass::CarriageReturn,
		RakuAST::Regex::CharClass::Digit,
		RakuAST::Regex::CharClass::Escape,
		RakuAST::Regex::CharClass::FormFeed,
		RakuAST::Regex::CharClass::HorizontalSpace,
		RakuAST::Regex::CharClass::Negatable,
		RakuAST::Regex::CharClass::Newline,
		RakuAST::Regex::CharClass::Nul,
		RakuAST::Regex::CharClass::Space,
		RakuAST::Regex::CharClass::Specified,
		RakuAST::Regex::CharClass::Tab,
		RakuAST::Regex::CharClass::VerticalSpace,
		RakuAST::Regex::CharClass::Word,
		RakuAST::Regex::CharClassElement,
		RakuAST::Regex::CharClassElement::Enumeration,
		RakuAST::Regex::CharClassElement::Property,
		RakuAST::Regex::CharClassElement::Rule,
		RakuAST::Regex::CharClassEnumerationElement,
		RakuAST::Regex::CharClassEnumerationElement::Character,
		RakuAST::Regex::CharClassEnumerationElement::Range,
		RakuAST::Regex::Conjunction,
		RakuAST::Regex::Group,
		RakuAST::Regex::InternalModifier,
		RakuAST::Regex::InternalModifier::IgnoreCase,
		RakuAST::Regex::InternalModifier::IgnoreMark,
		RakuAST::Regex::InternalModifier::Ratchet,
		RakuAST::Regex::InternalModifier::Sigspace,
		RakuAST::Regex::Interpolation,
		RakuAST::Regex::Literal,
		RakuAST::Regex::MatchFrom,
		RakuAST::Regex::MatchTo,
		RakuAST::Regex::NamedCapture,
		RakuAST::Regex::Nested,
		RakuAST::Regex::QuantifiedAtom,
		RakuAST::Regex::Quantifier,
		RakuAST::Regex::Quantifier::BlockRange,
		RakuAST::Regex::Quantifier::OneOrMore,
		RakuAST::Regex::Quantifier::Range,
		RakuAST::Regex::Quantifier::ZeroOrMore,
		RakuAST::Regex::Quantifier::ZeroOrOne,
		RakuAST::Regex::Quote,
		RakuAST::Regex::Sequence,
		RakuAST::Regex::SequentialAlternation,
		RakuAST::Regex::SequentialConjunction,
		RakuAST::Regex::Statement,
		RakuAST::Regex::Term,
		RakuAST::Regex::WithWhitespace
	],
	data => [
		RakuAST::CaptureSource,
		RakuAST::ArgList,
		RakuAST::ColonPair,
		RakuAST::ColonPair::False,
		RakuAST::ColonPair::Number,
		RakuAST::ColonPair::True,
		RakuAST::ColonPair::Value,
		RakuAST::ColonPair::Variable,
		RakuAST::ColonPairs,
		RakuAST::FatArrow,
		RakuAST::QuotePair,
		RakuAST::QuoteWordsAtom,
		RakuAST::SemiList,
		RakuAST::Circumfix,
		RakuAST::Circumfix::ArrayComposer,
		RakuAST::Circumfix::HashComposer,
		RakuAST::Circumfix::Parentheses,
		RakuAST::Postcircumfix,
		RakuAST::Postcircumfix::ArrayIndex,
		RakuAST::Postcircumfix::HashIndex,
		RakuAST::Postcircumfix::LiteralHashIndex
	],
	code => [
		RakuAST::Code,
		RakuAST::Routine,
		RakuAST::Method,
		RakuAST::Methodish,
		RakuAST::Sub,
		RakuAST::Submethod,
		RakuAST::PointyBlock,
		RakuAST::ExpressionThunk,
		RakuAST::ParameterDefaultThunk,
		RakuAST::Contextualizable,
		RakuAST::Contextualizer,
		RakuAST::Contextualizer::Hash,
		RakuAST::Contextualizer::Item,
		RakuAST::Contextualizer::List,
		RakuAST::LexicalScope,
		RakuAST::ImplicitBlockSemanticsProvider,
		RakuAST::ImplicitDeclarations,
		RakuAST::ImplicitLookups
	],
	type => [
		RakuAST::Type,
		RakuAST::Type::Capture,
		RakuAST::Type::Coercion,
		RakuAST::Type::Definedness,
		RakuAST::Type::Derived,
		RakuAST::Type::Enum,
		RakuAST::Type::Parameterized,
		RakuAST::Type::Setting,
		RakuAST::Type::Simple,
		RakuAST::Type::Subset,
		RakuAST::Trait,
		RakuAST::Trait::Does,
		RakuAST::Trait::Handles,
		RakuAST::Trait::Hides,
		RakuAST::Trait::Is,
		RakuAST::Trait::Of,
		RakuAST::Trait::Returns,
		RakuAST::Trait::Type,
		RakuAST::Trait::Will,
		RakuAST::Trait::WillBuild,
		RakuAST::Role::ResolveInstantiations,
		RakuAST::Role::TypeEnvVar
	],
	meta => [
		RakuAST::Meta,
		RakuAST::MetaInfix,
		RakuAST::CurryThunk,
		RakuAST::FakeSignature,
		RakuAST::PlaceholderParameterOwner
	],
	doc => [
		RakuAST::Doc,
		RakuAST::Doc::Block,
		RakuAST::Doc::Declarator,
		RakuAST::Doc::LegacyRow,
		RakuAST::Doc::Markup,
		RakuAST::Doc::Paragraph,
		RakuAST::Doc::Row,
		RakuAST::Pragma
	],
	special => [
		RakuAST::Blorst,
		RakuAST::Stub,
		RakuAST::Stub::Die,
		RakuAST::Stub::Fail,
		RakuAST::Stub::Warn,
		RakuAST::StubbyMeta,
		RakuAST::Term,
		RakuAST::Term::Capture,
		RakuAST::Term::EmptySet,
		RakuAST::Term::HyperWhatever,
		RakuAST::Term::Name,
		RakuAST::Term::Named,
		RakuAST::Term::RadixNumber,
		RakuAST::Term::Rand,
		RakuAST::Term::Reduce,
		RakuAST::Term::Self,
		RakuAST::Term::TopicCall,
		RakuAST::Term::Whatever,
		RakuAST::Termish,
		RakuAST::OnlyStar,
		RakuAST::ProducesNil,
		RakuAST::Ternary,
		RakuAST::Feed,
		RakuAST::Mixin,
		RakuAST::AttachTarget,
		RakuAST::Label,
		RakuAST::SinkBoundary,
		RakuAST::SinkPropagator,
		RakuAST::Sinkable
	],
	prefix => [
		RakuAST::StatementPrefix,
		RakuAST::StatementPrefix::Blorst,
		RakuAST::StatementPrefix::CallMethod,
		RakuAST::StatementPrefix::Do,
		RakuAST::StatementPrefix::Eager,
		RakuAST::StatementPrefix::Gather,
		RakuAST::StatementPrefix::Hyper,
		RakuAST::StatementPrefix::Lazy,
		RakuAST::StatementPrefix::Once,
		RakuAST::StatementPrefix::Quietly,
		RakuAST::StatementPrefix::Race,
		RakuAST::StatementPrefix::React,
		RakuAST::StatementPrefix::Sink,
		RakuAST::StatementPrefix::Start,
		RakuAST::StatementPrefix::Supply,
		RakuAST::StatementPrefix::Thunky,
		RakuAST::StatementPrefix::Try,
		RakuAST::StatementPrefix::Wheneverable,
		RakuAST::Prefix,
		RakuAST::Prefixish
	],
	postfix => [
		RakuAST::Postfix,
		RakuAST::Postfix::Literal,
		RakuAST::Postfix::Power,
		RakuAST::Postfix::Vulgar,
		RakuAST::Postfixish
	],
	var => [
		RakuAST::Var,
		RakuAST::Var::Attribute,
		RakuAST::Var::Attribute::Public,
		RakuAST::Var::Compiler,
		RakuAST::Var::Compiler::Block,
		RakuAST::Var::Compiler::File,
		RakuAST::Var::Compiler::Line,
		RakuAST::Var::Compiler::Lookup,
		RakuAST::Var::Compiler::Routine,
		RakuAST::Var::Doc,
		RakuAST::Var::Dynamic,
		RakuAST::Var::Lexical,
		RakuAST::Var::Lexical::Constant,
		RakuAST::Var::Lexical::Setting,
		RakuAST::Var::NamedCapture,
		RakuAST::Var::Package,
		RakuAST::Var::PositionalCapture,
		RakuAST::Var::Slang
	],
	parameter => [
		RakuAST::Parameter,
		RakuAST::ParameterDefaultThunk,
		RakuAST::ParameterTarget,
		RakuAST::ParameterTarget::Term,
		RakuAST::ParameterTarget::Var,
		RakuAST::ParameterTarget::Whatever
	],
	initializer => [
		RakuAST::Initializer,
		RakuAST::Initializer::Assign,
		RakuAST::Initializer::Bind,
		RakuAST::Initializer::CallAssign,
		RakuAST::Initializer::Expression,
		RakuAST::Assignment
	],
	metainfix => [
		RakuAST::MetaInfix,
		RakuAST::MetaInfix::Assign,
		RakuAST::MetaInfix::Cross,
		RakuAST::MetaInfix::Hyper,
		RakuAST::MetaInfix::Negate,
		RakuAST::MetaInfix::Reverse,
		RakuAST::MetaInfix::Sequence,
		RakuAST::MetaInfix::Zip
	],
	compile => [
		RakuAST::CompUnit,
		RakuAST::CompileTimeValue,
		RakuAST::Lookup,
		RakuAST::Name,
		RakuAST::Heredoc,
		RakuAST::Heredoc::InterpolatedWhiteSpace,
		RakuAST::Nqp,
		RakuAST::Nqp::Const
	],
	core => [
		RakuAST::Node,
		RakuAST::Expression
	],

	# Convenience groups for easier querying
	call       => [RakuAST::Call],
	int         => [RakuAST::IntLiteral],
	str         => [RakuAST::StrLiteral],
	op          => [
		RakuAST::Infixish,
		RakuAST::Prefixish,
		RakuAST::Postfixish,
	],
	apply-op    => [
		RakuAST::ApplyInfix,
		RakuAST::ApplyListInfix,
		RakuAST::ApplyDottyInfix,
		RakuAST::ApplyPostfix,
		RakuAST::ApplyPrefix,
		RakuAST::Ternary,
	],
	conditional => [
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
		RakuAST::Statement::Without,
		RakuAST::Statement::If,
		RakuAST::Statement::When,
		RakuAST::Statement::With,
	],
	iterable => [
		RakuAST::Statement::Loop,
		RakuAST::Statement::For,
		RakuAST::Statement::Whenever,
		RakuAST::ForLoopImplementation,
	],
	ignorable => [
		RakuAST::Block,
		RakuAST::Blockoid,
		RakuAST::StatementList,
		RakuAST::Statement::Expression,
		RakuAST::ArgList,
	],
	# Remove duplicated group definitions that are now covered by comprehensive groups above
);

my %id is Map = (
	"RakuAST::Call"                   => "name",
	"RakuAST::Statement::Expression"  => "expression",
	"RakuAST::Statement::IfWith"      => "condition",
	"RakuAST::Statement::Unless"      => "condition",
	"RakuAST::Statement::If"          => "condition",
	"RakuAST::Statement::When"        => "condition",
	"RakuAST::Statement::With"        => "condition",
	"RakuAST::Statement::Without"     => "condition",
	"RakuAST::Statement::Given"       => "topic",
	"RakuAST::Statement::For"         => "source",
	"RakuAST::Statement::Loop"        => "condition",
	"RakuAST::Statement::Loop::While" => "condition",
	"RakuAST::Statement::Loop::Until" => "condition",
	"RakuAST::Statement::Loop::RepeatWhile" => "condition",
	"RakuAST::Statement::Loop::RepeatUntil" => "condition",
	"RakuAST::Literal"                => "value",
	"RakuAST::IntLiteral"             => "value",
	"RakuAST::NumLiteral"             => "value",
	"RakuAST::StrLiteral"             => "value",
	"RakuAST::RatLiteral"             => "value",
	"RakuAST::ComplexLiteral"         => "value",
	"RakuAST::VersionLiteral"         => "value",
	"RakuAST::Name"                   => "simple-identifier",
	"RakuAST::Term::Name"             => "name",
	"RakuAST::ApplyInfix"             => "infix",
	"RakuAST::ApplyListInfix"         => "infix",
	"RakuAST::ApplyDottyInfix"        => "infix",
	"RakuAST::ApplyPostfix"           => "postfix",
	"RakuAST::ApplyPrefix"            => "prefix",
	"RakuAST::Infixish"               => "infix",
	"RakuAST::Infix"                  => "operator",
	"RakuAST::Prefix"                 => "operator",
	"RakuAST::Postfix"                => "operator",
	"RakuAST::FunctionInfix"          => "function",
	"RakuAST::ArgList"                => "args",
	"RakuAST::Var"                    => "name",
	"RakuAST::Var::Lexical"           => "desigilname",
	"RakuAST::Var::Package"           => "desigilname",
	"RakuAST::Var::Dynamic"           => "desigilname",
	"RakuAST::Var::Attribute"         => "name",
	"RakuAST::VarDeclaration"         => "name",
	"RakuAST::Method"                 => "name",
	"RakuAST::Sub"                    => "name",
	"RakuAST::Submethod"              => "name",
	"RakuAST::Routine"                => "name",
	"RakuAST::Class"                  => "name",
	"RakuAST::Role"                   => "name",
	"RakuAST::Module"                 => "name",
	"RakuAST::Grammar"                => "name",
	"RakuAST::Package"                => "name",
	"RakuAST::Parameter"              => "target",
	"RakuAST::Trait"                  => "type",
	"RakuAST::Trait::Does"            => "type",
	"RakuAST::Trait::Is"              => "type",
	"RakuAST::Trait::Of"              => "type",
	"RakuAST::Trait::Returns"         => "type",
	"RakuAST::RegexDeclaration"       => "name",
	"RakuAST::RuleDeclaration"        => "name",
	"RakuAST::TokenDeclaration"       => "name",
	"RakuAST::Label"                  => "name",
	"RakuAST::ColonPair"              => "key",
	"RakuAST::ColonPair::Value"       => "key",
	"RakuAST::ColonPair::Variable"    => "key",
	"RakuAST::FatArrow"               => "key",
	"RakuAST::NamedArg"               => "name",
	"RakuAST::Regex::NamedCapture"    => "name",
	"RakuAST::Regex::Literal"         => "text",
	"RakuAST::QuotedString"           => "literal",
	"RakuAST::Ternary"                => "condition",
);

method get-id-field($node) {
	for $node.^mro {
		.return with %id{.^name}
	}
}

subset ASTClass of Str will complain {"$_ is not a valid class"} where { !.defined || ::(.Str) !~~ Failure }
subset ASTGroup of Str will complain {"$_ is not a valid group"} where { !.defined || %groups{.Str} }

multi method add-ast-group(Str $name, ASTClass() @classes) {
	self.add-ast-group: $name, @=@classes.map: { ::($_) }
}

multi method add-ast-group(Str $name, @classes) {
	%groups := {%groups, $name => @classes}.Map
}

multi method set-ast-id(ASTClass:D $class, Str $id where {::($class).^can($_) || fail "$class has no method $id"}) {
	%id := { %id, $class => $id }.Map
}

multi method set-ast-id(Mu:U $class, Str $id) {
	self.set-ast-id: $class.^name, $id
}

multi method add-to-ast-group(ASTGroup $name, *@classes) {
	my @new-classes = @classes.duckmap: -> ASTClass:D $class { ::($class) };
	@new-classes.unshift: |%groups{$name};
	self.add-ast-group: $name, @new-classes
}

has ASTClass() @.classes;
has ASTGroup() @.groups;
has @.ids;
has %.atts;
has %.params;
has $.child is rw;
has $.gchild is rw;
has $.parent is rw;
has $.gparent is rw;
has $.descendant is rw;
has $.ascendant is rw;
has Str $.name;
has Callable() @.code;

multi method gist(::?CLASS:D: :$inside = False) {
	"{
		self.^name ~ ".new(" unless $inside
	}{
		(.Str for @!classes).join: ""
	}{
		('.' ~ .Str for @!groups).join: ""
	}{
		('#' ~ .Str for @!ids).join: ""
	}{
		"[" ~ %!atts.kv.map(-> $k, $v { $k ~ ( $v =:= Whatever ?? "" !! "=$v.gist()" ) }).join(', ') ~ ']' if %!atts
	}{
		("\{{$_}}" for @!code).join: ""
	}{
		'$' ~ .Str with $!name
	}{
		" > " ~ .gist(:inside) with $!child
	}{
		" >> " ~ .gist(:inside) with $!gchild
	}{
		" >>> " ~ .gist(:inside) with $!descendant
	}{
		" < " ~ .gist(:inside) with $!parent
	}{
		" << " ~ .gist(:inside) with $!gparent
	}{
		" <<< " ~ .gist(:inside) with $!ascendant
	}{
		")" unless $inside
	}"
}

multi add(ASTQuery::Match $base, $matcher, $node, ASTQuery::Match $match where *.so) {
	$base.list.push: |$match.list;
	for $match.hash.kv -> $key, $value {
		$base.hash.push: $key => $value
	}
	$match
}
multi add($, $, $, $ret) { $ret }

my $indent = 0;

sub prepare-type($value) {
	my $name = $value.^name;
	$name.subst: /(\w)\w+'::'/, {"$0::"}, :g
}

multi prepare-bool(Bool() $result where *.so) {
	"\o33[32;1mTrue\o33[m"
}

multi prepare-bool(Bool() $result where	*.not) {
	"\o33[31;1mFalse\o33[m"
}

multi prepare-bool(Mu) {"???"}

sub prepare-node($node) {
	"\o33[33;1m{ $node.&prepare-type }\o33[m"
}

my @current-caller;
sub prepare-caller(Bool() :$result) {
	"{
		!$result.defined
			?? "\o33[1m"
			!! $result
				?? "\o33[32;1m"
				!! "\o33[31;1m"
	}{
		do if callframe(4).code.name -> $name {
			@current-caller.push: $name;
			"{$name}({callframe(6).code.signature.params.grep(!*.named).skip>>.gist.join: ", "})"
		} else {
			@current-caller.pop
		}
	}\o33[m"
}

sub prepare-indent($indent, :$end) {
	"\o33[1;30m{
		$indent == 0
			?? ""
			!! join "", "│  " x $indent - 1, $end ?? "└─ " !! "├─ "
	}\o33[m"
}

sub deparse-and-format($node) {
	CATCH {
		default {
			return "\o33[31;1m{$node.^name} cannot be deparsed: $_\o33[m"
		}
	}

	my $code = $node.DEPARSE(ASTQuery::HighLighter);
	my $txt = $code.trans(["\n", "\t"] => ["␤", "␉"])
		.subst(/\s+/, " ", :g)
	;

	$txt.chars > 72
		?? $txt.substr(0, 72) ~ "\o33[30;1m...\o33[m"
		!! $txt
}

multi prepare-code(RakuAST::Node $node) {
	"\o33[1m{$node.&deparse-and-format}\o33[m"
}

multi prepare-code($node) {
	"\o33[31;1m(NOT RakuAST)\o33[m \o33[1m{
		$node
			.trans(["\n", "\t"] => ["␤", "␉"])
	}\o33[m"
}

sub print-validator-begin($node, $value) {
	return unless $DEBUG;
	note $indent.&prepare-indent, $node.&prepare-code, " (", $node.&prepare-node, ") - ", prepare-caller, ": ", $value;
	$indent++;
}

multi print-validator-end($, Mu, Mu $result) {
	True
}

multi print-validator-end($node, $value, $result) {
	return True unless $DEBUG;
	note $indent.&prepare-indent(:end), prepare-caller(:result($result)), " ({ $result.&prepare-bool })";
	$indent--;
	True
}

method ACCEPTS($node) {
	print-validator-begin $node, self.gist;
	POST print-validator-end $node, self.gist, $_;
	my $match = ASTQuery::Match.new: :ast($node), :matcher(self);
	{
		my UInt $count = 0;
		my $ans = [
			True,
			{:attr<classes>,    :validator<validate-class>     },
			{:attr<groups>,     :validator<validate-groups>    },
			{:attr<ids>,        :validator<validate-ids>       },
			{:attr<atts>,       :validator<validate-atts>      },
			{:attr<code>,       :validator<validate-code>      },
			{:attr<child>,      :validator<validate-child>     },
			{:attr<descendant>, :validator<validate-descendant>},
			{:attr<gchild>,     :validator<validate-gchild>    },
			{:attr<parent>,     :validator<validate-parent>    },
			{:attr<ascendant>,  :validator<validate-ascendant> },
		].reduce: sub (Bool() $ans, % (Str :$attr, Str :$validator)) {
			return False unless $ans;
			return True  unless self."$attr"();
			++$count;
			my $validated = self."$validator"($node, self."$attr"());
			$match.&add: self, $node, $validated;
		}
		return False unless $ans;
		#$match.hash.push: $!name => $node if $!name;
		#say $node.^name, " - ", $match.list if $DEBUG;
	}
	$match
}

multi method validate-code($node, @code) {
	print-validator-begin $node, @code;
	POST print-validator-end $node, @code, $_;
	([&&] do for @code -> &code {
		self.validate-code: $node, &code;
	}) ?? ASTQuery::Match.new: :list[$node] !! False
}

multi method validate-code($node, &code) {
	print-validator-begin $node, &code;
	POST print-validator-end $node, &code, $_;
	code($node) ?? ASTQuery::Match.new: :list[$node] !! False
}

method validate-ascendant($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	ASTQuery::Match.merge-or: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only;
	}
}

method validate-gparent($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	my @ignorables = %groups<ignorable><>;
	ASTQuery::Match.merge-or: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only || $ascendant ~~ @ignorables.any || last
	}
}

method validate-parent($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	ASTQuery::Match.new(:ast(@*LINEAGE.head), :matcher($parent))
		.query-root-only || False
}

method validate-descendant($node, $child) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-descendants-only || False
}

method validate-gchild($node, $gchild) {
	print-validator-begin $node, $gchild;
	POST print-validator-end $node, $gchild, $_;
	my $gchild-result = self.validate-child($node, $gchild);
	return $gchild-result if $gchild-result;

	my @list = self.query-child($node, ::?CLASS.new: :groups<ignorable>).list;
	ASTQuery::Match.merge-or: |do for @list -> $node {
		self.validate-gchild: $node, $gchild
	}
}

method query-child($node, $child, *%pars) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-children-only;
}

method validate-child($node, $child) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	self.query-child($node, $child) || False
}

multi method validate-groups($node, @groups) {
	print-validator-begin $node, @groups;
	POST print-validator-end $node, @groups, $_;
	self.validate-class: $node, %groups{@groups}.flat.unique
}

multi method validate-groups($node, $group) {
	print-validator-begin $node, $group;
	POST print-validator-end $node, $group, $_;
	self.validate-groups: $node, [$group,]
}

multi method validate-class($node, Str $class) {
	print-validator-begin $node, $class;
	POST print-validator-end $node, $class, $_;
	self.validate-class: $node, ::($class)
}

multi method validate-class($node, Mu:U $class) {
	print-validator-begin $node, $class;
	POST print-validator-end $node, $class, $_;
	do if $node ~~ $class {
		ASTQuery::Match.new: :list[$node]
	} else {
		False
	}
}

multi method validate-class($node, @classes) {
	print-validator-begin $node, @classes;
	POST print-validator-end $node, @classes, $_;
	my %done := :{};
	@classes.flatmap(-> $class {
		next if %done{$class}++;
		self.validate-class: $node, $class
	}).first(*.so) // False
}

multi method validate-ids($node, @ids) {
	print-validator-begin $node, @ids;
	POST print-validator-end $node, @ids, $_;
	my $key = self.get-id-field: $node;
	return False unless $key;
	@ids.unique.map(-> $id {
		self.validate-atts: $node, %($key => $id)
	}).first(*.so) // False
}

multi method validate-ids($node, $id) {
	print-validator-begin $node, $id;
	POST print-validator-end $node, $id, $_;
	self.validate-ids: $node, [$id,]
}

method validate-atts($node, %atts) {
	print-validator-begin $node, %atts;
	POST print-validator-end $node, %atts, $_;
	return ASTQuery::Match.new: :list[$node,]
		if ASTQuery::Match.merge-and: |%atts.kv.map: -> $key, $value is copy {
			$value = $value.($node) if $value ~~ Callable;
			self.validate-value: $node, $key, $value;
		}
	;
	False
}

multi method validate-value($node, $key, $ where * =:= False) {
	print-validator-begin $node, True;
	POST print-validator-end $node, True, $_;
	False
}

multi method validate-value($node, $key, $ where * =:= True) {
	print-validator-begin $node, True;
	POST print-validator-end $node, True, $_;
	ASTQuery::Match.new: :list[$node,]
}

multi method validate-value($node, $key, $value) {
	print-validator-begin $node, $value;
	POST print-validator-end $node, $value, $_;
	do if $node.^name.starts-with("RakuAST") && $value !~~ ::?CLASS {
		return False unless $key;
		return False unless $node.^can: $key; # it can be a problem if $key is 'none', for example
		my Any $nnode = $node."$key"();
		self.validate-value($nnode, $.get-id-field($nnode), $value)
	} else { 
		$value.ACCEPTS($node) && ASTQuery::Match.new(:list[$node,])
	} || False
}
