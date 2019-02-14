defmodule SmsBlitz.Adapters.Test do
  @behaviour SmsBlitz.Adapter

  @impl true
  def authenticate(_any), do: nil

  @impl true
  def send_sms(_any, sms_params) do
    send(test_pid(), {:sms, sms_params})
  end

  defp test_pid do
    Application.get_env(:sms_blitz, :test_pid) || self()
  end
end
