defmodule SmsBlitz do
  alias SmsBlitz.Adapters.{Plivo, Itagg, Twilio, Nexmo}


  default_adapters = %{
    plivo:  Plivo,
    itagg:  Itagg,
    twilio: Twilio,
    nexmo:  Nexmo
  }

  extra_adapters = Application.get_env(:sms_blitz, :extra_adapters)

  adapters = if extra_adapters && is_map(extra_adapters) do
    Map.merge(default_adapters, extra_adapters)
  else
    default_adapters
  end

  @adapters adapters

  def adapters(), do: Map.keys(@adapters)

  @spec send_sms(atom, SmsBlitz.Adapter.sms_params) :: SmsBlitz.Adapter.sms_result
  def send_sms(adapter_key, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) and is_atom(adapter_key) do

    case Map.fetch(@adapters, adapter_key) do
      :error -> {:error, :unknown_adapter}
      {:ok, adapter} ->
        auth = apply(adapter, :authenticate, [Application.get_env(:sms_blitz, adapter_key)])
        apply(adapter, :send_sms, [auth, [from: from, to: to, message: message]])
    end
  end
end
