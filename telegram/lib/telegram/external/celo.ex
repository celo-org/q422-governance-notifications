defmodule TelegramService.External.CeloConsts do
  @moduledoc "Celo blockchain constant values"

  defmacro __using__(_opts) do
    quote do
      @governance_proxy_address "0xd533ca259b330c7a88f74e000a3faea2d63b7972"
      @proposal_queued_topic "0x1bfe527f3548d9258c2512b6689f0acfccdd0557d80a53845db25fc57e93d8fe"

      @cusd_proxy_address "0x765de816845861e75a25fca122bb6898b8b1282a"
      @transfer_topic "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    end
  end
end