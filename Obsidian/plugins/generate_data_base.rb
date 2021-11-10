#encoding: utf-8

#> Prevent the game from launching
$GAME_LOOP = proc {}

def make_page_header(title)
  str = <<-EOF
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8"/>
	<meta name="description" content="Page de téléchargement de PSDK et ses composant."/>
	<meta name="keywords" content="PSDK, RGSS, Pokémon, SDK, Nuri Yuri, RPG Maker, Projet, Prisme, Origins"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>#{title} :: PSDK Database</title>
	<style>li.open { z-index: 100000;}</style>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"></script>
	<style>
html, .container-fluid {
	background-color: #3d6c96;
}
  </style>
</head>
<body>
	<div class="container-fluid">
		<br/>
		<img class="img-fluid mx-auto d-block" src="https://download.psdk.pokemonworkshop.com/dat/320.png"/>
		<h1 class="text-center psdk-text">#{title}</h1>
EOF
end

def make_page_footer
  str = <<-EOF
    <div class="text-center psdk-text">
			<strong>
				Page écrite par Nuri Yuri<br/>
				© 2017~2018 - Nuri Yuri, Merci de ne pas copier le contenu de cette page.
			</strong>
		</div>
	</div>
</body>
</html>
EOF
end

# Chargement des textes
langs = %w[en fr es] # ["fr","en","it","de","es"]
texts = []
langs.each do |lang| 
  texts << Marshal.load(Zlib::Inflate.inflate(load_data("Data/Text/#{lang}.dat")))
end

GameData::Pokemon.load
GameData::Item.load
GameData::Skill.load
GameData::Abilities.load

# Genération du fichier pour les Pokémon
if ARGV.include?('pokemon')
  page = make_page_header('Pokémon')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="#{texts.size}" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto(GameData::Pokemon.all.size - 1) do |i|
    names = []
    texts.each do |text_arr|
      names << text_arr[0][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center">#{i}</td>
          <td><b>#{GameData::Pokemon[i].db_symbol.inspect}</b></td>
          <td>#{names}</td>
        </tr>
EOF
  end
  page << <<-EOF
      </tbody>
    </table>
EOF
  page << make_page_footer
  File.open('db_pokemon.html', 'w') { |f| f << page }
end

# Genération du fichier pour les Objets
if ARGV.include?('item')
  page = make_page_header('Items')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="#{texts.size}" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto(GameData::Item.all.size - 1) do |i|
    next if GameData::Item[i].db_symbol == :__undef__
    names = []
    texts.each do |text_arr|
      names << text_arr[12][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center" rowspan="2">#{i}</td>
          <td><b>#{GameData::Item[i].db_symbol.inspect}</b></td>
          <td>#{names}</td>
        </tr>
        <tr>
          <td colspan="#{texts.size + 1}" class="#{GameData::Item[i].battle_usable ? 'bg-success' : (GameData::Item[i].holdable && !GameData::Item[i].map_usable ? 'bg-info' : '')}">#{texts[0][13][i]}</td>
        </tr>
EOF
  end
  page << <<-EOF
      </tbody>
    </table>
EOF
  page << make_page_footer
  File.open('db_item.html', 'w') { |f| f << page }
end

# Genération du fichier pour les Attaques
if ARGV.include?('skill')
  page = make_page_header('Moves')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col">be_method</th>
          <th scope="col" colspan="#{texts.size}" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto(GameData::Skill.all.size - 1) do |i|
    next if GameData::Skill[i].db_symbol == :__undef__
    names = []
    texts.each do |text_arr|
      names << text_arr[6][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center" rowspan="2">#{i}</td>
          <td><b>#{GameData::Skill[i].db_symbol.inspect}</b></td>
          <td><b>#{GameData::Skill[i].be_method}</b></td>
          <td>#{names}</td>
        </tr>
        <tr>
          <td colspan="#{texts.size + 2}">#{texts[0][7][i]}</td>
        </tr>
EOF
  end
  page << <<-EOF
      </tbody>
    </table>
EOF
  page << make_page_footer
  File.open('db_skill.html', 'w') { |f| f << page }
end

# Genération du fichier pour les Talents
if ARGV.include?('ability')
  page = make_page_header('Abilities')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="#{texts.size}" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  all_abilities = GameData::Abilities.instance_variable_get(:@psdk_id_to_gf_id)
  all_abilities.size.times do |i|
    next if GameData::Abilities.db_symbol(i) == :__undef__
    names = []
    id = all_abilities[i]
    texts.each do |text_arr|
      names << text_arr[4][id]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center" rowspan="2">#{i}</td>
          <td><b>#{GameData::Abilities.db_symbol(i).inspect}</b></td>
          <td>#{names}</td>
        </tr>
        <tr>
          <td colspan="#{texts.size + 1}">#{texts[0][5][id]}</td>
        </tr>
EOF
  end
  page << <<-EOF
      </tbody>
    </table>
EOF
  page << make_page_footer
  File.open('db_ability.html', 'w') { |f| f << page }
end