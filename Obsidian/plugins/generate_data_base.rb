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
langs = ["fr","en","it","de","es"]
texts = []
langs.each do |lang| 
  texts << Marshal.load(Zlib::Inflate.inflate(load_data("Data/Text/#{lang}.dat")))
end



# Genération du fichier pour les Pokémon
if ARGV.include?('pokemon')
  page = make_page_header('Pokémon')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="5" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto($game_data_pokemon.size - 1) do |i|
    names = []
    texts.each do |text_arr|
      names << text_arr[0][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center">#{i}</td>
          <td><b>#{GameData::Pokemon.db_symbol(i).inspect}</b></td>
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
  page = make_page_header('Objets')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="5" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto($game_data_item.size - 1) do |i|
    next if GameData::Item.db_symbol(i) == :__undef__
    names = []
    texts.each do |text_arr|
      names << text_arr[12][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center">#{i}</td>
          <td><b>#{GameData::Item.db_symbol(i).inspect}</b></td>
          <td>#{names}</td>
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
  page = make_page_header('Attaques')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="5" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  1.upto($game_data_skill.size - 1) do |i|
    next if GameData::Skill.db_symbol(i) == :__undef__
    names = []
    texts.each do |text_arr|
      names << text_arr[6][i]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center">#{i}</td>
          <td><b>#{GameData::Skill.db_symbol(i).inspect}</b></td>
          <td>#{names}</td>
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
  page = make_page_header('Talents')
  
  page << <<-EOF
    <table class="table table-striped table-hover table-sm table-dark">
      <thead>
        <tr>
          <th scope="col" class="text-center">#</th>
          <th scope="col">db_symbol</th>
          <th scope="col" colspan="5" class="text-center">Noms</th>
        </tr>
      </thead>
      <tbody>
EOF
  $game_data_abilities.size.times do |i|
    next if GameData::Abilities.db_symbol(i) == :__undef__
    names = []
    id = $game_data_abilities[i]
    texts.each do |text_arr|
      names << text_arr[4][id]
    end
    names = names.join('</td>
          <td>')
    page << <<-EOF
        <tr>
          <td class="text-center">#{i}</td>
          <td><b>#{GameData::Abilities.db_symbol(i).inspect}</b></td>
          <td>#{names}</td>
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