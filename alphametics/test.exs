defmodule FuncTest do
    def f1(a) do
        fn b->
            a + b > 9
        end
    end
end