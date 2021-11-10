#encoding: utf-8
require "zlib"
print("Nom du fichier : ")
begin
fn = gets.chomp.gsub(".dat","")
f=open(fn+".dat","rb")
data = Marshal.load(Zlib::Inflate.inflate(Marshal.load(f)))
f.close
Dir.mkdir(fn) rescue 0
id_descr = ["0 - Nom des Pokémon", "1 - Espèces des Pokémon", "2 - Description des Pokémon",
"3 - Types","4 - Nom des talents","5 - Description des talents","6 - Nom des attaques",
"7 - Description des attaques", "8 - Nom des natures","9 - Régions","10 - Nom des lieux",
"11 - Magasin","12 - Nom des objets","13 - Description des objets",
"14 - Menu Principal","15 - Poches du sac","16 - Nom des boites","17 - Messages évent communs",
"18 - String combat","19 - String combat","20 - String combat (menu)","21 - Utilisation attaque",
"22 - Sac", "23 - Equipe", "24 - Apprentissage","25 - Chargement","26 - Sauvegarde","27 - Résumé Pokémon",
"28 - Résumé informations","29 - Classes des dresseurs", "30 - Capture d'un Pokémon", 
"31 - Evolution",  "32 - Autres chaine combat",  "33 - Gestion boîte",  "34 - CDD",  "35 - Centre Pokémon",
"36 - Pension Pokémon", "37 - Textes de CS", "38 - Plantation Baies", "39 - Textes IN MAP","40 - Nom des baies", 
"41 - Obtension de choses", "42 - Options", "43 - Message Nommage"]

data.each_index do |i|
  str=""
  d=data[i]
  d.each_index do |j|
    str<<sprintf("%d : %s\r\n",j,d[j])
  end
  f=open(fn+"/"+(id_descr[i] || "#{i} unk")+".txt","wb")
  f.write(str)
  f.close
end
rescue Exception
  p $!,$!.message, $!.backtrace
  system("pause")
end
  