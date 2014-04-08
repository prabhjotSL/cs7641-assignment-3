class Hand
  include Comparable

  def initialize
    @cards = []
  end

  def <<(card)
    @cards << card
  end

  def worth
    worth_hash = {}
    aces = @cards.select(&:ace?)
    rest = @cards.reject(&:ace?)
    residual = rest.reduce(0) { |sum, card| sum += (card.modulo + 1) }

    aces.value.map do |ace|
      ace + residual
    end
  end

  def busted?
    worth.all? { |w| w > 21 }
  end

  def self.possible_combinations(aces)
    @aces = aces.dup

    while @aces.length > 1
      @aces[0] = fold(@aces[0], @aces[1])
      @aces.delete_at(1)
    end

    @aces
  end

  def fold(first, rest)
    first.map do |f|
      rest.flatten! if rest.length == 1
      rr = rest.map do |r|
        if r.is_a?(Array)
          fold(rest.first, rest[1..-1])
        else
          f + r
        end
      end
    end.flatten
  end
end

__END__

h = Hand.new
4.times do
  h << Card.new(1)
end

h.worth == [4]
