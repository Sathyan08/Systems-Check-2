require 'sinatra'

require 'sinatra/reloader'

require 'csv'


def pull_game_data(filename)

  game_data = []

  CSV.foreach(filename, {headers:true, :header_converters => :symbol, :converters => :all}) do |row|
    game_data<< row
  end

  game_data
end

def extract_team_names(game_data)

  team_names = []

  game_data.each do |game|
    team_names << game[:home_team]
    team_names << game[:away_team]
  end

  team_names.uniq
end



def pull_team_data(filename,team_name)

  team_data = []

  CSV.foreach(filename, {headers:true, header_converters: :symbol, converters: :all}.merge) do |row|
    if row["home_team"] == team_name || row["away_team"] == team_name
      team_data<< row
    end
  end

  team_data
end

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


##############################
##############################
##############################

get '/' do
  @game_data = pull_game_data("game_data.csv")

  @team_names = extract_team_names(@game_data)

  erb :index
end

get '/leaderboard' do
  @game_data = pull_game_data("game_data.csv")
  @team_names = extract_team_names(@game_data)
  @leaderboard = create_leader_board(@game_data,@team_names)

  erb :leaderboard
end

get '/team/:team' do
  @team = params[:team]
  @team_data = pull_team_data("game_data.csv", @team)

  erb :team
end

