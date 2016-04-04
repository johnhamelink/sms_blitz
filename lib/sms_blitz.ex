defmodule SmsBlitz do
  alias SmsBlitz.Adapters.{Plivo, Itagg}

  @spec send_sms(atom, SmsBlitz.Adapter.sms_params) :: SmsBlitz.Adapter.sms_result

  def send_sms(:plivo, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do
    Plivo.authenticate(Application.get_env(:sms_blitz, :plivo))
    |> Plivo.send_sms(from: from, to: to, message: message)
  end

  def send_sms(:itagg, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do
    Itagg.authenticate(Application.get_env(:sms_blitz, :itagg))
    |> Itagg.send_sms(from: from, to: to, message: message)
  end

end
