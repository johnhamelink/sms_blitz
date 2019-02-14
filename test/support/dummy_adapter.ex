defmodule SmsBlitz.Adapters.Dummy do
  @behaviour SmsBlitz.Adapter

  def authenticate(_any), do: :ok
  def send_sms(_any, _sms_params) do
     %{id: nil, result_string: nil, status_code: nil}
  end
end
