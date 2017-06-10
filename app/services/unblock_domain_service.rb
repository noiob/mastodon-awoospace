# frozen_string_literal: true

class UnblockDomainService < BaseService
  attr_accessor :domain_block

  def call(domain_block, retroactive)
    @domain_block = domain_block
    process_retroactive_updates if retroactive
    if !DomainWhitelist.enabled?
      domain_block.destroy
    end
  end

  def process_retroactive_updates
    blocked_accounts.in_batches.update_all(update_options)
  end

  def blocked_accounts
    Account.where(domain: domain_block.domain)
  end

  def update_options
    { domain_block_impact => false }
  end

  def domain_block_impact
    domain_block.silence? ? :silenced : :suspended
  end
end
