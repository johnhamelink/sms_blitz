defmodule SmsBlitz.Adapters.Itagg do

  def authenticate(foo) do
    :ok
  end

  def send_sms(auth, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do
    %{
      id: "dummy",
      result_string: "dummy",
      status_code: 404
    }
  end

end
