use experimental :rakuast, :will-complain;
use ASTQuery::Match;
use ASTQuery::HighLighter;
unit class ASTQuery::Matcher;

class ASTQuery::Matcher::AttrRel { has Str $.rel; has $.matcher; }
class ASTQuery::Matcher::AttrOp  { has Str $.op;  has $.value;    }

# Registry for user-defined functions (&function)
my %functions is Map = %();


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
=item RakuAST::Regex::Backtrack::Frugal
=item RakuAST::Regex::Backtrack::Greedy
=item RakuAST::Regex::Backtrack::Ratchet
=item RakuAST::Regex::BacktrackModifiedAtom
=item RakuAST::Regex::Block
=item RakuAST::Regex::Branching
=item RakuAST::Regex::CapturingGroup
=item RakuAST::Regex::CharClass
=item RakuAST::Regex::CharClassElement
=item RakuAST::Regex::CharClassElement::Enumeration
=item RakuAST::Regex::CharClassElement::Property
=item RakuAST::Regex::CharClassElement::Rule
=item RakuAST::Regex::CharClassEnumerationElement::Character
=item RakuAST::Regex::CharClassEnumerationElement::Range
=item RakuAST::Regex::InternalModifier::IgnoreCase
=item RakuAST::Regex::InternalModifier::IgnoreMark
=item RakuAST::Regex::InternalModifier::Ratchet
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
		RakuAST::Prefix,
		RakuAST::Postfix,
		RakuAST::Infixish,
		RakuAST::MetaInfix,
		RakuAST::MetaInfix::Assign,
		RakuAST::MetaInfix::Cross,
		RakuAST::MetaInfix::Hyper,
		RakuAST::MetaInfix::Negate,
		RakuAST::MetaInfix::Reverse,
		RakuAST::MetaInfix::Sequence,
		RakuAST::MetaInfix::Zip,
		RakuAST::Prefixish,
		RakuAST::Postfixish,
		RakuAST::Expression,
		RakuAST::ExpressionThunk,
		RakuAST::FatArrow,
		RakuAST::Feed,
		RakuAST::Postfix::Literal,
		RakuAST::Postfix::Power,
		RakuAST::Postfix::Vulgar,
		RakuAST::Ternary,
		RakuAST::Mixin,
	],
	literal => [
		RakuAST::ComplexLiteral,
		RakuAST::IntLiteral,
		RakuAST::NumLiteral,
		RakuAST::StrLiteral,
		RakuAST::RatLiteral,
		RakuAST::VersionLiteral,
		RakuAST::Constant,
		RakuAST::Literal,
		RakuAST::Heredoc,
		RakuAST::Heredoc::InterpolatedWhiteSpace,
		RakuAST::QuotedString,
		RakuAST::QuoteWordsAtom,
	],
	statement => [
		RakuAST::Block,
		RakuAST::BlockStatementSensitive,
		RakuAST::BlockThunk,
		RakuAST::Blockoid,
		RakuAST::PointyBlock,
		RakuAST::Statement,
		RakuAST::StatementList,
		RakuAST::StatementSequence,
		RakuAST::StatementModifier,
		RakuAST::StatementModifier::Condition::Thunk,
		RakuAST::StatementModifier::For::Thunk,
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
		RakuAST::StatementModifier::Given,
		RakuAST::StatementModifier::If,
		RakuAST::StatementModifier::Loop,
		RakuAST::StatementModifier::Unless,
		RakuAST::StatementModifier::Until,
		RakuAST::StatementModifier::When,
		RakuAST::StatementModifier::While,
		RakuAST::StatementModifier::With,
		RakuAST::StatementModifier::Without,
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
	],
	declaration => [
		RakuAST::Declaration,
		RakuAST::Declaration::External,
		RakuAST::Declaration::Import,
		RakuAST::Declaration::LexicalPackage,
		RakuAST::Declaration::ResolvedConstant,
		RakuAST::Declaration::External::Constant,
		RakuAST::Declaration::External::Setting,
		RakuAST::Var,
		RakuAST::NamedArg,
		RakuAST::Parameter,
		RakuAST::ParameterDefaultThunk,
		RakuAST::ParameterTarget,
		RakuAST::ParameterTarget::Term,
		RakuAST::ParameterTarget::Var,
		RakuAST::ParameterTarget::Whatever,
		RakuAST::Signature,
		RakuAST::Class,
		RakuAST::Role,
		RakuAST::RoleBody,
		RakuAST::Role::ResolveInstantiations,
		RakuAST::Role::TypeEnvVar,
		RakuAST::Module,
		RakuAST::Package,
		RakuAST::Package::Attachable,
		RakuAST::Grammar,
		RakuAST::AttachTarget,
	],
	control => [
		RakuAST::ForLoopImplementation,
		RakuAST::FlipFlop,
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
		RakuAST::Statement::With,
		RakuAST::Statement::When,
		RakuAST::Statement::Given,
		RakuAST::Statement::Whenever,
		RakuAST::StatementModifier::Condition,
		RakuAST::StatementModifier::For,
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
		RakuAST::ParseTime,
	],
	regex => [
		RakuAST::Regex,
		RakuAST::RegexDeclaration,
		RakuAST::RegexThunk,
		RakuAST::QuotedRegex,
		RakuAST::QuotedMatchConstruct,
		RakuAST::QuotedString,
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
		RakuAST::Regex::WithWhitespace,
		RakuAST::RuleDeclaration,
		RakuAST::TokenDeclaration,
	],
	data => [
		RakuAST::CaptureSource,
		RakuAST::ArgList,
		RakuAST::Name,
		RakuAST::Label,
		RakuAST::Lookup,
		RakuAST::ColonPair,
		RakuAST::ColonPair::False,
		RakuAST::ColonPair::Number,
		RakuAST::ColonPair::True,
		RakuAST::ColonPair::Value,
		RakuAST::ColonPair::Variable,
		RakuAST::ColonPairs,
		RakuAST::QuotePair,
		RakuAST::QuoteWordsAtom,
		RakuAST::SemiList,
		RakuAST::Postcircumfix,
		RakuAST::Postcircumfix::ArrayIndex,
		RakuAST::Postcircumfix::HashIndex,
		RakuAST::Postcircumfix::LiteralHashIndex,
		RakuAST::Circumfix,
		RakuAST::Circumfix::ArrayComposer,
		RakuAST::Circumfix::HashComposer,
		RakuAST::Circumfix::Parentheses,
		RakuAST::OnlyStar,
	],
	code => [
		RakuAST::CompUnit,
		RakuAST::Code,
		RakuAST::Routine,
		RakuAST::Method,
		RakuAST::Methodish,
		RakuAST::Sub,
		RakuAST::Submethod,
		RakuAST::Contextualizable,
		RakuAST::Contextualizer,
		RakuAST::Contextualizer::Hash,
		RakuAST::Contextualizer::Item,
		RakuAST::Contextualizer::List,
		RakuAST::ImplicitBlockSemanticsProvider,
		RakuAST::ImplicitDeclarations,
		RakuAST::ImplicitLookups,
		RakuAST::LexicalScope,
		RakuAST::AttachTarget,
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
		RakuAST::Native,
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
	],
	meta => [
		RakuAST::Meta,
		RakuAST::MetaInfix,
		RakuAST::CurryThunk,
		RakuAST::FakeSignature,
		RakuAST::PlaceholderParameterOwner,
		RakuAST::Knowhow,
		RakuAST::Nqp,
		RakuAST::Nqp::Const,
		RakuAST::CompileTimeValue,
		RakuAST::StubbyMeta,
	],
	doc => [
		RakuAST::Doc,
		RakuAST::Doc::Block,
		RakuAST::Doc::Declarator,
		RakuAST::Doc::LegacyRow,
		RakuAST::Doc::Markup,
		RakuAST::Doc::Paragraph,
		RakuAST::Doc::Row,
		RakuAST::Pragma,
		RakuAST::Substitution,
		RakuAST::SubstitutionReplacementThunk,
	],
	special => [
		RakuAST::Blorst,
		RakuAST::Stub,
		RakuAST::Stub::Die,
		RakuAST::Stub::Fail,
		RakuAST::Stub::Warn,
		RakuAST::Term,
		RakuAST::Termish,
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
		RakuAST::OnlyStar,
		RakuAST::ProducesNil,
		RakuAST::SinkBoundary,
		RakuAST::SinkPropagator,
		RakuAST::Sinkable,
	],

	call       => [RakuAST::Call],
	expression => [RakuAST::Statement::Expression],
	statement   => [RakuAST::Statement],
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
		#RakuAST::ApplyDottyInfix,
		RakuAST::ApplyPostfix,
		RakuAST::Ternary,
	],
	conditional => [
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
		RakuAST::Statement::Without,
	],
	iterable => [
		RakuAST::Statement::Loop,
		RakuAST::Statement::Loop::RepeatUntil,
		RakuAST::Statement::Loop::RepeatWhile,
		RakuAST::Statement::Loop::Until,
		RakuAST::Statement::Loop::While,
		RakuAST::Statement::For,
		RakuAST::Statement::Whenever,
	],
	ignorable => [
		RakuAST::Block,
		RakuAST::Blockoid,
		RakuAST::StatementList,
		RakuAST::Statement::Expression,
		RakuAST::ArgList,
	],
	node => [
		RakuAST::Node,
	],
	var => [
		RakuAST::VarDeclaration,
		RakuAST::Var,
		RakuAST::Var::Attribute,
		RakuAST::Var::Compiler,
		RakuAST::Var::Doc,
		RakuAST::Var::Dynamic,
		RakuAST::Var::Lexical,
		RakuAST::Var::NamedCapture,
		RakuAST::Var::Package,
		RakuAST::Var::PositionalCapture,
		RakuAST::Var::Slang,
		RakuAST::Var::Attribute::Public,
		RakuAST::Var::Compiler::Block,
		RakuAST::Var::Compiler::File,
		RakuAST::Var::Compiler::Line,
		RakuAST::Var::Compiler::Lookup,
		RakuAST::Var::Compiler::Routine,
		RakuAST::Var::Lexical::Constant,
		RakuAST::Var::Lexical::Setting,
	],
	var-usage => [
		RakuAST::Var,
	],
	var-declaration => [
		#RakuAST::VarDeclaration,
		RakuAST::VarDeclaration::Simple,
	],
	method-declaration => [
		RakuAST::Method
	],
	# --- ergonomic aliases and new groups ---
	operator => [
		RakuAST::Infixish,
		RakuAST::Prefixish,
		RakuAST::Postfixish,
	],
	apply-operator => [
		RakuAST::ApplyInfix,
		RakuAST::ApplyListInfix,
		RakuAST::ApplyPostfix,
		RakuAST::Ternary,
	],
	variable => [
		RakuAST::Var,
		RakuAST::VarDeclaration,
		RakuAST::VarDeclaration::Simple,
	],
	variable-usage => [
		RakuAST::Var,
	],
	variable-declaration => [
		RakuAST::VarDeclaration::Simple,
		RakuAST::VarDeclaration,
	],
	assignment => [
		RakuAST::Assignment,
		RakuAST::Initializer,
		RakuAST::Initializer::Assign,
		RakuAST::Initializer::Bind,
		RakuAST::Initializer::CallAssign,
		RakuAST::Initializer::Expression,
	],
);

