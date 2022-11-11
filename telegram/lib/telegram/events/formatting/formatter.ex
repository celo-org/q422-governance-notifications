defmodule TelegramService.Events.MessageFormatter do

  #cusd celo mainnet transfer
  def format(%{
    "topic" => "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    "contract_address_hash" => "0x765de816845861e75a25fca122bb6898b8b1282a",
    "transaction_hash" => tx_hash,
    "params" => %{
      "from" => from,
      "to" => to,
      "value" => value,
    }
    }) do
    """
    cUSD Transfer:
  *From*: #{from}
  To: #{to}
  Value: #{wei_to_eth(value)} cUSD

  View at https://explorer.celo.org/mainnet/tx/#{tx_hash}
"""
  end

  defp wei_to_eth(value), do: (value / :math.pow(10, 18)) |> Float.round(6) |> to_string()

end