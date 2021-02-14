defmodule Secretwords.Words do
  alias Secretwords.WordSlot

  def words(num) do
    words =
      all_words()
      |> Enum.shuffle()
      |> Enum.slice(num)

    types = word_slot_types()

    make_word_slots(words, types)
  end

  def make_word_slots(words, types) do
    [words, types]
    |> Enum.zip()
    |> Enum.map(fn {word, type} -> %WordSlot{word: word, type: type} end)
  end

  def word_slot_types() do
    [
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :neutral,
      :red,
      :red,
      :red,
      :red,
      :red,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :killer
    ]
    |> Enum.shuffle()
  end

  def all_words() do
    ~w(
      account
      act
      adjustment
      advertisement
      agreement
      air
      amount
      amusement
      animal
      answer
      apparatus
      approval
      argument
      art
      attack
      attempt
      attention
      attraction
      authority
      back
      balance
      base
      behavior
      belief
      birth
      bit
      bite
      blood
      blow
      body
      brass
      bread
      breath
      brother
      building
      burn
      burst
      business
      butter
      canvas
      care
      cause
      chalk
      chance
      change
      cloth
      coal
      color
      comfort
      committee
      company
      comparison
      competition
      condition
      connection
      control
      cook
      copper
      cork
      copy
      cough
      country
      cover
      crack
      credit
      crime
      crush
      cry
      current
      curve
      damage
      danger
      daughter
      day
      death
      debt
      decision
      degree
      design
      desire
      destruction
      detail
      development
      digestion
      direction
      discovery
      discussion
      disease
      disgust
      distance
      distribution
      division
      doubt
      drink
      driving
      dust
      earth
      edge
    )
  end
end
