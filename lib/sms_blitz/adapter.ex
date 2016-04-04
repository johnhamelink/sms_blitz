defmodule SmsBlitz.Adapter do
  @typedoc "Parameters required in order to send an SMS"
  @type sms_params :: [from: String.t, to: String.t, message: String.t]

  @typedoc "Standardised Response for SMS sending requests"
  @type sms_result :: %{id: String.t, result_string: String.t, status_code: number}

  @callback authenticate(any) :: any
  @callback send_sms(any, sms_params) :: sms_result
end
