def create_leader_board(game_data,team_names)

  leaderboard = []  ### this will be an array of hashes

  wins = {}
  loses = {}

  team_names.each do |team_name|
    wins[team_name] = 0
    loses[team_name] = 0
  end

  game_data.each do |game|

    # puts "game is #{game}"

    if game[:home_score] > game[:away_score]
      wins[game[:home_team]] += 1
      loses[game[:away_team]] += 1
    else
      wins[game[:away_team]] += 1
      loses[game[:home_team]] += 1
    end
  end
    wins_sorted = wins.sort_by {|team_name, wins| wins}
    wins_sorted.reverse!

  wins_sorted.each do |team_name, wins_number|
    leaderboard_position = {}
    leaderboard_position[:name] = team_name
    leaderboard_position[:wins] = wins_number
    leaderboard_position[:loses] = loses[team_name]
    leaderboard << leaderboard_position
  end

  leaderboard_copy = leaderboard

  wins_groups = []

  leaderboard_copy.each do |copy_position|
    wins_group = []
    wins_group << copy_position[:wins]
    wins_groups << wins_group
  end

  wins_groups.uniq!

  wins_groups.each do |wins_group|
    leaderboard.each do |leaderboard_position|
      if leaderboard_position[:wins] == wins_group[0]
        wins_group << leaderboard_position
      end
    end
  end

final_leaderboard = []

  wins_groups.each do |wins_group|
    wins_group.shift
    wins_group.sort_by! {|leaderboard_position| leaderboard_position[:loses]}
    until wins_group.length == 0
      final_leaderboard << wins_group.shift
    end
  end

final_leaderboard

end


game_data =[
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

team_names = ["Patriots","Broncos","Colts","Steelers"]

create_leader_board(game_data,team_names)
