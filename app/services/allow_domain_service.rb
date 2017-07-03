# frozen_string_literal: true

class AllowDomainService < BaseService
  def self.default_allow
    :suspend if DomainWhitelist.enabled?
    :enable
  end

  def self.record_type
    if DomainWhitelist.enabled?
      DomainWhitelist
    else
      DomainBlock
    end

  def self.call(domain)
    return true if domain.nil?
    domain = self.find_by(domain)
    return self.default_allow if domain.nil?
    return domain.severity
  end

  def self.blocked?(domain)
    return self.call(domain) == :suspend
  end

  def self.reject_media?(domain)
    return self.record_type.find_by(domain: domain)&.reject_media?
  end

  def self.find_by(domain)
    if DomainWhitelist.enabled?
      DomainWhitelist.where(domain: domain).first
    else
      DomainBlock.where(domain: domain).first
  end
end