my %id is Map = (
		# Calls and expressions
		"RakuAST::Call"                   => "name",
		"RakuAST::Statement::Expression"  => "expression",

		# Control statements
		"RakuAST::Statement::IfWith"      => "condition",
		"RakuAST::Statement::If"          => "condition",
		"RakuAST::Statement::Unless"      => "condition",
		"RakuAST::Statement::With"        => "condition",
		"RakuAST::Statement::Without"     => "condition",
		"RakuAST::Statement::When"        => "condition",
		"RakuAST::Statement::For"         => "source",
		"RakuAST::Statement::Loop"        => "condition",

		# Literals and names
		"RakuAST::Literal"                => "value",
		"RakuAST::Name"                   => "simple-identifier",
		"RakuAST::Term::Name"             => "name",

		# Operators and applications
		"RakuAST::Infix"                  => "operator",
		"RakuAST::Prefix"                 => "operator",
		"RakuAST::Postfix"                => "operator",
		"RakuAST::Infixish"               => "infix",
		"RakuAST::ApplyInfix"             => "infix",
		"RakuAST::ApplyListInfix"         => "infix",
		"RakuAST::ApplyDottyInfix"        => "infix",
		"RakuAST::ApplyPostfix"           => "postfix",
		"RakuAST::ApplyPrefix"            => "prefix",
		"RakuAST::FunctionInfix"          => "function",

		# Arguments
		"RakuAST::ArgList"                => "args",

		# Variables and declarations
		"RakuAST::Var::Lexical"           => "desigilname",
		"RakuAST::Var::Attribute"         => "name",
		"RakuAST::Var::Package"           => "name",
		"RakuAST::Var::Doc"               => "name",
		"RakuAST::Var::Dynamic"           => "name",
		"RakuAST::VarDeclaration"         => "name",
		"RakuAST::VarDeclaration::Simple" => "name",

		# Assignment
		"RakuAST::Assignment"             => "operator",

		# Declarations / routines / packages
		"RakuAST::Class"                  => "name",
		"RakuAST::Role"                   => "name",
		"RakuAST::Module"                 => "name",
		"RakuAST::Package"                => "name",
		"RakuAST::Grammar"                => "name",
		"RakuAST::Method"                 => "name",
		"RakuAST::Sub"                    => "name",
		"RakuAST::Submethod"              => "name",
		"RakuAST::Routine"                => "name",

		# Regex-related
		"RakuAST::RegexDeclaration"       => "name",
		"RakuAST::RuleDeclaration"        => "name",
		"RakuAST::TokenDeclaration"       => "name",
		"RakuAST::Regex::NamedCapture"    => "name",

		# Pairs
		"RakuAST::ColonPair"              => "key",
		"RakuAST::FatArrow"               => "key",

		# Misc
		"RakuAST::Label"                  => "name",
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

# Register a function by name; accepts either a matcher or a Callable
multi method add-function(Str $name, ::?CLASS:D $matcher) {
	%functions := { %functions, self!normalize-fname($name) => -> $node { ASTQuery::Match.new(:ast($node), :matcher($matcher)).query-root-only.so } }.Map
}

multi method add-function(Str $name, Callable $fn) {
	%functions := { %functions, self!normalize-fname($name) => $fn }.Map
}

method !normalize-fname(Str $name) { $name.subst(/^'&'/, '', :g(False)) }

method !get-function(Str $name) { %functions{ self!normalize-fname($name) } }

has ASTClass() @.classes;
has ASTGroup() @.groups;
has @.ids;
has @.functions;
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
		('&' ~ .Str for @!functions).join: ""
	}{
		('#' ~ .Str for @!ids).join: ""
	}{
		"[" ~ %!atts.kv.map(-> $k, $v { $k ~ ( $v =:= Whatever ?? "" !! "=$v.gist()" ) }).join(', ') ~ ']' if %!atts
	}{
		(quietly "\{{$_}}" for @!code).join: ""
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
sub prepare-caller(Mu :$result) {
	"{
		!$result.defined
			?? "\o33[1m"
			!! $result
				?? "\o33[32;1m"
				!! "\o33[31;1m"
		}
	}{
		do if callframe(4).code.name -> $name {
			@current-caller.push: $name;
			"{$name}({callframe(6).code.signature.params.grep(!*.named).skip>>.gist.join: ", "})"
		} else {
			@current-caller.pop if @current-caller
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
	return unless %*ENV<ASTQUERY_DEBUG>;
	note $indent.&prepare-indent, $node.&prepare-code, " (", $node.&prepare-node, ") - ", prepare-caller, ": ", $value;
	$indent++;
}

sub print-validator-end(|c) {
	return True unless %*ENV<ASTQUERY_DEBUG>;
	my ($node, $value, $result) = c.list;
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
			{:attr<functions>,  :validator<validate-functions> },
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
		#say $node.^name, " - ", $match.list if $*DEBUG;
	}
	$match
}

