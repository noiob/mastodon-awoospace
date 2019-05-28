# frozen_string_literal: true

class WhitelistDomainService < BaseService
  def self.call(domain, severity)
    d = DomainWhitelist.where(domain: domain).first_or_create!(domain: domain, severity: severity)
    d.severity = severity
    d.save!

    if severity == :silence
      Account.where(domain: domain).update_all(silenced_at: Time.now.utc)
    elsif severity == :enable
      Account.where(:domain => domain).update_all(suspended_at: nil)
    end
  end
end
