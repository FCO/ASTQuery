ASTQuery

ASTQuery is a Raku module designed to simplify the process of querying and manipulating Raku’s Abstract Syntax Trees (RakuAST). It provides a powerful and flexible query language that allows developers to analyze, refactor, and understand Raku code at a deeper level.

Synopsis

```raku
use ASTQuery;

# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_ * 3;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Example 1: Extract all 'apply-op' nodes where left operand is 1 and right operand is 3
my $result1 = $ast.&ast-query('.apply-op[left=1, right=3]');
say $result1.list;  # Outputs a list of matching nodes
say $result1.hash;  # Outputs an empty hash (no named captures used)

# Example 2: Find 'Infix' nodes that have an ancestor 'conditional' and capture 'IntLiteral' nodes with value 2
my $result2 = $ast.&ast-query('RakuAST::Infix << .conditional$cond .int#2$int');
say $result2.list;  # Outputs a list of matching 'Infix' nodes
say $result2.hash;  # Outputs a hash with captured nodes under 'cond' and 'int'

# Access captured nodes
my @conditional_nodes = $result2<cond>;  # Nodes captured as 'cond'
my @int_literals = $result2<int>;        # Nodes captured as 'int'

# Example 3: Find 'ApplyInfix' nodes where right operand is 2 and capture them as '$op'
my $result3 = $ast.&ast-query('RakuAST::Infix < .apply-op[right=2]$op');
say $result3<op>;  # Outputs the captured 'ApplyInfix' nodes

# Example 4: Find 'call' nodes that have a descendant 'Var' node and capture the 'Var' node as '$var'
my $result4 = $ast.&ast-query('.call >> RakuAST::Var$var');
say $result4.list;  # Outputs the list of matching 'call' nodes
say $result4.hash;  # Outputs the hash with the 'Var' node captured as 'var'

# Access the captured 'Var' node
my $var_node = $result4<var>;
say $var_node;  # Outputs the 'Var' node representing '$_'
```

In these examples:

	•	We parse some Raku code and generate its AST.
	•	We use ast-query with different query strings to find and capture specific nodes in the AST.
	•	The queries demonstrate the use of node descriptions, operators, and named captures.
	•	We retrieve the captured nodes using the <name> syntax.

Key Features

	•	Flexible Query Syntax: Use a rich and expressive syntax to define queries, allowing precise selection of AST nodes.
	•	Operators for Node Relationships: Utilize operators to specify parent-child and ancestor-descendant relationships between nodes.
	•	Named Captures: Save matched nodes using the $ prefix, enabling easy retrieval and manipulation.
	•	AST Modification: Not only query but also modify the AST, enabling powerful code transformations and refactoring tools.
	•	Simplified Node Matching: Ignore intermediary nodes from specific groups to simplify pattern matching.
	•	Comprehensive Results: ast-query returns an object with a list of matched nodes and a hash of named captures.
	•	Tool Integration: Designed to be used with tools like rak for searching and analyzing code across files.
	•	Code Analysis Modules: Potential to build modules that can detect common pitfalls or traps in Raku code.

Query Language Syntax

Node Description Format

The format to describe a node in ASTQuery is:

RakuAST::Class::Name.group#id[attr1, attr2=attrvalue]$name

	•	RakuAST::Class::Name: (Optional) The full class name of the node.
	•	.group: (Optional) A group that the node belongs to (groups are predefined and currently not customizable).
	•	#id: (Optional) An identifier attribute for the node (using the # prefix).
	•	[attributes]: (Optional) Attributes to match, specified in square brackets.
	•	$name: (Optional) A name to save the matched node, using the $ prefix.

Important Note: You should not use more than one name ($name) on a single node. Each node can have at most one named capture.

Operators for Node Relationships

ASTQuery supports several operators to define relationships between nodes:

	•	>: The left node has the right node as a child.
	•	<: The right node is the parent of the left node.
	•	>>: The left node has the right node as a descendant, but there are only nodes from the ignorable group between them.
	•	<<: The right node is an ancestor of the left node, with only nodes from the ignorable group between them.
	•	  (space): The left node has the right node as a descendant.