# --- functions (&function) ---

multi method validate-functions($node, @funcs) {
	print-validator-begin $node, @funcs;
	POST print-validator-end $node, @funcs, $_;
	([&&] do for @funcs.unique -> $fname { self.validate-function($node, $fname) })
		?? ASTQuery::Match.new: :list[$node]
		!! False
}

method validate-function($node, Str $fname) {
	my $impl = self!get-function($fname) // return False;
	note "func=$fname type=", $impl.^name, " WHAT=", $impl.WHAT.perl if %*ENV<ASTQUERY_DEBUG>;
	$impl($node) ?? ASTQuery::Match.new(:list[$node]) !! False
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
			my $value = $id;
			if $key eq 'name'
			&& $node.^name.starts-with('RakuAST::VarDeclaration')
			&& $id ~~ Str
			&& $id !~~ /^<[\$@%&]>/ {
				$value = -> $n { $n.^can('name') && $n.name ~~ Str && $n.name.subst(/^<[\$@%&]>/, '') eq $id };
			}
			self.validate-atts: $node, %($key => $value)
		}).first(*.so) // False
	}


multi method validate-ids($node, $id) {
	print-validator-begin $node, $id;
	POST print-validator-end $node, $id, $_;
	self.validate-ids: $node, [$id,]
}

