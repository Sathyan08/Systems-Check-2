require 'csv'

game_data = [
  {
    home_team: "Patriots",
    away_team: "Broncos",
    home_score: 7,
    away_score: 3
  },
  {
    home_team: "Broncos",
    away_team: "Colts",
    home_score: 3,
    away_score: 0
  },
  {
    home_team: "Patriots",
    away_team: "Colts",
    home_score: 11,
    away_score: 7
  },
  {
    home_team: "Steelers",
    away_team: "Patriots",
    home_score: 7,
    away_score: 21
  }
]

game_data.each do |game|
  File.open('game_data.csv','a') do |f|
    f.puts "#{game[:home_team]},#{game[:away_team]},#{game[:home_score]},#{game[:away_score]}"
  end
end
