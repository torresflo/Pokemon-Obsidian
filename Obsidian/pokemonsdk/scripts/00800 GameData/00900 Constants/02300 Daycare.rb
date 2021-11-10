module GameData
  module Daycare
    # Only use the FIRST FORM for breed groups
    USE_FIRST_FORM_BREED_GROUPS = false
    # Specific form handler (system that can force a for according to a code)
    SPECIFIC_FORM_HANDLER = {
      myfakepokemon: proc { |_mother, _father| next(rand(10)) } # Returns a random form between 0 and 9
    }
    # List of Pokemon that cannot breed (event if the conditions are valid)
    NOT_BREEDING = %i[phione manaphy]
    # List of Pokemon that only breed with Ditto
    BREEDING_WITH_DITTO = %i[phione manaphy]
    # ID of the Ditto group
    DITTO_GROUP = 13
    # ID of the breed group that forbid breeding
    NOT_BREEDING_GROUP = 15
    # List of price rate for all daycare
    # @return [Hash{Integer => Integer}]
    PRICE_RATE = Hash.new(100)
    # Egg rate according to the common group, common OT, oval_charm (dig(common_group?, common_OT?, oval_charm?))
    EGG_RATE = [
      [ # No Common Group
        [50, 80], # No Common OT. [no_oval_charm, oval_charm]
        [20, 40]  # Common OT. [no_oval_charm, oval_charm]
      ],
      [ # Common Group
        [70, 88], # No Common OT. [no_oval_charm, oval_charm]
        [50, 80]  # Common OT. [no_oval_charm, oval_charm]
      ]
    ]
    # "Female" breeder that can have different baby (non-incense condition)
    # @return [Hash{Symbol => Array}]
    BABY_VARIATION = {
      nidoranf: nidoran = %i[nidoranf nidoranm],
      nidoranm: nidoran,
      volbeat: volbeat = %i[volbeat illumise],
      illumise: volbeat,
      tauros: tauros = %i[tauros miltank],
      miltank: tauros
    }
    # Structure holding the information about the insence the male should hold
    # and the baby that will be generated
    IncenseInfo = Struct.new(:incense, :baby)
    # "Female" that can have different baby if the male hold an incense
    INCENSE_BABY = {
      marill: azurill = IncenseInfo.new(:sea_incense, :azurill),
      azumarill: azurill,
      wobbuffet: IncenseInfo.new(:lax_incense, :wynaut),
      roselia: budew = IncenseInfo.new(:rose_incense, :budew),
      roserade: budew,
      chimecho: IncenseInfo.new(:pure_incense, :chingling),
      sudowoodo: IncenseInfo.new(:rock_incense, :bonsly),
      mr_mime: IncenseInfo.new(:odd_incense, :mime_jr),
      chansey: happiny = IncenseInfo.new(:luck_incense, :happiny),
      blissey: happiny,
      snorlax: IncenseInfo.new(:full_incense, :munchlax),
      mantine: IncenseInfo.new(:wave_incense, :mantyke)
    }
    # Non inherite balls
    NON_INHERITED_BALL = %i[master_ball cherish_ball]
    # IV setter list
    IV_SET = %i[iv_hp= iv_dfe= iv_atk= iv_spd= iv_ats= iv_dfs=]
    # IV getter list
    IV_GET = %i[iv_hp iv_dfe iv_atk iv_spd iv_ats iv_dfs]
    # List of power item that transmit IV in the same order than IV_GET/IV_SET
    IV_POWER_ITEM = %i[power_weight power_belt power_bracer power_anklet power_lens power_band]
  end
end
