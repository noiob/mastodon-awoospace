# frozen_string_literal: true

class WhitelistDomainService < BaseService
  attr_reader :domain_whitelist

  def call(domain_whitelist)
    @domain_whitelist = domain_whitelist
    process_domain_whitelist
  end

  private

  def process_domain_whitelist
    if domain_whitelist.silence?
      silence_accounts!
    end
    enable_accounts!
  end

  def silence_accounts!
    whitelisted_domain_accounts.in_batches.update_all(silenced: true)
    clear_media! if domain_whitelist.reject_media?
  end

  def enable_accounts!
    UnblockDomainService.new.call(domain_whitelist, retroactive: true)
  end

  def whitelisted_domain
    domain_block.domain
  end

  def whitelisted_domain_accounts
    Account.where(domain: whitelisted_domain)
  end
end
