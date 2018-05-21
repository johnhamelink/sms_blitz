defmodule SmsBlitz.Adapters.Itagg do
  @behaviour SmsBlitz.Adapter
  @base_uri "https://secure.itagg.com/smsg"

  def authenticate({username, password, route}) do
    %{
      uri: Enum.join([@base_uri, "sms.mes"], "/"),
      auth: [
        usr: username,
        pwd: password,
        route: route
      ]
    }
  end

  def send_sms(%{uri: uri, auth: auth}, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do
    HTTPoison.post(uri, params(auth, from, to, message))
    |> handle_response!
  end

  defp handle_response!({:ok, %HTTPoison.Response{body: resp, status_code: status_code}}) do
    parse_response(resp)
    |> Enum.map(fn (response) ->
      %{
        id: response.submission_reference,
        result_string: response.error_text,
        status_code: status_code
      }
    end)
  end

  defp parse_response(body) when is_binary(body) do
    # Remove trailing newline and split by newlines
    lines =
      body
      |> String.replace_trailing("\n", "")
      |> String.split("\n")

    # Retrieve the header from the first line
    header =
      lines
      |> Enum.at(0)
      |> String.split("|")
      |> Enum.map(fn (header) ->
        # Convert each header to a Symbol
        header
        |> String.replace(" ", "_")
        |> String.to_atom
      end)

    # Map all subsequent lines to the header
    lines
    |> List.delete_at(0) # Delete the header
    |> Enum.map(fn (line) ->
      # Zip up the header atoms with the associated response data
      Enum.zip(header, String.split(line, "|"))
      |> Enum.into(%{})
    end)
  end

  defp params(auth, from, to, message) do
    {
      :form,
      [
        from: from,
        to: to,
        type: "text",
        txt: message,
      ] ++ auth
    }
  end
end