Ignorable Group

The ignorable group includes nodes that can be skipped over when using the >> and << operators. By default, this group includes:

	•	RakuAST::Block
	•	RakuAST::Blockoid
	•	RakuAST::StatementList
	•	RakuAST::Statement::Expression
	•	RakuAST::ArgList

Examples

Example 1: Matching Specific Infix Operations

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say 1 * 3;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'apply-op' nodes where left=1 and right=3
my $result = $ast.&ast-query('.apply-op[left=1, right=3]');
say $result.list;  # Outputs matching 'ApplyOp' nodes
say $result.hash;  # Outputs an empty hash (no named captures)
```

Output:

```raku
[RakuAST::ApplyInfix.new(
  left  => RakuAST::IntLiteral.new(1),
  infix => RakuAST::Infix.new("*"),
  right => RakuAST::IntLiteral.new(3)
)]
{}
```

Explanation:

	•	The query .apply-op[left=1, right=3] matches ApplyOp nodes with left operand 1 and right operand 3.

Example 2: Using the Ancestor Operator << and Named Captures

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_ * 3;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'Infix' nodes with an ancestor 'conditional' and capture 'IntLiteral' nodes with value 2
my $result = $ast.&ast-query('RakuAST::Infix << .conditional$cond .int#2$int');
say $result.list;  # Outputs matching 'Infix' nodes
say $result.hash;  # Outputs captured nodes under 'cond' and 'int'
```

Output:

```raku
[RakuAST::Infix.new("%%") RakuAST::Infix.new("*")]
{
  cond => RakuAST::Statement::If.new(
    condition => RakuAST::ApplyInfix.new(
      left  => RakuAST::Var::Lexical.new("$_"),
      infix => RakuAST::Infix.new("%%"),
      right => RakuAST::IntLiteral.new(2)
    ),
    then => ...
  ),
  int => [RakuAST::IntLiteral.new(2), RakuAST::IntLiteral.new(2)]
}
```

Explanation:

	•	The query RakuAST::Infix << .conditional$cond .int#2$int:
	•	Matches Infix nodes that have an ancestor matching .conditional$cond.
	•	Captures IntLiteral nodes with value 2 as $int.
	•	We can access the captured nodes using $result<cond> and $result<int>.

Example 3: Using the Parent Operator < and Capturing Nodes

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_ * 2;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'ApplyInfix' nodes where right=2 and capture them as '$op'
my $result = $ast.&ast-query('RakuAST::Infix < .apply-op[right=2]$op');
say $result<op>;  # Outputs the captured 'ApplyInfix' nodes
```

Output:

```raku
[RakuAST::ApplyInfix.new(
  left  => RakuAST::Var::Lexical.new("$_"),
  infix => RakuAST::Infix.new("*"),
  right => RakuAST::IntLiteral.new(2)
)]
```

Explanation:

	•	The query RakuAST::Infix < .apply-op[right=2]$op:
	•	Matches ApplyOp nodes with right operand 2 and whose parent is an Infix node.
	•	Captures the ApplyOp nodes as $op.

Example 4: Using the Descendant Operator >> and Capturing Variables

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'call' nodes that have a descendant 'Var' node and capture the 'Var' node as '$var'
my $result = $ast.&ast-query('.call >> RakuAST::Var$var');
say $result.list;  # Outputs the list of matching 'call' nodes
say $result.hash;  # Outputs the hash with the 'Var' node captured as 'var'

# Access the captured 'Var' node
my $var_node = $result<var>;
say $var_node;  # Outputs the 'Var' node representing '$_'
```

Output:

```raku
[RakuAST::Call::Name::WithoutParentheses.new(
  name => RakuAST::Name.from-identifier("say"),
  args => RakuAST::ArgList.new(
    RakuAST::Var::Lexical.new("$_")
  )
)]
{ var => RakuAST::Var::Lexical.new("$_") }
```

