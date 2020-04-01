#encoding: utf-8

#noyard
class Scene_Battle_Online < Scene_Battle
  Base_Wait_Method = Graphics.method(:update)
  CodeBase = 234
  attr_accessor :magneto
  #===
  #>Redéfinition de setup_battle pour considérer les données de l'autre joueur
  #===
  def setup_battle(type,actor_cnt,enemy_cnt,*battlers)
    $game_temp.vs_actors=1
    $game_temp.vs_enemies=1
    $game_temp.vs_type=type
    $game_temp.enemy_battler=[sprintf("%03d", 1+rand(182))]
    $game_temp.trainer_battle=true
    @actors=$actors.clone
    __sort_actors
    @victory_phrase = DefaultVictoryPhrase unless @victory_phrase
    @defeat_phrase = DefaultDefeatPhrase unless @defeat_phrase
    @trainer_names = DefaultNames unless @trainer_names
    @trainer_class = 0 unless @trainer_class
  end

  def configure_pokemons(*args)
    @seed = rand(0xFFFFFF)
    send_data(Marshal.dump([$trainer.name, @actors, @seed]), nil)
    data = receive_data
    @enemy_party.actors = data[1]
    @trainer_names = [data[0]]
    @seed += data[2]
    pc "Online seed: #{@seed}"
    srand(@seed)
    send_data(nil) #>Pour éviter que le prochain paquet soit incorrect !
    #>Démarrage du MagnetoVS
    @magneto = PFM::MagnetoVS.new(@actors, @enemy_party.actors, @trainer_names)
    @magneto.push_seed(@seed)

    pc "Actors : #{$actors.join(" ")}\nEnemies : #{@enemy_party.actors.join(" ")}"
  end

  PackFmt = 'I'
  PackArr = [0]
  ACK = "ACKO"
  def receive_data(meth = Base_Wait_Method)
    pc "receiving..."
    time = Time.new
    until @_Client.readable?
      meth.call
    end
    size = @_Client.recv(4).unpack(PackFmt)[0]
    data = String.new
    while data.size < size
      cnt = 0
      until @_Client.readable?
        meth.call
        cnt += 1
        raise Exception, "Failed to receive the whole data" if cnt > 60
      end
      delta = size - data.size
      data << @_Client.recv(delta < 0xFFF0 ? delta : 0xFFF0)
    end
    @_Client.write(ACK)
    return Marshal.load(data)
  end

  #===
  #>Envoie du data ou vérification de la reception de data par receive_data du partenaire
  # data = string si envoie
  # data = nil si vérification uniquement
  # meth = nil => pas de vérification de la reception
  #===
  def send_data(data, meth = Base_Wait_Method)
    pc "sending..."
    if(data)
      PackArr[0] = data.size
      @_Client.write(PackArr.pack(PackFmt))
      @_Client.write(data)
    end
    return unless meth
    until @_Client.readable?
      meth.call
    end
    unless(@_Client.recv(4) == ACK)
      raise Exception, "Failed to send the data properly"
    end
  end

  #===
  #>Récupération des actions de l'enemy
  #===
  def get_enemy_actions
    data = receive_data
    enemies = data[0]
    actions = data[1]
    i = nil
    index = 0
    targets = nil
    actions.each do |i|
      if(i[0] == 0)
=begin
        index = enemies.index(i[3]).to_i
        @enemies[index].position = i[3].position
        i[3] = @enemies[index]
=end
        if(i[2])
          if(i[2].is_a?(Integer)) #> Cible par attaque forcée
            i[2] = -i[2]-1
          else
            reset_targets(i[2])
          end
        end
        index = enemies.index(i[3]).to_i
        @enemies[index].position = -i[3].position-1
        i[3] = @enemies[index]
      elsif(i[0] == 1)
        i[1][1] = -i[1][1]-1
      elsif(i[0] == 2)
        i[1] = -i[1]-1
      end
    end
    @seed += data[2]
    return actions
  end
  #===
  #> Réorganiser les cibles
  #===
  def reset_targets(targets)
=begin
    if self.class == Scene_Battle_Server
      actors, enemies = @enemies, @actors
    else
      actors, enemies = @enemies, @actors#@actors, @enemies
    end
=end
    actors, enemies = @enemies, @actors
    position = nil
    i = nil
    targets.each_index do |i|
      if((position=targets[i].position) < 0)
        targets[i] = enemies[-position-1]
      else
        targets[i] = actors[position]
      end
    end
  end
  #===
  #>Selection d'un Pokémon en fin de tour ou pour un switch (Actor)
  #===
  def phase4_actor_select_pkmn(i)
    data = super(i)
    send_data(Marshal.dump(data))
    @magneto.push_switch(data)
    return data
  end
  #===
  #>Récupération du choix de l'adversaire
  #===
  def phase4_enemie_select_pkmn(i)
    data = receive_data
    data[1] = -data[1]-1
    @magneto.push_switch(data)
    return data
  end
  # Gestion erreur phase 4
  def update_phase4
    super
  rescue Exception
    puts $!.message
    battle_end(1)
  end
  # Gestion erreur phase 1
  def start_phase1
    super
  rescue Exception
    puts $!.message
    battle_end(1)
  end
  # Gestion erreur phase 1
  def update_phase1
    super
  rescue Exception
    puts $!.message
    battle_end(1)
  end

  def phase4_distribute_exp(i)

  end

  def phase5_ramassage

  end

  def phase5_object_actions

  end

  
  #===
  #> Fonctions de stockage et récup du code
  #===
  def self.code
    return @OpenNatCode
  end

  def self.code=(v)
    @OpenNatCode = v
  end
end