method validate-atts($node, %atts) {
	print-validator-begin $node, %atts;
	POST print-validator-end $node, $_;
	return ASTQuery::Match.new: :list[$node,]
		if ASTQuery::Match.merge-and: |%atts.kv.map: -> $key, $value is copy {
			return False unless $node.^can($key);
			$value = $value.($node) if $value ~~ Callable;
			self.validate-value: $node, $key, $value;
		}
	;
	False
}

proto method validate-value($node, $key, $value) {
	print-validator-begin $node, $value;
	POST print-validator-end $node, $value, $_;
	{*} || False
}

multi method validate-value($node, $key, Bool $ where *.not) {
	False
}

multi method validate-value($node, $key, Bool $ where *.so) {
	ASTQuery::Match.new: :list[$node,]
}

multi method validate-value(
	$node where !*.^name.starts-with("RakuAST"),
	$key,
	$value
) {
	$value.ACCEPTS($node) && ASTQuery::Match.new(:list[$node,])
}

multi method validate-value(
	$node,
	$key where !$node.^can($key),
	$
) {
	False
}

# Non-existent attribute should never succeed, even with Bool True
multi method validate-value(
	$node,
	$key where !$node.^can($key),
	Bool $
) {
	False
}

multi method validate-value(
	$node,
	$key where *.not,
	$
) {
	False
}

