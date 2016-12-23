# Isomorphic

This is an initial sketch.

Write Ruby code that is annotated for use on the browser, server or both. Server
code is stripped during compile time.

Use annotations to designate code for the `server` or for the `browser`. When
compiling a ruby file for the browser using Opal, an ast processor can remove
any code not designated for the browser. This prevents server code from ever
getting shipped to the browser. By default symbols are designated for `anywhere`
which means they'll be defined on the server and for the browser.

TODO:
[ ] hook up to opal compiler as a build step somehow
[ ] command line tool or plugin to use with opal compiler
[ ] cleanup and more tests
[ ] runtime removal of browser code using `method_added` hook and kernel methods

Examples:

```ruby
class Router
  server
  def run(req, res)
    # run a route on the server
  end

  browser
  def run()
    # run a route in the browser
  end
end
```

```ruby
class Router
  def server_method(req, res)
  end

  def browser_method()
  end

  # Provide method names to the `server` or `browser` annotations. The order
  # doesn't matter. Notice we did this at the end of the class but I could have
  # done it at the beginning.
  server :server_method
  browser :browser_method
end
```

```ruby
# Everything after the server annotation is for server only.
server
class Router
end

$server_only_var = "boom"

# Everything after the browser annotation is for the browser only.
browser
class BrowserThing
end

BROWSER_CONST = "bam"
```

## Installation

Not published yet.

## Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test:auto` to run the automated tests. You can also run `bin/console` for
an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).