Explanation:

	•	The query .call >> RakuAST::Var$var:
	•	Matches call nodes that have a descendant Var node.
	•	Captures the Var node as $var.
	•	We can access the captured Var node using $result<var>.

Retrieving Matched Nodes

The ast-query function returns an ASTQuery object with:

	•	@.list: An array containing all nodes that matched the query.
	•	%.hash: A hash where keys are the names of captured nodes (defined with $), and values are the nodes that matched those captures.

Accessing Captured Nodes

```raku
# Perform the query
my $result = $ast.&ast-query('.call#say$call');

# Access the captured node
my $call_node = $result<call>;

# Access all matched nodes
my @matched_nodes = $result.list;
```

Operators and Their Meanings

	•	>: Left node has the right node as a child.
	•	<: Right node is the parent of the left node.
	•	>>: Left node has the right node as a descendant, with only nodes from the ignorable group between them.
	•	<<: Right node is an ancestor of the left node, with only nodes from the ignorable group between them.
	•	  (space): Left node has the right node as a descendant.

More Operators

Additional operators are planned for future implementation, further enhancing the expressiveness of the query language.

Custom Groups

Note: Defining custom groups is a planned feature and is not yet implemented. In the future, users will be able to define custom groups to categorize nodes, enhancing query flexibility.

The ast-query Function

The ast-query function takes one argument:

	•	Query String: A string defining the node pattern using the query syntax.

It is called as a method on the AST:

```raku
my $result = $ast.&ast-query('query string');
```

It returns an ASTQuery object with:

	•	@.list: All nodes that matched the query.
	•	%.hash: Nodes captured with named captures (using the $ symbol).

Potential Use Cases

	•	Refactoring Tools: Automatically find and replace patterns in code, such as deprecated function calls.
	•	Code Analysis: Detect and warn about specific coding patterns or potential bugs.
	•	Educational Tools: Help learners visualize and understand the structure of Raku code.
	•	Compiler Development: Assist in writing compilers or interpreters that need to manipulate or analyze the AST.
	•	Custom Transformations: Implement domain-specific language features or custom syntax by transforming AST nodes.

Current Status and Future Directions

ASTQuery is currently in active development, focusing on refining the query syntax, implementing more operators, and expanding its capabilities.

Future Plans

	•	Implement More Operators: Enhance the query language with additional operators for more complex relationships.
	•	Custom Groups: Allow users to define and modify groups for greater flexibility (planned feature).
	•	Performance Improvements: Optimize the query engine for faster traversal and matching, especially for large ASTs.
	•	Tooling Integration: Develop plugins or extensions for editors and development tools.
	•	Extend Use Cases: Explore building additional modules for code analysis, refactoring, and more.
	•	Community Contributions: Encourage contributions to expand use cases, improve documentation, and enhance features.

Get Involved

Check out the ASTQuery repository on GitHub for code examples, the latest updates, and to contribute.

How You Can Help

	•	Feedback: Share your thoughts on the query syntax, features, and usability.
	•	Use Case Examples: Provide scenarios where ASTQuery could be beneficial, helping to guide feature development.
	•	Code Contributions: Contribute to the codebase by adding new features, fixing bugs, or optimizing performance.
	•	Documentation: Help improve the documentation by writing tutorials, guides, or enhancing existing content.

Note: ASTQuery is a project by Fernando Corrêa de Oliveira, aimed at making AST manipulation in Raku more accessible and powerful.

Conclusion

ASTQuery offers a powerful and flexible way to query and manipulate Raku’s ASTs using an expressive syntax that allows precise specification of nodes and their relationships. By introducing operators, named captures, and a comprehensive query language, ASTQuery provides developers with the tools needed to effectively analyze and transform Raku code at the AST level.

Whether you’re developing advanced tooling, performing complex code analysis, or exploring Raku’s internals, ASTQuery can significantly enhance your capabilities and streamline your workflow.

If you have any questions or need further assistance, please feel free to reach out or open an issue on the ASTQuery GitHub repository.
