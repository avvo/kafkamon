defmodule KafkamonWeb.OptionsController do
  use Phoenix.Controller , log: false

  alias Kafkamon.StatusChecking

  def ping(conn, _) do
    conn |> text("PONG")
  end

  def fail(conn, _) do
    msg = "Error intentionally raised from /options/fail"
    conn |> send_resp(:internal_server_error, msg)
  end

  def deploy_status(conn, _) do
    errs = StatusChecking.errors_local ++ StatusChecking.errors_remote
    errs |> send_errs(conn)
  end

  def full_stack_status(conn, _) do
    errs = StatusChecking.errors_local
    errs |> send_errs(conn)
  end

  defp send_errs([], conn), do: conn |> text("OK")
  defp send_errs(errs, conn) do
    msg = Enum.join(errs, "\n")
    conn |> send_resp(:internal_server_error, msg)
  end
end
