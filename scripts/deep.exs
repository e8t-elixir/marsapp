defmodule Fun do

  def find(m, [head | tail]) do
    case Map.fetch(m, head) do
      {:ok, inner} when is_map(inner) -> find(inner, tail)
      {:ok, inner} -> inner
      :error -> {:error, "key: (#{head}) not found"}
    end
  end

  def find(m, []), do: m

  def find(m, key), do: m |> Map.get(key)

  def run() do
    m = %{
      a: %{
        b: %{
          c: %{
            d: %{
              e: "DONE"
            }
          }
        }
      }
    }

    find(m, :a) |> IO.inspect()
    find(m, [:a, :b]) |> IO.inspect()
    find(m, [:a, :no]) |> IO.inspect()
  end
end

Fun.run()
