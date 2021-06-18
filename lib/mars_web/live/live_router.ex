defmodule MarsWeb.Live.Utils do
  def add(x, 1), do: x + 1
  def add(x, y), do: x + y
  def add(x, y, z), do: x + y + z
  def add1(x, 1), do: x + 1

  defmacro __using__(_) do
    quote do
      def log(msg), do: IO.puts(msg)
    end
  end
end

defmodule MarsWeb.Live.Helper do
  def create_args(fn_mdl, arg_cnt), do: Enum.map(1..arg_cnt, &Macro.var(:"arg#{&1}", fn_mdl))

  defmacro __using__(_) do
    quote do
      def log(msg), do: IO.puts(msg)
    end
  end

  # defmacro __using__(module) do
  defmacro use1(module) do
    module =
      module
      |> Macro.decompose_call()
      |> elem(1)
      |> (&apply(Module, :concat, [&1])).()
      |> IO.inspect(label: "macro args")

    module.__info__(:functions)
    |> Enum.each(fn {name, count} ->
      fn_args = create_args(module, count)
      fn_args |> Enum.count() |> IO.inspect(label: "using")

      quote do
        # 不能 delegate macro
        defdelegate unquote(name)(unquote_splicing(fn_args)), to: unquote(module)
      end
    end)
  end
end

defmodule MarsWeb.Live.Router do
  # defdelegate add(m, n), to: MarsWeb.Live.Utils

  # import MarsWeb.Live.Utils
  # calluse(MarsWeb.Live.Utils)

  # import MarsWeb.Live.Helper
  # calluse(MarsWeb.Live.Utils)
  # use MarsWeb.Live.Utils
  # use MarsWeb.Live.Helper

  def run() do
    require MarsWeb.Live.Helper
    # MarsWeb.Live.Helper.calluse(MarsWeb.Live.Utils)
  end

  defmacro liveless(path, live_view, action \\ nil, opts \\ []) do
    quote bind_quoted: binding() do
      {action, router_options} =
        Phoenix.LiveView.Router.__live__(__MODULE__, live_view, action, opts)

      __MODULE__ |> IO.inspect(label: "liveless")

      Phoenix.Router.get(path, Phoenix.LiveView.Plug, action, router_options)
    end
  end
end
