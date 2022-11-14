defmodule TelegramService.Events.MessageFormatter do
  use TelegramService.External.CeloConsts

  def format(%{
    "topic" => @transfer_topic,
    "contract_address_hash" => @cusd_proxy_address,
    "transaction_hash" => tx_hash,
    "params" => %{
      "from" => from,
      "to" => to,
      "value" => value,
    }
    }) do
    """
   [Transfer: #{wei_to_eth(value)} cUSD](https://explorer.celo.org/mainnet/tx/#{tx_hash})
  *From*: #{from}
  *To*: #{to}
"""
  end

  def format(%{
    "topic" => @proposal_queued_topic,
    "contract_address_hash" => @governance_proxy_address,
    "transaction_hash" => tx_hash,
    "params" => %{
      "proposal_id" => id,
      "proposer" => proposer
    }
  }) do
    """
       [Governance Proposal Queued](https://explorer.celo.org/mainnet/tx/#{tx_hash})
      *Proposal Id*: #{id}
      *Proposer*: #{proposer}
    """

  end

  defp wei_to_eth(value), do: (value / :math.pow(10, 18)) |> Float.round(6) |> to_string()

end