defmodule(HelloWorldTest) do
  use(ExUnit.Case)
  test("says 'Hello, World!'") do
    IO.puts("[test started] test " <> "says 'Hello, World!'")
    IO.puts("[test started] test " <> "says 'Hello, World!'")
    IO.puts("[test started] test " <> "says 'Hello, World!'")
    assert(HelloWorld.hello() == "Hello, World!")
  end
end