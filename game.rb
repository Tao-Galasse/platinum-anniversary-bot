# frozen_string_literal: true

class Game < Data.define(:name, :platform, :icon_url, :completed_at, :platinum)
  def platinum?
    platinum
  end

  def trophy_type
    platinum? ? 'platine' : '100%'
  end
end
