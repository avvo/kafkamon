defmodule Kafkamon.StatusChecking do

  def errors_local(_ \\ nil) do
    app_modules() |> alive_errs()
  end

  def errors_remote(_ \\ nil) do
    []
  end

  defp app_modules do
    []
  end

  defp alive_errs(modules), do: modules |> Enum.reduce([], &alive_err/2)

  defp alive_err(module, acc) do
    case application_alive?(module) do
      true -> acc
      false -> ["#{module} is down" | acc]
    end
  end

  def application_alive?(module) do
    case Process.whereis(module) do
      nil -> false
      pid -> Process.alive?(pid)
    end
  end
end