multi method validate-value(
	$node,
	$key,
	::?CLASS $value
) {
	my Any $nnode = $node."$key"();
	$value.ACCEPTS($nnode)
	&& ASTQuery::Match.new(:list[$nnode,])
}

multi method validate-value(
	$node,
	$key,
	Mu:U $value
) {
	do if $node."$key"() ~~ $value {
		ASTQuery::Match.new(:list[$node,])
	} else {
		False
	}
}

	multi method validate-value(
 		$node,
 		$key,
 		ASTQuery::Matcher::AttrRel $rel
 	) {
 		my $start = $node."$key"();
 		return False unless $start.defined;
 		given $rel.rel {
 			when 'child'      { self.validate-child($start,      $rel.matcher) || False }
 			when 'gchild'     { self.validate-gchild($start,     $rel.matcher) || False }
 			when 'descendant' { self.validate-descendant($start, $rel.matcher) || False }
 			default           { False }
 		}
 	}

 	method attr-leaf-value($v is copy) {
 		return $v unless $v.defined;
 		loop {
 			last unless $v.^name.starts-with('RakuAST');
 			my $id = self.get-id-field($v) // last;
 			last unless $v.^can($id);
 			my $next = $v."$id"();
 			last if $next === $v;
 			$v = $next;
 		}
 		$v
 	}

 	multi method validate-value(
 		$node,
 		$key,
 		ASTQuery::Matcher::AttrOp $op
 	) {
 		return False unless $node.^can($key);
 		my $current = $node."$key"();
 		return False unless $current.defined;
 	
 		my $want = $op.value;
 		my $cur-val = self.attr-leaf-value($current);
 	
 		my $ok = do given $op.op {
 			when 'contains' {
 				return False unless $cur-val.defined;
 				if $want ~~ Regex {
 					$cur-val ~~ $want
 				} elsif ($cur-val ~~ Str) && ($want ~~ Str) {
 					$cur-val.contains($want)
 				} else {
 					False
 				}
 			}
 			when 'starts' {
 				($cur-val ~~ Str) && ($want ~~ Str) && $cur-val.starts-with($want)
 			}
 			when 'ends' {
 				($cur-val ~~ Str) && ($want ~~ Str) && $cur-val.ends-with($want)
 			}
 			when 'regex' {
 				$cur-val ~~ $want
 			}
 			default { False }
 		};
 		$ok ?? ASTQuery::Match.new(:list[$node,]) !! False
 	}

 	# Generic value matcher: compare simple values or traverse into RakuAST nodes
 
 	multi method validate-value(
 
	$node,
	$key,
	$value
) {
	return False unless $node.^can($key);
	my $current = $node."$key"();
	return False unless $current.defined;
	if $current.^name.starts-with('RakuAST') {
		self.validate-value(
			$current,
			$.get-id-field($current),
			$value,
		)
	} else {
		$current ~~ $value
			?? ASTQuery::Match.new(:list[$node,])
			!! False
	}
}
