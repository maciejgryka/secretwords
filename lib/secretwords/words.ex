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

  def word_slot_types do
    [
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
      :red,
      :red,
      :red,
      :red,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :blue,
      :killer
    ]
    |> Enum.shuffle()
  end

  def all_words do
    # http://www.desiquintans.com/nounlist
    ~w(
      button
      film
      bugle
      part
      pneguin
      root
      mint
      bug
      staff
      marble
      nail
      giant
      berlin
      face
      horse
      pirate
      mint
      bug
      kiwi
      code
      bed
      circle
      state
      torch
      america
      ivory
      catchup
      witch
      male
      undertaker
      himalayas
      crown
      mouth
      tap
      lawyer
      satellite
      missile
      paste
      log
      loch ness
      spy
      unicorn
      racket
      beijing
      novel
      pipe
      plot
      pupil
      africa
      scuba diver
      ninja
      olympus
      tag
      ice
      spider
      angel
      embassy
      robot
      germany
      fork
      pricess
      time
      genious
      eagle
      wall
      pants
      england
      smuggler
      opera
      pyramid
      chech
      back
      nut
      sock
      tail
      crash
      pistol
      row
      hand
      swing
      dance
      link
      thief
      bark
      berry
      soldier
      temple
      orange
      tower
      poison
      ground
      note
      worm
      alps
      tick
      gold
      scientist
      spike
      disease
      port
      carrot
      flute
      trunk
      snow
      atlantis
      vacuum
      maple
      aztec
      night
      string
      plane
      hotel
      cricket
      cold
      parachute
      rome
      well
      screen
      fair
      hollywood
      washer
      cat
      shoe
      sink
      bill
      dinosaur
      club
      mole
      shot
      game
      sound
      slug
      space
      hook
      figure
      bat
      mass
      park
      compound
      paper
      sub
      beach
      turkey
      pin
      glass
      bear
      charge
      pound
      washington
      mine
      revolution
      oil
      chest
      conductor
      superhero
      cook
      pole
      apple
      yard
      dog
      gas
      cast
      box
      mound
      piano
      spot
      platypus
      stick
      tooth
      play
      pan
      bond
      center
      chick
      lap
      life
      server
      school
      chair
      water
      queen
      check
      file
      bar
      train
      field
      india
      round
      telescope
      cycle
      king
      pitch
      square
      grease
      amazon
      luck
      buffalo
      deck
      china
      bold
      pit
      fly
      lock
      brush
      web
      fan
      line
      plate
      green
      pass
      death
      stock
      egypt
      theater
      cover
      sell
      degree
      bow
      teacher
      pumpkin
      boom
      bang
      lab
      cliff
      fence
      capital
      tube
      point
      van
      vet
      icecream
      rabbit
      foal
      scale
      lemon
      bell
      mug
      concert
      seal
      cross
      shark
      jupiter
      calf
      air
      ship
      dice
      ghost
      boot
      centaur
      shadow
      heart
      hood
      dwarf
      plastic
      moscow
      palm
      strike
      kangaroo
      chocolate
      suit
      glove
      stream
      duck
      ring
      diamond
      whale
      cotton
      fish
      mercury
      roulette
      knight
      pie
      contract
      march
      knife
      church
      model
      tokio
      triangle
      cap
      rock
      london
      eye
      mexico
      ham
      draft
      agent
      buck
      bomb
      ruler
      grass
      spell
      alien
      key
      trip
      crane
      copper
      jack
      jet
      microscope
      litter
      head
      band
      fire
      tie
      table
      date
      drill
      ball
      doctor
      slip
      tablet
      limousine
      australia
      orgam
      jam
      rose
      change
      light
      belt
      police
      lion
      board
      cloak
      battery
      hawk
      drop
      phoenix
      casino
      pilot
      saturn
      hospital
      whip
      octopus
      snowman
      helicopter
      soul
      europe
      shakespeare
      engine
      comic
      mammoth
      robin
      bridge
      court
      spring
      france
      block
      match
      iron
      shop
      needle
      foot
      new york
      horseshoe
      honey
      arm
      bermuda
      post
      ray
      kid
      wind
      switch
      straw
      spine
      press
      track
      force
      skyscraper
      laser
      dress
      ambulance
      antarctica
      thumb
      forest
      bottle
      canada
      scorpion
      car
      wave
      millionaire
      day
      pool
      star
      card
      horn
      net
      moon
      olive
      grace
      fighter
      wake
      stadium
      dragon
      mouse
      war
      watch
      lead
      hole
      beat
      leprechaun
      nurse
    )
  end
end
