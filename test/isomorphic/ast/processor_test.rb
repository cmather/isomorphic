require "test_helper"
require "isomorphic/ast/processor"
require "parser/current"
require "unparser"
require "byebug"

def assert_code_equal(expected, actual, msg = nil)
  assert_equal expected.gsub(/\s/, ''), actual.gsub(/\s/, ''), msg
end

describe "Isomorphic::AST::Processor" do
  it "designate specific server methods" do
    source = <<-EOF
      class MyClass
        def server_method
          "server"
        end

        def anywhere_method
          "anywhere"
        end

        server :server_method
      end
    EOF

    expected = <<-EOF
      class MyClass
        def anywhere_method
          "anywhere"
        end
      end
    EOF

    original_ast = Parser::CurrentRuby.parse(source)
    filtered_ast = Isomorphic::AST::Processor.new(:browser).process(original_ast)
    result = Unparser.unparse(filtered_ast)
    assert_code_equal expected, result, "ast wasn't filtered correctly"
  end

  it "designate specific browser methods" do
    source = <<-EOF
      class MyClass
        def anywhere
          "anywhere"
        end

        def browser
          "browser"
        end

        browser :browser
      end
    EOF

    expected = <<-EOF
      class MyClass
        def anywhere
          "anywhere"
        end

        def browser
          "browser"
        end
      end
    EOF

    original_ast = Parser::CurrentRuby.parse(source)
    filtered_ast = Isomorphic::AST::Processor.new(:browser).process(original_ast)
    result = Unparser.unparse(filtered_ast)
    assert_code_equal expected, result, "ast wasn't filtered correctly"
  end

  it "designate specific regions" do
    source = <<-EOF
      class MyClass
        server
        def server
          "server"
        end

        browser
        def browser
          "browser"
        end
      end
    EOF

    expected = <<-EOF
      class MyClass
        def browser
          "browser"
        end
      end
    EOF

    original_ast = Parser::CurrentRuby.parse(source)
    filtered_ast = Isomorphic::AST::Processor.new(:browser).process(original_ast)
    result = Unparser.unparse(filtered_ast)
    assert_code_equal expected, result, "ast wasn't filtered correctly"
  end

  it "by default code goes on browser and server" do
    source = <<-EOF
      class MyClass
        def server
          "server"
        end

        def browser
          "browser"
        end
      end
    EOF

    expected = <<-EOF
      class MyClass
        def server
          "server"
        end

        def browser
          "browser"
        end
      end
    EOF

    original_ast = Parser::CurrentRuby.parse(source)
    filtered_ast = Isomorphic::AST::Processor.new(:browser).process(original_ast)
    result = Unparser.unparse(filtered_ast)
    assert_code_equal expected, result, "ast wasn't filtered correctly"
  end
end
